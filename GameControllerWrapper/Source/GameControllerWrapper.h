//
//  GameControllerWrapper.h
//  GameControllerWrapper
//
//  Created by Ben Schmidt on 2021-01-5.
//  Copyright © 2021 Noodlecake Studios Inc. All rights reserved.
//

//Enums
typedef enum ControlElementID {
    ButtonA,
    ButtonB,
    ButtonX,
    ButtonY,
    ButtonShoulderLeft,
    ButtonShoulderRight,
    ButtonTriggerLeft,
    ButtonTriggerRight,
    ButtonHome,
    ButtonMenu,
    ButtonOptions,
    ButtonUp,
    ButtonDown,
    ButtonLeft,
    ButtonRight,
    ButtonThumbstickLeft,
    ButtonThumbstickRight,
    Dpad,
    ThumbstickLeft,
    ThumbstickRight,
} ControlElementID;

typedef enum SymbolWeight {
    Ultralight,
    Thin,
    Light,
    Regular,
    Medium,
    Semibold,
    Bold,
    Heavy,
    Black
} SymbolWeight;

//Basic Checks
BOOL NCControllerConnected(void);
BOOL NCControllerHasExtendedProfile(void);

//Handlers
BOOL NCRegisterInputCallback(void (*unity_callback)(int, float, float));
BOOL NCRegisterControllerConnectedCallback(void (*unity_callback)(void));
BOOL NCRegisterControllerDisconnectedCallback(void (*unity_callback)(void));

//Get Glyphs
void NCSetSymbolStyle(float pointSize, SymbolWeight weight, BOOL fill, float red, float green, float blue);
long NCGenerateGlyphForInput(ControlElementID elemID);
BOOL NCGetGeneratedGlyph(Byte *imgBuffer);

