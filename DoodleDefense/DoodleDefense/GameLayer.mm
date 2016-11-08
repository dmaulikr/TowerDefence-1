

// ** -->>   IMPORT  CORE    <<-- ** //
#import "GameLayer.h"
#import "AppDelegate.h"
#import "AStarPathFinder.h"
#import "Menu.h"
// ** -->>   IMPORT  CORE    <<-- ** //



// ** -->>   IMPORT  MAPS    <<-- ** //
#import "map.h"
// ** -->>   IMPORT  MAPS    <<-- ** //



// ** -->>   IMPORT  ENEMIES    <<-- ** //
#import "Enemy.h"
// ** -->>   IMPORT  ENEMIES    <<-- ** //



// ** -->>   IMPORT  TOWERS    <<-- ** //
#import "Turret.h"
#import "FlameThrower.h"
#import "LightningGenerator.h"
// ** -->>   IMPORT  TOWERS    <<-- ** //



// ** -->>   IMPORT  GAME    <<-- ** //
#import "HUDLayer.h"
// ** -->>   IMPORT  GAME    <<-- ** //









@interface GameLayer()

@property (strong) CCTMXLayer *background;
@property (strong) CCTMXLayer *selectionLayer;
@property (strong) CCSprite *player;
@property (strong) CCTMXObjectGroup *towerItems;

@end

@implementation GameLayer

@synthesize enemies;
@synthesize FlameThrowers;
@synthesize LightningGenerators;
@synthesize turrets;

CGPoint lastTile;
bool isTouching=FALSE;
int touchHash = 0;
CCTMXObjectGroup *keypoints;

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene {
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
    
	// 'layer' is an autorelease object.
	GameLayer *layer = [GameLayer node];
    
	// add layer as a child to scene
	[scene addChild: layer];
    
	// return the scene
	return scene;
}


