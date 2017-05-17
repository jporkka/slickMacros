floatToolWindows.e
joe porkka, 2017

Bind a key to toggle floating / docked for each toolwindow
Change the g_tool_key_bindings_table table to add key assignments and functions.
 
Load this module, then run 
 
     bindToolwindowToggles      -- bind A+F2 to each toolwindow
     unbindToolwindowToggles    -- remove the A+F2 bindings.
     listToolwindowToggles      -- list the bindings.

