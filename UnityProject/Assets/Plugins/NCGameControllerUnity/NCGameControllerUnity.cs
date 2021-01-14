//
//  NCGameControllerUnity.cs
//  NCGameControllerUnity
//
//  Created by Ben Schmidt on 2021-01-6.
//  Copyright © 2021 Noodlecake Studios Inc. All rights reserved.
//

//Uncomment this to use the sample program that logs input and draws glyphs to the screen
//#define NC_CONTROLLER_TEST

using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Threading.Tasks;
using UnityEngine;

public class NCGameControllerUnity : MonoBehaviour
{
#if (UNITY_IOS || UNITY_TVOS || UNITY_STANDALONE_OSX)
    //*************************
    // Internal stuff
    //*************************

    private static Sprite _glyphSprite;
    private static SpriteRenderer _spriteRenderer;

    // Import the functionality from the Xcode plugin

#if (UNITY_IOS || UNITY_TVOS)
    [DllImport ("__Internal")]
    private static extern bool NCControllerConnected();

    [DllImport ("__Internal")]
    private static extern bool NCControllerHasExtendedProfile();

    [DllImport ("__Internal")]
    private static extern bool NCRegisterInputCallback(NCControllerInputDelgate callback);

    [DllImport ("__Internal")]
    private static extern bool NCRegisterControllerConnectedCallback(NCControllerConnectedDelgate callback);

    [DllImport ("__Internal")]
    private static extern bool NCRegisterControllerDisconnectedCallback(NCControllerDisconnectedDelgate callback);

    [DllImport ("__Internal")]
    private static extern void NCSetSymbolStyle(float pointSize, int weight, bool fill, bool forceSquare, float red, float green, float blue);

    [DllImport ("__Internal")]
    private static extern long NCGenerateGlyphForInput(int id);

    [DllImport ("__Internal")]
    private static extern bool NCGetGeneratedGlyph(byte[] imgBuffer);

#elif (UNITY_STANDALONE_OSX)
    [DllImport("GameControllerWrapperMac")]
    private static extern bool NCControllerConnected();

    [DllImport("GameControllerWrapperMac")]
    private static extern bool NCControllerHasExtendedProfile();

    [DllImport("GameControllerWrapperMac")]
    private static extern bool NCRegisterInputCallback(NCControllerInputDelgate callback);

    [DllImport("GameControllerWrapperMac")]
    private static extern bool NCRegisterControllerConnectedCallback(NCControllerConnectedDelgate callback);

    [DllImport("GameControllerWrapperMac")]
    private static extern bool NCRegisterControllerDisconnectedCallback(NCControllerDisconnectedDelgate callback);

    [DllImport("GameControllerWrapperMac")]
    private static extern void NCSetSymbolStyle(float pointSize, int weight, bool fill, bool forceSquare, float red, float green, float blue);

    [DllImport("GameControllerWrapperMac")]
    private static extern long NCGenerateGlyphForInput(int id);

    [DllImport("GameControllerWrapperMac")]
    private static extern bool NCGetGeneratedGlyph(byte[] imgBuffer);
#else
    //Wrong platform bub
#endif

    //We need to hang on to any delegates that are registered otherwise C# will free the function pointer
    private static NCControllerInputDelgate _inputDelegateInstance;
    private static NCControllerConnectedDelgate _connectedDelegateInstance;
    private static NCControllerDisconnectedDelgate _disconnectedDelegateInstance;


    //*************************
    // Public stuff
    //*************************

    /////ENUMS

    // Enum of all controller elements currently supported
    public enum NCControlElementID {
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
    };

    // The possible symbol weights for glyphs
    public enum NCSymbolWeight {
        Ultralight,
        Thin,
        Light,
        Regular,
        Medium,
        Semibold,
        Bold,
        Heavy,
        Black
    };

    ///// Delegate types

    // Called whenever the current controller has a change of state
    // 
    // controlID will be one of the values in the NCControlElementID array
    // If the controller element is a button: 
    //    val1 will be the pressure on the button (0 to 1)
    //    val2 will be whether or not the button is pressed (0 or 1)
    // If the controller element is a dpad or thumbstick
    //    val1 will be the X value (-1 to 1)
    //    val2 will be the Y value (-1 to 1)
    //
    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    public delegate void NCControllerInputDelgate(int controlID, float val1, float val2);

    // Called whenever a controller is connected
    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    public delegate void NCControllerConnectedDelgate();

    // Called whenever a controller is disconnected
    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    public delegate void NCControllerDisconnectedDelgate();

    ///// Methods

    // Returns true if any controller is connected to the device
    public static bool DeviceHasControllerConnected() {
        return NCControllerConnected();
    }

    // Returns true if the most recently touched controller has an "extended" controller profile
    // Apple defines this as a controller that has 4 face buttons, 4 shoulder buttons, 2 analog sticks and a dpad
    public static bool DeviceHasExtendedControllerConnected() {
        return NCControllerHasExtendedProfile();
    }

    // Registers whatever delegate you pass in to be called whenever the current controller has input state changes
    // Returns true if the delegate is successfully registered for callbacks
    public static bool RegisterControllerInputCallback(NCControllerInputDelgate del) {
        _inputDelegateInstance = del;
        return NCRegisterInputCallback(del);
    }

