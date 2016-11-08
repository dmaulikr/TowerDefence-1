

// ** -->>   IMPORT  CORE    <<-- ** //
#import "Menu.h"
#import "GameLayer.h"
// ** -->>   IMPORT  CORE    <<-- ** //








@implementation Menu

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene {
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
	// 'layer' is an autorelease object.
	Menu *layer = [Menu node];
    
	// add layer as a child to scene
	[scene addChild: layer];
    
	// return the scene
	return scene;
}

-(id)init {
    if ((self = [super init])) {
		// ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
		
        
        
        
        
        
        
        
        
        
        // ** -->>   SHOW  BACKGROUND    <<-- ** //
		CCSprite *background;
        background = [CCSprite spriteWithFile:@"Background.png"];
        CGSize originalSize = [background contentSize];
        float originalWidth = originalSize.width;
        float originalHeight = originalSize.height;
        float newScaleX = size.width/originalWidth;
        float newScaleY = size.height/originalHeight;
        [background setScaleX:newScaleX];
        [background setScaleY:newScaleY];
		background.position = ccp(size.width/2, size.height/2);
		[self addChild: background];
        // ** -->>   SHOW  BACKGROUND    <<-- ** //
        
        
        
        
        
        
        
        
        
		
        // ** -->>   SHOW  BASIC  BOXES    <<-- ** //
		CCSprite *logo;
        logo = [CCSprite spriteWithFile:@"Logo.png"];
        originalSize = [logo contentSize];
        originalWidth = originalSize.width;
        originalHeight = originalSize.height;
        newScaleX = (float)(837) /2 /originalWidth;
        newScaleY = (float)(429) /2 /originalHeight;
        [logo setScaleX:newScaleX];
        [logo setScaleY:newScaleY];
		logo.position = ccp(size.width-(logo.contentSize.width/4)-40, size.height-(logo.contentSize.height/4)-40);
		[self addChild: logo];
		
		CCSprite *appInfo;
        appInfo = [CCSprite spriteWithFile:@"AppInfo.png"];
        originalSize = [appInfo contentSize];
        originalWidth = originalSize.width;
        originalHeight = originalSize.height;
        newScaleX = (float)(502) /2 /originalWidth;
        newScaleY = (float)(66) /2 /originalHeight;
        [appInfo setScaleX:newScaleX];
        [appInfo setScaleY:newScaleY];
		appInfo.position = ccp((originalWidth/4)+40, (originalHeight/4)+20);
		[self addChild: appInfo];
		
		CCSprite *GameBox;
        GameBox = [CCSprite spriteWithFile:@"GameBox.png"];
        originalSize = [GameBox contentSize];
        originalWidth = originalSize.width;
        originalHeight = originalSize.height;
        newScaleX = (float)(882) /2 /originalWidth;
        newScaleY = (float)(732) /2 /originalHeight;
        [GameBox setScaleX:newScaleX];
        [GameBox setScaleY:newScaleY];
		GameBox.position = ccp(size.width-(GameBox.contentSize.width/4)-40, (GameBox.contentSize.height/4)+110);
        GameBox.opacity=150;
		[self addChild: GameBox];
        // ** -->>   SHOW  BASIC  BOXES    <<-- ** //
		
        
        
        
        
        
        
        
        
        
        // ** -->>   SETUP  RANKING  VIEW    <<-- ** //
		CCSprite *RankDown;
        RankDown = [CCSprite spriteWithFile:@"RankDown.png"];
        originalSize = [RankDown contentSize];
        originalWidth = originalSize.width;
        originalHeight = originalSize.height;
        newScaleX = (float)(125) /2 /originalWidth;
        newScaleY = (float)(126) /2 /originalHeight;
        [RankDown setScaleX:newScaleX];
        [RankDown setScaleY:newScaleY];
		RankDown.position = ccp((RankDown.contentSize.width/4)+125, size.height-(RankDown.contentSize.height/4)-105);
		[self addChild: RankDown];
		
		CCSprite *RankUp;
        RankUp = [CCSprite spriteWithFile:@"RankUp.png"];
        originalSize = [RankUp contentSize];
        originalWidth = originalSize.width;
        originalHeight = originalSize.height;
        newScaleX = (float)(125) /2 /originalWidth;
        newScaleY = (float)(126) /2 /originalHeight;
        [RankUp setScaleX:newScaleX];
        [RankUp setScaleY:newScaleY];
		RankUp.position = ccp((RankUp.contentSize.width/4)+385, size.height-(RankUp.contentSize.height/4)-105);
		[self addChild: RankUp];
		
		CCSprite *RankBarUnder;
		CCSprite *RankBarOver;
        RankBarUnder = [CCSprite spriteWithFile:@"RankBar.png"];
        RankBarOver = [CCSprite spriteWithFile:@"RankBar.png"];
        originalSize = [RankBarUnder contentSize];
        originalWidth = originalSize.width;
        originalHeight = originalSize.height;
        newScaleX = (float)(355) /2 /originalWidth;
        newScaleY = (float)(32) /2 /originalHeight;
        [RankBarUnder setScaleX:newScaleX];
        [RankBarUnder setScaleY:newScaleY];
        [RankBarOver setScaleX:newScaleX];
        [RankBarOver setScaleY:newScaleY];
		RankBarUnder.position = ccp((RankBarUnder.contentSize.width/4)+197, size.height-(RankBarUnder.contentSize.height/4)-105);
        RankBarUnder.opacity=150;
        
        float width = 275;
        RankBarOver.position = ccp(RankBarUnder.position.x - ((originalWidth-width)/4), RankBarUnder.position.y);
        [RankBarOver setTextureRect:CGRectMake(0, 0, width, 32)];
        
		[self addChild: RankBarUnder z:2];
		[self addChild: RankBarOver z:3];
        
        
        rankLabel = [CCLabelTTF labelWithString:@"Rank 68"
                                       fontName:@"Noteworthy-Bold"
                                       fontSize:30
                                     dimensions:CGSizeMake(354, 50)
                                     hAlignment:kCCTextAlignmentCenter
                                     vAlignment:kCCVerticalTextAlignmentTop];
        rankLabel.color = ccc3(32, 39, 41);
        rankLabel.position = ccp(RankBarUnder.position.x, RankBarUnder.position.y-23);
        [self addChild:rankLabel];
        
        xpLabel = [CCLabelTTF labelWithString:@"631xp till next rank!"
                                     fontName:@"Noteworthy"
                                     fontSize:15
                                   dimensions:CGSizeMake(354, 25)
                                   hAlignment:kCCTextAlignmentCenter
                                   vAlignment:kCCVerticalTextAlignmentTop];
        xpLabel.color = ccc3(79, 97, 101);
        xpLabel.position = ccp(rankLabel.position.x, rankLabel.position.y-24);
        [self addChild:xpLabel];
        
        userLabel = [CCLabelTTF labelWithString:@"Brodlum's Stats"
                                     fontName:@"Noteworthy-Bold"
                                     fontSize:18
                                   dimensions:CGSizeMake(323, 25)
                                   hAlignment:kCCTextAlignmentLeft
                                   vAlignment:kCCVerticalTextAlignmentTop];
        userLabel.color = ccc3(79, 97, 101);
        userLabel.position = ccp(RankDown.position.x-(RankDown.contentSize.width/4)+(userLabel.contentSize.width/2), RankDown.position.y+(RankDown.contentSize.height/4)+(userLabel.contentSize.height/2)+10);
        [self addChild:userLabel];
        
        
        [RankBarOver setOpacity:1.0];
        CCFadeTo *fadeIn = [CCFadeTo actionWithDuration:1.5 opacity:75];
        CCFadeTo *fadeOut = [CCFadeTo actionWithDuration:1.5 opacity:255];
        
        CCSequence *pulseSequence = [CCSequence actionOne:fadeIn two:fadeOut];
        CCRepeatForever *repeat = [CCRepeatForever actionWithAction:pulseSequence];
        [RankBarOver runAction:repeat];
        // ** -->>   SETUP  RANKING  VIEW    <<-- ** //
		
        
        
        
        
        
        
        
        
        
        // ** -->>   SETUP  MENU  ITEMS    <<-- ** //
		CCSprite *MapSelection;
        MapSelection = [CCSprite spriteWithFile:@"MapSelection.png"];
        originalSize = [MapSelection contentSize];
        originalWidth = originalSize.width;
        originalHeight = originalSize.height;
        newScaleX = (float)(282) /2 /originalWidth;
        newScaleY = (float)(166) /2 /originalHeight;
        [MapSelection setScaleX:newScaleX];
        [MapSelection setScaleY:newScaleY];
		MapSelection.position = ccp(GameBox.position.x-(GameBox.contentSize.width/4)+(MapSelection.contentSize.width/4)+78, GameBox.position.y+(GameBox.contentSize.height/4)-(MapSelection.contentSize.height/4)-59);
		[self addChild: MapSelection z:3];
		
		CCSprite *MapSelection_Map;
        MapSelection_Map = [CCSprite spriteWithFile:@"Map-Paper-Preview.png"];
        originalSize = [MapSelection_Map contentSize];
        originalWidth = originalSize.width;
        originalHeight = originalSize.height;
        newScaleX = (float)(270) /2 /originalWidth;
        newScaleY = (float)(154) /2 /originalHeight;
        [MapSelection_Map setScaleX:newScaleX];
        [MapSelection_Map setScaleY:newScaleY];
		MapSelection_Map.position = ccp(MapSelection.position.x, MapSelection.position.y);
		[self addChild: MapSelection_Map z:2];
        
        mapLabel = [CCLabelTTF labelWithString:@"YE' OLD PAPER"
                                       fontName:@"Noteworthy"
                                       fontSize:12
                                     dimensions:CGSizeMake(135, 22)
                                     hAlignment:kCCTextAlignmentCenter
                                     vAlignment:kCCVerticalTextAlignmentTop];
        mapLabel.color = ccc3(22, 29, 31);
        mapLabel.position = ccp(MapSelection.position.x, MapSelection.position.y+(MapSelection.contentSize.height/4)-9);
        [self addChild:mapLabel z:4];
        
        LeftButton = [CCMenuItemImage itemFromNormalImage:@"ArrowLeft.png" selectedImage:@"ArrowLeft-Sel.png" target:self selector:@selector(clickFacebook)];
        originalSize = [LeftButton contentSize];
        originalWidth = originalSize.width;
        originalHeight = originalSize.height;
        newScaleX = (float)(24.5) / originalWidth;
        newScaleY = (float)(24) / originalHeight;
        [LeftButton setScaleX:newScaleX];
        [LeftButton setScaleY:newScaleY];
        LeftButton.position = ccp(0, 0);
        
        RightButton = [CCMenuItemImage itemFromNormalImage:@"ArrowRight.png" selectedImage:@"ArrowRight-Sel.png" target:self selector:@selector(clickFacebook)];
        originalSize = [RightButton contentSize];
        originalWidth = originalSize.width;
        originalHeight = originalSize.height;
        newScaleX = (float)(24.5) / originalWidth;
        newScaleY = (float)(24) / originalHeight;
        [RightButton setScaleX:newScaleX];
        [RightButton setScaleY:newScaleY];
        RightButton.position = ccp((MapSelection.contentSize.width/2)+40, 0);
        CCMenu *miniMapOptions = [CCMenu menuWithItems: LeftButton, RightButton, nil];
        miniMapOptions.position = ccp(MapSelection.position.x-(MapSelection.contentSize.width/4)-20, MapSelection.position.y);
        [self addChild:miniMapOptions];
        
        //Testing                                    ***     REMOVE  THIS     ***                                                Testing//
        NSLog(@"%f", (RightButton.position.x+(RightButton.contentSize.width/4))-(LeftButton.position.x-(LeftButton.contentSize.width/4)));
        //Testing                                   ***     REMOVE  THIS     ***                                                 Testing//
        
        CCLabelTTF *SelectMapLabel = [CCLabelTTF labelWithString:@"Select Map"
                                                        fontName:@"Noteworthy-Bold"
                                                        fontSize:20
                                                      dimensions:CGSizeMake(130, 40)
                                                      hAlignment:kCCTextAlignmentLeft
                                                      vAlignment:kCCVerticalTextAlignmentTop];
        SelectMapLabel.color = ccc3(184, 207, 213);
        SelectMapLabel.position = ccp(miniMapOptions.position.x+(SelectMapLabel.contentSize.width/2)-20, MapSelection.position.y+(MapSelection.contentSize.height/4)+20);
        [self addChild:SelectMapLabel z:2];
        
        CCLabelTTF *GameModeLabel = [CCLabelTTF labelWithString:@"Game Mode"
                                                        fontName:@"Noteworthy-Bold"
                                                        fontSize:20
                                                      dimensions:CGSizeMake(130, 40)
                                                      hAlignment:kCCTextAlignmentLeft
                                                      vAlignment:kCCVerticalTextAlignmentTop];
        GameModeLabel.color = ccc3(184, 207, 213);
        GameModeLabel.position = ccp(SelectMapLabel.position.x+240, SelectMapLabel.position.y);
        [self addChild:GameModeLabel z:2];
        
        //TEST
        
        PlayButton = [CCMenuItemImage itemFromNormalImage:@"ButtonPlay.png" selectedImage:@"ButtonPlay-Sel.png" target:self selector:@selector(clickPlay)];
        originalSize = [PlayButton contentSize];
        originalWidth = originalSize.width;
        originalHeight = originalSize.height;
        newScaleX = (float)(410) /2 / originalWidth;
        newScaleY = (float)(90) /2 / originalHeight;
        [PlayButton setScaleX:newScaleX];
        [PlayButton setScaleY:newScaleY];
        PlayButton.position = ccp(0, 0);
		CCSprite *PlayButtonTest;
        CCMenu *playButtonMenu = [CCMenu menuWithItems: PlayButton, nil];
        playButtonMenu.position = ccp(MapSelection.position.x, MapSelection.position.y-(MapSelection.contentSize.height/4)-(PlayButton.contentSize.height/4)-20);
        [self addChild:playButtonMenu];
        // ** -->>   SETUP  MENU  ITEMS    <<-- ** //
        
        
        
        
        
        
        
        
        
        
        // ** -->>   SETUP  ICONS    <<-- ** //
        FacebookButton = [CCMenuItemImage itemFromNormalImage:@"Facebook-Icon.png" selectedImage:@"Facebook-Icon-Sel.png" target:self selector:@selector(clickFacebook)];
        originalSize = [FacebookButton contentSize];
        originalWidth = originalSize.width;
        originalHeight = originalSize.height;
        newScaleX = (float)(40) / originalWidth;
        newScaleY = (float)(40) / originalHeight;
        [FacebookButton setScaleX:newScaleX];
        [FacebookButton setScaleY:newScaleY];
        FacebookButton.position = ccp(0, 0);
        TwitterButton = [CCMenuItemImage itemFromNormalImage:@"Twitter-Icon.png" selectedImage:@"Twitter-Icon-Sel.png" target:self selector:@selector(clickTwitter)];
        [TwitterButton setScaleX:newScaleX];
        [TwitterButton setScaleY:newScaleY];
        TwitterButton.position = ccp(45, 0);
        GooglePlusButton = [CCMenuItemImage itemFromNormalImage:@"GooglePlus-Icon.png" selectedImage:@"GooglePlus-Icon-Sel.png" target:self selector:@selector(clickGooglePlus)];
        [GooglePlusButton setScaleX:newScaleX];
        [GooglePlusButton setScaleY:newScaleY];
        GooglePlusButton.position = ccp(90, 0);
        MusicButton = [CCMenuItemImage itemFromNormalImage:@"Music-Icon.png" selectedImage:@"Music-Icon-Sel.png" target:self selector:@selector(clickMusic)];
        [MusicButton setScaleX:newScaleX];
        [MusicButton setScaleY:newScaleY];
        MusicButton.position = ccp(45, 45);
        LeaderboardButton = [CCMenuItemImage itemFromNormalImage:@"Leaderboard-Icon.png" selectedImage:@"Leaderboard-Icon-Sel.png" target:self selector:@selector(clickLeaderboard)];
        [LeaderboardButton setScaleX:newScaleX];
        [LeaderboardButton setScaleY:newScaleY];        LeaderboardButton.position = ccp(90, 45);
        CCMenu *miniOptions = [CCMenu menuWithItems: FacebookButton, TwitterButton, GooglePlusButton, MusicButton, LeaderboardButton, nil];
        miniOptions.position = ccp(size.width-127, 35);
        [self addChild:miniOptions];
        // ** -->>   SETUP  ICONS    <<-- ** //
    }
    return self;
}

-(void)clickPlay{
    [self gotoGame];
    
}

-(void)clickFacebook {
    
}
-(void)clickTwitter {
    
}
-(void)clickGooglePlus {
    
}
-(void)clickMusic {
    if (MusicButton.opacity==255) {
        MusicButton.opacity=100;
    } else {
        MusicButton.opacity=255;
    }
}
-(void)clickLeaderboard {
    if (LeaderboardButton.opacity==255) {
        LeaderboardButton.opacity=100;
    } else {
        LeaderboardButton.opacity=255;
    }
}

-(void)gotoGame {
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.3 scene:[GameLayer scene]]];
}

@end