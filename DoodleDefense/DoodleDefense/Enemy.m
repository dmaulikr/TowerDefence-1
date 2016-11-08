#import "Enemy.h"
#import "Turret.h"

#define HEALTH_BAR_WIDTH 20
#define HEALTH_BAR_ORIGIN -10

@implementation Enemy

@synthesize mySprite, theGame;

CCTexture2D* textureRight;
CCTexture2D* textureLeft;
CCTexture2D* textureDown;
CCTexture2D* textureUp;

+(id)nodeWithTheGame:(GameLayer*)_game {
    return [[self alloc] initWithTheGame:_game];
}

-(id)initWithTheGame:(GameLayer *)_game {
	if ((self=[super init])) {
        
		theGame = _game;
        maxHp = 30;
        currentHp = maxHp;
        
        active = NO;
        
        walkingSpeed = 0.5;
        
        
        
        
        
        attackedBy = [[NSMutableArray alloc] initWithCapacity:500];
        
        
        mySprite = [CCSprite spriteWithFile:@"v1.png"];
        [self setSize:33 :33];
		[self addChild:mySprite];
        
        lastX=theGame.startPosition.x;
        lastY=theGame.startPosition.y;
        self.position=theGame.startPosition;
        
        [theGame.tileMap addChild:self];
        
        
        
        
        // ** clear previous paths *** [[CCActionManager sharedManager] removeAllActionsFromTarget:mySprite];
        
                
        textureRight = [[CCTextureCache sharedTextureCache] addImage:@"v1.png"];
        textureLeft = [[CCTextureCache sharedTextureCache] addImage:@"v2.png"];
        textureDown = [[CCTextureCache sharedTextureCache] addImage:@"v3.png"];
        textureUp = [[CCTextureCache sharedTextureCache] addImage:@"v4.png"];
	}
	return self;
}

-(void)poked {
    //[[CCActionManager sharedManager] removeAllActions];
}

-(void)doActivate {
    active = YES;
    [self schedule:@selector(nextFrame:)];

}

-(void)updatePath {
    //[[AStarPathFinder alloc] cleanPath];
    //[mySprite stopAllActions];
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


-(void) nextFrame: (ccTime)dt {
    [self updatePath];
    //update seekers position at +100 pixels per second
    int currentX=self.position.x;
    int currentY=self.position.y;
    
    int lastX2=lastX;
    int lastY2=lastY;
    
    lastX=currentX;
    lastY=currentY;
    
    if (currentX>lastX2) {
        [mySprite setTexture: textureRight];
        return;
    }
    if (currentX<lastX2) {
        [mySprite setTexture: textureLeft];
        return;
    }
    if (currentY<lastY2) {
        [mySprite setTexture: textureDown];
        return;
    }
    if (currentY>lastY2) {
        [mySprite setTexture: textureUp];
        return;
    }
    if (ccpDistance(ccp(currentX, currentY), theGame.endPosition) < 30) {
        [theGame enemyReached:self];
        [self getRemoved];
    }
    return;
}


- (void)draw
{
    ccDrawSolidRect(ccp(myPosition.x+HEALTH_BAR_ORIGIN, myPosition.y+20),
                    ccp(myPosition.x+HEALTH_BAR_ORIGIN+HEALTH_BAR_WIDTH, myPosition.y+18),
                    ccc4f(1.0, 0, 0, 1.0));
    
    ccDrawSolidRect(ccp(myPosition.x+HEALTH_BAR_ORIGIN, myPosition.y+20),
                    ccp(myPosition.x+HEALTH_BAR_ORIGIN + (float)(currentHp * HEALTH_BAR_WIDTH)/maxHp, myPosition.y+18),
                    ccc4f(0, 1.0, 0, 1.0));
}

-(void)getRemoved
{
    for(Turret* attacker in attackedBy)
    {
        [attacker targetKilled];
    }
    
    [self.parent removeChild:self cleanup:YES];
    [theGame.enemies removeObject:self];
    [self removeAllChildren];
    
    //Notify the game that we killed an enemy so we can check if we can send another wave
    [theGame enemyGotKilled];
}

-(void)getAttacked:(Turret *)attacker
{
    [attackedBy addObject:attacker];
}

-(void)gotLostSight:(Turret *)attacker
{
    [attackedBy removeObject:attacker];
}

-(void)getDamaged:(int)damage
{
    currentHp -=damage;
    if(currentHp <=0)
    {
        //[theGame awardGold:200];
        [theGame enemyDestroyed:self];
        [self getRemoved];
    }
}

@end