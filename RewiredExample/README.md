# NCGameControllerUnity - Rewired example
1. Set up a custom controller in the rewired editor. Check out the 01, 02a, and 02b screenshots. If you're going to use some of my example code then you'll need to make sure all of the axis and buttons are listed with the same indexes as in the screenshots. I tried to export this custom controller from Rewired to save everyone time but it seemed to export a bunch of other project settings. If anyone knows how to export *just* the custom controllers let me know and/or send me a file which others can import!
2. Set controller mappings for the custom controller. See screenshot 03 for an example but this will be game dependent
3. Implement the callback methods into your input handler class. A big chunk of this is likely game dependent so the example class provided is not really a drop-in solution. You'll probably want to copy-paste the bottom four classes and they will require minimal modifications, but check the NOTE: comments.


