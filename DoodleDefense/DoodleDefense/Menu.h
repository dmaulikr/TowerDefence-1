// ** -->>    IMPORT  CORE  FRAMEWORKS     <<-- ** //
// ** -->>                                 <<-- ** //
// ** -->>                                 <<-- ** //
#import "cocos2d.h"
#import <Foundation/Foundation.h>
// ** -->>                                 <<-- ** //
// ** -->>                                 <<-- ** //
// ** -->>    IMPORT  CORE  FRAMEWORKS     <<-- ** //






// HUDLayer
@interface Menu : CCLayer {
    CCLabelTTF *rankLabel;
    CCLabelTTF *xpLabel;
    CCLabelTTF *userLabel;
    
    CCLabelTTF *mapLabel;
    
    CCMenuItem *FacebookButton;
    CCMenuItem *TwitterButton;
    CCMenuItem *GooglePlusButton;
    CCMenuItem *MusicButton;
    CCMenuItem *LeaderboardButton;
    
    
    CCMenuItem *PlayButton;
    
    
    CCMenuItem *LeftButton;
    CCMenuItem *RightButton;
    
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end