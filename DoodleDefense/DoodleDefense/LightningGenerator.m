#import "LightningGenerator.h"
#import "Enemy.h"
#import "Lightning.h"




@implementation LightningGenerator

@synthesize mySprite, theGame;

+(id)nodeWithTheGame:(GameLayer*)_game at:(CGPoint)point {
    return [[self alloc] initWithTheGame:_game at:point];
}

-(id)initWithTheGame:(GameLayer *)_game  at:(CGPoint)point{
	if ((self=[super init])) {
        
		theGame = _game;
        cooldown = 0;
        attackRange = 205;
        damage = 5.0;
        fireRate = 1.0;
        
        mySprite = [CCSprite spriteWithFile:@"LightningGeneratorTurret.png"];
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

-(void)draw {
 ccDrawColor4B(70, 70, 70, 70);
 ccDrawCircle(mySprite.position, attackRange, 360, 30, false);
 [super draw];
}

-(void)update:(ccTime)dt {
    mySprite.rotation+=2;
    if (chosenEnemy){
        //We make it turn to target the enemy chosen
        //CGPoint normalized = ccpNormalize(ccp(chosenEnemy.position.x-self.position.x,chosenEnemy.position.y-self.position.y));
        //mySprite.rotation = CC_RADIANS_TO_DEGREES(atan2(normalized.y,-normalized.x));
        
        if(![theGame circle:self.position withRadius:attackRange collisionWithCircle:chosenEnemy.position collisionCircleRadius:1]) {
            [self lostSightOfEnemy];
        }
    } else {
        for(Enemy * enemy in theGame.enemies) {
            if([theGame circle:self.position withRadius:attackRange collisionWithCircle:enemy.position collisionCircleRadius:1]) {
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
    CGPoint normalized = ccpNormalize(ccp(chosenEnemy.position.x-self.position.x,chosenEnemy.position.y-self.position.y));
    CCParticleFire *flameParticles = [[CCParticleFire alloc]initWithTotalParticles:25];
    flameParticles.texture = [[CCTextureCache sharedTextureCache] addImage:@"blueOrb.png"];
    [flameParticles setPosition:self.position];
    [flameParticles setTotalParticles:25];
    //[flameParticles setStartColor:ccc4f(10, 10, 255, 255)];
    flameParticles.angle = 180-CC_RADIANS_TO_DEGREES(atan2(normalized.y,-normalized.x));
    flameParticles.position = self.position;
    flameParticles.autoRemoveOnFinish = YES;
    flameParticles.life=0.34;
    flameParticles.angleVar=50;
    [flameParticles setBlendFunc:(ccBlendFunc) { GL_ONE, GL_ONE_MINUS_CONSTANT_COLOR }];
    
    
    flameParticles.startSize = 40;
    flameParticles.startSizeVar = 0;
    flameParticles.endSize = 0;
    flameParticles.endSizeVar = 5;
    flameParticles.speed = 1200;
    flameParticles.emissionRate = 70;
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
