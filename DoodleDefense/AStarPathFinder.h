@interface AStarNode : NSObject
{
@public
	AStarNode *parent;
	CGPoint point;
	NSInteger g;
	NSInteger h;
}

+ (id)nodeAtPoint:(CGPoint)p;
- (id)initAtPoint:(CGPoint)p;
- (int)cost;

@end

@protocol AStarDelegate <NSObject>
- (BOOL)AStarBlocked:(CGPoint)p;
- (BOOL)AStarBlockedIgnore:(CGPoint)p;
- (CGPoint)AStarPositionAt:(CGPoint)p;
@end

@interface AStarPathFinder : CCNode
{
	NSInteger _width;
	NSInteger _height;
	NSMutableSet *_openNodes;
	NSMutableSet *_closedNodes;
	ccColor3B _color;
	CGPoint _direction;
	CGImageRef _image;
	id <AStarDelegate> __unsafe_unretained _delegate;
}

@property(nonatomic, assign) ccColor3B color;
@property(nonatomic, readonly) CGPoint direction;
@property(nonatomic, unsafe_unretained) id <AStarDelegate> delegate;

- (id)initWithWidth:(NSInteger)width height:(NSInteger)height;
- (BOOL)highlightPathFrom:(CGPoint)from to:(CGPoint)to display:(BOOL)display;
- (BOOL)highlightPathFrom:(CGPoint)from to:(CGPoint)to;
- (NSArray *)getPath:(CGPoint)from to:(CGPoint)to display:(BOOL)display;
- (NSArray *)getPath:(CGPoint)from to:(CGPoint)to;
- (void)clearHighlightPath;
- (BOOL)stepNode:(CCNode *)node from:(CGPoint)from to:(CGPoint)to use:(BOOL)use;

@end
