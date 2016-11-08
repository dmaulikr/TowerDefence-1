#import "Enemy.h"






// A class that represents a step of the computed path
@interface ShortestPathStep : NSObject
{
	CGPoint position;
	int gScore;
	int hScore;
	ShortestPathStep *parent;
}

@property (nonatomic, assign) CGPoint position;
@property (nonatomic, assign) int gScore;
@property (nonatomic, assign) int hScore;
@property (nonatomic, assign) ShortestPathStep *parent;

- (id)initWithPosition:(CGPoint)pos;
- (int)fScore;

@end

@implementation ShortestPathStep

@synthesize position;
@synthesize gScore;
@synthesize hScore;
@synthesize parent;

- (id)initWithPosition:(CGPoint)pos
{
	if ((self = [super init])) {
		position = pos;
		gScore = 0;
		hScore = 0;
		parent = nil;
	}
	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@  pos=[%.0f;%.0f]  g=%d  h=%d  f=%d", [super description], self.position.x, self.position.y, self.gScore, self.hScore, [self fScore]];
}

- (BOOL)isEqual:(ShortestPathStep *)other
{
	return CGPointEqualToPoint(self.position, other.position);
}

- (int)fScore
{
	return self.gScore + self.hScore;
}

@end


@interface Enemy ()
@property (nonatomic, retain) NSMutableArray *spOpenSteps;
@property (nonatomic, retain) NSMutableArray *spClosedSteps;
@property (nonatomic, retain) NSMutableArray *shortestPath;

- (void)popStepAndAnimate;
- (void)constructPathAndStartAnimationFromStep:(ShortestPathStep *)step;
- (void)insertInOpenSteps:(ShortestPathStep *)step;
- (int)computeHScoreFromCoord:(CGPoint)fromCoord toCoord:(CGPoint)toCoord;
- (int)costToMoveFromStep:(ShortestPathStep *)fromStep toAdjacentStep:(ShortestPathStep *)toStep;
@end












#define HEALTH_BAR_WIDTH 20
#define HEALTH_BAR_ORIGIN -10

@implementation Enemy

@synthesize spOpenSteps;
@synthesize spClosedSteps;
@synthesize shortestPath;

@synthesize mySprite, theGame;

+(id)nodeWithTheGame:(HelloWorldLayer*)_game {
    //NSLog(@"AAAAAA");
    return [[self alloc] initWithTheGame:_game];
}

-(id)initWithTheGame:(HelloWorldLayer *)_game {
    //NSLog(@"BBBBBB");
	if ((self=[super init])) {
        
        self.spOpenSteps = nil;
        self.spClosedSteps = nil;
        
		
		theGame = _game;
        maxHp = 40;
        currentHp = maxHp;
        
        active = NO;
        
        walkingSpeed = 2.5;
        
        mySprite = [CCSprite spriteWithFile:@"enemy.png"];
		[self addChild:mySprite];
        
        CGPoint pos = [theGame startPosition];
        myPosition = pos;
        
        attackedBy = [[NSMutableArray alloc] initWithCapacity:5];
        
        self.shortestPath = nil;
        
        [mySprite setPosition:pos];
		
        [theGame addChild:self];
        
        CGPoint i1 = [theGame tileCoordForPosition:ccp(250, 500)];
        NSLog(@"i1: %f, %f", i1.x, i1.y);
        CGPoint i2 = [theGame positionForTileCoord:i1];
        NSLog(@"i2: %f, %f", i2.x, i2.y);
        
        [self performSelector:@selector(doActivate) withObject:self afterDelay:3.0 ];
        
        [self scheduleUpdate];
        
	}
	
	return self;
}

-(void)doActivate
{
    //[self moveToward:[theGame endPosition]];
}


-(void)update:(ccTime)dt
{
    return;
    if(!active)return;
    /*
    if([theGame circle:myPosition withRadius:1 collisionWithCircle:destinationWaypoint.myPosition collisionCircleRadius:1])
    {
        if(destinationWaypoint.nextWaypoint)
        {
            destinationWaypoint = destinationWaypoint.nextWaypoint;
        }else
        {
            //Reached the end of the road. Damage the player
            [theGame getHpDamage];
            [self getRemoved];
        }
    }*/
    
    CGPoint targetPoint = theGame.endPosition;
    float movementSpeed = walkingSpeed;
    
    CGPoint normalized = ccpNormalize(ccp(targetPoint.x-myPosition.x,targetPoint.y-myPosition.y));
    mySprite.rotation = CC_RADIANS_TO_DEGREES(atan2(normalized.y,-normalized.x));
    
    myPosition = ccp(myPosition.x+normalized.x * movementSpeed,myPosition.y+normalized.y * movementSpeed);
    
    [mySprite setPosition:myPosition];
    
    
}



