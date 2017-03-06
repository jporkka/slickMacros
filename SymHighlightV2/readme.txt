OK, here is the new version.
Loading it should be easier this time.
Be sure to unload the current one first.
Unpack the zip and put the files where Slick can find them - in your slick path, or in your config directory directly.

Then from the Slick command line run
symtagload

This should load all the modules in the right order to make it work.
To unload, run
symtagunload.

For key binding, run 
symtagBindKeys.


This release it mostly about cleaning up the code and making it work more reliably.
I haven't tested it extensively yet, but seems to work.


In the dialog there are some shortcuts.
"c" - cycle color
"Shift+c" - cycle color backwards.
"e" - toggle enable/disable
"w" - toggle word mode on/off.
"F2" - edit the highlight word.
