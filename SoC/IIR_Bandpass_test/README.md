Test of IIR bandpass filter in verilog. 

Filter is prototyped in MATLAB, then the coefficients are scaled and converted to fixed-point integers. 

The Python program takes the sos output matrix of the MATLAB code and turns it into parameters for four instances
of second order IIR filter. 

The four sos sections are implemented on the FPGA in Direct-form 1 configuration, and are cascaded together. 

The goal is to make a 5-15 Hz bandpass filter with > 30 db attenuation at line frequencies (60 Hz) as described by the 
QRS detection algorithm proposed by Pan and Thompkins 
https://www.robots.ox.ac.uk/~gari/teaching/cdt/A3/readings/ECG/Pan+Tompkins.pdf
