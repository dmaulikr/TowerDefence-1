#import "FlameThrower.h"
#import "Enemy.h"




@implementation FlameThrower

@synthesize mySprite, theGame;

+(id)nodeWithTheGame:(GameLayer*)_game at:(CGPoint)point {
    return [[self alloc] initWithTheGame:_game at:point];
}

-(id)initWithTheGame:(GameLayer *)_game  at:(CGPoint)point{
	if ((self=[super init])) {
        
		theGame = _game;
        cooldown = 0;
        attackRange = 175;
        damage = 1.6;
        fireRate = 0.075;
        
        mySprite = [CCSprite spriteWithFile:@"FlameThrowerTurret.png"];
        [self setSize:170 :170];
		[self addChild:mySprite z:1000000000];
        
        self.position=point;
        
        [theGame.tileMap addChild:self];
        
        [self scheduleUpdate];
	}
	return self;
}

- (void) setSize : (int)newWidth : (int)newHeight {
    CGSize originalSize = [mySprite contentSize];
    float originalWidth = originalSize.width;
    float originalHeight = originalSize.height;
    float newScaleX = (float)(newWidth) / originalWidth;
    float newScaleY = (float)(newHeight) / originalHeight;
    [mySprite setScaleX:newScaleX];
    [mySprite setScaleY:newScaleY];
}
/*
-(void)draw {
    ccDrawColor4B(70, 70, 70, 70);
    ccDrawCircle(mySprite.position, attackRange, 360, 30, false);
    [super draw];
}
*/
-(void)update:(ccTime)dt {
    if (chosenEnemy){
        //We make it turn to target the enemy chosen
        CGPoint normalized = ccpNormalize(ccp(chosenEnemy.position.x-self.position.x,chosenEnemy.position.y-self.position.y));
        mySprite.rotation = CC_RADIANS_TO_DEGREES(atan2(normalized.y,-normalized.x));
        
        if(![theGame circle:self.position withRadius:attackRange collisionWithCircle:chosenEnemy.position collisionCircleRadius:1])
        {
            [self lostSightOfEnemy];
        }
    } else {
        for(Enemy * enemy in theGame.enemies)
        {
            if([theGame circle:self.position withRadius:attackRange collisionWithCircle:enemy.position collisionCircleRadius:1])
            {
                [self chosenEnemyForAttack:enemy];
                break;
            }
        }
    }
}

-(void)attackEnemy {
    [self schedule:@selector(shootWeapon) interval:fireRate];
}

-(void)chosenEnemyForAttack:(Enemy *)enemy {
    chosenEnemy = enemy;
    [self attackEnemy];
    [self shootWeapon];
    [enemy getAttacked:self];
}

-(void)shootWeapon {
    /*
     CCSprite * bullet = [CCSprite spriteWithFile:@"bullet.png"];
     CGSize originalSize = [bullet contentSize];
     float originalWidth = originalSize.width;
     float originalHeight = originalSize.height;
     float newScaleX = (float)(5) / originalWidth;
     float newScaleY = (float)(5) / originalHeight;
     [bullet setScaleX:newScaleX];
     [bullet setScaleY:newScaleY];
     [theGame addChild:bullet];
     [bullet setPosition:ccp(self.position.x-(theGame.tileMap.tileSize.width/2), self.position.y-(theGame.tileMap.tileSize.height/2))];
     */
    /*[bullet runAction:[CCSequence actions:[CCMoveTo actionWithDuration:0.1 position:chosenEnemy.position],[CCCallFunc actionWithTarget:self selector:@selector(damageEnemy)],[CCCallFuncN actionWithTarget:self selector:@selector(removeBullet:)], nil]];*/
    
    
    CCParticleFire* flameParticles = [[CCParticleFire alloc]initWithTotalParticles:25];
    flameParticles.texture = [[CCTextureCache sharedTextureCache] addImage:@"fire.png"];
    flameParticles.position = self.position;
    flameParticles.autoRemoveOnFinish = YES;
    flameParticles.life=0.34;
    flameParticles.angleVar=50;
    
    
    flameParticles.startSize = 40;
    flameParticles.startSizeVar = 0;
    flameParticles.endSize = 0;
    flameParticles.endSizeVar = 5;
    flameParticles.speed = 600;
    flameParticles.emissionRate = 70;
    flameParticles.angle = 180-mySprite.rotation;
    flameParticles.angleVar = 0;
    flameParticles.duration = 0.15f;
    flameParticles.posVar = ccp(7,7);
    [_parent addChild:flameParticles z:self.zOrder-1];
    
    
    [self damageEnemy];
    
    
}

-(void)removeBullet:(CCSprite *)bullet
{
    [bullet.parent removeChild:bullet cleanup:YES];
}

-(void)damageEnemy
{
    [chosenEnemy getDamaged:damage];
}

-(void)targetKilled
{
    if(chosenEnemy)
        chosenEnemy =nil;
    
    [self unschedule:@selector(shootWeapon)];
}

-(void)lostSightOfEnemy
{
    [chosenEnemy gotLostSight:self];
    if(chosenEnemy)
        chosenEnemy =nil;
    
    [self unschedule:@selector(shootWeapon)];
}


@end
