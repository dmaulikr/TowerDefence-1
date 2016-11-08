//
//  IntroLayer.h
//  DoodleDefense
//
//  Created by Brychan Odlum on 25/06/2013.
//  Copyright Brychan Odlum 2013. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface IntroLayer : CCLayer {
    CCSprite *LoadingBar;
    float LoadingBarTotal;
    CCLabelTTF *loadingPart;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
