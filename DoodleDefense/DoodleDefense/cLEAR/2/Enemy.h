#import "cocos2d.h"
#import <OpenAL/al.h>


// A class that represents a step of the computed path
@interface ShortestPathStep : NSObject
{
}

@property (nonatomic, assign) CGPoint position;
@property (nonatomic, assign) int gScore;
@property (nonatomic, assign) int hScore;
@property (nonatomic, assign) ShortestPathStep *parent;

- (id)initWithPosition:(CGPoint)pos;
- (int)fScore;

@end




@class HelloWorldLayer;

@interface Enemy : CCSprite {
    HelloWorldLayer * _layer;
    CCAnimation *_facingForwardAnimation;
    CCAnimation *_facingBackAnimation;
    CCAnimation *_facingLeftAnimation;
    CCAnimation *_facingRightAnimation;
    CCAnimation *_curAnimation;
    CCAnimate *_curAnimate;
    int _numBones;
    
    CGPoint position;
    int gScore;
    int hScore;
    ShortestPathStep *parent;
}

@property (readonly) int numBones;
- (id)initWithLayer:(HelloWorldLayer *)layer;
- (void)moveToward:(CGPoint)target;

-(void)doActivate;

@end
