#import "Turret.h"
#import "Enemy.h"




@implementation Turret

@synthesize mySprite, theGame;

+(id)nodeWithTheGame:(GameLayer*)_game at:(CGPoint)point {
    return [[self alloc] initWithTheGame:_game at:point];
}

-(id)initWithTheGame:(GameLayer *)_game  at:(CGPoint)point{
	if ((self=[super init])) {
        
		theGame = _game;
        cooldown = 0;
        attackRange = 150;
        damage = 2.5;
        fireRate = 0.15;
        
        mySprite = [CCSprite spriteWithFile:@"MachineGunTurretWaiting.png"];
        [self setSize:170 :170];
		[self addChild:mySprite z:1000000000];

        self.position=point;
        
        [theGame.tileMap addChild:self];
        
        
        CCTexture2D *turretFlare = [[CCTextureCache sharedTextureCache] addImage:@"MachineGunTurretFlare.png"];
        
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

/*-(void)draw {
    ccDrawColor4B(70, 70, 70, 70);
    ccDrawCircle(mySprite.position, attackRange, 360, 30, false);
    [super draw];
}*/

-(void)update:(ccTime)dt {
    [mySprite setTexture:[[CCTextureCache sharedTextureCache] addImage:@"MachineGunTurretWaiting.png"]];
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
    int randomFromTo = ( (arc4random() % (3-1+1)) + 1 );
    if (randomFromTo == 1)      [mySprite setTexture:[[CCTextureCache sharedTextureCache] addImage:@"MachineGunTurretFlare_1.png"]];
    if (randomFromTo == 2)      [mySprite setTexture:[[CCTextureCache sharedTextureCache] addImage:@"MachineGunTurretFlare_2.png"]];
    if (randomFromTo == 3)      [mySprite setTexture:[[CCTextureCache sharedTextureCache] addImage:@"MachineGunTurretFlare_3.png"]];
    [self damageEnemy];
    [theGame removeChild:chosenEnemy cleanup:YES];
    
    
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
