#import "cocos2d.h"
#import "GameLayer.h"


@class GameLayer, Enemy;

@interface FlameThrower : CCSprite {
    CGPoint myPosition;
    int cooldown;
    int attackRange;
    int damage;
    float fireRate;
    Enemy *chosenEnemy;
}

@property (nonatomic,assign) GameLayer *theGame;
@property (strong) CCSprite *mySprite;


+(id)nodeWithTheGame:(GameLayer*)_game at:(CGPoint)point;
-(id)initWithTheGame:(GameLayer *)_game at:(CGPoint)point;
-(void)targetKilled;

@end