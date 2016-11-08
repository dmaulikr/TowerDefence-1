#import "cocos2d.h"
#import "HelloWorldLayer.h"


@class HelloWorldLayer;

@interface Enemy: CCNode {
    CGPoint myPosition;
    int maxHp;
    int currentHp;
    float walkingSpeed;
    BOOL active;
    NSMutableArray *attackedBy;
    NSMutableArray *shortestPath;
    
    
@private
	NSMutableArray *spOpenSteps;
	NSMutableArray *spClosedSteps;
}

@property (strong) CCTMXLayer *towerLayer;
@property (nonatomic,assign) HelloWorldLayer *theGame;
@property (nonatomic,assign) CCSprite *mySprite;


+(id)nodeWithTheGame:(HelloWorldLayer*)_game;
-(id)initWithTheGame:(HelloWorldLayer *)_game;
-(void)doActivate;
-(void)getRemoved;
-(void)getDamaged:(int)damage;


@end

