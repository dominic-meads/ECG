#include <stdio.h>
#include "platform.h"
//#include "platform.c"
#include "xil_printf.h"
#include "mb_interface.h"
#include "xparameters.h"

#define AXI4_STREAM_ID 0
//#define getfsl(val, id)         asm volatile ("get\t%0,rfsl" stringify(id) : "=d" (val))

int main()
{
    init_platform();
    microblaze_disable_interrupts();

    int data[30];
    while(1)
    {
        // read in data on slave AXIS
        for (int i = 0; i <= 29; i++)
        {
            getfsl(data[i], 2);  // channel 0 is the pre-filter-output
        }
        // do some processing
        // output data on master AXIS
        // for (int i = 0; i <= 29; i++)
        // {
        //     putfsl(data[i], 0);
        // }
        // print data that was read in
        for (int i = 0; i <= 29; i++)
        {
            //xil_printf("Data from AXI4-Stream (Sample %d): %d\n\r\n\r",i,data[i]);
            xil_printf("%d\n\r",data[i]);
        }
    }
    cleanup_platform();
    return 0;
}
