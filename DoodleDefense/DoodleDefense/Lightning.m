#import "Lightning.h"
#import "CCVertex.h"

@implementation Lightning
{
    ccV2F_T2F *lightningVertices_;
    GLuint lightningVAOName_;
    GLuint lightningBuffersVBO_;
    unsigned int lightningBuffersCapacity_;
    CGPoint *pointVertices_;
    NSUInteger noOfPoints_;
    NSUInteger noOfInitialPoints_;
    
    NSUInteger seed_;
    
    GLuint colorLocation_;
    ccColor3B color_;
    ccColor3B colorUnmodified_;
    GLubyte opacity_;
    CCTexture2D *lightningTexture_;
    ccBlendFunc blendFunc_;
    BOOL opacityModifyRGB_;
    BOOL wasCapacityIncreased_;
    
    Lightning *splitLightning_;
    ccTime duration_;
    ccTime fadeDuration_;
}

@synthesize strikeSource = strikeSource_;
@synthesize strikeSplitDestination = strikeSplitDestination_;
@synthesize strikeDestination = strikeDestination_;
@synthesize displacement = displacement_;
@synthesize minDisplacement = minDisplacement_;
@synthesize lightningWidth = lightningWidth_;
@synthesize split = split_;
@synthesize fadeDuration = fadeDuration_;
@synthesize duration = duration_;

+ (id) lightningWithStrikePoint:(CGPoint)source strikePoint2:(CGPoint)destination duration:(ccTime)duration fadeDuration:(ccTime)fadeDuration textureName:(NSString *)texturename
{
    CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:texturename];
    return [[self alloc] initWithStrikePoint:source strikePoint2:destination duration:duration fadeDuration:fadeDuration texture:texture];
}

+ (id) lightningWithStrikePoint:(CGPoint)source strikePoint2:(CGPoint)destination duration:(ccTime)duration fadeDuration:(ccTime)fadeDuration texture:(CCTexture2D *)texture
{
    return [[self alloc] initWithStrikePoint:source strikePoint2:destination duration:duration fadeDuration:fadeDuration texture:texture];
}

- (id) initWithStrikePoint:(CGPoint)source strikePoint2:(CGPoint)destination duration:(ccTime)duration fadeDuration:(ccTime)fadeDuration textureName:(NSString *)texturename
{
    CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage:texturename];
    return [self initWithStrikePoint:source strikePoint2:destination duration:duration fadeDuration:fadeDuration texture:texture];
}

- (id) initWithStrikePoint:(CGPoint)source strikePoint2:(CGPoint)destination duration:(ccTime)duration fadeDuration:(ccTime)fadeDuration texture:(CCTexture2D *)texture
{
    if (self = [super init])
    {
        color_ = colorUnmodified_ = ccWHITE;
        opacity_ = 255;
        blendFunc_ = (ccBlendFunc) {CC_BLEND_SRC, CC_BLEND_DST};
        _shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionTexture_uColor];
        colorLocation_ = glGetUniformLocation( _shaderProgram->_program, "u_color");
        lightningTexture_ = texture;
        opacityModifyRGB_ = NO;
        
        strikeSource_ = source;
        strikeSplitDestination_ = CGPointZero;
        strikeDestination_ = destination;
        
        duration_ = duration;
        fadeDuration_ = fadeDuration;
        
        split_ = NO;
        
        displacement_ = 120;
        minDisplacement_ = 4;
        lightningWidth_ = 1.0f;
        
        [self ensureCapacity:16];
        
        glGenVertexArrays(1, &lightningVAOName_);
        ccGLBindVAO(lightningVAOName_);
        
        glGenBuffers(1, &lightningBuffersVBO_);
        glBindBuffer(GL_ARRAY_BUFFER, lightningBuffersVBO_);
        glBufferData(GL_ARRAY_BUFFER, sizeof(ccV2F_T2F) * lightningBuffersCapacity_, lightningVertices_, GL_DYNAMIC_DRAW);
        
        glEnableVertexAttribArray(kCCVertexAttrib_Position);
        glVertexAttribPointer( kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, sizeof(ccV2F_T2F), (GLvoid *)offsetof(ccV2F_T2F, vertices) );
        
        glEnableVertexAttribArray(kCCVertexAttrib_TexCoords);
        glVertexAttribPointer( kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, sizeof(ccV2F_T2F), (GLvoid *)offsetof(ccV2F_T2F, texCoords) );
        
        ccGLBindVAO(0);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        CHECK_GL_ERROR();
        wasCapacityIncreased_ = NO;
    }
    
    return self;
}

