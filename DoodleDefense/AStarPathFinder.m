#import "AStarPathFinder.h"

@implementation AStarPathFinder

@synthesize color = _color;
@synthesize direction = _direction;
@synthesize delegate = _delegate;

static const NSInteger adjacentTilesCount = 8;
static const NSInteger adjacentTiles[8][2] = {{-1, 1}, {0, 1}, {1, 1}, {-1, 0}, {1, 0}, {-1, -1}, {0, -1}, {1, -1}};

- (AStarNode *)lowCostNode
{
	AStarNode *lowCostNode = [_openNodes anyObject];
	for (AStarNode *otherNode in _openNodes)
	{
		if ([otherNode cost] < [lowCostNode cost])
		{
			lowCostNode = otherNode;
		}
		else if ([otherNode cost] == [lowCostNode cost])
		{
			if (otherNode->h < lowCostNode->h)
				lowCostNode = otherNode;
		}
	}
	return lowCostNode;
}

- (AStarNode *)findPathFrom:(CGPoint)from to:(CGPoint)to display:(BOOL)display
{
	[_openNodes removeAllObjects];
	[_closedNodes removeAllObjects];

	if ([_delegate AStarBlockedIgnore:to])
	{
		return nil;
	}

	AStarNode *origin = [AStarNode nodeAtPoint:from];
	origin->parent = nil;
	[_openNodes addObject:origin];

	AStarNode *closestNode;
	while ([_openNodes count])
	{
		closestNode = [self lowCostNode];
		if (closestNode->point.x == to.x && closestNode->point.y == to.y)
		{
			return closestNode;
		}
		else
		{
			[_openNodes removeObject:closestNode];
			[_closedNodes addObject:closestNode];

			for (int i = 0; i < adjacentTilesCount; i++)
			{
				int x = adjacentTiles[i][0];
				int y = adjacentTiles[i][1];

				AStarNode *adjacentNode = [AStarNode nodeAtPoint:ccp(x + closestNode->point.x, y + closestNode->point.y)];
				adjacentNode->parent = closestNode;

				if ([_closedNodes containsObject:adjacentNode])
					continue;

				if (CGPointEqualToPoint(adjacentNode->point, to))
				{
					if ([_delegate AStarBlockedIgnore:adjacentNode->point])
					{
						[_closedNodes addObject:adjacentNode];
						continue;
					}
				}
				else
				{
					if ([_delegate AStarBlocked:adjacentNode->point])
					{
						[_closedNodes addObject:adjacentNode];
						continue;
					}
				}

				if (abs(x) == 1 && abs(y) == 1)
				{
					adjacentNode->g = 14 + closestNode->g;
				}
				else
				{
					adjacentNode->g = 10 + closestNode->g;
				}
				adjacentNode->h = (int) (ABS(adjacentNode->point.x - to.x) + ABS(adjacentNode->point.y - to.y)) * 10;

				BOOL redraw = YES;

				if ([_openNodes containsObject:adjacentNode])
				{
					redraw = NO;

					AStarNode *otherNode = [_openNodes member:adjacentNode];
					long newCost = otherNode->g - otherNode->parent->g + closestNode->g;
					if (newCost < otherNode->g)
					{
						otherNode->g = adjacentNode->g;
						otherNode->parent = closestNode;
						redraw = YES;
					}
				}
				else
				{
					[_openNodes addObject:adjacentNode];
				}

				//todo: refactor->method
				//todo: undraw text first if exists?
				if (display && redraw)
				{
					CGPoint p0 = [_delegate AStarPositionAt:adjacentNode->point];

					CCSprite *arrow;
					if (x > 0 && y > 0) arrow = [CCSprite spriteWithSpriteFrameName:@"arrow3"]; // nw
					else if (x < 0 && y < 0) arrow = [CCSprite spriteWithSpriteFrameName:@"arrow7"]; // se
					else if (x > 0 && y < 0) arrow = [CCSprite spriteWithSpriteFrameName:@"arrow1"]; // sw
					else if (x < 0 && adjacentTiles[i][1] > 0) arrow = [CCSprite spriteWithSpriteFrameName:@"arrow5"]; // ne
					else if (x > 0) arrow = [CCSprite spriteWithSpriteFrameName:@"arrow2"]; // w
					else if (x < 0) arrow = [CCSprite spriteWithSpriteFrameName:@"arrow6"]; // e
					else if (y > 0) arrow = [CCSprite spriteWithSpriteFrameName:@"arrow4"]; // n
					else arrow = [CCSprite spriteWithSpriteFrameName:@"arrow0"]; // s

					arrow.position = ccp(p0.x + _width / 2, p0.y + _height / 2);
					arrow.anchorPoint = ccp(0.5f, 0.5f);
					arrow.color = colorYellow;
					[self addChild:arrow];

					NSString *gstring = [NSString stringWithFormat:@"%d", adjacentNode->g];
					NSString *hstring = [NSString stringWithFormat:@"%d", adjacentNode->h];
					NSString *coststring = [NSString stringWithFormat:@"%d", adjacentNode.cost];

					CCLabelBMFont *dcost = [CCLabelBMFont labelWithString:gstring fntFile:pixelFont];
					dcost.color = colorDekoBlueDark;
					dcost.position = ccp(p0.x, p0.y);
					dcost.anchorPoint = ccp(0.0f, 0.0f);
					dcost.scale = 0.5f;
					[self addChild:dcost];

					CCLabelBMFont *hcost = [CCLabelBMFont labelWithString:hstring fntFile:pixelFont];
					hcost.color = colorDekoRedDark;
					hcost.position = ccp(p0.x + _height, p0.y);
					hcost.anchorPoint = ccp(1.0f, 0.0f);
					hcost.scale = 0.5f;
					[self addChild:hcost];

					CCLabelBMFont *cost = [CCLabelBMFont labelWithString:coststring fntFile:pixelFont];
					cost.color = colorDekoGreenDark;
					cost.position = ccp(p0.x + _width, p0.y + _height);
					cost.anchorPoint = ccp(1.0f, 1.0f);
					cost.scale = 0.5f;
					[self addChild:cost];
				}
			}
		}
	}
	[self removeAllChildrenWithCleanup:YES];
	return nil;
}

