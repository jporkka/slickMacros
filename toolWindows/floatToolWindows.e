/*
 * floatToolWindows.e
 * joe porkka, 2017
 * 
 * Bind a key to toggle floating / docked for each toolwindow
 * Change the g_tool_key_bindings_table table to add key assignments and functions.
 *  
 * Load this module, then run 
 *  
 *      jp_toolwindow_toggles_bind      -- bind A+F2 to each toolwindow
 *      jp_toolwindow_toggles_unbind    -- remove the A+F2 bindings.
 *      jp_toolwindow_toggles_list      -- list the bindings.
 *  
 */


//#pragma option(pedantic,on)
#pragma option(strict,on)
#pragma option(strict2,on)
#include "slick.sh"    
#import "keybindings.e"
#import "se/ui/twautohide.e"
#import "se/ui/twevent.e"
#import "se/ui/toolwindow.e"

namespace float_tool_windows {
    struct Bindings
    {
        _str mKeyName;
        _str mBoundFunction;
    };

    static Bindings g_tool_key_bindings_table [] = {
        {'C-PAD-5',     'twc_toggle_dock_tool_window_with_focus' },
        {'C-F4',        'twc_close_tool_window_with_focus'       },
        {'C-PAD-PLUS',  'twc_toggle_pin_tool_window_with_focus'  },
        {'C-S-PGUP',    'wfont_zoom_in'                      },
        {'C-S-PGDN',    'wfont_zoom_out'                     },
        {'C-S-PGDN',    'wfont_zoom_out'                     },
    };
    static _str g_tool_window_list[] = 
    {
        '_tbsearch_form',               // activate_search
        '_tbtagwin_form',               // activate_tagwin,activate_symbol,activate_preview
        '_tbtagrefs_form',              // activate_references
        '_tbshell_form',                // activate_build
        '_tboutputwin_form',            // activate_output
        '_tbprojects_form',             // activate_projects,activate_project_files
        '_tbcontext_form',              // activate_context
        '_tbproctree_form',             // activate_defs,activate_project_procs,activate_project_defs
        '_tbfilelist_form',             // activate_files
        '_tbfilelist_form',             // activate_files_files
        '_tbfilelist_form',             // activate_files_project
        '_tbfilelist_form',             // activate_files_workspace
        '_tbfind_symbol_form',          // activate_find_symbol
        '_tbcbrowser_form',             // activate_cbrowser,activate_project_classes,activate_symbols_browser
        '_tbFTPOpen_form',              // activate_ftp,activate_project_ftp
        '_tbcbrowser_form',             // activate_project
        '_tbopen_form',                 // activate_open,activate_project_open()
        '_tbdebug_stack_form',          // activate_call_stack
        '_tbdebug_locals_form',         // activate_locals
        '_tbdebug_members_form',        // activate_members
        '_tbdebug_watches_form',        // activate_watch
        '_tbdebug_autovars_form',       // activate_autos
        '_tbdebug_autovars_form',       // activate_variables
        '_tbdebug_threads_form',        // activate_threads
        '_tbdebug_classes_form',        // activate_classes
        '_tbdebug_regs_form',           // activate_registers
        '_tbdebug_memory_form',         // activate_memory
        '_tbdebug_breakpoints_form',    // activate_breakpoints
        '_tbannotations_browser_form',  // activate_annotations
        '_tbmessages_browser_form',     // activate_messages
        '_tbbookmarks_form',            // activate_bookmarks
        '_tbdebug_exceptions_form',     // activate_exceptions
        '_tbdebug_sessions_form',       // activate_sessions
        '_tbfind_form',                 // activate_find
        '_git_repository_browser_form', // git repo browser
    };

    void get_key_bindings(_str fnName, _str (&keyBindings)[])
    {
        // For a more complete example, see at source for append_key_bindings
        // in "bind.e".
        int match_index=find_index(fnName, COMMAND_TYPE);
        //int match_index=find_index("float_window_toggle",COMMAND_TYPE);
        int index;
        VSEVENT_BINDING bindings:[];
        for (index = 0; index < g_tool_window_list._length(); ++index) {
            int tableIndex = find_index(g_tool_window_list[index], EVENTTAB_TYPE);
            if (index != 0) {
                //set_eventtab_index(tableIndex,event, fnIndexToBind);
                VSEVENT_BINDING list[];
                list_bindings(tableIndex,list,match_index);
                if (list._length()>0 ) {
                    int i;
                    for (i=0;i<list._length();++i) {
                        auto binding = list[i];
                        bindings:[binding.iEvent] = list[i];
                    }
                }
            }
        }

        VSEVENT_BINDING value;
        foreach ( index => value in bindings )
        {
            auto binding = bindings:[index];
            _str event = index2event(binding.iEvent);
            _str name = event2name(event, "S");
            //say("Index:" index ", Event #" binding.binding  ", name:" name);
            keyBindings[keyBindings._length()] = name;
        }
    }