- (BOOL) ensureCapacity:(NSUInteger)count
{
    if ( count > lightningBuffersCapacity_)
    {
        lightningBuffersCapacity_ = MAX(lightningBuffersCapacity_, count);
        lightningVertices_ = (ccV2F_T2F *)realloc( lightningVertices_, lightningBuffersCapacity_ * sizeof(ccV2F_T2F) );
        pointVertices_ = (CGPoint *)realloc( pointVertices_, lightningBuffersCapacity_ * 0.5f * sizeof(CGPoint) );
        return YES;
    }
    
    return NO;
}

- (void) draw
{
    CC_NODE_DRAW_SETUP();
    ccGLBlendFunc( blendFunc_.src, blendFunc_.dst );
    ccColor4F floatColor = ccc4FFromccc3B(color_);
    floatColor.a = opacity_ / 255.0f;
    [_shaderProgram setUniformLocation:colorLocation_ withF1:floatColor.r f2:floatColor.g f3:floatColor.b f4:floatColor.a];
    ccGLBindTexture2D( [lightningTexture_ name] );
    
    ccGLBindVAO( lightningVAOName_ );
    glDrawArrays(GL_TRIANGLE_STRIP, 0, (GLsizei)noOfPoints_ * 2);
    CC_INCREMENT_GL_DRAWS(1);
}

- (void) strikeRandom
{
    seed_ = rand();
    [self strike];
}

- (void) strikeWithSeed:(NSInteger)seed
{
    seed_ = seed;
    [self strike];
}

- (void) setInitialPoints:(CGPoint *)initialPoints noOfInitialPoints:(NSUInteger)noOfInitialPoints
{
    noOfInitialPoints_ = noOfInitialPoints;
    wasCapacityIncreased_ = [self ensureCapacity:noOfInitialPoints * 2];
    for (NSUInteger i = 0; i < noOfInitialPoints_; i++)
    {
        pointVertices_ = initialPoints;
    }
}

- (void) strike
{
    self.visible = NO;
    if (opacityModifyRGB_)
    {
        [self runAction:[CCSequence actions:
                         [CCShow action],
                         [CCDelayTime actionWithDuration:duration_],
                         [CCFadeTo actionWithDuration:fadeDuration_ opacity:0],
                         nil]];
    }
    else
    {
        CCTintTo *tintTo = [CCTintTo actionWithDuration:fadeDuration_ red:0 green:0 blue:0];
        CCFadeTo *fadeTo = [CCFadeTo actionWithDuration:fadeDuration_ opacity:0];
        CCSpawn *fadeAction = [CCSpawn actionOne:tintTo two:fadeTo];
        [self runAction:[CCSequence actions:
                         [CCShow action],
                         [CCDelayTime actionWithDuration:duration_],
                         fadeAction,
                         nil]];
    }
    
    srand(seed_);
    NSInteger noOfLines = [self computeNumberOfLines:strikeSource_ pt2:strikeDestination_ displace:displacement_ minDisplace:minDisplacement_];
    noOfPoints_ = noOfInitialPoints_ + noOfLines + 1;
    wasCapacityIncreased_ = [self ensureCapacity:noOfPoints_ * 2] || wasCapacityIncreased_;
    noOfPoints_ = noOfInitialPoints_;
    srand(seed_);
    CGPoint mid = [self addLightning:strikeSource_ pt2:strikeDestination_ displace:displacement_ minDisplace:minDisplacement_];
    ccVertexTexLineToPolygon(*(pointVertices_), lightningWidth_, lightningVertices_, 0, noOfPoints_);
    float texDelta = 1.0f / noOfPoints_;
    for (NSUInteger i = 0; i < noOfPoints_; i++ )
    {
        lightningVertices_->texCoords = (ccTex2F) {0, texDelta * i};
        lightningVertices_->texCoords = (ccTex2F) {1, texDelta * i};
    }
    
    glBindBuffer(GL_ARRAY_BUFFER, lightningBuffersVBO_ );
    if (wasCapacityIncreased_)
    {
        glBufferData(GL_ARRAY_BUFFER, sizeof(ccV2F_T2F) * noOfPoints_ * 2, lightningVertices_, GL_DYNAMIC_DRAW);
    }
    else
    {
        glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(ccV2F_T2F) * noOfPoints_ * 2, lightningVertices_);
    }
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    if (split_)
    {
        if (splitLightning_ == 0)
        {
            splitLightning_ = [[Lightning alloc] initWithStrikePoint:mid strikePoint2:strikeSplitDestination_ duration:duration_ fadeDuration:fadeDuration_ texture:lightningTexture_];
            [self addChild:splitLightning_ z:-1];
        }
        
        splitLightning_.strikeSource = mid;
        splitLightning_.strikeDestination = strikeSplitDestination_;
        splitLightning_.minDisplacement = minDisplacement_;
        splitLightning_.displacement = displacement_ * 0.5f;
        splitLightning_.lightningWidth = lightningWidth_;
        splitLightning_.color = color_;
        splitLightning_.opacity = opacity_;
        splitLightning_.duration = duration_;
        splitLightning_.fadeDuration = fadeDuration_;
        [splitLightning_ setOpacityModifyRGB:opacityModifyRGB_];
        [splitLightning_ setInitialPoints:pointVertices_ noOfInitialPoints:noOfPoints_ * 0.5f + 1];
        [splitLightning_ strikeWithSeed:seed_];
    }
    
    wasCapacityIncreased_ = NO;
}