-(id)init {
    if ((self = [super init])) {
        
        // ** -->>   DEFINE  APPLICATIONs  WINDOW  SIZE    <<-- ** //
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        //Perhaps this variable should be global?
        // ** -->>   DEFINE  APPLICATIONs  WINDOW  SIZE    <<-- ** //
        
        
        // ** -->>   ENABLE  //  DISABLE  DEVELOPER  MODE    <<-- ** //
        devMode = true;                                                             // ** -->>   REMEMBER TO SET THIS TO "FALSE" ON RELEASE    <<-- ** //
        // ** -->>   ENABLE  //  DISABLE  DEVELOPER  MODE    <<-- ** //
        
        
        // ** -->>   LOAD  BACKGROUND  DATA    <<-- ** //
        CCSprite *background = [CCSprite spriteWithFile:@"Map_Paper.png"];
        background.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:background z:-4];
        CGSize originalSize = [background contentSize];
        float originalWidth = originalSize.width;
        float originalHeight = originalSize.height;
        float newScaleX = (float)(winSize.width) / originalWidth;
        float newScaleY = (float)(winSize.height) / originalHeight;
        [background setScaleX:newScaleX];
        [background setScaleY:newScaleY];
        // ** -->>   LOAD  BACKGROUND  DATA    <<-- ** //
        
        // ** -->>   LOAD  MAP  TYPES    <<-- ** //
        if (IS_RETINA) {
            //self.tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"mapFileIpadRetina.tmx"];
            _tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"mapFileIpad.tmx"];
        } else {
            _tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"mapFileIpad.tmx"];
        }
        // ** -->>   LOAD  MAP  TYPES    <<-- ** //
        
        
        TowerOptionsArea = [CCSprite spriteWithFile:@"TowerOptions.png"];
        
        
        
        // ** -->>   LOAD  SELECTED  MAP  DATA    <<-- ** //
        _towerItems = [_tileMap objectGroupNamed:@"towerpoints"];
        NSAssert(_towerItems != nil, @"tile map has no objects object layer");
        
        _background = [_tileMap layerNamed:@"Background"];
        _selectionLayer = [_tileMap layerNamed:@"Selection"];
        _towerLayer = [_tileMap layerNamed:@"Towers"];
        [_tileMap reorderChild:[_tileMap layerNamed:@"Towers"] z:-2];
        [_tileMap reorderChild:[_tileMap layerNamed:@"Selection"] z:-1];
        
        keypoints = [_tileMap objectGroupNamed:@"keypoints"];
        NSAssert(keypoints != nil, @"tile map has no objects object layer");
        
        int height1 = self.tileMap.contentSize.height;
        int width1 = self.tileMap.contentSize.width;
        CGPoint point = ccp((winSize.width/2)-(width1/2), (winSize.height/2)-(height1/2)+10);
        self.tileMap.position=point;
        // ** -->>   LOAD  SELECTED  MAP  DATA    <<-- ** //
        
        
        
        
        
        // ** -->>    LOAD  SPRITE  SHEETS    <<-- ** //
        //Enemies
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"enemy.plist"];
        _batchNodeEnemies = [CCSpriteBatchNode batchNodeWithFile:@"enemy.png"];
        [self addChild:_batchNodeEnemies];
        
        
        CCTextureCache* textureCache = [CCTextureCache sharedTextureCache];
        CCTexture2D *v1 = [textureCache addImage:@"v1.png"];
        CCTexture2D *v2 = [textureCache addImage:@"v2.png"];
        CCTexture2D *v3 = [textureCache addImage:@"v3.png"];
        CCTexture2D *v4 = [textureCache addImage:@"v4.png"];
        // ** -->>    LOAD  SPRITE  SHEETS    <<-- ** //
        
        
        
        
        
        [self addChild:_tileMap z:-3];
        
        self.touchEnabled = YES;
        placeType=00;
        
        
        // ** -->>   ENEMY  DATA  TYPES    <<-- ** //
        // 00 = SELECTION TOOL
        // 01 = BARACADE
        // 02 = MACHINE GUN
        // 03 = FLAMETHROWER
        // 04 = CANNON
        // 05 = LASER GUN
        // 06 = LIGHTNING CANNON
        // 07 = ROCKET LAUNCHER
        // 08 = BOMB
        // 09 = NUKE
        // ** -->>   ENEMY  DATA  TYPES    <<-- ** //
        
        // ** -->>   ENEMY  COST  TYPES    <<-- ** // DEFINE THIS LAT
        // 00 = SELECTION TOOL
        // 01 = BARACADE
        // 02 = MACHINE GUN
        // 03 = FLAMETHROWER
        // 04 = CANNON
        // 05 = LASER GUN
        // 06 = LIGHTNING CANNON
        // 07 = ROCKET LAUNCHER
        // 08 = BOMB
        // 09 = NUKE
        // ** -->>   ENEMY  COST  TYPES    <<-- ** //
        
        
        
        // ** -->>   LOAD  ENEMY  AND  WAVE  DATA    <<-- ** //
        enemies = [[NSMutableArray alloc] init];
        FlameThrowers = [[NSMutableArray alloc] init];
        LightningGenerators = [[NSMutableArray alloc] init];
        [self loadWave];
        // ** -->>   LOAD  ENEMY  AND  WAVE  DATA    <<-- ** //
        
        
        
        
        // ** -->>    LOAD  GAME OPTIONS AND HUD    <<-- ** //
        [self setupScore];
        [self setupHealth];
        // ** -->>    CREATE  TOWER  BUTTONS    <<-- ** //
        MachineGunButton = [CCMenuItemImage itemFromNormalImage:@"MachineGun.png" selectedImage:@"MachineGun_Sel.png" target:self selector:@selector(select01)];
        originalSize = [MachineGunButton contentSize];
        originalWidth = originalSize.width;
        originalHeight = originalSize.height;
        newScaleX = (float)(70) / originalWidth;
        newScaleY = (float)(70) / originalHeight;
        [MachineGunButton setScaleX:newScaleX];
        [MachineGunButton setScaleY:newScaleY];
        MachineGunButton.position = ccp(60, 40);
        FlameThrowerButton = [CCMenuItemImage itemFromNormalImage:@"FlameThrower.png" selectedImage:@"FlameThrower_Sel.png" target:self selector:@selector(select02)];
        [FlameThrowerButton setScaleX:newScaleX];
        [FlameThrowerButton setScaleY:newScaleY];
        FlameThrowerButton.position = ccp(150, 40);
        LightningGeneratorButton = [CCMenuItemImage itemFromNormalImage:@"LightningGenerator.png" selectedImage:@"LightningGenerator_Sel.png" target:self selector:@selector(select03)];
        [LightningGeneratorButton setScaleX:newScaleX];
        [LightningGeneratorButton setScaleY:newScaleY];
        LightningGeneratorButton.position = ccp(240, 40);
        CCMenu *towerMenu = [CCMenu menuWithItems:MachineGunButton, FlameThrowerButton, LightningGeneratorButton, nil];
        towerMenu.position = CGPointZero;
        [self addChild:towerMenu];
        // ** -->>    CREATE  TOWER  BUTTONS    <<-- ** //=
        
        
    }
    return self;
}

-(void)gameOver {
	[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.3 scene:[Menu scene]]];
}


-(void)selectionButtons:(int)type {
    if (type == 1) {
        if (placeType == 00) {
            placeType = 01;
            MachineGunButton.opacity = 255;
            FlameThrowerButton.opacity = 75;
            LightningGeneratorButton.opacity = 75;
        } else {
            placeType = 00;
            MachineGunButton.opacity = 255;
            FlameThrowerButton.opacity = 255;
            LightningGeneratorButton.opacity = 255;
        }
    }
    if (type == 2) {
        if (placeType == 00) {
            placeType = 02;
            MachineGunButton.opacity = 75;
            FlameThrowerButton.opacity = 255;
            LightningGeneratorButton.opacity = 75;
        } else {
            placeType = 00;
            MachineGunButton.opacity = 255;
            FlameThrowerButton.opacity = 255;
            LightningGeneratorButton.opacity = 255;
        }
    }
    if (type == 3) {
        if (placeType == 00) {
            placeType = 03;
            MachineGunButton.opacity = 75;
            FlameThrowerButton.opacity = 75;
            LightningGeneratorButton.opacity = 2555;
        } else {
            placeType = 00;
            MachineGunButton.opacity = 255;
            FlameThrowerButton.opacity = 255;
            LightningGeneratorButton.opacity = 255;
        }
    }
    if (type == 4) {
        placeType = 04;
    }
    if (type == 5) {
        placeType = 05;
    }
    if (type == 6) {
        placeType = 06;
    }
}

