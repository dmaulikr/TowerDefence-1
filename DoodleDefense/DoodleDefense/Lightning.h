#import "cocos2d.h"

@interface Lightning : CCNode<CCRGBAProtocol, CCTextureProtocol>

@property (nonatomic, readwrite) CGPoint strikeSource;
@property (nonatomic, readwrite) CGPoint strikeSplitDestination;
@property (nonatomic, readwrite) CGPoint strikeDestination;
@property (nonatomic, readwrite) ccColor3B color;
@property (nonatomic, readwrite) GLubyte opacity;
@property (nonatomic, readwrite) BOOL split;
@property (nonatomic, readwrite) NSInteger displacement;
@property (nonatomic, readwrite) NSInteger minDisplacement;
@property (nonatomic, readwrite) float lightningWidth;
@property (nonatomic, readwrite) ccTime fadeDuration;
@property (nonatomic, readwrite) ccTime duration;
@property (nonatomic, readwrite) ccBlendFunc blendFunc;

+ (id) lightningWithStrikePoint:(CGPoint)source strikePoint2:(CGPoint)destination duration:(ccTime)duration fadeDuration:(ccTime)fadeDuration textureName:(NSString*)texturename;
+ (id) lightningWithStrikePoint:(CGPoint)source strikePoint2:(CGPoint)destination duration:(ccTime)duration fadeDuration:(ccTime)fadeDuration texture:(CCTexture2D*)texture;
- (id) initWithStrikePoint:(CGPoint)source strikePoint2:(CGPoint)destination duration:(ccTime)duration fadeDuration:(ccTime)fadeDuration textureName:(NSString*)texturename;
- (id) initWithStrikePoint:(CGPoint)source strikePoint2:(CGPoint)destination duration:(ccTime)duration fadeDuration:(ccTime)fadeDuration texture:(CCTexture2D*)texture;

- (void) strikeRandom;
- (void) strikeWithSeed:(NSInteger)seed;
- (void) strike;
- (void) setInitialPoints:(CGPoint *)initialPoints noOfInitialPoints:(NSUInteger)noOfInitialPoints;
- (void) setOpacityModifyRGB:(BOOL)modify;
@end