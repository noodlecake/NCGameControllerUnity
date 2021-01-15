# NCGameControllerUnity - TextMeshPro Example
This is an example of how to get the glyphs from Apple's Game Controller framework to work with TextMesh Pro.
Special thanks to Joon for providing this!

1. Unzip TMPCustomSprites.zip and place it in you Unity project's resource directory.
2. Modify your project's TMP Settings object to point to the resource folder. You shouldn't need to change the default sprite asset to the one in here but I included it just in case.
3. Use AppleControllerSpriteManager.cs to get the glyphs into TMP. Note that this file has been modified a bit to remove some game-specific stuff so it's untested but it should mostly work. Consider submitting a pull request if you find an issue and fix it!

The method used to do this make this work is somewhat explained here: https://forum.unity.com/threads/inline-graphics-require-sprite-sheets.474109/

This implementation can only display 10 glyph sprites at a time but you could probably add more sprite assets to the TMPCustomSprites directory and increase the spriteAssetCount variable if you're needing to display more in a controller mapping scene or something.
