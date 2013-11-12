//
//  Moods.h
//  moodist
//
//  Created by Aaron Jones on 1/29/13.
//  Copyright (c) 2013 shak/ti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Moods : NSObject


+ (NSString*)getMoodForIndex:(int)index;
+ (int)getNumberOfAvailableMoods;
+ (UIColor*) getTextColorForMood:(NSString*)mood;
+ (NSString*) getPinImageNameForMood:(NSString*)mood;
+ (NSString*) getCollectivePinImageNameForMood:(NSString*)mood;
+ (NSString*) getFormattedMoodString:(NSString*)mood;
+ (NSString*) getTableRowImageForMood:(NSString*)mood;
+ (NSString*) getBackgraoundImageForMood:(NSString*)mood;
+ (NSString*) getMoodSquareImageNameForMood:(NSString*)mood;
+ (NSString*) getMoodSquareImageNameForMood:(NSString*)mood shouldFlattenTop:(bool)shouldFlatten;
+ (NSString*) getMoodReviewBarImageForMood:(NSString*)mood;
@end