    boolean do_bind_tool_window_toggles(int fnIndexToBind, _str keyName)
    {
        int index;
        auto event = event2index(name2event(keyName));
        //say("Keyname: "keyName", n2e:"name2event(keyName)", event:"event);
        if (event == -1) {
            _message_box("unknown event name: " keyName, "do_bind_tool_window_toggles", IDOK);
            return false;
        }
        for (index = 0; index < g_tool_window_list._length(); ++index) {
            int tableIndex = find_index(g_tool_window_list[index], EVENTTAB_TYPE);
            if (tableIndex == 0) {
                _message_box("unknown tool window: " g_tool_window_list[index], "do_bind_tool_window_toggles", IDOK);
                return false;
            } else {
                set_eventtab_index(tableIndex,event, fnIndexToBind);
            }
        }
        return true;
    }
};

using namespace float_tool_windows;

///////////////////////////////////////////////
// Commands to manipulate tool windows
///////////////////////////////////////////////
//_command void float_tool_window_with_focus()
//{
//    int fwid = _get_focus();
//    if (fwid > 0) {
//        int wid = fwid.p_active_form;
//        if (wid.p_isToolWindow) {
//            float_tool_window(wid);
//        }
//    }
//}
//
//_command void dock_tool_window_with_focus()
//{
//    int fwid = _get_focus();
//    if (fwid > 0) {
//        int wid = fwid.p_active_form;
//        if (wid.p_isToolWindow) {
//            dock_tool_window(wid);
//        }
//    }
//}
//
_command void twc_toggle_dock_tool_window_with_focus()
{
    int fwid = _get_focus();
    if (fwid > 0) {
        int wid = fwid.p_active_form;
        if (wid.p_isToolWindow) {
            if ( tw_is_floating(wid) ) {
                dock_tool_window(wid);
            } else {
                float_tool_window(wid);
            }
        }
        fwid._set_focus();
    } else {
        //int wid = fwid.p_active_form;
        //say("No fwid:" fwid", Form:"wid", FormName:"wid.p_name);
    }
}

_command void twc_toggle_pin_tool_window_with_focus()
{
    int fwid = _get_focus();
    if (fwid > 0) {
        int wid = fwid.p_active_form;
        if (wid.p_isToolWindow) {
            if ( tw_is_auto(wid) ) {
                //say("Toggle restore:"tw_is_auto(wid));
                autorestore_tool_window(wid);
                p_window_id = fwid;
                _set_focus();
            } else {
                //say("Toggle hide:"tw_is_auto(wid));
                autohide_tool_window(wid);
            }
        }
    }
}

_command void twc_close_tool_window_with_focus()
{
    int fwid = _get_focus();
    if (fwid > 0) {
        int wid = fwid.p_active_form;
        if (wid.p_isToolWindow) {
            hide_tool_window(wid);
        }
    }
}

///////////////////////////////////////////////
// Commands to manage tool window key bindings
///////////////////////////////////////////////
_command void jp_toolwindow_toggles_bind()
{
    int fnIndex;

    foreach (auto binding in g_tool_key_bindings_table) {
        fnIndex  = find_index(binding.mBoundFunction, COMMAND_TYPE);
        if (fnIndex == 0) {
            _message_box("unknown function: " binding.mBoundFunction, "jp_toolwindow_toggles_bind", IDOK);
            break;
        }
        if (!do_bind_tool_window_toggles(fnIndex, binding.mKeyName))
        {
            break;
        }
        say("BINDING "binding.mBoundFunction"("fnIndex") to "binding.mKeyName " ");
    }
}

_command void jp_toolwindow_toggles_unbind()
{
    foreach (auto binding in g_tool_key_bindings_table) {
        _str bindings [];
        get_key_bindings(binding.mBoundFunction, bindings);
        _str name;
        foreach (name in bindings) {
            do_bind_tool_window_toggles(0, name);
        }
    }
}

_command void jp_toolwindow_toggles_list()
{
    foreach (auto binding in g_tool_key_bindings_table) {
        _str bindings [];
        get_key_bindings(binding.mBoundFunction, bindings);
        _str name;
        foreach (name in bindings) {
            say(name " bound to " binding.mBoundFunction);
        }
    }
}

