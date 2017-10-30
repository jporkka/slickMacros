#include "slick.sh"


// call_list_safe...
// If a call_list target function causes a slick-stack then Slick
// can get into a bad state where it keeps calling this function and
// the function keeps crashing.
// For targets like "_switchbuf_" this can be unrecoverable.
//
// This safe version of call_list keeps track - so if a function doesn't
// return, it won't get called again -- instant recovery.
// Restarting slickedit clears its memory of bad functions.
// 
//  Replaces the normal call_list with 
#define gcall_list_indexes g_Call_list_indexes
#define gcall_list_indexes_fail g_Call_list_indexes_fail
static int gcall_list_indexes:[][];
static int gcall_list_indexes_fail:[][];

definit()
{
   gcall_list_indexes._makeempty();
   gcall_list_indexes_fail._makeempty();
}

static boolean all_indexes_callable(int (&idx_list)[]) {
   foreach (auto index in idx_list) {
      if (!index_callable(index)) {
         return false;
      }
   }
   return true;
}

void _on_load_module_call_list_safe()
{
   gcall_list_indexes._makeempty();
   gcall_list_indexes_fail._makeempty();
}

void call_list_safe(_str prefix_name, ...)
{
   int orig_view_id=0;
   get_window_id(orig_view_id);

   // get the list of macro functions associated with this prefix
   int index=0;
   int idx_list[];
   int (*pidx_list)[];

   int fail_list[];
   int (*pfail_list)[];

   pidx_list=gcall_list_indexes._indexin(prefix_name);
   if (pidx_list && all_indexes_callable(*pidx_list)) {
       idx_list = *pidx_list;
       pfail_list=gcall_list_indexes_fail._indexin(prefix_name);
       fail_list = *pfail_list;
       //say("Faillist length :"fail_list._length());
   } else {
      max := _default_option(VSOPTION_WARNING_ARRAY_SIZE);
      index = name_match(prefix_name,1,PROC_TYPE);
      for (;;) {
         if ( !index ) { break; }
         if ( index_callable(index) ) {
            if (idx_list._length() >= max) {
               break;
            }
            idx_list :+= index;
            fail_list :+= 0;
         }
         index = name_match(prefix_name,0,PROC_TYPE);
      }
      gcall_list_indexes:[prefix_name] = idx_list;
      gcall_list_indexes_fail:[prefix_name] = fail_list;
   }
   pfail_list=gcall_list_indexes_fail._indexin(prefix_name);

   // now call each of them
   int i;
   for (i = 0; i < idx_list._length(); ++i) {
      index = idx_list[i];
      //say("I"i", index:"index", fail_list[i]:"fail_list[i]);
      if ((*pfail_list)[i] == 0) {
         (*pfail_list)[i] = 1;
          switch (arg()) {
          case 1: call_index(                                                 index); break;
          case 2: call_index(arg(2),                                          index); break;
          case 3: call_index(arg(2),arg(3),                                   index); break;
          case 4: call_index(arg(2),arg(3),arg(4),                            index); break;
          case 5: call_index(arg(2),arg(3),arg(4),arg(5),                     index); break;
          case 6: call_index(arg(2),arg(3),arg(4),arg(5),arg(6),              index); break;
          case 7: call_index(arg(2),arg(3),arg(4),arg(5),arg(6),arg(7),       index); break;
          case 8: call_index(arg(2),arg(3),arg(4),arg(5),arg(6),arg(7),arg(8),index); break;
          }
          (*pfail_list)[i] = 0;
      }
   }

   // restore to the original window, in case it changed
   if ( _iswindow_valid(orig_view_id) ) {
      activate_window(orig_view_id);
   }
}