- (void)moveToward:(CGPoint)target
{
    // Get current tile coordinate and desired tile coord
    CGPoint fromTileCoord = [theGame tileCoordForPosition:self.position];
    CGPoint toTileCoord = [theGame tileCoordForPosition:target];
    
    //NSLog(@"X1 %f Y1 %f, X2 %f Y2 %f ||||, %f, %f", fromTileCoord.x, fromTileCoord.y, toTileCoord.x, toTileCoord.y, target.x, target.y);
    
    // Check that there is a path to compute ;-)
    if (CGPointEqualToPoint(fromTileCoord, toTileCoord)) {
        NSLog(@"You're already there! :P");
        return;
    }
    
    // Must check that the desired location is walkable
    // In our case it's really easy, because only wall are unwalkable
    if ([theGame isWallAtTileCoord:toTileCoord]) {
        //[[SimpleAudioEngine sharedEngine] playEffect:@"hitWall.wav"];
        return;
    }
    
    
    //BOOL pathFound = NO;
    self.spOpenSteps = [[[NSMutableArray alloc] init] autorelease];
    self.spClosedSteps = [[[NSMutableArray alloc] init] autorelease];
    
    // Start by adding the from position to the open list
    [self insertInOpenSteps:[[[ShortestPathStep alloc] initWithPosition:fromTileCoord] autorelease]];
    
    do {
        // Get the lowest F cost step
        // Because the list is ordered, the first step is always the one with the lowest F cost
        ShortestPathStep *currentStep = [self.spOpenSteps objectAtIndex:0];
        
        // Add the current step to the closed set
        [self.spClosedSteps addObject:currentStep];
        
        // Remove it from the open list
        // Note that if we wanted to first removing from the open list, care should be taken to the memory
        [self.spOpenSteps removeObjectAtIndex:0];
        
        // If the currentStep is the desired tile coordinate, we are done!
        if (CGPointEqualToPoint(currentStep.position, toTileCoord)) {
            
            [self constructPathAndStartAnimationFromStep:currentStep];
            ShortestPathStep *tmpStep = currentStep;
            do {
                tmpStep = tmpStep.parent; // Go backward
            } while (tmpStep != nil); // Until there is not more parent
            
            self.spOpenSteps = nil; // Set to nil to release unused memory
            self.spClosedSteps = nil; // Set to nil to release unused memory
            break;
        }
        
        // Get the adjacent tiles coord of the current step
        //NSLog(@"1");
        NSArray *adjSteps = [theGame walkableAdjacentTilesCoordForTileCoord:currentStep.position];
       // NSLog(@"2");
        for (NSValue *v in adjSteps) {
            ShortestPathStep *step = [[ShortestPathStep alloc] initWithPosition:[v CGPointValue]];
            
            // Check if the step isn't already in the closed set
            if ([self.spClosedSteps containsObject:step]) {
                [step release]; // Must releasing it to not leaking memory ;-)
                continue; // Ignore it
            }
            
            // Compute the cost from the current step to that step
            int moveCost = [self costToMoveFromStep:currentStep toAdjacentStep:step];
            
            // Check if the step is already in the open list
            NSUInteger index = [self.spOpenSteps indexOfObject:step];
            
            if (index == NSNotFound) { // Not on the open list, so add it
                
                // Set the current step as the parent
                step.parent = currentStep;
                
                // The G score is equal to the parent G score + the cost to move from the parent to it
                step.gScore = currentStep.gScore + moveCost;
                
                // Compute the H score which is the estimated movement cost to move from that step to the desired tile coordinate
                step.hScore = [self computeHScoreFromCoord:step.position toCoord:toTileCoord];
                
                // Adding it with the function which is preserving the list ordered by F score
                [self insertInOpenSteps:step];
                
                // Done, now release the step
                [step release];
            }
            else { // Already in the open list
                
                [step release]; // Release the freshly created one
                step = [self.spOpenSteps objectAtIndex:index]; // To retrieve the old one (which has its scores already computed ;-)
                
                // Check to see if the G score for that step is lower if we use the current step to get there
                if ((currentStep.gScore + moveCost) < step.gScore) {
                    
                    // The G score is equal to the parent G score + the cost to move from the parent to it
                    step.gScore = currentStep.gScore + moveCost;
                    
                    // Because the G Score has changed, the F score may have changed too
                    // So to keep the open list ordered we have to remove the step, and re-insert it with
                    // the insert function which is preserving the list ordered by F score
                    
                    // We have to retain it before removing it from the list
                    [step retain];
                    
                    // Now we can removing it from the list without be afraid that it can be released
                    [self.spOpenSteps removeObjectAtIndex:index];
                    
                    // Re-insert it with the function which is preserving the list ordered by F score
                    [self insertInOpenSteps:step];
                    
                    // Now we can release it because the oredered list retain it
                    [step release];
                }
            }
        }
        
    } while ([self.spOpenSteps count] > 0);
    
    if (self.shortestPath == nil) { // No path found
        //****//[[SimpleAudioEngine sharedEngine] playEffect:@"hitWall.wav"];
    }
    
}

