#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "00"

#define DMA_DEV_ID			XPAR_AXIDMA_0_DEVICE_ID
#define DDR_BASE_ADDR		XPAR_AXIDMA_0_BASEADDR
#define RX_BUFFER_BASE		(0x00100000)
#define MAX_PKT_LEN			16 //bytes

int main()
{
    XAxiDma_Config *CfgPtr;
    XAxiDma AxiDma;
    int Status;
    int reset_done;
    u16 *RxBufferPtr;
    u16 sample_array[512] = {0};

    init_platform();

    print("\nHello World\n\r");
    print("Successfully ran Hello World application\n\r");

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

    RxBufferPtr = (u16 *)RX_BUFFER_BASE;

    XAxiDma_Reset(&AxiDma);
    reset_done = XAxiDma_ResetIsDone(&AxiDma);

    while(reset_done != 1)
    {

    }

    XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK,XAXIDMA_DEVICE_TO_DMA);
    XAxiDma_IntrDisable(&AxiDma, XAXIDMA_IRQ_ALL_MASK,XAXIDMA_DMA_TO_DEVICE);

    Xil_DCacheFlushRange((UINTPTR)RxBufferPtr, MAX_PKT_LEN);

    for (int i = 0; i <= 63; i++)  // perform 64 8-sample transfers
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

		for(int Index = 0; Index < 8; Index++)
		{
		//printf("%u\n",RxBufferPtr[Index]);
		sample_array[(i*8)+Index] = RxBufferPtr[Index];
		}
		Xil_DCacheFlushRange((UINTPTR)RxBufferPtr, MAX_PKT_LEN);
    }

	for(int j = 0; j < 512; j++)
	{
	printf("%u\n",sample_array[j]);
	}

    cleanup_platform();
    return 0;
}
