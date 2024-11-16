%% Generates fixed-point coefficients for biquads implemented in FPGA. 
% See biquad code: https://github.com/dominic-meads/Vivado-Projects/blob/main/IIR_Direct_form_1_Biquad/iir_DF1_Biquad_AXIS.v
%
% Want to generate Bandpass filter with cuttoffs of 5 Hz and 15 Hz (corner
% frequencies defined in Pan-Thompkins QRS detection algorithm)

close all
clear all
clc

fs = 500;
fc1 = 5;
fc2 = 15;
Wc1 = fc1/(fs/2);
Wc2 = fc2/(fs/2);
[B,A] = butter(4,[Wc1,Wc2]);
filter_stable = isstable(B,A)

%% check zplane and frequency response
figure;
zplane(B,A);
title("Floating Point Coefficients Z-plane");
figure;
freqz(B,A,2^10,fs);
title("Floating Point Coefficients Frequency Response");

%% Generate fixed-point integer coefficients for FPGA

% Note embedding gain is okay here because FPGA bqiaud strcture is DF1
% gain is put into first section
[sos] = tf2sos(B,A);

% scale 
sos_scaled = (2^23)*sos;

% round to integer coefficients
sos_fixed = fix(sos_scaled)

%% Check stability of each section individually

for i = 1:size(sos_fixed,1)  % iterate for each row in sos matrix
    B_fixed = sos_fixed(i,1:3);
    A_fixed = sos_fixed(i,4:6);
    disp(['Section ', num2str(i), ' is stable?']);
    fixed_filter_stable = isstable(B_fixed,A_fixed)
    figure;
    zplane(B_fixed,A_fixed);
    title(['Section ', num2str(i), ' fixed-point zplane']);
end 

%% check frequency response and zplane of fixed-point coefficients

[B_fixed,A_fixed] = sos2tf(sos_fixed);
figure;
zplane(B_fixed,A_fixed);
title('fixed-point zplane');

