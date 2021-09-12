
// xretrace_plugin.sh is copied to xretrace.sh when packaging the xretrace plugin
#define XRETRACE_IS_PLUGIN yes

#define XRETRACE_VERSION '2.10'

#define XRETRACE_PATH "plugin://user_graeme.xretrace.ver." :+ XRETRACE_VERSION :+ "/"


#define XRETRACE_BITMAPS_PATH  XRETRACE_PATH :+ "bitmaps" :+ FILESEP



#define XRETRACE_MODULE_NAME XRETRACE_PATH :+ 'xretrace.e'

#define  XRETRACE_DATA_PATH  'c:/temp'
#define  XRETRACE_USE_SUBFOLDER YES



