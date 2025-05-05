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

%% find maximums of 2nd derivative signal
p = deriv;  % rename for easier reading in the "find()" function
L = length(deriv);
ecg_diff_2_max = find((p(1:L-2)<p(2:L-1))&(p(2:L-1)>p(3:L)))+1; 

%% find maximums of moving-averaged signal
p = moving_avg;
L = length(moving_avg);
ecg_ma_max = find((p(1:L-2)<p(2:L-1))&(p(2:L-1)>p(3:L)))+1;

%% if needed: plot maxes and mins

%% plot detected peaks

% I have double detected peaks.
% Go through peaks and reject doubles 

double_peaks = find(peaks);
QRS_peaks = double_peaks(1:2:end); % pick out every other element

figure;
plot(n,FIR_bp);
hold on;
h = plot(double_peaks,FIR_bp(double_peaks),'s','MarkerSize',10,...
    'MarkerEdgeColor','red',...
    'MarkerFaceColor',[1 .6 .6]);
ylim([0 3000]);
title("Double Detected Peaks");

figure;
plot(n,FIR_bp);
hold on;
h = plot(QRS_peaks,FIR_bp(QRS_peaks),'s','MarkerSize',10,...
    'MarkerEdgeColor','red',...
    'MarkerFaceColor',[1 .6 .6]);
ylim([0 3000]);
title("Detected QRS Peaks");




