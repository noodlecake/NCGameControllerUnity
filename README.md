# NCGameControllerUnity
Plugin to get input and glyphs from Apple's Game Controller framework into Unity

Putting this out there to help people out who might be looking to do this. This plugin is unlikely to be well maintained but feel free to submit pull requests if you make improvements!

Basic info
-------------

**NCGameControllerUnity.unitypackage** - The assembled package to use in your project. Once in your project, check the NCGameControllerUnity.cs file to figure out usage. The "Public stuff" section contains all of the public methods you need and the "Test stuff" section has some examples on how to write and use the callbacks in your game.

**RewiredExample** - This folder contains some example code and instructions to help you make this plugin work with Rewired. Some of the callbacks in here may be useful even if you aren't using Rewired.

**TextMeshProExample** - This folder contains some example code to help you get the glyphs from this plugin into TextMesh Pro.

**GameControllerWrapper** - This folder contains the Xcode projects used to generate the static library / bundle files that link to the framework.

**UnityProject** - This folder contains the Unity project used to generate the .unityplugin and to do some basic testing.

Check the README files in the individual folders for more details.

Tips
-----
- If you want to get an idea of how the symbols look without messing with the style in code, download the SF Symbols app which allows you to see all of the symbols and try the different weights: https://developer.apple.com/sf-symbols/
- This plugin will work in the editor if you're developing on a Mac and have your platform set to "PC, Mac & Linux Standalone". If you make changes to the underlying Mac bundle of the plugin you'll need to restart Unity to see your changes though.
- This plugin requires iOS 14+ / tvOS 14+ / macOS 11.0 (Big Sur) since that's when the glyphs were added to Apple's Game Controller framework. The input handling could probably work on older OS versions but you would need to rebuild the libraries with a lower minimum OS version.

Potential Improvements
-----------------------
- There could be better PlayStation and Xbox support added for things like the DualShock 4's touch pad. This is accessible from Apple's framework but was not added as it wasn't needed in the projects this was made for.
- The plugin assumes that only one player can be playing at a time on the device. It could potentially be extended for local multiplayer.
- It's possible there's some edge cases that aren't covered when you disconnect / reconnect / swap controllers.
