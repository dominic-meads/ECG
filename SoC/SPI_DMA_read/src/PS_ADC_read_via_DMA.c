#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xaxidma.h"

#define DMA_DEV_ID			XPAR_AXIDMA_0_DEVICE_ID
#define DDR_BASE_ADDR		XPAR_AXIDMA_0_BASEADDR
#define RX_BUFFER_BASE		(0x00100000)
#define MAX_PKT_LEN			256 //bytes

int main()
{
    XAxiDma_Config *CfgPtr;
    XAxiDma AxiDma;
    int Status;
    int reset_done;
    u8 *RxBufferPtr;
    u32 addr;
    u16 value[MAX_PKT_LEN];

    init_platform();

    print("Hello World\n\r");
    print("Successfully ran Hello World application");

    CfgPtr = XAxiDma_LookupConfig(DMA_DEV_ID);
    if (!CfgPtr) 
    {
      printf("No config found for %d\r\n", DMA_DEV_ID);
      return XST_FAILURE;
    }

    Status = XAxiDma_CfgInitialize(&AxiDma, CfgPtr);
    if (Status != XST_SUCCESS) 
    {
      printf("Initialization DMA failed %d\r\n", Status);
      return XST_FAILURE;
    }

    RxBufferPtr = (u8 *)RX_BUFFER_BASE;

    addr = (u32)RX_BUFFER_BASE;

    XAxiDma_Reset(&AxiDma);
    reset_done = XAxiDma_ResetIsDone(&AxiDma);

    while(reset_done != 1)
    {

    }

    XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK,XAXIDMA_DEVICE_TO_DMA);
    XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK,XAXIDMA_DMA_TO_DEVICE);

    while(1)
    {
      Status = XAxiDma_SimpleTransfer(&AxiDma,(UINTPTR)RX_BUFFER_BASE,MAX_PKT_LEN, XAXIDMA_DEVICE_TO_DMA);
      if (Status != XST_SUCCESS) 
      {
        printf("XFER failed %d\r\n", Status);
        return XST_FAILURE;
      }
      while ((XAxiDma_Busy(&AxiDma,XAXIDMA_DEVICE_TO_DMA)))
      {
        /* Wait */
      }
      Xil_DCacheFlushRange((UINTPTR)RxBufferPtr, MAX_PKT_LEN);

      for(int Index = 0; Index < MAX_PKT_LEN; Index++) 
      {
		    value[Index] = RxBufferPtr[Index];
        printf("%d\n",value[Index]);
      }
    }

    cleanup_platform();
    return 0;
}