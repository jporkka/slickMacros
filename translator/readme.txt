Use the advanced regex functionality in Slickedit to do multiple search and replace operations at once.

First, create a table in a text file in the format:

	FromText==>ToText
    abc==>def
    123==>576

Now, select this text and run the macro translateTerms.

It will open the find and replace dialog with SearchFor and ReplaceWith populated with the regex necessary to 
translate each of the terms in the provided table.

