using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using Random = UnityEngine.Random;

//if you don't use Rewired you can probably remove this import and GetSpriteStringForAction()
using Rewired;

public class AppleControllerSpriteManager2
{
#if (UNITY_IOS || UNITY_TVOS || UNITY_STANDALONE_OSX)
    static Dictionary<NCGameControllerUnity.NCControlElementID, Texture2D> customGlyphs;
#endif
    static TMP_SpriteAsset[] customSpriteAssets;

    static Texture2D emptyTexture;
    static bool _init;
    static int _currentIndex;   // loops through all glyphs

    public static void Init()
    {
#if (UNITY_IOS || UNITY_TVOS || UNITY_STANDALONE_OSX)
        if (_init) return;
        _init = true;

        var go = new GameObject();

        //Set the style of your glyph here
        NCGameControllerUnity.SetGlyphStyle(128, NCGameControllerUnity.NCSymbolWeight.Regular, true, false, 1,1,1);

        customGlyphs = new Dictionary<NCGameControllerUnity.NCControlElementID, Texture2D>();

        var spriteAssetCount = 11;
        customSpriteAssets = new TMP_SpriteAsset[spriteAssetCount];

        for (int i = 0; i < spriteAssetCount; i++)
        {
	        customSpriteAssets[i] = Resources.Load<TMP_SpriteAsset>("TMPCustomSprites/customGlyph"+i);
        }
        
        emptyTexture  = Resources.Load<Texture2D>("TMPCustomSprites/emptyTexture");
#endif
    }

#if (UNITY_IOS || UNITY_TVOS || UNITY_STANDALONE_OSX)
    //returns a sprite string for use in TextMesh Pro
	static string GetSpriteStringForControlElement(NCGameControllerUnity.NCControlElementID element)
	{
		// find texture if it exists
		var result = "";

		if (!customGlyphs.ContainsKey(element))
		{
			var rawGlyphTexture = NCGameControllerUnity.GetGlyph(element);
			var fixedGlyphTexture = FixGlyphTexture(rawGlyphTexture);
			customGlyphs.Add(element, fixedGlyphTexture);
		}

		// put texture into spriteasset
		var glyphTexture = customGlyphs[element];
		customSpriteAssets[_currentIndex].material.mainTexture = glyphTexture;

		var metrics = customSpriteAssets[_currentIndex].spriteGlyphTable[0].metrics;
		metrics.width = 256f * (glyphTexture.width / (float) glyphTexture.height);
		metrics.height = 256f;
		customSpriteAssets[_currentIndex].spriteGlyphTable[0].metrics = metrics;

		// return tmpro valid string
		result = "<sprite=\"customGlyph" + (_currentIndex) + "\" name=\"customGlyph0\" tint>";

		// move onto the next spriteasset
		_currentIndex++;
		if (_currentIndex >= customSpriteAssets.Length) _currentIndex = 0;

		return result;
	}
#endif

    //returns a sprite string for use in TextMesh Pro
	public static string GetSpriteStringForElementString(string elementIdentifierName)
	{
#if (UNITY_IOS || UNITY_TVOS || UNITY_STANDALONE_OSX)
		var element = GetElementFromString(elementIdentifierName);
		return GetSpriteStringForControlElement(element);
#else
        return "";
#endif
	}
	
	//This is used to get the sprite from a Rewired action instead of knowing the actual button
    public static string GetSpriteStringForAction(int actionId)
    {
#if (UNITY_IOS || UNITY_TVOS || UNITY_STANDALONE_OSX)
        Init();
        
        // Convert action ID to NcControlElementID;
        Rewired.Player.ControllerHelper playerControllers = ReInput.players.GetPlayer(0).controllers;
        var map = playerControllers.maps.GetFirstElementMapWithAction(playerControllers.GetLastActiveController(), actionId, true);

	    List<ActionElementMap> multimap = new List<ActionElementMap>();
        playerControllers.maps.GetElementMapsWithAction(playerControllers.GetLastActiveController(), actionId, true, multimap);

        var element = NCGameControllerUnity.NCControlElementID.ButtonA;
        if (multimap != null && multimap.Count > 1)
        {
	        var element1 = GetElementFromString(multimap[0].elementIdentifierName);
	        var element2 = GetElementFromString(multimap[1].elementIdentifierName);

	        Debug.Log("found multi element " + element1 + " " + element2);

	        return GetSpriteStringForControlElement(element1)+ " " + GetSpriteStringForControlElement(element2);
        }
        else if (map != null)
        {
	        element = GetElementFromString(map.elementIdentifierName);
	        Debug.Log("found element " + element);
        }
	    else
	    {
		    Debug.LogWarning("Couldn't find proper mapping for Rewired action " + actionId);
	    }

	    return GetSpriteStringForControlElement(element);
#else
        return "";
#endif
    }

    //This is done to handle the fact that the glyphs returned by Apple are not all the same dimensions
    static Texture2D FixGlyphTexture(Texture2D rawGlyphTexture)
    {
	    var newTexture = new Texture2D(emptyTexture.width, emptyTexture.height, TextureFormat.RGBA32, false);
	    Graphics.CopyTexture(emptyTexture, newTexture);
	    Graphics.CopyTexture(rawGlyphTexture, 0, 0, 0, 0, rawGlyphTexture.width, rawGlyphTexture.height, newTexture, 0, 0, 
		    emptyTexture.width/2 - rawGlyphTexture.width/2,
		    emptyTexture.height/2 - rawGlyphTexture.height/2);
	    
	    return newTexture;
    }
    
#if (UNITY_IOS || UNITY_TVOS || UNITY_STANDALONE_OSX)
    //given the button name as a string, gets the NCControlElementID
	static NCGameControllerUnity.NCControlElementID GetElementFromString(string value) 
    {
	    var values = (NCGameControllerUnity.NCControlElementID[]) Enum.GetValues(typeof(NCGameControllerUnity.NCControlElementID)); 
	    foreach (var enumvalue in values)
	    {
		    if (enumvalue.ToString().ToUpper().Equals(value.ToUpper()))
		    {
			    return enumvalue;
		    }
	    }

        //Handle axis values you might get from Rewired
        if (value == "DpadX") return NCGameControllerUnity.NCControlElementID.ThumbstickLeft;
        if (value == "DpadY") return NCGameControllerUnity.NCControlElementID.ThumbstickLeft;
	    if (value == "ThumbstickLeftX") return NCGameControllerUnity.NCControlElementID.ThumbstickRight;
        if (value == "ThumbstickLeftY") return NCGameControllerUnity.NCControlElementID.ThumbstickRight;
        if (value == "ThumbstickRightX") return NCGameControllerUnity.NCControlElementID.Dpad;
        if (value == "ThumbstickRightY") return NCGameControllerUnity.NCControlElementID.Dpad;
        if (value == "TriggerLeftMagnitude") return NCGameControllerUnity.NCControlElementID.ButtonTriggerLeft;
        if (value == "TriggerRightMagnitude") return NCGameControllerUnity.NCControlElementID.ButtonTriggerRight;
	    
	    Debug.LogWarning("Couldn't find proper glyph for " + value);
	    return values[0];
    }
#endif
}