// Insert a path step (ShortestPathStep) in the ordered open steps list (spOpenSteps)
- (void)insertInOpenSteps:(ShortestPathStep *)step
{
	int stepFScore = [step fScore]; // Compute only once the step F score's
	int count = [self.spOpenSteps count];
	int i = 0; // It will be the index at which we will insert the step
	for (; i < count; i++) {
		if (stepFScore <= [[self.spOpenSteps objectAtIndex:i] fScore]) { // if the step F score's is lower or equals to the step at index i
			// Then we found the index at which we have to insert the new step
			break;
		}
	}
	// Insert the new step at the good index to preserve the F score ordering
	[self.spOpenSteps insertObject:step atIndex:i];
}

// Compute the H score from a position to another (from the current position to the final desired position
- (int)computeHScoreFromCoord:(CGPoint)fromCoord toCoord:(CGPoint)toCoord
{
	// Here we use the Manhattan method, which calculates the total number of step moved horizontally and vertically to reach the
	// final desired step from the current step, ignoring any obstacles that may be in the way
	return abs(toCoord.x - fromCoord.x) + abs(toCoord.y - fromCoord.y);
}

// Compute the cost of moving from a step to an adjecent one
- (int)costToMoveFromStep:(ShortestPathStep *)fromStep toAdjacentStep:(ShortestPathStep *)toStep
{
	return ((fromStep.position.x != toStep.position.x) && (fromStep.position.y != toStep.position.y)) ? 14 : 10;
}

// Go backward from a step (the final one) to reconstruct the shortest computed path
- (void)constructPathAndStartAnimationFromStep:(ShortestPathStep *)step
{
	self.shortestPath = [NSMutableArray array];
    
	do {
		if (step.parent != nil) { // Don't add the last step which is the start position (remember we go backward, so the last one is the origin position ;-)
			[self.shortestPath insertObject:step atIndex:0]; // Always insert at index 0 to reverse the path
		}
		step = step.parent; // Go backward
	} while (step != nil); // Until there is no more parents
	
	// Call the popStepAndAnimate to initiate the animations
	[self popStepAndAnimate];
}

// Add new method
- (void)popStepAndAnimate
{
	// Check if there remains path steps to go through
	if ([self.shortestPath count] == 0) {
		self.shortestPath = nil;
		return;
	}
    
	// Get the next step to move to
	ShortestPathStep *s = [self.shortestPath objectAtIndex:0];
    
	// Prepare the action and the callback
	id moveAction = [CCMoveTo actionWithDuration:0.4 position:[theGame positionForTileCoord:s.position]];
	id moveCallback = [CCCallFunc actionWithTarget:self selector:@selector(popStepAndAnimate)]; // set the method itself as the callback
    
	// Remove the step
	[self.shortestPath removeObjectAtIndex:0];
    
	// Play actions
	[self runAction:[CCSequence actions:moveAction, moveCallback, nil]];
}


/*
-(void)getRemoved
{
    for(Tower * attacker in attackedBy)
    {
        [attacker targetKilled];
    }
    
    [self.parent removeChild:self cleanup:YES];
    [theGame.enemies removeObject:self];
    
    //Notify the game that we killed an enemy so we can check if we can send another wave
    [theGame enemyGotKilled];
}
*/
/*
-(void)getAttacked:(Tower *)attacker
{
    [attackedBy addObject:attacker];
}

-(void)gotLostSight:(Tower *)attacker
{
    [attackedBy removeObject:attacker];
}
*/
/*
-(void)getDamaged:(int)damage
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"laser_shoot.wav"];
    currentHp -=damage;
    if(currentHp <=0)
    {
        [theGame awardGold:200];
        [self getRemoved];
    }
}
*/
- (void)draw
{
    //NSLog(@"DDDDDD");
    ccDrawSolidRect(ccp(myPosition.x+HEALTH_BAR_ORIGIN, myPosition.y+16),
                    ccp(myPosition.x+HEALTH_BAR_ORIGIN+HEALTH_BAR_WIDTH, myPosition.y+14),
                    ccc4f(1.0, 0, 0, 1.0));
    
    ccDrawSolidRect(ccp(myPosition.x+HEALTH_BAR_ORIGIN, myPosition.y+16),
                    ccp(myPosition.x+HEALTH_BAR_ORIGIN + (float)(currentHp * HEALTH_BAR_WIDTH)/maxHp, myPosition.y+14),
                    ccc4f(0, 1.0, 0, 1.0));
}

- (void)dealloc
{
	[spOpenSteps release]; spOpenSteps = nil;
	[spClosedSteps release]; spClosedSteps = nil;
    [shortestPath release]; shortestPath = nil;
	[super dealloc];
}

@end