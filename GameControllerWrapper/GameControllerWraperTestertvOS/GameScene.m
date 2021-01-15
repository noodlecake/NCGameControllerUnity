//
//  GameScene.m
//  GameControllerWrapperTester
//
//  Created by Ben Schmidt on 2021-01-15.
//

#import "GameScene.h"
#import "GameControllerWrapper.h"

SKSpriteNode *glyph;

void fake_unity_callback(int input_type, float val1, float val2) {
    NSLog(@"BEN CALLBACK: %d, %f, %f", input_type, val1, val2);
    NCSetSymbolStyle(50, Bold, YES, YES, 0.0, 1.0, 1.0);
    
    if (input_type == Dpad) {
        //otherwise this tramples over the up/down/left/right events
        return;
    }
    long len = NCGenerateGlyphForInput(input_type);
    if (len > 0) {
        Byte texBytes[len];
        NCGetGeneratedGlyph(texBytes);
        NSData *texData = [NSData dataWithBytes:texBytes length:len];
        UIImage *img = [[UIImage alloc] initWithData:texData];
        SKTexture *tex = [SKTexture textureWithImage:img];
        glyph = [SKSpriteNode spriteNodeWithTexture:tex];
    } else {
        glyph = [[SKSpriteNode alloc] init];
    }
    NSLog(@"BEN GLYPH SIZE: %d x %d", (int)glyph.size.width, (int)glyph.size.height);
}

void fake_connected_callback() {
    NSLog(@"BEN CONNECTED");
}

void fake_disconnected_callback() {
    NSLog(@"BEN DISCONNECTED");
}

@implementation GameScene {
    SKShapeNode *_spinnyNode;
    SKLabelNode *_label;
}

- (void)didMoveToView:(SKView *)view {
    // Setup your scene here
    
    // Get label node from scene and store it for use later
    _label = (SKLabelNode *)[self childNodeWithName:@"//helloLabel"];
    
    _label.alpha = 0.0;
    [_label runAction:[SKAction fadeInWithDuration:2.0]];
    
    CGFloat w = (self.size.width + self.size.height) * 0.05;
    
    // Create shape node to use during mouse interaction
    _spinnyNode = [SKShapeNode shapeNodeWithRectOfSize:CGSizeMake(w, w) cornerRadius:w * 0.3];
    _spinnyNode.lineWidth = 2.5;
    
    [_spinnyNode runAction:[SKAction repeatActionForever:[SKAction rotateByAngle:M_PI duration:1]]];
    [_spinnyNode runAction:[SKAction sequence:@[
                                                [SKAction waitForDuration:0.5],
                                                [SKAction fadeOutWithDuration:0.5],
                                                [SKAction removeFromParent],
                                                ]]];
}


- (void)touchDownAtPoint:(CGPoint)pos {
    SKShapeNode *n = [_spinnyNode copy];
    n.position = pos;
    n.strokeColor = [SKColor greenColor];
    [self addChild:n];
}

- (void)touchMovedToPoint:(CGPoint)pos {
    SKShapeNode *n = [_spinnyNode copy];
    n.position = pos;
    n.strokeColor = [SKColor blueColor];
    [self addChild:n];
}

- (void)touchUpAtPoint:(CGPoint)pos {
    SKShapeNode *n = [_spinnyNode copy];
    n.position = pos;
    n.strokeColor = [SKColor redColor];
    [self addChild:n];
    
    NCRegisterInputCallback(fake_unity_callback);
    NCRegisterControllerConnectedCallback(fake_connected_callback);
    NCRegisterControllerDisconnectedCallback(fake_disconnected_callback);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Run 'Pulse' action from 'Actions.sks'
    [_label runAction:[SKAction actionNamed:@"Pulse"] withKey:@"fadeInOut"];
    
    for (UITouch *t in touches) {[self touchDownAtPoint:[t locationInNode:self]];}
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    for (UITouch *t in touches) {[self touchMovedToPoint:[t locationInNode:self]];}
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *t in touches) {[self touchUpAtPoint:[t locationInNode:self]];}
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *t in touches) {[self touchUpAtPoint:[t locationInNode:self]];}
}


-(void)update:(CFTimeInterval)currentTime {
    // Called before each frame is rendered
    
    if (glyph != nil) {
        [self removeAllChildren];
        [self addChild:glyph];
        glyph = nil;
    }
}

@end