-(void)select01 {   [self selectionButtons:1];  }
-(void)select02 {   [self selectionButtons:2];  }
-(void)select03 {   [self selectionButtons:3];  }
-(void)select04 {   [self selectionButtons:4];  }
-(void)select05 {   [self selectionButtons:5];  }
-(void)select06 {   [self selectionButtons:6];  }

-(int)getCost:(int)type {
    if (devMode)       return 0;
    if (type == 1)     return 10;
    if (type == 2)     return 15;
    if (type == 3)     return 20;
    if (type == 4)     return 25;
    if (type == 5)     return 30;
    if (type == 6)     return 35;
    if (type == 7)     return 40;
    if (type == 8)     return 45;
    if (type == 9)     return 50;
    return 0;
}

-(void)setupHealth {
    health = 20;
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    healthText = [CCLabelTTF labelWithString:@"20"
                                   fontName:@"Marker Felt"
                                   fontSize:25
                                 dimensions:CGSizeMake(50, 50)
                                 hAlignment:kCCTextAlignmentLeft
                                  vAlignment:kCCVerticalTextAlignmentTop];
    healthText.opacity=180;
    healthText.color = ccc3(200, 200, 200);
    healthText.position = ccp(winSize.width-40, winSize.height-45);
    [self addChild:healthText z:20];
}

-(void)setupScore {
    points = 10;
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    scoreText = [CCLabelTTF labelWithString:@"10"
                                   fontName:@"Marker Felt"
                                   fontSize:25
                                 dimensions:CGSizeMake(50, 50)
                                 hAlignment:kCCTextAlignmentLeft
                                 vAlignment:kCCVerticalTextAlignmentTop];
    scoreText.opacity=180;
    scoreText.color = ccc3(200, 200, 200);
    scoreText.position = ccp(138, winSize.height-45);
    [self addChild:scoreText z:20];
}

-(void)updateScore {
    [scoreText setString:[NSString stringWithFormat:@"%d", points]];
    scoreText.opacity = 255;
    [scoreText runAction:[CCFadeTo actionWithDuration:0.5 opacity:180]];
}

-(void)updateHealth {
    [healthText setString:[NSString stringWithFormat:@"%d", health]];
    healthText.opacity = 255;
    [healthText runAction:[CCFadeTo actionWithDuration:0.5 opacity:180]];
}

-(void)scoreHitAtPosition:(CGPoint)position withPoints:(int)points2 {
    points += points2;
    [self updateScore];
    
    /*
    NSString* curScoreTxt = [NSString stringWithFormat:@"+ %d", points2];
    CCLabelTTF *curScore = [CCLabelTTF labelWithString:curScoreTxt fontName:@"Marker Felt" fontSize:24];
    curScore.color = ccBLUE;
    curScore.position = position;
    [self addChild:curScore z:20];
    
    id opacityAct1 = [CCActionTween actionWithDuration:1 key:@"opacity" from:255 to:0];
    id opacityAct2 = [CCActionTween actionWithDuration:3 key:@"opacity" from:0 to:255];
    id actionCallFunc = [CCCallFuncN actionWithTarget:self selector:@selector(removeScoreText:)];
    id seq = [CCSequence actionOne:opacityAct1 two:actionCallFunc];
    [curScore runAction:seq];
    */
}

-(void)removeScoreText:(CCLabelTTF *)scoreLabel {
    [scoreLabel removeFromParent];
}

-(CGPoint)startPosition {
    NSMutableDictionary *SpawnPoint = [keypoints objectNamed:@"SpawnPoint"];
    int x = [[SpawnPoint valueForKey:@"x"] intValue];
    int y = [[SpawnPoint valueForKey:@"y"] intValue];
    return ccp(x, y);
}


-(CGPoint)endPosition {
    NSMutableDictionary *FinalPoint = [keypoints objectNamed:@"FinalPoint"];
    int x = [[FinalPoint valueForKey:@"x"] intValue];
    int y = [[FinalPoint valueForKey:@"y"] intValue];
    return ccp(x, y);
}

-(void) tick2
{
    if (isTouching==TRUE) {
    }
    if (isTouching==FALSE) {
    }
}
#pragma mark - handle touches
-(void)registerWithTouchDispatcher {
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self
                                                              priority:0
                                                       swallowsTouches:YES];
}

