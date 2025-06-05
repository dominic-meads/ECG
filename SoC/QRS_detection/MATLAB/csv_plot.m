close all
clear all
clc
%% Script to read ECG csv file from python program and graph it. 

DERIV_THRESHOLD = 0;
MA_THRESHOLD = 0;

cd 'C:\Users\demea\ECG\SoC\QRS_detection\python'

ECG_table = readtable('ECG_data.csv', 'VariableNamingRule', 'preserve');
FIR_bp = ECG_table.FIR_BP_sample;
moving_avg = ECG_table.Moving_Averaged_sample; 
deriv = ECG_table.Deriv_sample; 
peaks = ECG_table.peak; 
n = ECG_table.sample_number; 

cd 'C:\Users\demea\ECG\SoC\QRS_detection\MATLAB'

%% find maximums of 2nd derivative signal
% loop is matlab equivalent of flat_max_has_occurred() function in C code
p = deriv;  % rename for easier reading in the loop
L = length(deriv);
k = 1;
for i = 21:L
    if p(i-20) > 0 && p(i-11) > 0 && p(i-1) > 0  % detect max in positive portion of signal
        if p(i-20) < p(i-11) && p(i-11) > p(i-1)
            if p(i-11) > DERIV_THRESHOLD
                ecg_diff_2_max(k) = i-11;
                k = k + 1;
            end
        end 
    end 
end 

%% find maximums of MA derivative signal
% loop is matlab equivalent of flat_max_has_occurred() function in C code
a = moving_avg; 
L = length(moving_avg);
k = 1;
for i = 21:L
    if a(i-20) > 0 && a(i-11) > 0 && a(i-1) > 0  % detect max in positive portion of signal
        if a(i-20) < a(i-11) && a(i-11) > a(i-1)
            if a(i-11) > MA_THRESHOLD
                ma_max(k) = i-11;
                k = k + 1;
            end
        end 
    end 
end 

%% graph all signals and peaks

figure;
plot(n,FIR_bp,LineWidth=2);
hold on;
plot(n,moving_avg,LineWidth=2);
hold on;
plot(ma_max, moving_avg(ma_max+1), 'b*', MarkerSize=10);
hold on;
plot(n,deriv,LineWidth=2);
hold on;
plot(ecg_diff_2_max, deriv(ecg_diff_2_max+1), 'b.', MarkerSize=20);
% uncomment below 2 line to plot peak locations
hold on;
plot(n,peaks*1000); % increase amplitude to see where peaks are
title("Detected Maxes")
xlabel("Sample #");
ylim([-2000,6000]);
ylabel("Amplitude");

% uncomment below line to plot peak locations
legend("FIR BP", "Moving Average", "Moving Average Maximum", "Smoothed 2nd Deriv", "2nd Deriv Maximums", "Peak Location"); %
%legend("FIR BP", "Moving Average", "Moving Average Maximum", "Smoothed 2nd Deriv", "2nd Deriv Maximums");

%% plot detected peaks

% % I have double detected peaks.
% % Go through peaks and reject doubles 

% double_peaks = find(peaks);
% QRS_peaks = double_peaks(1:2:end); % pick out every other element
% 
% figure;
% plot(n,FIR_bp);
% hold on;
% h = plot(double_peaks,FIR_bp(double_peaks),'s','MarkerSize',10,...
%     'MarkerEdgeColor','red',...
%     'MarkerFaceColor',[1 .6 .6]);
% ylim([0 3000]);
% title("Double Detected Peaks");
% 
% figure;
% plot(n,FIR_bp);
% hold on;
% h = plot(QRS_peaks,FIR_bp(QRS_peaks),'s','MarkerSize',10,...
%     'MarkerEdgeColor','red',...
%     'MarkerFaceColor',[1 .6 .6]);
% ylim([0 3000]);
% title("Detected QRS Peaks");

QRS_peaks = find(peaks);

figure;
plot(n,FIR_bp);
hold on;
h = plot(QRS_peaks,FIR_bp(QRS_peaks),'s','MarkerSize',10,...
    'MarkerEdgeColor','red',...
    'MarkerFaceColor',[1 .6 .6]);
ylim([0 3000]);
title("Detected QRS Peaks");
xlabel("Sample #");
ylabel("Amplitude");