- (CGPoint) addLightning:(CGPoint)pt1 pt2:(CGPoint)pt2 displace:(NSInteger)displace minDisplace:(NSInteger)minDisplace
{
    CGPoint mid = ccpMult(ccpAdd(pt1,pt2), 0.5f);
    
    if (displace < minDisplace)
    {
        if (noOfPoints_ == 0)
        {
            pointVertices_[0] = pt1;
            noOfPoints_++;
        }
        
        pointVertices_[noOfPoints_] = pt2;
        noOfPoints_++;
    }
    else
    {
        mid.x += ( (rand() % 101) / 100.0f - 0.5f ) * displace;
        mid.y += ( (rand() % 101) / 100.0f - 0.5f ) * displace;
        
        [self addLightning:pt1 pt2:mid displace:displace * 0.5f minDisplace:minDisplace];
        [self addLightning:mid pt2:pt2 displace:displace * 0.5f minDisplace:minDisplace];
    }
    
    return mid;
}

- (NSUInteger) computeNumberOfLines:(CGPoint)pt1 pt2:(CGPoint)pt2 displace:(NSInteger)displace minDisplace:(NSInteger)minDisplace
{
    CGPoint mid = ccpMult(ccpAdd(pt1,pt2), 0.5f);
    
    if (displace < minDisplace)
    {
        return 1;
    }
    
    mid.x += ( (rand() % 101) / 100.0f - 0.5f ) * displace;
    mid.y += ( (rand() % 101) / 100.0f - 0.5f ) * displace;
    
    return
    [self computeNumberOfLines:pt1 pt2:mid displace:displace * 0.5f minDisplace:minDisplace] +
    [self computeNumberOfLines:mid pt2:pt2 displace:displace * 0.5f minDisplace:minDisplace];
}

- (void) updateBlendFunc
{
    if ( !lightningTexture_ || ![lightningTexture_ hasPremultipliedAlpha] )
    {
        blendFunc_.src = GL_SRC_ALPHA;
        blendFunc_.dst = GL_ONE_MINUS_SRC_ALPHA;
        [self setOpacityModifyRGB:NO];
    }
    else
    {
        blendFunc_.src = CC_BLEND_SRC;
        blendFunc_.dst = CC_BLEND_DST;
    }
}

- (void) setTexture:(CCTexture2D *)texture
{
    if ( lightningTexture_ != texture )
    {
        [self updateBlendFunc];
    }
}

- (CCTexture2D *) texture
{
    return lightningTexture_;
}

- (GLubyte) opacity
{
    return opacity_;
}

- (void) setOpacity:(GLubyte)anOpacity
{
    opacity_ = anOpacity;
    
    // special opacity for premultiplied textures
    if ( opacityModifyRGB_ )
    {
        [self setColor:colorUnmodified_];
    }
}

- (ccColor3B) color
{
    if (opacityModifyRGB_)
    {
        return colorUnmodified_;
    }
    
    return color_;
}

- (void) setColor:(ccColor3B)color3
{
    color_ = colorUnmodified_ = color3;
    
    if ( opacityModifyRGB_ )
    {
        color_.r = color3.r * opacity_ / 255.0f;
        color_.g = color3.g * opacity_ / 255.0f;
        color_.b = color3.b * opacity_ / 255.0f;
    }
}

- (void) setOpacityModifyRGB:(BOOL)modify
{
    ccColor3B oldColor = self.color;
    opacityModifyRGB_ = modify;
    self.color = oldColor;
}

- (BOOL) doesOpacityModifyRGB
{
    return opacityModifyRGB_;
}

- (void) dealloc
{
    free(lightningVertices_);
    free(pointVertices_);
    glDeleteBuffers(0, &lightningBuffersVBO_);
    glDeleteBuffers(0, &lightningVAOName_);
}

@end