-(BOOL)loadWave {
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"Waves" ofType:@"plist"];
    NSArray * waveData = [NSArray arrayWithContentsOfFile:plistPath];
    
    if(wave >= [waveData count])
    {
        return NO;
    }
    
    currentWaveData =[NSArray arrayWithArray:[waveData objectAtIndex:wave]];
    
    for(NSDictionary * enemyData in currentWaveData) {
        
        //[self schedule:@selector(activateEnemy) withObject:enemy afterDelay:[[enemyData objectForKey:@"spawnTime"]floatValue]];
        //[self performSelector:@selector(activateEnemy) withObject:enemy afterDelay:[[enemyData objectForKey:@"spawnTime"]floatValue]];
        //[self schedule:@selector(spawnEnemy) interval:[[enemyData objectForKey:@"spawnTime"]floatValue]];
        [self performSelector:@selector(quickCallActivate) withObject:nil afterDelay:[[enemyData objectForKey:@"spawnTime"]floatValue]];
        
        
        
       
    
        
    }
    
    wave++;
    //[ui_wave_lbl setString:[NSString stringWithFormat:@"WAVE: %d",wave]];
    
    return YES;
    
}

-(void)quickCallActivate {
    Enemy * enemy = [Enemy nodeWithTheGame:self];
    [enemies addObject:enemy];
    [enemy doActivate];
    [self activateEnemy:enemy];
}


-(void)activateEnemy:(Enemy *)enemy {
    //CGPoint StartPoint = [self tileCoordForPosition:self.startPosition];
    CGPoint StartPoint = [self tileCoordForPosition:enemy.position];
    CGPoint EndPoint = [self tileCoordForPosition:self.endPosition];
    
    // Initialize the A* pathfinder.
    AStarPathFinder *pathFinder = [[AStarPathFinder alloc]
                                   initWithTileMap:self.tileMap groundLayer:@"Background"];
    [pathFinder addCollideLayer:@"Towers"];
    [pathFinder setCollideKey:@"Wall"];
    [pathFinder addCollideLayer:@"Background"];
    [pathFinder setCollideKey:@"Wall"];
    
    [pathFinder setConsiderDiagonalMovement:NO];
    [pathFinder moveSprite:enemy from:StartPoint to:EndPoint atSpeed:0.5f];
}

-(void)recalculatePaths {
    [[CCActionManager sharedManager] removeAllActions];
    
    for (Enemy *e in enemies) {     [self activateEnemy:e];     }
}

-(void)loadEditor:(CGPoint)point {
    int type_f = [_towerLayer tileGIDAt:point];
    int tower_type = [self translateTileToTowerType:type_f];
    if (tower_type <= 100) {
        NSLog(@"!THE TOWER --> %d <-- THE TOWER!", tower_type);
        CGPoint temp = [self tileCoordForPosition:point];
        NSLog(@"%f, %f <----------- LOOK AT ME. IM ASKING FOR ATTENTION!!!!!", temp.x, temp.y);
        TowerOptionsArea.position = [self positionForTileCoord:[self tileCoordForPosition:point]];
        [self addChild:TowerOptionsArea z:4];
        
    }
}

-(void)clickCell:(CGPoint)point {
    // ** -->>   PLACE  NEW  TOWER    <<-- ** //
    if (points  < [self getCost:placeType]) {
        NSLog(@"NOT_ENOUGH_POINTS");
    } else {
        points-=[self getCost:placeType];
        if (placeType == 0) {
            //Load tool for editing a tower, E.G. sell tower, upgrade tower view radius etc.
        }
        
        
        if (placeType == 1) {
            if ([self isWallAtTileCoord:lastTile]) return;
            Turret *tower = [Turret nodeWithTheGame:self at:[self positionForTileCoord:lastTile]];
            [turrets addObject:tower];
            [_towerLayer setTileGID:4 at:point];
            
        }
        if (placeType == 2) {
            if ([self isWallAtTileCoord:lastTile]) return;
            FlameThrower *tower= [FlameThrower nodeWithTheGame:self at:[self positionForTileCoord:lastTile]];
            [turrets addObject:tower];
            [_towerLayer setTileGID:5 at:point];
        }
        if (placeType == 3) {
            if ([self isWallAtTileCoord:lastTile]) return;
            LightningGenerator *tower= [LightningGenerator nodeWithTheGame:self at:[self positionForTileCoord:lastTile]];
            [turrets addObject:tower];
            [_towerLayer setTileGID:7 at:point];
            NSLog(@"TEST");
        }
        [self updateScore];
        [self recalculatePaths];
        // ** -->>   PLACE  NEW  TOWER    <<-- ** //
    }
}