    // Registers whatever delegate you pass in to be called whenever a new controller is connected to the device
    // Returns true if the delegate is successfully registered for callbacks
    public static bool RegisterControllerConnectedCallback(NCControllerConnectedDelgate del) {
        _connectedDelegateInstance = del;
        return NCRegisterControllerConnectedCallback(del);
    }

    // Registers whatever delegate you pass in to be called whenever the controller that has registered to receive input callbacks disconnects from the device
    // Returns true if the delegate is successfully registered for callbacks
    public static bool RegisterControllerDisconnectedCallback(NCControllerDisconnectedDelgate del) {
        _disconnectedDelegateInstance = del;
        return NCRegisterControllerDisconnectedCallback(del);
    }

    // Lets you customize the style of the glyphs that Apple provides
    // Any glyphs generated after setting the style will use the style that was set
    // pointSize - basically the font size of the glyph
    // weight - similar to fonts, go check the NCSymbolWeight enum
    // fill - if true, it will try to use the "filled" version of the symbols that apple provides
    // forceSquare - return textures with padding to make them a square rather than the original size provided by Apple
    // red, green, blue - color the texture
    public static void SetGlyphStyle(float pointSize, NCSymbolWeight weight, bool fill, bool forceSquare, float red, float green, float blue) {
        NCSetSymbolStyle(pointSize, (int)weight, fill, forceSquare, red, green, blue);
    }

    // Get the apple glyph for the given control element, based on the controller which we are registered to receive input from
    // Note that you cannot get glyphs until you register a controller input handler
    public static Texture2D GetGlyph(NCControlElementID elementID) {
        long len = NCGenerateGlyphForInput((int)elementID);

        Texture2D tex = new Texture2D(1,1);
        if (len > 0) {
            byte[] imgBuffer = new byte[len];
            NCGetGeneratedGlyph(imgBuffer);
            tex.LoadImage(imgBuffer, false);
        }
        return tex;
    }

    //*************************
    // Test stuff - uncomment the NC_CONTROLLER_TEST define at the top of the file to use
    //*************************
#if NC_CONTROLLER_TEST
    private static NCGameControllerUnity testWrapper;
    void Start()
    {
        _spriteRenderer = gameObject.AddComponent<SpriteRenderer>() as SpriteRenderer;

        try {
            testWrapper = this;

            Debug.Log("Controller Connected: " + NCGameControllerUnity.DeviceHasControllerConnected());
            Debug.Log("Has Extended Profile: " + NCGameControllerUnity.DeviceHasExtededControllerConnected());

            Debug.Log("Register Input Callback: " + NCGameControllerUnity.RegisterControllerInputCallback(ControllerInputTest));
            Debug.Log("Register Connected Callback: " + NCGameControllerUnity.RegisterControllerConnectedCallback(ControllerConnectedTest));
            Debug.Log("Register Disconnected Callback: " + NCGameControllerUnity.RegisterControllerDisconnectedCallback(ControllerDisonnectedTest));

            SetGlyphStyle(100, NCSymbolWeight.Light, true, true, 0.0f, 1.0f, 1.0f);

        } catch (Exception e) {
            Debug.Log("NCGameControllerUnity Error: " + e);
        }
    }

    public void DisplayGlyph(NCControlElementID id) {
        Texture2D tex = GetGlyph(id);
        Debug.Log("Texture size is " + tex.width + " x " + tex.height);
        _glyphSprite = Sprite.Create(tex, new Rect(0.0f, 0.0f, tex.width, tex.height), new Vector2(0.5f, 0.5f), 100.0f);
        _spriteRenderer.sprite = _glyphSprite;
    }

    [AOT.MonoPInvokeCallback(typeof(NCControllerInputDelgate))]
    private static void ControllerInputTest(int id, float val1, float val2)
    {
        if (!Application.isPlaying) return;
        if (id >= 0 && id < Enum.GetNames(typeof(NCControlElementID)).Length) {
            Debug.Log("Controller Input! ID: " + ((NCControlElementID)id).ToString("g") + "   val1: " + val1 + "   val2: " + val2);
            
            //"Dpad" and "ButtonUp" etc buttons come in at the same time
            //Comment out Dpad here so that we can see individual dpad buttons
            if ((NCControlElementID)id != NCControlElementID.Dpad) {
                NCGameControllerUnity.testWrapper.DisplayGlyph((NCControlElementID)id);
            }
        }
    }

    [AOT.MonoPInvokeCallback(typeof(NCControllerConnectedDelgate))]
    private static void ControllerConnectedTest()
    {
        if (!Application.isPlaying) return;
        Debug.Log("Controller Connected!");
        Debug.Log("Register Input Callback: " + NCGameControllerUnity.RegisterControllerInputCallback(ControllerInputTest));
    }

    [AOT.MonoPInvokeCallback(typeof(NCControllerDisconnectedDelgate))]
    private static void ControllerDisonnectedTest()
    {
        if (!Application.isPlaying) return;
        Debug.Log("Controller Disconnected!");
    }
#endif
#endif
}