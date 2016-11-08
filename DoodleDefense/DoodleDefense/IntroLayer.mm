//
//  IntroLayer.m
//  DoodleDefense
//
//  Created by Brychan Odlum on 25/06/2013.
//  Copyright Brychan Odlum 2013. All rights reserved.
//


// Import the interfaces
#import "IntroLayer.h"
#import "Menu.h"


#pragma mark - IntroLayer

// HelloWorldLayer implementation
@implementation IntroLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	IntroLayer *layer = [IntroLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

//
-(id) init
{
	if( (self=[super init])) {
		
		// ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
		
		CCSprite *background;
		
		if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ) {
			background = [CCSprite spriteWithFile:@"Default.png"];
			background.rotation = 90;
		} else {
			background = [CCSprite spriteWithFile:@"Default-Landscape~ipad.png"];
		}
		background.position = ccp(size.width/2, size.height/2);
		
		// add the label as a child to this Layer
		[self addChild: background z:1];
        
        
        
        LoadingBar = [CCSprite spriteWithFile:@"LoadingBar.png"];
        CGSize originalSize = [LoadingBar contentSize];
        float originalWidth = originalSize.width;
        float originalHeight = originalSize.height;
        LoadingBarTotal = originalWidth;
        float newScaleX = originalWidth /2 /originalWidth;
        float newScaleY = originalHeight /2 /originalHeight;
        [LoadingBar setScaleX:newScaleX];
        [LoadingBar setScaleY:newScaleY];
		LoadingBar.position = ccp(size.width/2, size.height/2);
        
		[self addChild: LoadingBar z:2];
        
        float width = 0;
        LoadingBar.position = ccp(size.width/2 - ((originalWidth-width)/4), size.height/2);
        [LoadingBar setTextureRect:CGRectMake(0, 0, width, 32)];
        
        [LoadingBar setOpacity:1.0];
        CCFadeTo *fadeIn = [CCFadeTo actionWithDuration:0.5 opacity:55];
        CCFadeTo *fadeOut = [CCFadeTo actionWithDuration:0.5 opacity:255];
        CCSequence *pulseSequence = [CCSequence actionOne:fadeIn two:fadeOut];
        CCRepeatForever *repeat = [CCRepeatForever actionWithAction:pulseSequence];
        [LoadingBar runAction:repeat];
        [self schedule:@selector(nextFrame:)];
        
        
        
        loadingPart = [CCLabelTTF labelWithString:@"Caching texture data"
                                       fontName:@"Noteworthy-Bold"
                                       fontSize:15
                                     dimensions:CGSizeMake(298, 25)
                                     hAlignment:kCCTextAlignmentCenter
                                     vAlignment:kCCVerticalTextAlignmentTop];
        loadingPart.color = ccc3(158, 134, 109);
        loadingPart.position = ccp((size.width/2), (size.height/2)-23);
        [self addChild:loadingPart z:2];
	}
	
	return self;
}

-(void) nextFrame: (ccTime)dt {
    CGSize size = [[CCDirector sharedDirector] winSize];
    if (LoadingBar.textureRect.size.width < LoadingBarTotal) {
        float width = LoadingBar.textureRect.size.width+(arc4random() % (2-0+1)) + 0;
        LoadingBar.position = ccp(size.width/2 - ((LoadingBarTotal-width)/4), size.height/2);
        [LoadingBar setTextureRect:CGRectMake(0, 0, width, 32)];
        if (LoadingBar.textureRect.size.width > (LoadingBarTotal/3)*1) {
            loadingPart.string = @"Implementing player stats";
        }
        if (LoadingBar.textureRect.size.width > (LoadingBarTotal/3)*2) {
            loadingPart.string = @"Plotting world domination";
        }
    } else {
        [self unschedule:@selector(nextFrame:)];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:1.0 scene:[Menu scene]]];
    }
    
}

-(void) onEnter
{
	[super onEnter];
	//[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[Menu scene] ]];
}
@end
