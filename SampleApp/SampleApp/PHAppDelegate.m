/*******************************************************************************
 Copyright (c) 2013 Koninklijke Philips N.V.
 All Rights Reserved.
 ********************************************************************************/

#import "PHAppDelegate.h"

#import "PHMainViewController.h"
#import "PHLoadingViewController.h"

#import "MoodPanelViewController.h"

#import <HueSDK/HueSDK.h>

@interface PHAppDelegate ()

@property (nonatomic, strong) PHLoadingViewController *loadingView;

@property (nonatomic, strong) UIAlertView *noConnectionAlert;
@property (nonatomic, strong) UIAlertView *noBridgeFoundAlert;
@property (nonatomic, strong) UIAlertView *authenticationFailedAlert;

@property (nonatomic, strong) PHBridgePushLinkViewController *pushLinkViewController;
@property (nonatomic, strong) PHBridgeSelectionViewController *bridgeSelectionViewController;

@property (nonatomic, strong) PHSoftwareUpdateManager *updateManager;

@end

@implementation PHAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    /***************************************************
     The Hue SDK is created as a property in the App delegate .h file
     (@property (nonatomic, strong) PHHueSDK *phHueSDK;)
     
     and the SDK instance can then be created:
     // Create sdk instance
     self.phHueSDK = [[PHHueSDK alloc] init];
     
     next, the startUpSDK call will initialize the SDK and kick off its regular heartbeat timer:
     [self.phHueSDK startUpSDK];
     *****************************************************/
    
    // Create sdk instance
    self.phHueSDK = [[PHHueSDK alloc] init];
    [self.phHueSDK startUpSDK];
    
    // Create the main view controller in a navigation controller and make the navigation controller the rootviewcontroller of the app
    //PHMainViewController *mainViewController = [[PHMainViewController alloc] initWithStyle:UITableViewCellStyleSubtitle];
    //self.navigationController = [[UINavigationController alloc] initWithRootViewController:mainViewController];
    
    MoodPanelViewController *mainViewController = [[MoodPanelViewController alloc] initWithNibName:@"MoodPanelView" bundle:nil];
    //self.navigationController = [[UINavigationController alloc] initWithRootViewController:mainViewController];
    
    
    self.window.rootViewController = mainViewController;
    [self.window makeKeyAndVisible];
    
    PHNotificationManager *notificationManager = [PHNotificationManager defaultManager];
    
    /***************************************************
     The SDK will send the following notifications in response to events:
     
     - LOCAL_CONNECTION_NOTIFICATION 
       This notification will notify that the bridge heartbeat occurred and the bridge resources cache data has been updated
     
     - NO_LOCAL_CONNECTION_NOTIFICATION
       This notification will notify that there is no connection with the bridge
     
     - NO_LOCAL_AUTHENTICATION_NOTIFICATION
       This notification will notify that there is no authentication against the bridge
     *****************************************************/
    
    [notificationManager registerObject:self withSelector:@selector(localConnection) forNotification:LOCAL_CONNECTION_NOTIFICATION];
    [notificationManager registerObject:self withSelector:@selector(noLocalConnection) forNotification:NO_LOCAL_CONNECTION_NOTIFICATION];
    [notificationManager registerObject:self withSelector:@selector(notAuthenticated) forNotification:NO_LOCAL_AUTHENTICATION_NOTIFICATION];
    
    /***************************************************
     The local heartbeat is a regular timer event in the SDK. Once enabled the SDK regular collects the current state of resources managed
     by the bridge into the Bridge Resources Cache
     *****************************************************/
    
    [self enableLocalHeartbeat];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Stop heartbeat
    [self disableLocalHeartbeat];
    
    // Remove any open popups
    if (self.noConnectionAlert != nil) {
        [self.noConnectionAlert dismissWithClickedButtonIndex:[self.noConnectionAlert cancelButtonIndex] animated:NO];
        self.noConnectionAlert = nil;
    }
    if (self.noBridgeFoundAlert != nil) {
        [self.noBridgeFoundAlert dismissWithClickedButtonIndex:[self.noBridgeFoundAlert cancelButtonIndex] animated:NO];
        self.noBridgeFoundAlert = nil;
    }
    if (self.authenticationFailedAlert != nil) {
        [self.authenticationFailedAlert dismissWithClickedButtonIndex:[self.authenticationFailedAlert cancelButtonIndex] animated:NO];
        self.authenticationFailedAlert = nil;
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Start heartbeat
    [self enableLocalHeartbeat];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

#pragma mark - Loading view

/**
 Shows an overlay over the whole screen with a black box with spinner and loading text in the middle
 @param text The text to display under the spinner
 */
- (void)showLoadingViewWithText:(NSString *)text {
    // First remove
    [self removeLoadingView];
    
    // Then add new
    self.loadingView = [[PHLoadingViewController alloc] initWithNibName:@"PHLoadingViewController" bundle:[NSBundle mainBundle]];
    self.loadingView.view.frame = self.navigationController.view.bounds;
    [self.navigationController.view addSubview:self.loadingView.view];
    self.loadingView.loadingLabel.text = text;
}

/**
 Removes the full screen loading overlay.
 */
- (void)removeLoadingView {
    if (self.loadingView != nil) {
        [self.loadingView.view removeFromSuperview];
        self.loadingView = nil;
    }
}

#pragma mark - HueSDK

/**
 Notification receiver for successful local connection
 */
- (void)localConnection {
    // Check current connection state
    [self checkConnectionState];
    
    // Check if an update is available
    [self performSelector:@selector(updateCheck) withObject:nil afterDelay:1];
}

/**
 Checks for software update status
 */
- (void)updateCheck {
    if (self.updateManager == nil) {
        // Create update manager
        self.updateManager = [[PHSoftwareUpdateManager alloc] initWithDelegate:self];
    }
    // Check status
    [self.updateManager checkUpdateStatus];
}

/**
 Notification receiver for failed local connection
 */
- (void)noLocalConnection {
    // Check current connection state
    [self checkConnectionState];
}

/**
 Notification receiver for failed local authentication
 */
- (void)notAuthenticated {
    /***************************************************
     We are not authenticated so we start the authentication process
     *****************************************************/

    // Move to main screen (as you can't control lights when not connected)
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    // Dismiss modal views when connection is lost
    if (self.navigationController.presentedViewController) {
        [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
    }
    
    // Remove no connection alert
    if (self.noConnectionAlert != nil) {
        [self.noConnectionAlert dismissWithClickedButtonIndex:[self.noConnectionAlert cancelButtonIndex] animated:YES];
        self.noConnectionAlert = nil;
    }
    
    /***************************************************
     doAuthentication will start the push linking
     *****************************************************/
    
    // Start local authenticion process
    [self performSelector:@selector(doAuthentication) withObject:nil afterDelay:0.5];
}

/**
 Checks if we are currently connected to the bridge locally and if not, it will show an error when the error is not already shown.
 */
- (void)checkConnectionState {
    if (!self.phHueSDK.localConnected) {
        // Dismiss modal views when connection is lost
        if (self.navigationController.presentedViewController) {
            [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
        }
        
        // No connection at all, show connection popup
        if (self.noConnectionAlert == nil) {
            [self.navigationController popToRootViewControllerAnimated:YES];
            
            // Showing popup, so remove this view
            [self removeLoadingView];
            [self showNoConnectionDialog];
        }
    }
    else {
        // One of the connections is made, remove popups and loading views
        if (self.noConnectionAlert != nil) {
            [self.noConnectionAlert dismissWithClickedButtonIndex:[self.noConnectionAlert cancelButtonIndex] animated:YES];
            self.noConnectionAlert = nil;
        }
        
        [self removeLoadingView];
    }
}

/**
 Shows the first no connection alert with more connection options
 */
- (void)showNoConnectionDialog {
    self.noConnectionAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection lost", @"No connection alert title")
                                                        message:NSLocalizedString(@"Connection to bridge is lost", @"No connection alert message")
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"Reconnect", @"No connection alert reconnect button"), NSLocalizedString(@"More", @"No connection alert more button"), nil];
    self.noConnectionAlert.tag = 1;
    [self.noConnectionAlert show];
}

/**
 Shows the second no connection alert with more connection options
 */
- (void)showNoConnectionMoreOptionsDialog {
    self.noConnectionAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"More options", @"Second No connection alert title")
                                                        message:NSLocalizedString(@"Choose your connection option", @"Second No connection alert message")
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"Find new bridge", @"No connection find new bridge button"), nil];
    self.noConnectionAlert.tag = 2;
    [self.noConnectionAlert show];
}

