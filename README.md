# NCGameControllerUnity
Plugin to get input and glyphs from Apple's Game Controller framework into Unity

Basic info
-------------

**NCGameControllerUnity.unitypackage** - The assembled package to use in your project. Once in your project, check the NCGameControllerUnity.cs file to figure out usage. The "Public stuff" section contains all of the public methods you need and the "Test stuff" section has some examples on how to write and use the callbacks in your game.

**RewiredExample** - This folder contains some example code and instructions to help you make this plugin work with Rewired. Some of the callbacks in here may be useful even if you aren't using Rewired.

**TextMeshProExample** - This folder contains some example code to help you get the glyphs from this plugin into TextMesh Pro.

**GameControllerWrapper** - This folder contains the Xcode projects used to generate the static library / bundle files that link to the framework.

**UnityProject** - This folder contains the Unity project used to generate the .unityplugin and to do some basic testing.

Check the README files in the individual folders for more details.
