#import "Enemy.h"
#import "AStarPathFinder.h"


@implementation Enemy

@synthesize mySprite, theGame;

CCTexture2D* textureRight;
CCTexture2D* textureLeft;
CCTexture2D* textureDown;
CCTexture2D* textureUp;

+(id)nodeWithTheGame:(HelloWorldLayer*)_game {
    return [[self alloc] initWithTheGame:_game];
}

-(id)initWithTheGame:(HelloWorldLayer *)_game {
	if ((self=[super init])) {
        
		theGame = _game;
        maxHp = 40;
        currentHp = maxHp;
        
        active = NO;
        
        walkingSpeed = 0.5;
        
        
        
        
        
        
        mySprite = [CCSprite spriteWithFile:@"v1.png"];
        [self setSize:33 :33];
		[self addChild:mySprite];
        
        lastX=theGame.startPosition.x;
        lastY=theGame.startPosition.y;
        mySprite.position=theGame.startPosition;
        
        [theGame.tileMap addChild:self];
        
        CGPoint StartPoint = [theGame tileCoordForPosition:theGame.startPosition];
        CGPoint EndPoint = [theGame tileCoordForPosition:theGame.endPosition];
        
        // Initialize the A* pathfinder.
        AStarPathFinder *pathFinder = [[AStarPathFinder alloc]
                      initWithTileMap:theGame.tileMap groundLayer:@"Background"];
        [pathFinder addCollideLayer:@"Towers"];
        [pathFinder setCollideKey:@"Wall"];
        
        [pathFinder setConsiderDiagonalMovement:NO];
        [pathFinder highlightPathFrom:StartPoint to:EndPoint];
        [pathFinder moveSprite:mySprite from:StartPoint to:EndPoint atSpeed:1.0f];
        
        
        [self schedule:@selector(nextFrame:)];
        
        textureRight = [[CCTextureCache sharedTextureCache] addImage:@"v1.png"];
        textureLeft = [[CCTextureCache sharedTextureCache] addImage:@"v2.png"];
        textureDown = [[CCTextureCache sharedTextureCache] addImage:@"v3.png"];
        textureUp = [[CCTextureCache sharedTextureCache] addImage:@"v4.png"];
        
        
	}
    
	return self;
}

-(void)doActivate
{
    active = YES;
    NSLog(@"TEST");
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
    //update seekers position at +100 pixels per second
    int currentX=mySprite.position.x;
    int currentY=mySprite.position.y;
    
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
    return;
}
@end