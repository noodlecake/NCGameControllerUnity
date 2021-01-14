//
//  GameScene.m
//  GameControllerWrapperTester
//
//  Created by Ben Schmidt on 2021-01-06.
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
        NSImage *img = [[NSImage alloc] initWithData:texData];
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
}

- (void)keyDown:(NSEvent *)theEvent {
    switch (theEvent.keyCode) {
        case 0x31 /* SPACE */:
            // Run 'Pulse' action from 'Actions.sks'
            [_label runAction:[SKAction actionNamed:@"Pulse"] withKey:@"fadeInOut"];
            break;
            
        default:
            NSLog(@"keyDown:'%@' keyCode: 0x%02X", theEvent.characters, theEvent.keyCode);
            break;
    }
}

- (void)mouseDown:(NSEvent *)theEvent {
    [self touchDownAtPoint:[theEvent locationInNode:self]];
}
- (void)mouseDragged:(NSEvent *)theEvent {
    [self touchMovedToPoint:[theEvent locationInNode:self]];
}

- (void)mouseUp:(NSEvent *)theEvent {
    [self touchUpAtPoint:[theEvent locationInNode:self]];
    NCRegisterInputCallback(fake_unity_callback);
    NCRegisterControllerConnectedCallback(fake_connected_callback);
    NCRegisterControllerDisconnectedCallback(fake_disconnected_callback);
}




-(void)update:(CFTimeInterval)currentTime {
    // Called before each frame is rendered
//    NSLog(@"Controller Connected: %d", NCControllerConnected());
//    NSLog(@"Has Extended Profile: %d", NCControllerHasExtendedProfile());
    if (glyph != nil) {
        [self removeAllChildren];
        [self addChild:glyph];
        glyph = nil;
    }
}

@end
