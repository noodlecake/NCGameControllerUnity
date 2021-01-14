//
//  GameControllerWrapper.m
//  GameControllerWrapper
//
//  Created by Ben Schmidt on 2021-01-5.
//  Copyright © 2021 Noodlecake Studios Inc. All rights reserved.
//

@import GameController;

#if TARGET_OS_OSX
@import AppKit;
#elif TARGET_OS_IPHONE //includes tvOS
@import UIKit;
#endif

#import "GameControllerWrapper.h"

static GCController *current_controller;

@interface NCConnectionHandler : NSObject

@property (nonatomic, copy) void (^connectedBlock)(void);
@property (nonatomic, copy) void (^disconnectedBlock)(void);

- (void) controllerConnected:(NSNotification *) notification;
- (void) controllerDisconnected:(NSNotification *) notification;

@end

@implementation NCConnectionHandler
    - (void) controllerConnected:(NSNotification *) notification {
        self.connectedBlock();
    }
    - (void) controllerDisconnected:(NSNotification *) notification {
        if (notification.object == current_controller) {
            self.disconnectedBlock();
        }
    }
@end

static NCConnectionHandler *connection_handler;

#if TARGET_OS_OSX
static NSImageSymbolConfiguration *glyph_config;
static NSColor *glyph_color;
#elif TARGET_OS_IPHONE //includes tvOS
static UIImageSymbolConfiguration *glyph_config;
static UIColor *glyph_color;
#endif
static BOOL glyph_fill;
static NSData *last_glyph;


//***************************
//Basic Checks
//***************************

//Returns true if a controller is connected
BOOL NCControllerConnected(void) {
    GCController *controller = GCController.current;
    if (!controller) {
        return NO;
    }
    return YES;
}

//Returns true if a controller is connected and has an extended profile (4 face buttons, analog sticks, shoulder buttons)
BOOL NCControllerHasExtendedProfile(void) {
    GCController *controller = GCController.current;
    if (!controller) {
        return NO;
    }
    return (controller.extendedGamepad != nil);
}

//***************************
//Handlers
//***************************

