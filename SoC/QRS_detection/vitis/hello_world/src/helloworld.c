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

//#define DEBUG_60_BPM
#define DEBUG_40_BPM

#define SAMPLE_VECTOR_SIZE 21

#ifdef DEBUG_60_BPM
    #define DERIV_TO_MA_DELAY_CYCLES 18
    #define MA_TO_FIR_DELAY_CYCLES   89  // changed from 96
    #define DERIV_THRESHOLD_VALUE    300
    #define MA_THRESHOLD_VALUE       1500
    #define FIR_BP_THRESHOLD_VALUE   1850
#endif

#ifdef DEBUG_40_BPM
    #define DERIV_TO_MA_DELAY_CYCLES 18
    #define MA_TO_FIR_DELAY_CYCLES   89  // changed from 96
    #define DERIV_THRESHOLD_VALUE    1200
    #define MA_THRESHOLD_VALUE       4250
    #define FIR_BP_THRESHOLD_VALUE   1850
#endif

// function to determine if max has occured in a flatter signal
// it takes the past 8 samples and the current sample to determine if there has been a max
// a 21 sample window is used to detect peaks in non-impulsive signals such as the moving-average signal
// "past_20_sample is the oldest of the 21 samples, "past_10_sample" is the 10th oldest, etc...
// the max must be higher than the "threshold" for the "status" variable to update
int flat_max_has_occurred(int past_20_sample, int past_10_sample, int current_sample, int threshold)
{
    int status = 0;

    // make sure the peak is in the positive portion of signal
    if(past_20_sample > 0 && past_10_sample > 0 && current_sample > 0)
    {
        // if the peak is at "past_4_sample", then both "past_8_sample" and "current_sample" will be less
        if(past_20_sample < past_10_sample && past_10_sample > current_sample)
        {
            if(past_10_sample >= threshold)
            {
                status = 1;  // max above threshold has occurred                
            }
            else 
            {
                status = 0; 
            }
        }
        else
        {
            status = 0;
        }
    }
    
    return status;
}

// function to determine if max has occured in impulsive signal such as qrs complex
// in an impulsive signal, maximum will be more defined and peak of signal is less flat. 
// Therefore, the window to look at the max of the signal can be less samples than in the
// "flat_max_has_occured()" function. Having a shorter window decreases delay from 
// actual peak to detected peak.
// "past_4_sample is the oldest of the 5 samples, "past_2_sample" is the 2nd oldest
// the max must be higher than the "threshold" for the "status" variable to update
int impulsive_max_has_occurred(int past_4_sample, int past_2_sample, int current_sample, int threshold)
{
    int status = 0;

    // make sure the peak is in the positive portion of signal
    if(past_4_sample > 0 && past_2_sample > 0 && current_sample > 0)
    {
        // if the peak is at "past_2_sample", then both "past_4_sample" and "current_sample" will be less
        if(past_4_sample < past_2_sample && past_2_sample > current_sample)
        {
            if(past_2_sample >= threshold)
            {
                status = 1;  // max above threshold has occurred
            }
            else 
            {
                status = 0; 
            }
        }
        else
        {
            status = 0;
        }
    }
    
    return status;
}

// function to right shift array by 1 element
void right_shift_array(int * arr, int size)
{
    for(int i = size-1; i > 0; i--)
    {
        arr[i] = arr[i-1];
    }
    arr[0] = 0;
}

int main()
{
    init_platform();
    microblaze_disable_interrupts();

    // arrays to hold samples, index 19 is the oldest sample, index 0 is the newest
    int ch0_samples[SAMPLE_VECTOR_SIZE] = {};
    int ch1_samples[SAMPLE_VECTOR_SIZE] = {};
    int ch2_samples[SAMPLE_VECTOR_SIZE] = {};

    // sample 2nd derivative (ch2) DERIV_TO_MA_DELAY_CYCLES times before sampling moving average to align
    for(int i = 0; i < DERIV_TO_MA_DELAY_CYCLES; i++)
    {
        getfsl(ch2_samples[0], 2);  
    }

    // sample Moving Averager (ch1) AND 2nd derivative (ch2) MA_TO_FIR_DELAY_CYCLES times before sampling FIR BP
    for(int i = 0; i < MA_TO_FIR_DELAY_CYCLES; i++)
    {
        getfsl(ch1_samples[0], 1); 
        getfsl(ch2_samples[0], 2);  
    }

    // enter infinite loop now that all signals are aligned
    while(1)
    {
        // shift to make room for new sample
        right_shift_array(ch0_samples, SAMPLE_VECTOR_SIZE);
        right_shift_array(ch1_samples, SAMPLE_VECTOR_SIZE);
        right_shift_array(ch2_samples, SAMPLE_VECTOR_SIZE);      

        // get current sample for all channels
        getfsl(ch0_samples[0], 0);
        getfsl(ch1_samples[0], 1); 
        getfsl(ch2_samples[0], 2); 

        // start looking for max of 2nd derivative (ch2)
        if (flat_max_has_occurred(ch2_samples[20], ch2_samples[10], ch2_samples[0], DERIV_THRESHOLD_VALUE) == 1) 
        {
            // look for max of ECG/FIR BP (ch0) until max (above threshold) of moving average (ch1) is found
            while(flat_max_has_occurred(ch1_samples[20], ch1_samples[10], ch1_samples[0], MA_THRESHOLD_VALUE) == 0) 
            {
                // shift to make room for new sample
                right_shift_array(ch0_samples, SAMPLE_VECTOR_SIZE);
                right_shift_array(ch1_samples, SAMPLE_VECTOR_SIZE);
                right_shift_array(ch2_samples, SAMPLE_VECTOR_SIZE);      

                // get current sample for all channels
                getfsl(ch0_samples[0], 0);
                getfsl(ch1_samples[0], 1); 
                getfsl(ch2_samples[0], 2);

                // detect max above specified threshold
                // look for max over smaller window for max (qrs complex more implusive than MA or 2nd deriv)
                if(impulsive_max_has_occurred(ch0_samples[4], ch0_samples[2], ch0_samples[0], FIR_BP_THRESHOLD_VALUE) == 1)
                {
                    xil_printf("%d,%d,%d, 1\n\r",ch0_samples[0],ch1_samples[0],ch2_samples[0]);  // print a 1 to show peak occurs here
                    // what I think is happening here is that because I am using 5 samples in my 
                    // max_has_occured() function, there are essentially two maxes occuring next
                    // to each other. Maybe implement some sort of delay after the first one has occured?
                    // or a flag to ignore other maxes?
                    //xil_printf("ECG Max occurred ------\n\r");
                }
                else
                {
                    xil_printf("%d,%d,%d, 0\n\r",ch0_samples[0],ch1_samples[0],ch2_samples[0]);  // print a 0 to show no peak at current sample
                }
            }
            //xil_printf("MA max occured--------\n\r");
        }
        else 
        {
            xil_printf("%d,%d,%d, 0\n\r",ch0_samples[0],ch1_samples[0],ch2_samples[0]);  // print a 0 to show no peak at current sample
        }   
    }

    cleanup_platform();
    return 0;
}