#pragma mark - Heartbeat control

/**
 Starts the local heartbeat with a 10 second interval
 */
- (void)enableLocalHeartbeat {
    /***************************************************
     The heartbeat processing collects data from the bridge
     so now try to see if we have a bridge already connected
     *****************************************************/

    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    if (cache != nil && cache.bridgeConfiguration != nil && cache.bridgeConfiguration.ipaddress != nil) {
        // Some bridge is known
        [self.phHueSDK enableLocalConnectionUsingInterval:10];
    }
    else {
        /***************************************************
         No bridge connected so start the bridge search process
         *****************************************************/
        
        // No bridge known
        [self searchForBridgeLocal];
    }
}

/**
 Stops the local heartbeat
 */
- (void)disableLocalHeartbeat {
    [self.phHueSDK disableLocalConnection];
}

#pragma mark - Bridge searching and selection

/**
 Search for bridges using UPnP and portal discovery, shows results to user or gives error when none found.
 */
- (void)searchForBridgeLocal {
    // Stop heartbeats
    [self disableLocalHeartbeat];
    
    // Show search screen
    [self showLoadingViewWithText:NSLocalizedString(@"Searching...", @"Searching for bridges text")];
    /***************************************************
     A bridge search is started using UPnP to find local bridges
     *****************************************************/
    
    // Start search
    PHBridgeSearching *bridgeSearch = [[PHBridgeSearching alloc] initWithUpnpSearch:YES andPortalSearch:YES];
    [bridgeSearch startSearchWithCompletionHandler:^(NSDictionary *bridgesFound) {
        // Done with search, remove loading view
        [self removeLoadingView];
        
        /***************************************************
        The search is complete, check whether we found a bridge
         *****************************************************/
       
        // Check for results
        if (bridgesFound.count > 0) {
            // Results were found, show options to user (from a user point of view, you should select automatically when there is only one bridge found)
            self.bridgeSelectionViewController = [[PHBridgeSelectionViewController alloc] initWithNibName:@"PHBridgeSelectionViewController" bundle:[NSBundle mainBundle] bridges:bridgesFound delegate:self];
            
            /***************************************************
             Use the list of bridges, present them to the user, so one can be selected.
             *****************************************************/

            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.bridgeSelectionViewController];
            navController.modalPresentationStyle = UIModalPresentationFormSheet;
            [self.navigationController presentViewController:navController animated:YES completion:nil];
        }
        else {
            /***************************************************
             No bridge was found was found. Tell the user and offer to retry..
             *****************************************************/

            // No bridges were found, show this to the user
            self.noBridgeFoundAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No bridges", @"No bridge found alert title")
                                                                 message:NSLocalizedString(@"Could not find bridge", @"No bridge found alert message")
                                                                delegate:self
                                                       cancelButtonTitle:nil
                                                       otherButtonTitles:NSLocalizedString(@"Retry", @"No bridge found alert retry button"), nil];
            self.noBridgeFoundAlert.tag = 1;
            [self.noBridgeFoundAlert show];
        }
    }];
}

