Testbench to determine how many delays are involved with each signal. 

The input signals to the processor are the FIR bandpass (to remove 60 Hz noise), the 75-point moving averaged signal, and the smoothed 2nd derivative. Each of these has a unique delay (in TVALID assertions/clock cycles) associated with it. 

In order for the peak detection software to work, all input signals to the processor must be phase aligned. It was prototyped in MATLAB this way using zero-phase filtering (see function "filtfilt" in MATLAB). 

This testbench/project determines correct delay to phase align all signals. 