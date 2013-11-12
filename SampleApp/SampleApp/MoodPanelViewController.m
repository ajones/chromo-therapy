//
//  MoodPanelViewController.m
//  SampleApp
//
//  Created by Aaron Jones on 11/11/13.
//  Copyright (c) 2013 Philips. All rights reserved.
//

#import "MoodPanelViewController.h"
#import "Moods.h"

#import <HueSDK/HueSDK.h>

@interface MoodPanelViewController ()

@property (strong, nonatomic) NSArray *lights;

@end

@implementation MoodPanelViewController

@synthesize lights;
@synthesize moodListScrollView;


static int MOOD_TILES_PER_ROW = 3;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setUpscrollView];
    [self placeMoodTiles];
    [self updateLights];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setUpscrollView {
    float tileWidth = [self getTileWidth];
    float contentHeight = ([Moods getNumberOfAvailableMoods] / MOOD_TILES_PER_ROW) * tileWidth;
    moodListScrollView.contentSize = CGSizeMake(moodListScrollView.frame.size.width, contentHeight);
    
    [self placeMoodTiles];
}

- (void) placeMoodTiles {
    float tileWidth = [self getTileWidth];
    CGRect tileRect = CGRectMake(0,0,tileWidth,tileWidth);
    
    UIImageView * background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CheckIn-squares-whole"]];
    background.frame = CGRectMake(0, 0, background.frame.size.width, background.frame.size.height);
    [moodListScrollView addSubview:background];
    
    
    
    for (int i = 0; i < [Moods getNumberOfAvailableMoods]; i ++) {
        int columnPosition = i % MOOD_TILES_PER_ROW;
        int rowPosition = (i - columnPosition)/MOOD_TILES_PER_ROW;
        
        tileRect.origin.x = columnPosition * tileWidth;
        tileRect.origin.y = rowPosition * tileWidth;
        
        //NSLog(@"building tile at pos [%d, %d]",columnPosition,rowPosition);
        
        // build button
        UIButton * moodTile = [UIButton buttonWithType:UIButtonTypeCustom];
        //NSString * imageName = [Moods getMoodSquareImageNameForMood:[Moods getMoodForIndex:i]];
        //UIImage * buttonImage = [UIImage imageNamed:imageName];
        moodTile.backgroundColor = [UIColor clearColor];
        //[moodTile setImage:buttonImage forState:UIControlStateNormal];
        moodTile.frame = tileRect;
        moodTile.tag = i;
        [moodTile addTarget:self action:@selector(moodTileSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        // add label
        CGRect labelFrame = moodTile.frame;
        labelFrame.origin.x = 0;
        labelFrame.origin.y = 0;
        
        UILabel * buttonLabel = [[UILabel alloc] initWithFrame:labelFrame];
        buttonLabel.text = [Moods getMoodForIndex:i];
        buttonLabel.textColor = [UIColor whiteColor];
        buttonLabel.backgroundColor = [UIColor clearColor];
        buttonLabel.textAlignment = UITextAlignmentCenter;
        buttonLabel.adjustsFontSizeToFitWidth = true;
        buttonLabel.minimumScaleFactor = 0.5;
        buttonLabel.font = [UIFont fontWithName:@"Helvetica" size:20];
        [moodTile addSubview:buttonLabel];
        
        [moodListScrollView addSubview:moodTile];
    }
}

- (float) getTileWidth {
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    return screenBounds.size.width / MOOD_TILES_PER_ROW ;
}




//------------------------------
//     Tap Handler
//------------------------------

- (void) moodTileSelected:(id)sender {
    UIButton * tappedButton = (UIButton*)sender;
    NSString * mood = [Moods getMoodForIndex:tappedButton.tag];
    NSLog(@"SELECTED MOOD :%@", mood);
    
    // TODO
    // HOOK INTO LIGHTS
    UIColor * col = [Moods getTextColorForMood:mood];
    [self setAllConnectedLightsToColor:col];
}

//------------------------------
//     HUE
//------------------------------

- (void)updateLights {
    /***************************************************
     The notification of changes to the lights information
     in the Bridge resources cache called this method.
     Now we access Bridge resources cache to get updated
     information and reload the displayed lights table.
     *****************************************************/
    
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    
    self.lights = [cache.lights.allValues sortedArrayUsingComparator:^NSComparisonResult(PHLight *light1, PHLight *light2) {
        return [light1.identifier compare:light2.identifier options:NSNumericSearch];
    }];
}

- (void)setAllConnectedLightsToColor:(UIColor*)color {
    // Create a lightstate based on selected options
    PHLightState *lightState = [self createLightStateWithUIColor:color];
    
    /***************************************************
     The BridgeSendAPI is used to send commands to the bridge.
     Here we are updating the settings chosen by the user
     for the selected light.
     These settings are sent as a PHLightState to update
     the light with the given light identifiers.
     *****************************************************/
    
    // Create a bridge send api, used for sending commands to bridge locally
    id<PHBridgeSendAPI> bridgeSendAPI = [[[PHOverallFactory alloc] init] bridgeSendAPI];
    
    // Send lightstate to light
    for (PHLight* light in self.lights) {
        
        [bridgeSendAPI updateLightStateForId:light.identifier withLighState:lightState completionHandler:^(NSArray *errors) {
            if (errors != nil) {
                NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
                NSLog(@"%@",message);
                /*
                UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Response", @"")
                                                                     message:message
                                                                    delegate:nil
                                                           cancelButtonTitle:nil
                                                           otherButtonTitles:NSLocalizedString(@"Ok", @""), nil];
                [errorAlert show];
                 */
            }
        }];
    }
    
}


/**
 Creates a lightstate based on selected options in the user interface
 @return the lightstate
 */
- (PHLightState *)createLightStateWithUIColor:(UIColor *)color {
    /***************************************************
     The PHLightState class is used as a parameter for the
     Hue SDK. It contains the attribute settings for an individual
     light. This method creates it from the current
     user interface settings for the light
     *****************************************************/
    
    // Create an empty lightstate
    PHLightState *lightState = [[PHLightState alloc] init];
    [lightState setOnBool:true];
    
    CGFloat hue;
    CGFloat saturation;
    CGFloat brightness;
    CGFloat alpha;
    
    if ([color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha])
    {
        [lightState setHue:[self convertValueForJSON:hue withBase:65535]];
        [lightState setSaturation:[self convertValueForJSON:saturation withBase:254]];
        [lightState setBrightness:[self convertValueForJSON:brightness withBase:254]];
    }
    
    
    /*
    // Check if on value should be send
    if (self.sendOn.on) {
        [lightState setOnBool:self.valueOn.on];
    }
    
    // Check if hue value should be send
    if (self.sendHue.on) {
        [lightState setHue:[NSNumber numberWithInt:((int)self.valueHueSlider.value)]];
    }
    
    // Check if saturation value should be send
    if (self.sendSat.on) {
        [lightState setSaturation:[NSNumber numberWithInt:((int)self.valueSatSlider.value)]];
    }
    
    // Check if brightness value should be send
    if (self.sendBri.on) {
        [lightState setBrightness:[NSNumber numberWithInt:((int)self.valueBriSlider.value)]];
    }
    
    // Check if xy values should be send
    if (self.sendXY.on) {
        [lightState setX:[NSNumber numberWithFloat:self.valueXSlider.value]];
        [lightState setY:[NSNumber numberWithFloat:self.valueYSlider.value]];
    }
    
    // Check if effect value should be send
    if (self.sendEffect.on) {
        if (self.valueEffect.selectedSegmentIndex == 0) {
            lightState.effect = EFFECT_NONE;
        }
        else if (self.valueEffect.selectedSegmentIndex == 1) {
            lightState.effect = EFFECT_COLORLOOP;
        }
    }
    
    // Check if alert value should be send
    if (self.sendAlert.on) {
        if (self.valueAlert.selectedSegmentIndex == 0) {
            lightState.alert = ALERT_NONE;
        }
        else if (self.valueAlert.selectedSegmentIndex == 1) {
            lightState.alert = ALERT_SELECT;
        }
        else if (self.valueAlert.selectedSegmentIndex == 2) {
            lightState.alert = ALERT_LSELECT;
        }
    }
    
    // Check if transition time should be send
    if (self.sendTransitionTime.on) {
        [lightState setTransitionTime:[NSNumber numberWithInt:((int)self.valueTransitionTimeSlider.value)]];
    }
    */
    
    return lightState;
}

- (NSNumber *) convertValueForJSON:(CGFloat) val withBase:(int)base {
    return [NSNumber numberWithInt:(int)(val * base)];
}

@end
