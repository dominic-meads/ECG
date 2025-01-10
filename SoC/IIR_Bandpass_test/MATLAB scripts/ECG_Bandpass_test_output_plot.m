%% Reads exported csv files (with samples) from Digilent Logic Analyzer 
% Samples are outputs from IIR bandpass filter on FPGA
% Set Digilent Analog Discovery 2 Logic Analyzer to 4096 samples @ fs = 500 Hz (make sure not 512 Hz)
% output data format is two's complement

clear all
%close all
clc

fs = 500;
vref = 3.12; % voltage reference of ADC (unipolar)

ECG_raw_table = readtable('ECG_raw.csv', 'VariableNamingRule', 'preserve');
ecg_raw = ECG_raw_table.axis_tdata;
v_ecg_raw = vref*(ecg_raw./4095);
t = (0:length(v_ecg_raw)-1)/(fs);
figure('Color',[1,1,1]);
plot(t,v_ecg_raw);
title('Raw ECG signal from AFE');
xlabel('Time (s)');
ylabel('ECG Amplitude (V)');
hold on;

bp_output_table = readtable('ECG_bandpass_test.csv', 'VariableNamingRule', 'preserve');
ecg_bp_filtered = bp_output_table.axis_tdata;
v_ecg_bp = vref*(ecg_bp_filtered./4095);
t = (0:length(v_ecg_bp)-1)/(fs);
%figure('Color',[1,1,1]);
plot(t,v_ecg_bp,'r');
title('ECG signal filtered with 8th order Bandpass (Fpass = 5-15 Hz)');
xlabel('Time (s)');
ylabel('ECG Amplitude (V)');