- (AStarNode *)findPathFrom:(CGPoint)from to:(CGPoint)to
{
	return [self findPathFrom:from to:to display:NO];
}

- (NSArray *)getPath:(CGPoint)from to:(CGPoint)to display:(BOOL)display
{
	NSMutableArray *nodes = [NSMutableArray array];
	AStarNode *node = [self findPathFrom:from to:to display:display];
	if (node == nil)
		return nodes;
	while (node != nil)
	{
		[nodes addObject:node];
		node = node->parent;
	}
	return [[nodes reverseObjectEnumerator] allObjects];
}

- (NSArray *)getPath:(CGPoint)from to:(CGPoint)to
{
	return [self getPath:from to:to display:NO];
}

- (void)clearHighlightPath
{
	[self removeAllChildrenWithCleanup:YES];
}

- (BOOL)highlightPathFrom:(CGPoint)from to:(CGPoint)to display:(BOOL)display
{
	[self clearHighlightPath];

	CGFloat tileWidthOffset = PixelsToPointsF(_width) / 2;
	CGFloat tileHeightOffset = PixelsToPointsF(_height) / 2;

	NSArray *nodes = [self getPath:from to:to display:display];
	if ([nodes count] == 0)
	{
		CGPoint p0 = [_delegate AStarPositionAt:from];
		p0.x = p0.x + tileWidthOffset;
		p0.y = p0.y + tileHeightOffset;

		CGPoint p1 = [_delegate AStarPositionAt:to];
		p1.x = p1.x + tileWidthOffset;
		p1.y = p1.y + tileHeightOffset;

		_direction = ccpSub(p0, p1);
		return NO;
	}

	if (!GameDefaults.blendPath)
	{
		GLubyte tempOpacity = 150;
		NSInteger tempOpacityStep = 100 / nodes.count;

		for (AStarNode *node in nodes)
		{
			CGPoint p1 = [_delegate AStarPositionAt:node->point];
			p1.x = p1.x + tileWidthOffset;
			p1.y = p1.y + tileHeightOffset;

			CCSprite *tileSprite = [CCSprite spriteWithCGImage:_image key:@"k"];
			tileSprite.position = p1;
			tileSprite.color = _color;
			tileSprite.opacity = tempOpacity;

			tileSprite.blendFunc = (ccBlendFunc) {GL_SRC_ALPHA, GL_ONE};
			[self addChild:tileSprite];

			tempOpacity -= tempOpacityStep;
		}
	}
	else
	{
		ccColor3B start = _color;// ccWHITE;
		ccColor3B end = ccBLACK;

//		if (ccc3BEqual(_color, colorDekoRedDark))
//		{
//			start = ccc3(249, 16, 69);
//			end = ccc3(184, 0, 87);
//		}
//		else if (ccc3BEqual(_color, colorDekoBlueDark))
//		{
//			start = ccc3(19, 130, 181);
//			end = ccc3(0, 72, 149);
//		}
//		else if (ccc3BEqual(_color, colorDekoYellowDark))
//		{
//			start = ccc3(255, 122, 0);
//			end = ccc3(0, 0, 0);
//		}
//		else if (ccc3BEqual(_color, colorDekoGreenDark))
//		{
//			start = ccc3(99, 134, 16);
//			end = ccc3(106, 100, 8);
//		}

		CGFloat tempOpacity = 0;
		CGFloat tempOpacityStep = 100 / nodes.count;
		tempOpacityStep = tempOpacityStep / 100;

		for (AStarNode *node in nodes)
		{
			CGPoint p1 = [_delegate AStarPositionAt:node->point];
			p1.x = p1.x + tileWidthOffset;
			p1.y = p1.y + tileHeightOffset;

			CCSprite *tileSprite = [CCSprite spriteWithCGImage:_image key:@"k"];
			tileSprite.position = p1;

			ccColor3B currentColor = gradientValue(start, end, tempOpacity);
			tileSprite.color = currentColor;

			tileSprite.blendFunc = (ccBlendFunc) {GL_ONE, GL_ONE_MINUS_SRC_COLOR};
			[self addChild:tileSprite];

			tempOpacity += tempOpacityStep;
		}
	}

	if (nodes.count > 1)
	{
		AStarNode *node0 = [nodes objectAtIndex:0];
		AStarNode *node1 = [nodes objectAtIndex:1];

		CGPoint p0 = [_delegate AStarPositionAt:node0->point];
		p0.x = p0.x + tileWidthOffset;
		p0.y = p0.y + tileHeightOffset;

		CGPoint p1 = [_delegate AStarPositionAt:node1->point];
		p1.x = p1.x + tileWidthOffset;
		p1.y = p1.y + tileHeightOffset;

		_direction = ccpSub(p0, p1);
	}
	
	return YES;
}

