# NCGameControllerUnity - GameControllerWrapper
- These are the Xcode projects I build the static libraries / mac bundle with
- If you want to make a new one / update, you need to archive the build otherwise Apple might complain during submission to the app store
- The mac version could probably also use a static library but I already had it working as a bundle so I didn't change it
- There's probably a way to make them all into one Xcode project but I was having troubles with that so... ¯\\_(ツ)_/¯
- The tester project tries to register a controller when you click the screen. It should then log the controller's input and draw the button glyph to the screen
