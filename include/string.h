/* String Manipulation Functions */

 u16b strlen(u8b *s1)
 {	u16b counter =0;
	while(*s1)
	{	counter++;
		s1++;
	}
	return counter;
 }

 u8b streq(char *s1,char *s2)
 {	if(strlen(s1)==strlen(s2))
	{	int i=0;
		for(;i<strlen(s1);++i)
		{	if(s1[i]!=s2[i])
				return 0;
		}
		return 1;

	}
	return 0;
 }
 