-(void)enemyReached:(Enemy *)enemy {
    health-=1;
    if (health <= 0)
        [self gameOver];
    
    

    [self updateHealth];
    CCParticleSun* explosion2 = [[CCParticleSun alloc]initWithTotalParticles:150];
    explosion2.autoRemoveOnFinish = YES;
    explosion2.startSize = 70.0f;
    explosion2.speed = 0.01f;
    explosion2.anchorPoint = ccp(0.0f,0.0f);
    explosion2.position = ccp(enemy.position.x-16, enemy.position.y+33);
    explosion2.duration = 0.05f;
    [self addChild:explosion2 z:self.zOrder+1];
    [self removeChild:enemy cleanup:YES];
    [enemies removeObject:enemy];
    [enemies removeObjectIdenticalTo:enemy];
    CCParticleExplosion* explosion = [[CCParticleExplosion alloc]initWithTotalParticles:5];
    explosion.texture = [[CCTextureCache sharedTextureCache] addImage:@"particle_1.png"];
    explosion.autoRemoveOnFinish = YES;
    explosion.startSize = 1.0f;
    explosion.speed = 30.0f;
    explosion.anchorPoint = ccp(0.0f,0.0f);
    explosion.position = ccp(enemy.position.x-16, enemy.position.y+33);
    explosion.duration = 0.05f;
    [self addChild:explosion z:self.zOrder+1];
    
    explosion = [[CCParticleExplosion alloc]initWithTotalParticles:25];
    explosion.texture = [[CCTextureCache sharedTextureCache] addImage:@"particle_2.png"];
    explosion.autoRemoveOnFinish = YES;
    explosion.startSize = 1.0f;
    explosion.speed = 30.0f;
    explosion.anchorPoint = ccp(0.0f,0.0f);
    explosion.position = ccp(enemy.position.x-16, enemy.position.y-22);
    explosion.duration = 0.05f;
    [self addChild:explosion z:self.zOrder+1];
    
    explosion = [[CCParticleExplosion alloc]initWithTotalParticles:25];
    explosion.texture = [[CCTextureCache sharedTextureCache] addImage:@"particle_3.png"];
    explosion.autoRemoveOnFinish = YES;
    explosion.startSize = 1.0f;
    explosion.speed = 30.0f;
    explosion.anchorPoint = ccp(0.0f,0.0f);
    explosion.position = ccp(enemy.position.x-16, enemy.position.y+33);
    explosion.duration = 0.05f;
    [self addChild:explosion z:self.zOrder+1];
    
    explosion = [[CCParticleExplosion alloc]initWithTotalParticles:25];
    explosion.texture = [[CCTextureCache sharedTextureCache] addImage:@"particle_4.png"];
    explosion.autoRemoveOnFinish = YES;
    explosion.startSize = 1.0f;
    explosion.speed = 30.0f;
    explosion.anchorPoint = ccp(0.0f,0.0f);
    explosion.position = ccp(enemy.position.x-16, enemy.position.y+33);
    explosion.duration = 0.05f;
    [self addChild:explosion z:self.zOrder+1];
    
    CCParticleSun* explosion3 = [[CCParticleSun alloc]initWithTotalParticles:250];
    explosion3.texture = [[CCTextureCache sharedTextureCache] addImage:@"fire.png"];
    explosion3.autoRemoveOnFinish = YES;
    explosion3.startSize = 20.0f;
    explosion3.speed = 30.0f;
    explosion3.anchorPoint = ccp(0.0f,0.0f);
    explosion3.position = ccp(enemy.position.x-16, enemy.position.y+33);
    explosion3.duration = 0.15f;
    [self addChild:explosion3 z:self.zOrder+1];
}

-(void)enemyDestroyed:(Enemy *)enemy {
    [self scoreHitAtPosition:enemy.position withPoints:1];
    [enemies removeObject:enemy];
    [enemies removeObjectIdenticalTo:enemy];
    CCParticleExplosion* explosion = [[CCParticleExplosion alloc]initWithTotalParticles:5];
    explosion.texture = [[CCTextureCache sharedTextureCache] addImage:@"particle_1.png"];
    explosion.autoRemoveOnFinish = YES;
    explosion.startSize = 1.0f;
    explosion.speed = 30.0f;
    explosion.anchorPoint = ccp(0.0f,0.0f);
    explosion.position = ccp(enemy.position.x-16, enemy.position.y+33);
    explosion.duration = 0.05f;
    [self addChild:explosion z:self.zOrder+1];
    
    [enemies removeObject:enemy];
    [enemies removeObjectIdenticalTo:enemy];
    explosion = [[CCParticleExplosion alloc]initWithTotalParticles:5];
    explosion.texture = [[CCTextureCache sharedTextureCache] addImage:@"particle_2.png"];
    explosion.autoRemoveOnFinish = YES;
    explosion.startSize = 1.0f;
    explosion.speed = 30.0f;
    explosion.anchorPoint = ccp(0.0f,0.0f);
    explosion.position = ccp(enemy.position.x-16, enemy.position.y+33);
    explosion.duration = 0.05f;
    [self addChild:explosion z:self.zOrder+1];
    
    [enemies removeObject:enemy];
    [enemies removeObjectIdenticalTo:enemy];
    explosion = [[CCParticleExplosion alloc]initWithTotalParticles:5];
    explosion.texture = [[CCTextureCache sharedTextureCache] addImage:@"particle_3.png"];
    explosion.autoRemoveOnFinish = YES;
    explosion.startSize = 1.0f;
    explosion.speed = 30.0f;
    explosion.anchorPoint = ccp(0.0f,0.0f);
    explosion.position = ccp(enemy.position.x-16, enemy.position.y+33);
    explosion.duration = 0.05f;
    [self addChild:explosion z:self.zOrder+1];
    
    [enemies removeObject:enemy];
    [enemies removeObjectIdenticalTo:enemy];
    explosion = [[CCParticleExplosion alloc]initWithTotalParticles:5];
    explosion.texture = [[CCTextureCache sharedTextureCache] addImage:@"particle_4.png"];
    explosion.autoRemoveOnFinish = YES;
    explosion.startSize = 1.0f;
    explosion.speed = 30.0f;
    explosion.anchorPoint = ccp(0.0f,0.0f);
    explosion.position = ccp(enemy.position.x-16, enemy.position.y+33);
    explosion.duration = 0.05f;
    [self addChild:explosion z:self.zOrder+1];
    
    CCParticleSun* explosion2 = [[CCParticleSun alloc]initWithTotalParticles:150];
    explosion2.texture = [[CCTextureCache sharedTextureCache] addImage:@"fire.png"];
    explosion2.autoRemoveOnFinish = YES;
    explosion2.startSize = 20.0f;
    explosion2.speed = 30.0f;
    explosion2.anchorPoint = ccp(0.0f,0.0f);
    explosion2.position = ccp(enemy.position.x-16, enemy.position.y+33);
    explosion2.duration = 0.15f;
    [self addChild:explosion2 z:self.zOrder+1];
}

