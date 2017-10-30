If a call_list target function causes a slick-stack then Slick         
can get into a bad state where it keeps calling this function and      
the function keeps crashing.                                           
For targets like "_switchbuf_" this can be unrecoverable.              
                                                                       
This safe version of call_list keeps track - so if a function doesn't  
return, it won't get called again -- instant recovery.                 
Restarting slickedit clears its memory of bad functions.               
Modify message
* calllist2.e (3.49 kB - downloaded 8 times.)

https://community.slickedit.com/index.php/topic,15372.0.html