//Registers to be told if the input state of the most recent controller changes
//Returns true if successful, false otherwise
//For the callback, the first argument specifies which button/dpad/stick changed (see enum in .h)
//If it's a button, the first float is the pressure on the button, and the second will be 1 if it's "pressed"
//If it's a dpad/stick the first float is the X value, second is Y
BOOL NCRegisterInputCallback(void (*unity_callback)(int, float, float)) {
    current_controller = GCController.current;
    if (!current_controller) {
        return NO;
    }
    
    if (current_controller.extendedGamepad != nil) {
        GCExtendedGamepadValueChangedHandler mainHandler = ^(GCExtendedGamepad *gamepad, GCControllerElement *element) {
            int elemId = -1;
            float val1 = 0;
            float val2 = 0;
            
            if (element == gamepad.buttonA) {
                elemId = ButtonA;
            } else if (element == gamepad.buttonB) {
                elemId = ButtonB;
            } else if (element == gamepad.buttonX) {
                elemId = ButtonX;
            } else if (element == gamepad.buttonY) {
                elemId = ButtonY;
            } else if (element == gamepad.leftShoulder) {
                elemId = ButtonShoulderLeft;
            } else if (element == gamepad.rightShoulder) {
                elemId = ButtonShoulderRight;
            } else if (element == gamepad.leftTrigger) {
                elemId = ButtonTriggerLeft;
            } else if (element == gamepad.rightTrigger) {
                elemId = ButtonTriggerRight;
            } else if (element == gamepad.buttonHome) {
                elemId = ButtonHome;
            } else if (element == gamepad.buttonMenu) {
                elemId = ButtonMenu;
            } else if (element == gamepad.buttonOptions) {
                elemId = ButtonOptions;
            } else if (element == gamepad.leftThumbstickButton) {
                elemId = ButtonThumbstickLeft;
            } else if (element == gamepad.rightThumbstickButton) {
                elemId = ButtonThumbstickRight;
            } else if (element == gamepad.dpad) {
                elemId = Dpad;
            } else if (element == gamepad.leftThumbstick) {
                elemId = ThumbstickLeft;
            } else if (element == gamepad.rightThumbstick) {
                elemId = ThumbstickRight;
            }
            
            if ([element isKindOfClass:[GCControllerButtonInput class]]) {
                val1 = ((GCControllerButtonInput*)element).value;
                val2 = ((GCControllerButtonInput*)element).pressed;
            } else if ([element isKindOfClass:[GCControllerDirectionPad class]]) {
                val1 = ((GCControllerDirectionPad*)element).xAxis.value;
                val2 = ((GCControllerDirectionPad*)element).yAxis.value;
            }
            
            unity_callback(elemId, val1, val2);
        };
        
        GCControllerButtonValueChangedHandler dpadHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed) {
            int elemId = 0;
            
            if (button == ((GCControllerDirectionPad*)button.collection).up) {
                elemId = ButtonUp;
            } else if (button == ((GCControllerDirectionPad*)button.collection).down) {
                elemId = ButtonDown;
            } else if (button == ((GCControllerDirectionPad*)button.collection).left) {
                elemId = ButtonLeft;
            } else if (button == ((GCControllerDirectionPad*)button.collection).right) {
                elemId = ButtonRight;
            }
            
            unity_callback(elemId, value, (float)pressed);
        };
        
        current_controller.extendedGamepad.valueChangedHandler = mainHandler;
        current_controller.extendedGamepad.dpad.up.valueChangedHandler = dpadHandler;
        current_controller.extendedGamepad.dpad.down.valueChangedHandler = dpadHandler;
        current_controller.extendedGamepad.dpad.left.valueChangedHandler = dpadHandler;
        current_controller.extendedGamepad.dpad.right.valueChangedHandler = dpadHandler;
        
        return YES;
    } else if (current_controller.microGamepad != nil) {
        GCMicroGamepadValueChangedHandler mainHandler = ^(GCMicroGamepad *gamepad, GCControllerElement *element) {
            int elemId = -1;
            float val1 = 0;
            float val2 = 0;
            
            if (element == gamepad.buttonA) {
                elemId = ButtonA;
            } else if (element == gamepad.buttonX) {
                elemId = ButtonX;
            } else if (element == gamepad.buttonMenu) {
                elemId = ButtonMenu;
            } else if (element == gamepad.dpad) {
                elemId = Dpad;
            }
            
            if (elemId <= ButtonThumbstickRight) {
                val1 = ((GCControllerButtonInput*)element).value;
                val2 = ((GCControllerButtonInput*)element).pressed;
            } else if (elemId <= ThumbstickRight) {
                val1 = ((GCControllerDirectionPad*)element).xAxis.value;
                val2 = ((GCControllerDirectionPad*)element).yAxis.value;
            }
            
            unity_callback(elemId, val1, val2);
        };
        
        GCControllerButtonValueChangedHandler dpadHandler = ^(GCControllerButtonInput *button, float value, BOOL pressed) {
            int elemId = 0;
            
            if (button == ((GCControllerDirectionPad*)button.collection).up) {
                elemId = ButtonUp;
            } else if (button == ((GCControllerDirectionPad*)button.collection).down) {
                elemId = ButtonDown;
            } else if (button == ((GCControllerDirectionPad*)button.collection).left) {
                elemId = ButtonLeft;
            } else if (button == ((GCControllerDirectionPad*)button.collection).right) {
                elemId = ButtonRight;
            }
            
            unity_callback(elemId, value, (float)pressed);
        };
        
        current_controller.microGamepad.valueChangedHandler = mainHandler;
        current_controller.microGamepad.dpad.up.valueChangedHandler = dpadHandler;
        current_controller.microGamepad.dpad.down.valueChangedHandler = dpadHandler;
        current_controller.microGamepad.dpad.left.valueChangedHandler = dpadHandler;
        current_controller.microGamepad.dpad.right.valueChangedHandler = dpadHandler;
        
        return YES;
    }
    
    // Should never happen
    return NO;
}

//Registers to be told if a controller connects
//Returns true if successful, false otherwise
BOOL NCRegisterControllerConnectedCallback(void (*unity_callback)(void)) {
    if (!connection_handler) {
        connection_handler = [[NCConnectionHandler alloc] init];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:connection_handler
                                                        name:GCControllerDidConnectNotification
                                                      object:nil];
    }
    
    connection_handler.connectedBlock = ^ {
        unity_callback();
    };
    
    [[NSNotificationCenter defaultCenter] addObserver:connection_handler
                                             selector:@selector(controllerConnected:)
                                                 name:GCControllerDidConnectNotification
                                               object:nil];

    return YES;
}

