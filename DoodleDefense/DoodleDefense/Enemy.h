#import "cocos2d.h"
#import "GameLayer.h"


@class GameLayer;

@interface Enemy: CCSprite{
    CGPoint myPosition;
    int cost;
    int maxHp;
    int currentHp;
    float walkingSpeed;
    BOOL active;
    NSMutableArray *attackedBy;
    
    int lastX;
    int lastY;
}

@property (nonatomic,assign) GameLayer *theGame;
@property (strong) CCSprite *mySprite;


+(id)nodeWithTheGame:(GameLayer*)_game;
-(id)initWithTheGame:(GameLayer *)_game;
-(void)doActivate;
-(void)getRemoved;
-(void)getAttacked:(Turret *)attacker;
-(void)gotLostSight:(Turret *)attacker;
-(void)getDamaged:(int)damage;

-(void)poked;


@end