/**
 Delegate method for PHbridgeSelectionViewController which is invoked when a bridge is selected
 */
- (void)bridgeSelectedWithIpAddress:(NSString *)ipAddress andMacAddress:(NSString *)macAddress {
    /***************************************************
    Removing the selection view controller takes us to 
     the 'normal' UI view
     *****************************************************/

    // Remove the selection view controller
    self.bridgeSelectionViewController = nil;
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    // Show a connecting view while we try to connect to the bridge
    [self showLoadingViewWithText:NSLocalizedString(@"Connecting...", @"Connecting text")];
    
    // Set SDK to use bridge and our default username (which should be the same across all apps, so pushlinking is only required once)
    NSString *username = [PHUtilities whitelistIdentifier];
    
    /***************************************************
     Set the username, ipaddress and mac address,
     as the bridge properties that the SDK framework will use
     *****************************************************/
    
    [UIAppDelegate.phHueSDK setBridgeToUseWithIpAddress:ipAddress macAddress:macAddress andUsername:username];
    
    /***************************************************
     Setting the hearbeat running will cause the SDK
     to regularly update the cache with the status of the 
     bridge resources
     *****************************************************/

    // Start local heartbeat again
    [self performSelector:@selector(enableLocalHeartbeat) withObject:nil afterDelay:1];
}

#pragma mark - Bridge authentication

/**
 Start the local authentication process
 */
