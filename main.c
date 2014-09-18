/* OPOS Kernel Entry Point */

# include "defs.h"
# include "syssrv.c"
# include "init.c"
# include "console.c"
# include "shell.c"
# include "system.c"



void main()
{	
	int i=0 , j=0 , k = 0;char name[10];
	char buffer[255];
	clear(color(BLACK,WHITE)) ;
	print("OPOS v1.0",1,1);
	print("Loading.........",1,2) ;
	for(i=0;i<0xfff;++i)	
		for(j=0;j<0xfff;++j)
			for(k=0;k<0x4;++k);	
	welcome(); /* The Welcome Screen */
	osh_init();
	/*system_call();*/
	osh_load();
	print("Shut down..",1,3);
	print("You may shut down the system now.",1,4);
	for(;;);
}

