

// ** -->>    IMPORT  CORE  FRAMEWORKS  PLUS  LAYERS     <<-- ** //
// ** -->>                                               <<-- ** //
// ** -->>                                               <<-- ** //
                       #import "cocos2d.h"
                   #import <GameKit/GameKit.h>
                      #import <HUDLayer.h>
// ** -->>                                               <<-- ** //
// ** -->>                                               <<-- ** //
// ** -->>    IMPORT  CORE  FRAMEWORKS  PLUS  LAYERS     <<-- ** //





// ** -->>   DEFINE  ENEMY  CLASSES    <<-- ** //
@class Enemy;
// ** -->>   DEFINE  ENEMY  CLASSES    <<-- ** //



// ** -->>   DEFINE  TOWER  CLASSES    <<-- ** //
@class Turret;
@class FlameThrower;
@class LightningGenerator;
// ** -->>   DEFINE  TOWER  CLASSES    <<-- ** //






// HelloWorldLayer
@interface GameLayer : CCLayer{
    HUDLayer *_hud;
    CCLabelBMFont *_statusLabel;
    
    
    
    CCLabelTTF *scoreText;
    CCLabelTTF *healthText;
    int wave;
    int points;
    int placeType;
    int health;
    BOOL devMode;
    
    CCSpriteBatchNode *_batchNodeEnemies;
    CCSpriteBatchNode *_batchNodeTowers;
    NSArray * currentWaveData;
    
    CCLabelBMFont *youwin;
    
    CCMenuItem *MachineGunButton;
    CCMenuItem *FlameThrowerButton;
    CCMenuItem *LightningGeneratorButton;
    
    
    
    CCSprite *TowerOptionsArea;
    
}

@property (strong) CCTMXTiledMap *tileMap;
@property (nonatomic,strong) NSMutableArray *towerpoints;
@property (strong) CCTMXLayer *towerLayer;






// ** -->>   DEFINE  ENEMY  ARRAYS    <<-- ** //
@property (nonatomic,strong) NSMutableArray *enemies;
// ** -->>   DEFINE  ENEMY  ARRAYS    <<-- ** //





// ** -->>   DEFINE  TOWER  ARRAYS    <<-- ** //
@property (nonatomic,strong) NSMutableArray *turrets;
@property (nonatomic,strong) NSMutableArray *FlameThrowers;
@property (nonatomic,strong) NSMutableArray *LightningGenerators;
// ** -->>   DEFINE  TOWER  ARRAYS    <<-- ** //





// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

-(CGPoint)tileCoordForPosition:(CGPoint)position;
-(BOOL)isWallAtTileCoord:(CGPoint)tileCoord;

-(void)enemyReached:(Enemy *)enemy;
-(void)enemyDestroyed:(Enemy *)enemy;
-(void)enemyGotKilled;
-(void)activateEnemy:(Enemy *)enemy;
-(CGPoint)startPosition;
-(CGPoint)endPosition;
- (CGPoint)positionForTileCoord:(CGPoint)tileCoord;

- (NSArray *)walkableAdjacentTilesCoordForTileCoord:(CGPoint)tileCoord;


-(BOOL)circle:(CGPoint)circlePoint withRadius:(float)radius collisionWithCircle:(CGPoint)circlePointTwo collisionCircleRadius:(float)radiusTwo;


-(id)initWithHUD:(HUDLayer *)hud;

+(void)select01;
+(void)select02;
+(void)select03;
+(void)select04;
+(void)select05;
+(void)select06;

@end