- (BOOL)highlightPathFrom:(CGPoint)from to:(CGPoint)to
{
	return [self highlightPathFrom:from to:to display:NO];
}

- (BOOL)stepNode:(CCNode *)node from:(CGPoint)from to:(CGPoint)to use:(BOOL)use
{
	if (!CGPointEqualToPoint(from, to))	_direction = ccpSub(from, to);
	BOOL arrived = NO;
	NSArray *nodes = [self getPath:from to:to];
	if (nodes.count <= 2)
	{
		arrived = YES;
	}
	if (nodes.count > 1)
	{
		BOOL move = YES;
		if (use && arrived) move = NO;
		if (move)
		{
			CGFloat tileWidthOffset = PixelsToPointsF(_width) / 2;
			CGFloat tileHeightOffset = PixelsToPointsF(_height) / 2;

			AStarNode *node0 = [nodes objectAtIndex:0];
			AStarNode *node1 = [nodes objectAtIndex:1];

			CGPoint p0 = [_delegate AStarPositionAt:node0->point];
			p0.x = p0.x + tileWidthOffset;
			p0.y = p0.y + tileHeightOffset;

			CGPoint p1 = [_delegate AStarPositionAt:node1->point];
			p1.x = p1.x + tileWidthOffset;
			p1.y = p1.y + tileHeightOffset;

			_direction = ccpSub(p0, p1);

			node.position = p1;
		}
	}
	return arrived;
}

- (void)makePathTile
{
	CGFloat width = PixelsToPointsF(_width);
	CGFloat height = PixelsToPointsF(_height);

	CGColorSpaceRef imageColorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(NULL, (size_t)width, (size_t)height, 8, (size_t)(width * 4), imageColorSpace, kCGImageAlphaPremultipliedLast);

	CGColorSpaceRelease(imageColorSpace);

	CGContextSetRGBFillColor(context, 1, 1, 1, 1);
	CGContextFillRect(context, CGRectMake(0.0f, 0.0f, width, height));

	_image = CGBitmapContextCreateImage(context);

	CGContextRelease(context);
}

