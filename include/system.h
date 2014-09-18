/*************************************************************************************
                                         GDT Date Structures
*************************************************************************************/

/* Defining GDT entry which is 8 byte long */
struct gdt_entry
{
    unsigned short limit_low;
    unsigned short base_low;
    unsigned char base_middle;
    unsigned char access;
    unsigned char granularity;
    unsigned char base_high;
};
/*__attribute__((packed));*/

/* Special pointer which includes the limit: The max bytes
*  taken up by the GDT, minus 1. */

struct gdt_ptr
{
    unsigned short limit;
    unsigned long base;
};
/*__attribute__((packed));*/

/*************************************************************************************
                               IDT Date Structures
*************************************************************************************/


/* Defining GDT entry which is 8 byte long */
struct idt_entry
{
    unsigned short base_lo;
    unsigned short sel;        /* Our kernel segment goes here! */
    unsigned char always0;     /* This will ALWAYS be set to 0! */
    unsigned char flags;       /* Set using the above table! */
    unsigned short base_hi;
};
/*__attribute__((packed));*/

struct idt_ptr
{
    unsigned short limit;
    unsigned int base;
};
/*__attribute__((packed));*/