-(void)enemyGotKilled {
    if ([enemies count]<=0) {
        if(![self loadWave]) {
            
            //[[CCDirector sharedDirector] replaceScene:[CCTransitionSplitCols transitionWithDuration:1 scene:[HelloWorldLayer scene]]];
        }
    }
}

-(BOOL)isPathValidFrom:(CGPoint )startP to:(CGPoint )endP {
    // Initialize the A* pathfinder.
    AStarPathFinder *pathFinder = [[AStarPathFinder alloc] initWithTileMap:self.tileMap groundLayer:@"Background"];
    [pathFinder addCollideLayer:@"Towers"];
    [pathFinder addCollideLayer:@"Background"];
    [pathFinder setCollideKey:@"Wall"];
    
    [pathFinder setConsiderDiagonalMovement:NO];
    NSArray *test = [pathFinder getPath:startP to:endP];
    if (test.count)
        return true;
    else
        return false;
}

-(CGPoint)gridLocation:(CGPoint )location {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    location = [[CCDirector sharedDirector] convertToGL: location];
    
    int OffsetX = (winSize.width/2)-(_tileMap.contentSize.width/2);
    int OffsetY = (winSize.height/2)-(_tileMap.contentSize.height/2);
    
    return CGPointMake((location.x-OffsetX)*[UIScreen mainScreen].scale, (location.y-OffsetY)*[UIScreen mainScreen].scale);
}

-(void)highlightCell:(CGPoint )cell {
    [self endHighlightCell];
    lastTile = cell;
    [_selectionLayer setTileGID:3 at:cell];
}

-(void)endHighlightCell {
    [_selectionLayer removeTileAt:lastTile];
}

