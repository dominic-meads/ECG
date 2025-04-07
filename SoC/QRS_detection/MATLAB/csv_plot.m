close all
clear all
clc
%% Script to read ECG csv file from python program and graph it. 

cd 'C:\Users\demea\ECG\SoC\QRS_detection\python'

ECG_table = readtable('ECG_data.csv', 'VariableNamingRule', 'preserve');
FIR_bp = ECG_table.FIR_BP_sample;
moving_avg = ECG_table.Moving_Averaged_sample; 
deriv = ECG_table.Deriv_sample; 
peaks = ECG_table.peak; 
n = ECG_table.sample_number; 

cd 'C:\Users\demea\ECG\SoC\QRS_detection\MATLAB'

figure;
plot(n,FIR_bp);
hold on;
plot(n,moving_avg);
hold on;
plot(n,deriv);
hold on;
plot(n,peaks*1000); % increase amplitude to see where peaks are
xlabel("Sample #");
ylim([-1000,3000]);
ylabel("Amplitude");
legend("FIR_BP", "Moving Average", "Smoothed 2nd Deriv", "Peak Location");

%%
% find maximums of 2nd derivative signal
p = deriv;  % rename for easier reading in the "find()" function
L = length(deriv);
ecg_diff_2_max = find((p(1:L-2)<p(2:L-1))&(p(2:L-1)>p(3:L)))+1; 

% threshold (reject maximums that are less than a threshold)
diff_2_threshold = 300; 
indicies_to_remove = find(ecg_diff_2_smooth(ecg_diff_2_max) < diff_2_threshold);
ecg_diff_2_max(indicies_to_remove) = [];  % remove maximums less than threshold



