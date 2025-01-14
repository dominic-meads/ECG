/******************************************************************************
* Copyright (C) 2023 Advanced Micro Devices, Inc. All Rights Reserved.
* SPDX-License-Identifier: MIT
******************************************************************************/
/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   115200
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */
 // UART Baud rate edited in "platform.h"
#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "mb_interface.h"
#include "xparameters.h"
#define AXI4_STREAM_ID 0
//#define getfsl(val, id)         asm volatile ("get\t%0,rfsl" stringify(id) : "=d" (val))
int main()
{
    init_platform();
    microblaze_disable_interrupts();
    //print("Hello World\n\r");
    //print("Successfully ran Hello World application");
    int data[30];
    while(1)
    {
        // read in data on slave AXIS
        for (int i = 0; i <= 29; i++)
        {
            getfsl(data[i], 0);
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

