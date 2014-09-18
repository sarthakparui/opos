 # include "defs.h"
 # include "syssrv.c"
 # include "console.c"

 void init();
 void welcome();

 void init()
 {

 /* No Initializations for now */

 }

 /* The Welcoming Screen */
  
 void welcome()
 {	
	clear(color(BLUE,WHITE));
	boxoutset(10,2,70,8,color(BLUE,WHITE),color(BLUE,BLACK));
	boxinset (18,3,62,7,color(BLUE,WHITE),color(BLUE,BLACK));
	setattrib(color(BLUE,WHITE));
	print("OPOS - the OPen source Operating System",21,5);
	boxinset (10,10,70,22,color(BLUE,WHITE),color(BLUE,BLACK));
	print("* Project      : OPOS ",12,12);
	print("* Initiated By : Dipanjan Das ",12,13);
	print("* Contact me   : its.dipanjan.das@gmail.com ",12,14);
	print("* Design Goals..",12,17);
	print("   1) 32 bit,Protected Mode.",12,18);
	print("   2) Multitasking,FIFO Scheduling.",12,19);
	print("   3) File Systems: FAT 12/16/32,NTFS.",12,20);
	print("   4) CUI.",12,21);
	print(" Press Any Key To Continue... ",23,24);
	getch();
	clear(color(BLACK,WHITE));
 }
 