//Registers to be told if the current controller disconnects
//Returns true if successful, false otherwise
BOOL NCRegisterControllerDisconnectedCallback(void (*unity_callback)(void)) {
    if (!connection_handler) {
        connection_handler = [[NCConnectionHandler alloc] init];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:connection_handler
                                                        name:GCControllerDidDisconnectNotification
                                                      object:nil];
    }
    
    connection_handler.disconnectedBlock = ^ {
        unity_callback();
    };
    
    [[NSNotificationCenter defaultCenter] addObserver:connection_handler
                                             selector:@selector(controllerDisconnected:)
                                                 name:GCControllerDidDisconnectNotification
                                               object:nil];

    return YES;
}

//***************************
//Get Glyphs
//***************************
void NCSetSymbolStyle(float pointSize, SymbolWeight weight, BOOL fill, float red, float green, float blue) {
    glyph_fill = fill;
    
#if TARGET_OS_OSX
    glyph_color = [NSColor colorWithRed:red green:green blue:blue alpha:1];
    
    NSFontWeight appleWeight;
    switch (weight) {
        case Ultralight:
            appleWeight = NSFontWeightUltraLight;
            break;
        case Thin:
            appleWeight = NSFontWeightThin;
            break;
        case Light:
            appleWeight = NSFontWeightLight;
            break;
        case Regular:
            appleWeight = NSFontWeightRegular;
            break;
        case Medium:
            appleWeight = NSFontWeightMedium;
            break;
        case Semibold:
            appleWeight = NSFontWeightSemibold;
            break;
        case Bold:
            appleWeight = NSFontWeightBold;
            break;
        case Heavy:
            appleWeight = NSFontWeightHeavy;
            break;
        case Black:
            appleWeight = NSFontWeightBlack;
            break;
        default:
            appleWeight = NSFontWeightRegular;
            break;
    }
    
    glyph_config = [NSImageSymbolConfiguration configurationWithPointSize:pointSize weight:appleWeight];
    
    
#elif TARGET_OS_IPHONE //includes tvOS
    glyph_color = [UIColor colorWithRed:red green:green blue:blue alpha:1];
    
    UIImageSymbolWeight appleWeight;
    switch (weight) {
        case Ultralight:
            appleWeight = UIImageSymbolWeightUltraLight;
            break;
        case Thin:
            appleWeight = UIImageSymbolWeightThin;
            break;
        case Light:
            appleWeight = UIImageSymbolWeightLight;
            break;
        case Regular:
            appleWeight = UIImageSymbolWeightRegular;
            break;
        case Medium:
            appleWeight = UIImageSymbolWeightMedium;
            break;
        case Semibold:
            appleWeight = UIImageSymbolWeightSemibold;
            break;
        case Bold:
            appleWeight = UIImageSymbolWeightBold;
            break;
        case Heavy:
            appleWeight = UIImageSymbolWeightHeavy;
            break;
        case Black:
            appleWeight = UIImageSymbolWeightBlack;
            break;
        default:
            appleWeight = UIImageSymbolWeightRegular;
            break;
    }
    
    glyph_config = [UIImageSymbolConfiguration configurationWithPointSize:pointSize weight:appleWeight];
#endif
}

