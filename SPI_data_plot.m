% Settings for ILA are 4096 samples @ fs = 500 kHz

clear all
close all
clc

% code for 4096 samples @ fs = 500 Hz (ECG sample frequency)
ECG_clean_table = readtable('ECG_clean.csv', 'VariableNamingRule', 'preserve');
[a,b] = size(ECG_clean_table);
ecg_clean = zeros(1,a);
ecg_clean = ECG_clean_table.Data;

v = 3.3*(ecg_clean./4095);
fs = 500;
t = (0:length(v)-1)/(fs);
figure('Color',[1,1,1]);
plot(t,v);
title('ECG signal');
xlabel('Time (s)');
ylabel('ECG Amplitude (V)');


ECG_noisy_60Hz_table = readtable('ECG_noisy_60Hz.csv', 'VariableNamingRule', 'preserve');
[a,b] = size(ECG_noisy_60Hz_table);
ecg_noisy = zeros(1,a);
ecg_noisy = ECG_noisy_60Hz_table.Data;

v = 3.3*(ecg_noisy./4095);
fs = 500;
t = (0:length(v)-1)/(fs);
figure('Color',[1,1,1]);
plot(t,v);
title('ECG signal (60 Hz noise)');
xlabel('Time (s)');
ylabel('ECG Amplitude (V)');


ECG_baseline_drift_table = readtable('ECG_baseline_drift.csv', 'VariableNamingRule', 'preserve');
[a,b] = size(ECG_baseline_drift_table);
ecg_bd = zeros(1,a);
ecg_bd = ECG_baseline_drift_table.Data;

v = 3.3*(ecg_bd./4095);
fs = 500;
t = (0:length(v)-1)/(fs);
figure('Color',[1,1,1]);
plot(t,v);
title('ECG signal (Baseline Drift)');
xlabel('Time (s)');
ylabel('ECG Amplitude (V)');


ECG_after_exercise_table = readtable('ECG_after_exercise.csv', 'VariableNamingRule', 'preserve');
[a,b] = size(ECG_after_exercise_table);
ecg_fast = zeros(1,a);
ecg_fast = ECG_after_exercise_table.Data;

v = 3.3*(ecg_fast./4095);
fs = 500;
t = (0:length(v)-1)/(fs);
figure('Color',[1,1,1]);
plot(t,v);
title('ECG signal (After Jumping Jacks)');
xlabel('Time (s)');
ylabel('ECG Amplitude (V)');


% % Code for 4096 samples @ fs = 20 KHz
% data = zeros(1,40)
% current_dv = 0;
% previous_dv = 0;
% 
% k = 1;
% 
% for i = 2:a
%     % keep track of current and previous dv states
%     current_dv = SPI_data.DV(i);    
%     previous_dv = SPI_data.DV(i-1);
% 
%     % if dv transitons between 0 and 1 (rising edge), keep the data.
%     if (current_dv == 1) && (previous_dv == 0)    
%         data(k) = SPI_data.Data(i);
%         k = k+1;
%     end
% end