-(void)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    NSLog(@"BEGAN");
    if (touchHash != 0)
        return;
    touchHash = touch.hash;
    isTouching = true;
    CGPoint location = [touch locationInView: [touch view]];
    if ([self isPointOnMap:location]) {
        [self highlightCell:[self tileCoordForPosition:[self gridLocation:location]]];
    }
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    if (touchHash != touch.hash)
    if (touchHash != 0)
        return;
    CGPoint location = [touch locationInView: [touch view]];
    if ([self isPointOnMap:location]) {
        [self highlightCell:[self tileCoordForPosition:[self gridLocation:location]]];
    }
}
-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    NSLog(@"ENDED");
    if (touchHash != touch.hash)
        return;
    NSLog(@"1");
    touchHash = 0;
    [self endHighlightCell];
    NSLog(@"2");
    
    CGPoint location = [touch locationInView: [touch view]];
    if ([self isPointOnMap:location]) {
        NSLog(@"3");
        
        
        // ** -->>   SHOW  TOWER  EDITOR    <<-- ** //
        if (placeType == 0) {
            int temp_type = [_towerLayer tileGIDAt:lastTile];
            [self loadEditor:lastTile];
            return;
        }
        // ** -->>   SHOW  TOWER  EDITOR    <<-- ** //
        
        
        if ([self isOkayToPlace:location] != 0) {
            [_background removeTileAt:lastTile];
            NSLog(@"4");
            [self clickCell:lastTile];
            NSLog(@"5");
        }
        [_background removeTileAt:lastTile];
    }
}
/*
-(void)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    if(isTouching==TRUE) {
        //return;
        NSLog(@"No. Just no");
    }
    // ** ** ** ** ** [[CCActionManager sharedManager] removeAllActions]; ** ** ** ** **
    
 
    
    isTouching=TRUE;
    CGSize winSize = [CCDirector sharedDirector].winSize;
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL: location];
    
    int OffsetX = (winSize.width/2)-(_tileMap.contentSize.width/2);
    int OffsetY = (winSize.height/2)-(_tileMap.contentSize.height/2);
    
    CGPoint gridLocation = CGPointMake((location.x-OffsetX)*[UIScreen mainScreen].scale, (location.y-OffsetY)*[UIScreen mainScreen].scale);
    
    NSString* curScoreTxt = [NSString stringWithFormat:@"+"];
    CCLabelTTF *curScore = [CCLabelTTF labelWithString:curScoreTxt fontName:@"Marker Felt" fontSize:24];
    curScore.color = ccc3(255,0,0);
    curScore.position = location;
    [self addChild:curScore z:20];
    
    if ([self isPointOnMap:location]) {
        CGPoint tile = [self tileCoordForPosition:gridLocation];
        lastTile = tile;
        //[_background removeTileAt:tile];
        //NSLog(@"%i", [_turrets tileGIDAt:tile]);
        //[_turrets setTileGID:4 at:tile];
        //[_turretTops setTileGID:5 at:tile];
        [_selectionLayer setTileGID:3 at:tile];
    }
    
    
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL: location];
    
    int OffsetX = (winSize.width/2)-(_tileMap.contentSize.width/2);
    int OffsetY = (winSize.height/2)-(_tileMap.contentSize.height/2);
    
    CGPoint gridLocation = CGPointMake((location.x-OffsetX)*[UIScreen mainScreen].scale, (location.y-OffsetY)*[UIScreen mainScreen].scale);
    if ([self isPointOnMap:location]) {
        CGPoint tile = [self tileCoordForPosition:gridLocation];
        if (lastTile.x!=-1) {
            if ((lastTile.x != tile.x) or (lastTile.y != tile.y)) {
                [_selectionLayer removeTileAt:lastTile];
                CGPoint newTile = [self tileCoordForPosition:gridLocation];
                lastTile = newTile;
                [_selectionLayer setTileGID:3 at:newTile];
            }
        }
    }
    
}


-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    if (isTouching==FALSE) return;
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL: location];
    isTouching=FALSE;
    if ([_selectionLayer tileGIDAt:lastTile] != 0) {
        [_selectionLayer removeTileAt:lastTile];
        if (![self isWallAtTileCoord:[self tileCoordForPosition:location]])
            [_towerLayer setTileGID:4 at:lastTile];
        int validPath = 1;
        for (Enemy *e in enemies) {
            if (![self isPathValidFrom:[self tileCoordForPosition:e.position] to:[self tileCoordForPosition:self.endPosition]]) {
                validPath = 0;
                break;
            }
        }
        if (![self isPathValidFrom:[self tileCoordForPosition:self.startPosition] to:[self tileCoordForPosition:self.endPosition]]) {
            validPath = 0;
        }
        if (([self tileCoordForPosition:location].x == 0) && ([self tileCoordForPosition:location].x == 7))
            validPath=0;
        if ([self isWallAtTileCoord:[self tileCoordForPosition:location]])
            validPath=0;
        if (validPath == 0) {
            [_towerLayer removeTileAt:lastTile];
        } else {
            Turret *turret = [Turret nodeWithTheGame:self at:[self positionForTileCoord:lastTile]];
            [turrets addObject:turret];
        }
        [self recalculatePaths];
        lastTile.x=-1;
        lastTile.y=-1;
    }
}
 */








/*
-(CGPoint)tileCoordForPosition:(CGPoint)position {
    int x = position.x / _tileMap.tileSize.width;
    int y = ((_tileMap.mapSize.height * _tileMap.tileSize.height) - position.y) / _tileMap.tileSize.height;
    return ccp(x,y);
}

- (CGPoint)positionForTileCoord:(CGPoint)tileCoord {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    int OffsetX = (winSize.width/2)-(_tileMap.contentSize.width/2);
    int OffsetY = (winSize.height/2)-(_tileMap.contentSize.height/2);
    
    int x = OffsetX+(tileCoord.x*_tileMap.tileSize.width);
    int y = OffsetY+(tileCoord.y*_tileMap.tileSize.height);
    //NSLog(@"x: %d, y: %d", x, y);
    return ccp (tileCoord.x, tileCoord.y);
}
*/



























//            ****        ****     ***********************     ****        ****            //
//            ****        ****     ***********************     ****        ****            //
//            ****        ****     *CORE  GAME  FUNCTIONS*     ****        ****            //
//            ****        ****     *CORE  GAME  FUNCTIONS*     ****        ****            //
//            ****        ****     *CORE  GAME  FUNCTIONS*     ****        ****            //
//            ****        ****     ***********************     ****        ****            //
//            ****        ****     ***********************     ****        ****            //





















