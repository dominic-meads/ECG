/******************************************************************************
Peak detection of QRS complex. 

Program phase aligns all input signals by delaying the output with FIFO buffers in the FPGA
    Input signals:
        - FIR bandpass
        - Moving average
        - smoothed 2nd derivative

Once signals are all phase aligned, program looks for maximum of smoothed 2nd derivative. When
that is found, program starts looking for maximum of the FIR BP ECG signal. The maximum of the
ECG signal corresponds to the QRS complex peak. When this peak/maxium is discovered, program
prints a "1" over uart in addition to the ECG sample. Program stops looking for ECG peak once
the moving average signal reaches its peak. 

V1.0 4/6/2025
Dominic Meads
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "mb_interface.h"
#include "xparameters.h"

#define DERIV_TO_MA_DELAY_CYCLES 18
#define MA_TO_FIR_DELAY_CYCLES   95
#define DERIV_THRESHOLD_VALUE    300

// function to determine if max has occured
int max_has_occurred(int past_2_sample, int past_sample, int current_sample)
{
    int status = 0;

    // if the peak is at "past_sample", then both "past_2_sample" and "current_sample" will be less
    if(past_2_sample < past_sample && past_sample > current_sample)
    {
        status = 1;  // max has occurred
    }
    else
    {
        status = 0;
    }
    
    return status;
}

int main()
{
    init_platform();
    microblaze_disable_interrupts();

    print("Hello World\n\r");
    print("Successfully ran Hello World application");

    int past_2_ch0_sample  = 0;  // the oldest sample (delay of two)
    int past_ch0_sample    = 0;  // the previous sample
    int current_ch0_sample = 0;  // current sample

    int past_2_ch1_sample  = 0;  
    int past_ch1_sample    = 0;  
    int current_ch1_sample = 0; 

    int past_2_ch2_sample  = 0;  
    int past_ch2_sample    = 0;  
    int current_ch2_sample = 0; 

    // sample 2nd derivative (ch2) DERIV_TO_MA_DELAY_CYCLES times before sampling moving average to align
    for(int i = 0; i < DERIV_TO_MA_DELAY_CYCLES; i++)
    {
        getfsl(current_ch2_sample, 2);  
    }

    // sample Moving Averager (ch1) AND 2nd derivative (ch2) MA_TO_FIR_DELAY_CYCLES times before sampling FIR BP
    for(int i = 0; i < MA_TO_FIR_DELAY_CYCLES; i++)
    {
        getfsl(current_ch1_sample, 1); 
        getfsl(current_ch2_sample, 2);  
    }

    // enter infinite loop now that all signals are aligned
    while(1)
    {
        // update past samples
        past_2_ch0_sample = past_ch0_sample;
        past_ch0_sample = current_ch0_sample;

        past_2_ch1_sample = past_ch1_sample;
        past_ch1_sample = current_ch1_sample;

        past_2_ch2_sample = past_ch2_sample;
        past_ch2_sample = current_ch2_sample;        

        // get current sample for all channels
        getfsl(current_ch0_sample, 0);
        getfsl(current_ch1_sample, 1); 
        getfsl(current_ch2_sample, 2); 

        // start looking for max of 2nd derivative (ch2)
        if (max_has_occurred(past_2_ch2_sample, past_ch2_sample, current_ch2_sample) == 1) 
        {
            if (past_ch2_sample >= DERIV_THRESHOLD_VALUE)  // max must be greater than threshold
            {
                // look for max of ECG/FIR BP (ch0) until max of moving average is found
                while(max_has_occurred(past_2_ch1_sample, past_ch1_sample, current_ch1_sample) == 0) 
                {
                    // update past samples
                    past_2_ch0_sample = past_ch0_sample;
                    past_ch0_sample = current_ch0_sample;

                    past_2_ch1_sample = past_ch1_sample;
                    past_ch1_sample = current_ch1_sample;

                    past_2_ch2_sample = past_ch2_sample;
                    past_ch2_sample = current_ch2_sample;        

                    // get current sample for all channels
                    getfsl(current_ch0_sample, 0);
                    getfsl(current_ch1_sample, 1); 
                    getfsl(current_ch2_sample, 2); 

                    if(max_has_occurred(past_2_ch0_sample, past_ch0_sample, current_ch0_sample) == 1)
                    {
                        xil_printf("%d, 1\n\r",current_ch0_sample);  // print a 1 to show peak occurs here
                    }
                    else
                    {
                        xil_printf("%d, 0\n\r",current_ch0_sample);  // print a 0 to show no peak at current sample
                    }
                }
            }
            else
            {
                xil_printf("%d, 0\n\r",current_ch0_sample);  // print a 0 to show no peak at current sample
            }
        }
        else 
        {
            xil_printf("%d, 0\n\r",current_ch0_sample);  // print a 0 to show no peak at current sample
        }   
    }

    cleanup_platform();
    return 0;
}

