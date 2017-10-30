/*
 * autoFixCols.e
 * joe porkka, 2017
 *
 * I've found that some tool windows in Slick that have a table with columns do not always
 * get correctly sized by default.
 * 
 * The result is one or more columns isn't visible because the columns are much too wide.
 * Fixing this manually is difficult.
 * Some tools, like References, do not have column headers or horizontal scrollers,
 * making it impossible to fix manually.
 * 
 * This macro adds a hot key, Alt+Q, to several of these tool windows.
 * This function will automatically resize the columns in these tables to fit their contents.
 * 
 * The supported tool windows are
 *  Tool            Form name                     Commands which open this tool
 *  Find Symbol     _tbfind_symbol_form           activate_find_symbol, gui_push_tag
 *  Annotations     _tbannotations_browser_form   activate_annotations, annotations_browser
 *  Projects        _tbprojects_form              activate_projects, activate_project_files
 *  References      _tbtagrefs_form               activate_references
 *  Defs            _tbproctree_form              activate_defs, activate_project_procs, activate_project_defs
 *  Message List    _tbmessages_browser_form      activate_messages
 *  _tbdebug_watches_form
 *  _tbopen_form
 *   
 */

#pragma option(pedantic,on)
#include "slick.sh"    
#import "treeview.sh"
#import "treeview.e"
#import "stdprocs.e"

static void sizeColumns(int treeWID)
{
    treeWID._TreeSizeColumnToContents(-1);
}

static void autoResize(_str ctlName, _str formName)
{
    treeWid := _find_control(ctlName);
    if (treeWid) {
        sizeColumns(treeWid);
    }
}

defeventtab _tbfind_symbol_form;
void _tbfind_symbol_form.'A-Q'()
{
    autoResize("ctl_symbols", "_tbfind_symbol_form");
}

defeventtab _tbmessages_browser_form;
void _tbmessages_browser_form.'A-Q'()
{
    autoResize("_message_tree", "_tbmessages_browser_form");
}

defeventtab _tbproctree_form;
void _tbproctree_form.'A-Q'()
{
    autoResize("_proc_tree", "_tbproctree_form");
}

defeventtab _tbprojects_form;
void _tbprojects_form.'A-Q'()
{
    autoResize("_proj_tooltab_tree", "_tbprojects_form");
}

defeventtab _tbannotations_browser_form;
void _tbannotations_browser_form.'A-Q'()
{
    autoResize("_annotation_tree", "_tbannotations_browser_form");
}

defeventtab _tbtagrefs_form;
void _tbtagrefs_form.'A-Q'()
{
    autoResize("ctlreferences", "_tbtagrefs_form");
}

defeventtab _tbdebug_watches_form;
void _tbdebug_watches_form.'A-Q'()
{
    autoResize("ctl_watches_tree1", "_tbdebug_watches_form");
}

defeventtab _tbopen_form;
void _tbopen_form.'A-Q'()
{
    autoResize("_file_tree", "_tbopen_form");
}