- (void)dealloc
{
	KKLOG();
	
	CFRelease(_image);
}

- (void)initArrows
{
	CCSpriteFrameCache *cache = [CCSpriteFrameCache sharedSpriteFrameCache];
	[cache addSpriteFramesWithFile:fileGeneralPlist textureFile:fileGeneral];

	CCSpriteFrame *arrows = [cache spriteFrameByName:atlasArrows];

	CCSpriteFrame *arrow0 = [CCSpriteFrame frameWithTexture:arrows.texture rect:CGRectMake(arrows.rect.origin.x + 0.0f, arrows.rect.origin.y + 0.0f, 3.0f, 3.0f)];
	CCSpriteFrame *arrow1 = [CCSpriteFrame frameWithTexture:arrows.texture rect:CGRectMake(arrows.rect.origin.x + 3.0f, arrows.rect.origin.y + 0.0f, 3.0f, 3.0f)];
	CCSpriteFrame *arrow2 = [CCSpriteFrame frameWithTexture:arrows.texture rect:CGRectMake(arrows.rect.origin.x + 6.0f, arrows.rect.origin.y + 0.0f, 3.0f, 3.0f)];
	CCSpriteFrame *arrow3 = [CCSpriteFrame frameWithTexture:arrows.texture rect:CGRectMake(arrows.rect.origin.x + 9.0f, arrows.rect.origin.y + 0.0f, 3.0f, 3.0f)];
	CCSpriteFrame *arrow4 = [CCSpriteFrame frameWithTexture:arrows.texture rect:CGRectMake(arrows.rect.origin.x + 12.0f, arrows.rect.origin.y + 0.0f, 3.0f, 3.0f)];
	CCSpriteFrame *arrow5 = [CCSpriteFrame frameWithTexture:arrows.texture rect:CGRectMake(arrows.rect.origin.x + 15.0f, arrows.rect.origin.y + 0.0f, 3.0f, 3.0f)];
	CCSpriteFrame *arrow6 = [CCSpriteFrame frameWithTexture:arrows.texture rect:CGRectMake(arrows.rect.origin.x + 18.0f, arrows.rect.origin.y + 0.0f, 3.0f, 3.0f)];
	CCSpriteFrame *arrow7 = [CCSpriteFrame frameWithTexture:arrows.texture rect:CGRectMake(arrows.rect.origin.x + 21.0f, arrows.rect.origin.y + 0.0f, 3.0f, 3.0f)];
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFrame:arrow0 name:@"arrow0"];
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFrame:arrow1 name:@"arrow1"];
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFrame:arrow2 name:@"arrow2"];
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFrame:arrow3 name:@"arrow3"];
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFrame:arrow4 name:@"arrow4"];
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFrame:arrow5 name:@"arrow5"];
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFrame:arrow6 name:@"arrow6"];
	[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFrame:arrow7 name:@"arrow7"];
}

- (id)initWithWidth:(NSInteger)width height:(NSInteger)height
{
	KKLOG();

	self = [super init];
	if (self)
	{
		_height = width;
		_width = height;
		_openNodes = [NSMutableSet setWithCapacity:16];
		_closedNodes = [NSMutableSet setWithCapacity:64];
		_color = colorDekoGreenDark;
		[self makePathTile];
		[self initArrows];
	}
	return self;
}

@end

@implementation AStarNode

+ (id)nodeAtPoint:(CGPoint)p;
{
	return [[AStarNode alloc] initAtPoint:p];
}

- (id)initAtPoint:(CGPoint)p
{
	point = p;
	return self;
}

- (int)cost
{
	return g + h;
}

- (NSUInteger)hash
{
	return (NSUInteger)(((int) point.x << 16) | ((int) point.y & 0xFFFF));
}

- (BOOL)isEqual:(id)otherObject
{
	if (![otherObject isKindOfClass:[self class]])
	{
		return NO;
	}
	AStarNode *otherNode = (AStarNode *)otherObject;
	if (point.x != otherNode->point.x || point.y != otherNode->point.y)
	{
		return NO;
	}
	return YES;
}

@end