long NCGenerateGlyphForInput(ControlElementID elemID) {
    if (elemID < ButtonA || elemID > ThumbstickRight) {
        return -1;
    }
    
    if (!current_controller) {
        return -1;
    }
    
    GCControllerElement *elem = nil;
    
    if (current_controller.extendedGamepad != nil) {
        switch (elemID) {
            case ButtonA:
                elem = current_controller.extendedGamepad.buttonA;
                break;
            case ButtonB:
                elem = current_controller.extendedGamepad.buttonB;
                break;
            case ButtonX:
                elem = current_controller.extendedGamepad.buttonX;
                break;
            case ButtonY:
                elem = current_controller.extendedGamepad.buttonY;
                break;
            case ButtonShoulderLeft:
                elem = current_controller.extendedGamepad.leftShoulder;
                break;
            case ButtonShoulderRight:
                elem = current_controller.extendedGamepad.rightShoulder;
                break;
            case ButtonTriggerLeft:
                elem = current_controller.extendedGamepad.leftTrigger;
                break;
            case ButtonTriggerRight:
                elem = current_controller.extendedGamepad.rightTrigger;
                break;
            case ButtonHome:
                elem = current_controller.extendedGamepad.buttonHome;
                break;
            case ButtonMenu:
                elem = current_controller.extendedGamepad.buttonMenu;
                break;
            case ButtonOptions:
                elem = current_controller.extendedGamepad.buttonOptions;
                break;
            case ButtonUp:
                elem = current_controller.extendedGamepad.dpad.up;
                break;
            case ButtonDown:
                elem = current_controller.extendedGamepad.dpad.down;
                break;
            case ButtonLeft:
                elem = current_controller.extendedGamepad.dpad.left;
                break;
            case ButtonRight:
                elem = current_controller.extendedGamepad.dpad.right;
                break;
            case ButtonThumbstickLeft:
                elem = current_controller.extendedGamepad.leftThumbstickButton;
                break;
            case ButtonThumbstickRight:
                elem = current_controller.extendedGamepad.rightThumbstickButton;
                break;
            case Dpad:
                elem = current_controller.extendedGamepad.dpad;
                break;
            case ThumbstickLeft:
                elem = current_controller.extendedGamepad.leftThumbstick;
                break;
            case ThumbstickRight:
                elem = current_controller.extendedGamepad.rightThumbstick;
                break;
            default:
                return -1;
        }
    } else if (current_controller.microGamepad != nil) {
        switch (elemID) {
            case ButtonA:
                elem = current_controller.microGamepad.buttonA;
                break;
            case ButtonX:
                elem = current_controller.microGamepad.buttonX;
                break;
            case ButtonMenu:
                elem = current_controller.microGamepad.buttonMenu;
                break;
            case ButtonUp:
                elem = current_controller.microGamepad.dpad.up;
                break;
            case ButtonDown:
                elem = current_controller.microGamepad.dpad.down;
                break;
            case ButtonLeft:
                elem = current_controller.microGamepad.dpad.left;
                break;
            case ButtonRight:
                elem = current_controller.microGamepad.dpad.right;
                break;
            case Dpad:
                elem = current_controller.microGamepad.dpad;
                break;
            default:
                return -1;
        }
    }
    
    NSString *symbolName = elem.sfSymbolsName;
    
    //This is here because Apple's framework has a bug and doesn't populate the symbol of these correctly.
    //If they fix the bug, it should have a symbol name by here and it won't affect anything.
    if (!symbolName) {
        switch (elemID) {
            case ButtonUp:
                symbolName = @"dpad.up";
                break;
            case ButtonDown:
                elem = current_controller.microGamepad.dpad.down;
                symbolName = @"dpad.down";
                break;
            case ButtonLeft:
                elem = current_controller.microGamepad.dpad.left;
                symbolName = @"dpad.left";
                break;
            case ButtonRight:
                elem = current_controller.microGamepad.dpad.right;
                symbolName = @"dpad.right";
                break;
            default:
                return -1;
        }
    }
    
    if (glyph_fill && ![symbolName hasSuffix:@".fill"]) {
        symbolName = [NSString stringWithFormat:@"%@.fill", symbolName];
    } else if (!glyph_fill && [symbolName hasSuffix:@".fill"]) {
        symbolName = [symbolName substringToIndex:[symbolName length] - 5];
    }
    
#if TARGET_OS_OSX
    NSImage *glyph = [NSImage imageWithSystemSymbolName:symbolName accessibilityDescription:nil];
    if (!glyph) {
        return -1;
    }
        
    if (glyph_config != nil) {
        glyph = [glyph imageWithSymbolConfiguration:glyph_config];
    }
    
    //why can iOS do this so easily but not mac - tint the image
    if (glyph_color != nil) {
        [glyph lockFocus];
        [glyph_color set];
        NSRect imageRect = {NSZeroPoint, [glyph size]};
        NSRectFillUsingOperation(imageRect, NSCompositingOperationSourceIn);
        [glyph unlockFocus];
    }

    //making the png data is also harder on mac
    NSData *imageData = [glyph TIFFRepresentation];
    NSBitmapImageRep* bitmap = [[NSBitmapImageRep alloc] initWithData:imageData];
    NSData* bitmapData = [bitmap representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
    last_glyph = bitmapData;
    
    return [last_glyph length];
    
#elif TARGET_OS_IPHONE //includes tvOS
    UIImage *glyph;
    if (glyph_config) {
        glyph = [UIImage systemImageNamed:symbolName withConfiguration:glyph_config];
    } else {
        glyph = [UIImage systemImageNamed:symbolName];
    }
    
    if (glyph_color) {
        glyph = [glyph imageWithTintColor:glyph_color];
    }
    
    last_glyph = UIImagePNGRepresentation(glyph);
    
    return [last_glyph length];
#endif

    //should never get here
    return -1;
}


BOOL NCGetGeneratedGlyph(Byte *imgBuffer) {
    if (!last_glyph) {
        return NO;
    }
    
    [last_glyph getBytes:imgBuffer length:last_glyph.length];
    return YES;
}