- (void)doAuthentication {
    // Disable heartbeats
    [self disableLocalHeartbeat];
    
    /***************************************************
     To be certain that we own this bridge we must manually 
     push link it. Here we display the view to do this.
     *****************************************************/
    
    // Create an interface for the pushlinking
    self.pushLinkViewController = [[PHBridgePushLinkViewController alloc] initWithNibName:@"PHBridgePushLinkViewController" bundle:[NSBundle mainBundle] hueSDK:UIAppDelegate.phHueSDK delegate:self];
    
    [self.navigationController presentViewController:self.pushLinkViewController animated:YES completion:^{
        /***************************************************
         Start the push linking process.
         *****************************************************/
        
        // Start pushlinking when the interface is shown
        [self.pushLinkViewController startPushLinking];
    }];
}

/**
 Delegate method for PHBridgePushLinkViewController which is invoked if the pushlinking was successfull
 */
- (void)pushlinkSuccess {
    /***************************************************
     Push linking succeeded we are authenticated against 
     the chosen bridge.
     *****************************************************/
    
    // Remove pushlink view controller
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    self.pushLinkViewController = nil;
    
    // Start local heartbeat
    [self performSelector:@selector(enableLocalHeartbeat) withObject:nil afterDelay:1];
}

/**
 Delegate method for PHBridgePushLinkViewController which is invoked if the pushlinking was not successfull
 */
- (void)pushlinkFailed:(PHError *)error {
    // Remove pushlink view controller
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    self.pushLinkViewController = nil;
    
    // Check which error occured
    if (error.code == PUSHLINK_NO_CONNECTION) {
        // No local connection to bridge
        [self noLocalConnection];
        
        // Start local heartbeat (to see when connection comes back)
        [self performSelector:@selector(enableLocalHeartbeat) withObject:nil afterDelay:1];
    }
    else {
        // Bridge button not pressed in time
        self.authenticationFailedAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Authentication failed", @"Authentication failed alert title")
                                                                    message:NSLocalizedString(@"Make sure you press the button within 30 seconds", @"Authentication failed alert message")
                                                                   delegate:self
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:NSLocalizedString(@"Retry", @"Authentication failed alert retry button"), NSLocalizedString(@"More", @"Authentication failed alert more button"), nil];
        [self.authenticationFailedAlert show];
    }
}

#pragma mark - Alertview delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == self.noConnectionAlert && alertView.tag == 1) {
        // This is a no connection alert with option to reconnect or more options
        self.noConnectionAlert = nil;
        
        if (buttonIndex == 0) {
            // Retry, just wait for the heartbeat to finish
            [self showLoadingViewWithText:NSLocalizedString(@"Connecting...", @"Connecting text")];
        }
        else if (buttonIndex == 1) {
            // More options
            [self showNoConnectionMoreOptionsDialog];
        }
    }
    else if (alertView == self.noConnectionAlert && alertView.tag == 2) {
        // This is a no connection alert with the find new bridge and setup away from home options
        self.noConnectionAlert = nil;
        
        if (buttonIndex == 0) {
            // Find new bridge
            [self searchForBridgeLocal];
        }
    }
    else if (alertView == self.noBridgeFoundAlert && alertView.tag == 1) {
        // This is the alert which is shown when no bridges are found locally
        self.noBridgeFoundAlert = nil;
        
        if (buttonIndex == 0) {
            // Retry
            [self searchForBridgeLocal];
        }
    }
    else if (alertView == self.authenticationFailedAlert) {
        // This is the alert which is shown when local pushlinking authentication has failed
        self.authenticationFailedAlert = nil;
        
        if (buttonIndex == 0) {
            // Retry
            [self doAuthentication];
        }
        else if (buttonIndex == 1) {
            // Find new
            [self showNoConnectionMoreOptionsDialog];
        }
    }
}

#pragma mark - Software update delegate

- (BOOL)shouldShowMessageForNoSoftwareUpdate {
    // We should not show messages when there is no update
    return NO;
}

- (BOOL)shouldShowMessageForDownloadingSoftwareUpdate {
    // We should not show messages when we are still downloading updates
    return NO;
}

- (BOOL)shouldIgnorePostponeDate {
    // Postpone date should be honored
    return NO;
}

- (void)softwareUpdateStarted {
    // Remove any views which might obstuct the updating view
    if (self.navigationController.presentedViewController) {
        [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
    }
    
    // Show loading view while updating
    [self showLoadingViewWithText:NSLocalizedString(@"Updating...", @"Updating text")];
}

- (void)softwareUpdateFinishedSuccessfull:(BOOL)success {
    // Remove loading view
    [self removeLoadingView];
}

@end
