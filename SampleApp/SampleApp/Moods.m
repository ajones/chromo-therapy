//
//  Moods.m
//  moodist
//
//  Created by Aaron Jones on 1/29/13.
//  Copyright (c) 2013 shak/ti. All rights reserved.
//

#import "Moods.h"

@implementation Moods

static NSArray *moodsArray = nil;

+ (void) checkInit {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        moodsArray = [[NSArray alloc] initWithObjects:
                      @"happy",
                      @"hopeful",
                      @"excited",
                      @"hungry",
                      @"sexy",
                      @"angry",
                      @"guilty",
                      @"buzzed",
                      @"jealous",
                      @"whimsical",
                      @"grateful",
                      @"creative",
                      @"romantic",
                      @"intellectual",
                      @"inspired",
                      @"silly",
                      @"anxious",
                      @"active",
                      @"frustrated",
                      @"disappointed",
                      @"confident",
                      @"nostalgic",
                      @"sad",
                      @"social",
                      @"adventurous",
                      @"centered",
                      @"spiritual",
                      @"lonely",
                      @"ungrounded",
                      @"tired",
                      @"sick",
                      @"scared",
                      @"stressed",
                      nil];

    });
}



+ (UIColor*) getTextColorForMood:(NSString*)mood {
    if ([mood caseInsensitiveCompare:@"happy"] == NSOrderedSame) {
        return [UIColor colorWithRed:246.0/255.0 green:237/255.0 blue:0.0/255.0 alpha:1];
    } else if ([mood caseInsensitiveCompare:@"hopeful"] == NSOrderedSame) {
        return [UIColor colorWithRed:212.0/255.0 green:160.0/255.0 blue:0.0/255.0 alpha:1];
    } else if ([mood caseInsensitiveCompare:@"excited"] == NSOrderedSame) {
        return [UIColor colorWithRed:201.0/255.0 green:131.0/255.0 blue:16.0/255.0 alpha:1];
    } else if ([mood caseInsensitiveCompare:@"sexy"] == NSOrderedSame) {
        return [UIColor colorWithRed:190.0/255.0 green:18.0/255.0 blue:31.0/255.0 alpha:1];
    } else if ([mood caseInsensitiveCompare:@"angry"] == NSOrderedSame) {
        return [UIColor colorWithRed:78.0/255.0 green:16.0/255.0 blue:20.0/255.0 alpha:1];
    } else if ([mood caseInsensitiveCompare:@"buzzed"] == NSOrderedSame) {
        return [UIColor colorWithRed:177.0/255.0 green:60.0/255.0 blue:35.0/255.0 alpha:1];
    } else if ([mood caseInsensitiveCompare:@"whimsical"] == NSOrderedSame) {
        return [UIColor colorWithRed:58.0/255.0 green:11.0/255.0 blue:59.0/255.0 alpha:1];
    } else if ([mood caseInsensitiveCompare:@"grateful"] == NSOrderedSame) {
        return [UIColor colorWithRed:112.0/255.0 green:96.0/255.0 blue:147.0/255.0 alpha:1];
    } else if ([mood caseInsensitiveCompare:@"artsy"] == NSOrderedSame) {
        return [UIColor colorWithRed:106.0/255.0 green:22.0/255.0 blue:79.0/255.0 alpha:1];
    } else if ([mood caseInsensitiveCompare:@"romantic"] == NSOrderedSame) {
        return [UIColor colorWithRed:183.0/255.0 green:44.0/255.0 blue:95.0/255.0 alpha:1];
    } else if ([mood caseInsensitiveCompare:@"intellectual"] == NSOrderedSame) {
        return [UIColor colorWithRed:47.0/255.0 green:27.0/255.0 blue:57.0/255.0 alpha:1];
    } else if ([mood caseInsensitiveCompare:@"naughty"] == NSOrderedSame) {
        return [UIColor colorWithRed:119.0/255.0 green:4.0/255.0 blue:74.0/255.0 alpha:1];
    } else if ([mood caseInsensitiveCompare:@"silly"] == NSOrderedSame) {
        return [UIColor colorWithRed:198.0/255.0 green:214.0/255.0 blue:50.0/255.0 alpha:1];
    } else if ([mood caseInsensitiveCompare:@"active"] == NSOrderedSame) {
        return [UIColor colorWithRed:144.0/255.0 green:192.0/255.0 blue:93.0/255.0 alpha:1];
    } else if ([mood caseInsensitiveCompare:@"curious"] == NSOrderedSame) {
        return [UIColor colorWithRed:55.0/255.0 green:151.0/255.0 blue:69.0/255.0 alpha:1];
    } else if ([mood caseInsensitiveCompare:@"athletic"] == NSOrderedSame) {
        return [UIColor colorWithRed:88.0/255.0 green:133.0/255.0 blue:59.0/255.0 alpha:1];
    } else if ([mood caseInsensitiveCompare:@"frustrated"] == NSOrderedSame) {
        return [UIColor colorWithRed:60.0/255.0 green:70.0/255.0 blue:100.0/255.0 alpha:1];
    } else if ([mood caseInsensitiveCompare:@"nostalgic"] == NSOrderedSame) {
        return [UIColor colorWithRed:50.0/255.0 green:112.0/255.0 blue:137.0/255.0 alpha:1];
    } else if ([mood caseInsensitiveCompare:@"pityparty"] == NSOrderedSame) {
        return [UIColor colorWithRed:23.0/255.0 green:39.0/255.0 blue:87.0/255.0 alpha:1];
    } else if ([mood caseInsensitiveCompare:@"social"] == NSOrderedSame) {
        return [UIColor colorWithRed:41.0/255.0 green:87.0/255.0 blue:166.0/255.0 alpha:1];
    } else if ([mood caseInsensitiveCompare:@"adventurous"] == NSOrderedSame) {
        return [UIColor colorWithRed:81.0/255.0 green:61.0/255.0 blue:142.0/255.0 alpha:1];
    } else if ([mood caseInsensitiveCompare:@"centered"] == NSOrderedSame) {
        return [UIColor colorWithRed:84.0/255.0 green:136.0/255.0 blue:200.0/255.0 alpha:1];
    } else if ([mood caseInsensitiveCompare:@"spiritual"] == NSOrderedSame) {
        return [UIColor colorWithRed:177.0/255.0 green:203.0/255.0 blue:228.0/255.0 alpha:1];
    } else if ([mood caseInsensitiveCompare:@"quiet"] == NSOrderedSame) {
        return [UIColor colorWithRed:166.0/255.0 green:200.0/255.0 blue:171.0/255.0 alpha:1];
    } else if ([mood caseInsensitiveCompare:@"ungrounded"] == NSOrderedSame) {
        return [UIColor colorWithRed:90.0/255.0 green:102.0/255.0 blue:81.0/255.0 alpha:1];
    } else if ([mood caseInsensitiveCompare:@"tired"] == NSOrderedSame) {
        return [UIColor colorWithRed:115.0/255.0 green:108.0/255.0 blue:114.0/255.0 alpha:1];
    } else if ([mood caseInsensitiveCompare:@"stressed"] == NSOrderedSame) {
        return [UIColor colorWithRed:42.0/255.0 green:42.0/255.0 blue:44.0/255.0 alpha:1];
    }
    
    // TODO : find colors!!
    else if ([mood caseInsensitiveCompare:@"anxious"] == NSOrderedSame) {
        return [UIColor colorWithRed:42.0/255.0 green:42.0/255.0 blue:44.0/255.0 alpha:1];
    } else if ([mood caseInsensitiveCompare:@"confident"] == NSOrderedSame) {
        return [UIColor colorWithRed:42.0/255.0 green:42.0/255.0 blue:44.0/255.0 alpha:1];
    } else if ([mood caseInsensitiveCompare:@"defeated"] == NSOrderedSame) {
        return [UIColor colorWithRed:42.0/255.0 green:42.0/255.0 blue:44.0/255.0 alpha:1];
    } else if ([mood caseInsensitiveCompare:@"hungry"] == NSOrderedSame) {
        return [UIColor colorWithRed:42.0/255.0 green:42.0/255.0 blue:44.0/255.0 alpha:1];
    } else if ([mood caseInsensitiveCompare:@"jealous"] == NSOrderedSame) {
        return [UIColor colorWithRed:42.0/255.0 green:42.0/255.0 blue:44.0/255.0 alpha:1];
    } else if ([mood caseInsensitiveCompare:@"lonely"] == NSOrderedSame) {
        return [UIColor colorWithRed:42.0/255.0 green:42.0/255.0 blue:44.0/255.0 alpha:1];
    } else if ([mood caseInsensitiveCompare:@"paranoid"] == NSOrderedSame) {
        return [UIColor colorWithRed:42.0/255.0 green:42.0/255.0 blue:44.0/255.0 alpha:1];
    } else if ([mood caseInsensitiveCompare:@"scared"] == NSOrderedSame) {
        return [UIColor colorWithRed:42.0/255.0 green:42.0/255.0 blue:44.0/255.0 alpha:1];
    } else if ([mood caseInsensitiveCompare:@"sick"] == NSOrderedSame) {
        return [UIColor colorWithRed:42.0/255.0 green:42.0/255.0 blue:44.0/255.0 alpha:1];
    }
    
    
    else {
        return [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
    }
}

+ (NSString*) getPinImageNameForMood:(NSString*)mood {
    return [NSString stringWithFormat:@"Map-squares-%@.png",mood];
}
+ (NSString*) getCollectivePinImageNameForMood:(NSString*)mood {
    return [NSString stringWithFormat:@"Map-triangles-%@.png",mood];
}

+ (NSString*) getTableRowImageForMood:(NSString*)mood {
    return [NSString stringWithFormat:@"DataViz-ScndLvl-%@.png",mood];
}

+ (NSString*) getMoodReviewBarImageForMood:(NSString*)mood {
    return [NSString stringWithFormat:@"DataViz-Percentage-Bar-%@.png",mood];
}

+ (NSString*) getBackgraoundImageForMood:(NSString*)mood {
    return [NSString stringWithFormat:@"ActivityView-colorbckgrd-%@.png",mood];
}


+ (NSString*) getMoodSquareImageNameForMood:(NSString*)mood {
    return [Moods getMoodSquareImageNameForMood:mood shouldFlattenTop:false];
}
+ (NSString*) getMoodSquareImageNameForMood:(NSString*)mood shouldFlattenTop:(bool)shouldFlatten {
    if (shouldFlatten){
        if([mood caseInsensitiveCompare:@"happy"]       == NSOrderedSame ||
           [mood caseInsensitiveCompare:@"hopeful"]     == NSOrderedSame ||
           [mood caseInsensitiveCompare:@"excited"]     == NSOrderedSame ) {
            return [NSString stringWithFormat:@"CheckIn-%@-straight.png",mood];
        } 
    } 
    return [NSString stringWithFormat:@"CheckIn-%@.png",mood];
}



+ (NSString*) getFormattedMoodString:(NSString*)mood {
    NSString * firstLetter = [mood substringToIndex:1];
    NSString * restOfString = [mood substringFromIndex:1];
    return [[firstLetter uppercaseString] stringByAppendingString:restOfString];
}


+ (NSString*)getMoodForIndex:(int)index {
    [Moods checkInit];
    if (index < 0 || index > [moodsArray count]) {
        return nil;
    } else {
        return [moodsArray objectAtIndex:index];
    }
}

+ (int)getNumberOfAvailableMoods {
    [Moods checkInit];
    return [moodsArray count];
}

@end
