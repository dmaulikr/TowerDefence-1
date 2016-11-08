

// ** -->>   IMPORT  CORE    <<-- ** //
#import "HUDLayer.h"
#import "GameLayer.h"
// ** -->>   IMPORT  CORE    <<-- ** //








@implementation HUDLayer

-(void)showHUD {
    
}

-(id)init {
    if ((self = [super init])) {
        // ** -->>    CREATE  TOWER  BUTTONS    <<-- ** //
        CCMenuItem *MachineGunButton = [CCMenuItemImage itemFromNormalImage:@"MachineGun.png" selectedImage:@"MachineGun_Sel.png" target:self selector:@selector(select01)];
        CGSize originalSize = [MachineGunButton contentSize];
        float originalWidth = originalSize.width;
        float originalHeight = originalSize.height;
        float newScaleX = (float)(70) / originalWidth;
        float newScaleY = (float)(70) / originalHeight;
        [MachineGunButton setScaleX:newScaleX];
        [MachineGunButton setScaleY:newScaleY];
        MachineGunButton.position = ccp(60, 40);
        CCMenuItem *FlameThrowerButton = [CCMenuItemImage itemFromNormalImage:@"FlameThrower.png" selectedImage:@"FlameThrower_Sel.png" target:self selector:@selector(select02)];
        [FlameThrowerButton setScaleX:newScaleX];
        [FlameThrowerButton setScaleY:newScaleY];
        FlameThrowerButton.position = ccp(150, 40);
        CCMenuItem *LightningGeneratorButton = [CCMenuItemImage itemFromNormalImage:@"LightningGenerator.png" selectedImage:@"LightningGenerator_Sel.png" target:self selector:@selector(select03)];
        [LightningGeneratorButton setScaleX:newScaleX];
        [LightningGeneratorButton setScaleY:newScaleY];
        LightningGeneratorButton.position = ccp(240, 40);
        CCMenu *towerMenu = [CCMenu menuWithItems:MachineGunButton, FlameThrowerButton, LightningGeneratorButton, nil];
        towerMenu.position = CGPointZero;
        [self addChild:towerMenu];
        // ** -->>    CREATE  TOWER  BUTTONS    <<-- ** //
    }
    return self;
}

-(void)select01 {       [GameLayer select01];        }
-(void)select02 {       [GameLayer select02];        }
-(void)select03 {       [GameLayer select03];        }
-(void)select04 {       [GameLayer select04];        }
-(void)select05 {       [GameLayer select05];        }
-(void)select06 {       [GameLayer select06];        }

-(void)setStatusString:(NSString *)string {
    
}
@end