// ** -->>   CORE  FUNCTIONS  (LEVEL 1)    <<-- ** //
-(int)translateTileToTowerType:(int)towerGID {
    if (towerGID == 4) return 01;
    if (towerGID == 5) return 02;
    if (towerGID == 7) return 03;
}
// ** -->>   CORE  FUNCTIONS  (LEVEL 1)    <<-- ** //





// ** -->>   CORE  FUNCTIONS  (LEVEL 2)    <<-- ** //
- (CGPoint)tileCoordForPosition:(CGPoint)position {
    int x = position.x / _tileMap.tileSize.width;
    int y = ((_tileMap.mapSize.height * _tileMap.tileSize.height) - position.y) / _tileMap.tileSize.height;
    return ccp(x, y);
}
- (CGPoint)positionForTileCoord:(CGPoint)tileCoord {
    int x = (tileCoord.x * _tileMap.tileSize.width) + _tileMap.tileSize.width/2;
    int y = (_tileMap.mapSize.height * _tileMap.tileSize.height) - (tileCoord.y * _tileMap.tileSize.height) - _tileMap.tileSize.height/2;
    return [self convertToNodeSpace:ccp(x,y)];
}
-(BOOL)isOkayToPlace:(CGPoint)location {
    if ([self isWallAtTileCoord:[self tileCoordForPosition:[self gridLocation:location]]])
        return 0;
    [_background setTileGID:2 at:lastTile];
    for (Enemy *e in enemies) {
        NSLog(@"0000000011111");
        NSLog(@"%f, %f", [self tileCoordForPosition:e.position].x, [self tileCoordForPosition:e.position].y);
        NSLog(@"%f, %f", [self tileCoordForPosition:self.endPosition].x, [self tileCoordForPosition:self.endPosition].y);
        if (![self isPathValidFrom:[self tileCoordForPosition:e.position] to:[self tileCoordForPosition:self.endPosition]]) {
            NSLog(@"No");
            return 0;
            //break;
        }
    }
    if (![self isPathValidFrom:[self tileCoordForPosition:self.startPosition] to:[self tileCoordForPosition:self.endPosition]]) {
        return 0;
    }
    if (([self tileCoordForPosition:[self gridLocation:location]].x == 0) && ([self tileCoordForPosition:[self gridLocation:location]].x == 7))
        return 0;
    return 1;
}
- (BOOL)isPointOnMap:(CGPoint)point {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    int OffsetX = (winSize.width/2)-(_tileMap.contentSize.width/2);
    int OffsetY = (winSize.height/2)-(_tileMap.contentSize.height/2);
    int lowerMapX = 0+OffsetX;
    int upperMapX = _tileMap.contentSize.width+OffsetX;
    int lowerMapY = 0+OffsetY;
    int upperMapY = _tileMap.contentSize.height+OffsetY;
    if ((point.x >= lowerMapX) && (point.x <= upperMapX) && (point.y >= lowerMapY) && (point.y <= upperMapY)) {
        return TRUE;
    } else {
        return FALSE;
    }
}
-(BOOL)isWallAtTileCoord:(CGPoint)tileCoord {
    if ([self isProp:@"Wall" atTileCoord:tileCoord forLayer:_towerLayer] == 1) { return 1;}
    if ([self isProp:@"Wall" atTileCoord:tileCoord forLayer:_background] == 1) { return 1;}
    return 0;
}
- (BOOL)isValidTileCoord:(CGPoint)tileCoord {
    if (tileCoord.x < 0 || tileCoord.y < 0 ||
        tileCoord.x >= _tileMap.mapSize.width ||
        tileCoord.y >= _tileMap.mapSize.height) {
        return FALSE;
    } else {
        return TRUE;
    }
}
-(BOOL)isProp:(NSString*)prop atTileCoord:(CGPoint)tileCoord forLayer:(CCTMXLayer *)layer {
    int gid = [layer tileGIDAt:tileCoord];
    NSDictionary * properties = [_tileMap propertiesForGID:gid];
    if (properties == nil) return NO;
    return [properties objectForKey:prop] != nil;
}

// ** -->>   CORE  FUNCTIONS  (LEVEL 2)    <<-- ** //





// ** -->>   CORE  FUNCTIONS  (LEVEL 3)    <<-- ** //
-(BOOL)circle:(CGPoint) circlePoint withRadius:(float) radius collisionWithCircle:(CGPoint) circlePointTwo collisionCircleRadius:(float) radiusTwo {
    float xdif = circlePoint.x - circlePointTwo.x;
    float ydif = circlePoint.y - circlePointTwo.y;
    float distance = sqrt(xdif*xdif+ydif*ydif);
    if(distance <= radius+radiusTwo)
        return YES;
    return NO;
}
-(BOOL) retina {
    return FALSE;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
        ([UIScreen mainScreen].scale == 2.0)) {
        return TRUE;
    } else {
        return FALSE;
    }
}
// ** -->>   CORE  FUNCTIONS  (LEVEL 3)    <<-- ** //



@end