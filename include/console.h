 # ifndef _CONSOLE_
 # define _CONSOLE_

 # ifndef  OPOS_CPI
 # define  OPOS_CPI
 # endif
 
 /* A few global variables which store the
    properties of a console */

 const u8b Height = 25; /* Screen Height */
 const u8b Width  = 80; /* Screen Width  */

 const u8b TAB_Width = 4;
 const u8b TAB='\t';
 const u8b EOL='\n';

 const u8b horiz_line = 'Ä';
 const u8b vert_line  = '³';
 const u8b ul_corner  = 'Ú';
 const u8b ur_corner  = '¿';
 const u8b ll_corner  = 'À';
 const u8b lr_corner  = 'Ù';

 /* Color Constants */

 # define BLACK		0
 # define BLUE  	1
 # define GREEN		2
 # define CYAN		3
 # define RED		4
 # define MAGENTA	5
 # define BROWN 	6
 # define LIGHTGRAY	7
 # define DARKGRAY	8
 # define LIGHTBLUE 	9
 # define LIGHTGREEN	10
 # define LIGHTCYAN	11
 # define PINK		12
 # define LIGHTMAGENTA	13
 # define YELLOW	14
 # define WHITE		15
  
 # endif
