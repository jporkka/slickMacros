I've found that some tool windows in Slick that have a table with columns do not always
get correctly sized by default.

The result is one or more columns isn't visible because the columns are much too wide.
Fixing this manually is difficult.
Some tools, like References, do not have column headers or horizontal scrollers,
making it impossible to fix manually.

This macro adds a hot key, Alt+Q, to several of these tool windows.
This function will automatically resize the columns in these tables to fit their contents.

