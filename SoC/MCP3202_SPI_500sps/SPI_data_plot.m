%% Reads exported csv files (with samples) from Digilent Logic Analyzer 
% Set Digilent Analog Discovery 2 Logic Analyzer to 4096 samples @ fs = 500 Hz (make sure not 512 Hz)

clear all
close all
clc

% code for 4096 samples @ fs = 500 Hz (ECG sample frequency)
ECG_clean_table = readtable('ECG_clean.csv', 'VariableNamingRule', 'preserve');
[a,b] = size(ECG_clean_table);
ecg_clean = zeros(1,a);
ecg_clean = ECG_clean_table.Data;

v = 3.3*(ecg_clean./4095); % change all to vref
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



% From electrode
Vref = 3.12;
Ts = 1/fs;
n = 0:4095;
t = n*Ts;

ecg_body = 1.56 + 1.56*cos(2*pi*60*t) + 0.01*cos(2*pi*1*t) + 0.02*cos(2*pi*2*t);
t = (0:length(ecg_body)-1)/(fs);

ecg_body_seg = ecg_body(1250:2250); 
ts = (0:length(ecg_body_seg)-1)/(fs);

figure('Color',[1,1,1]);
plot(ts,ecg_body_seg);
title('ECG signal (At Electrode)');
ylim([0 3.12]);
xlabel('Time (s)');
ylabel('ECG Amplitude (V)');


% From AFE

ecg_noisy_seg = Vref*(ecg_noisy(1250:2250)./4095); 
ts = (0:length(ecg_noisy_seg)-1)/(fs);

figure('Color',[1,1,1]);
plot(ts,ecg_noisy_seg);
title('ECG signal (AFE Output)');
ylim([0 3.12]);
xlabel('Time (s)');
ylabel('ECG Amplitude (V)');

% After Filter

fc = 50;
Wc = fc/(fs/2);
b = fir1(1000,Wc);
freqz(b,1,2^10,fs);


ecg_filt1 = filtfilt(b,1,ecg_noisy);
ecg_filt2 = smoothdata(ecg_filt1);
ecg_filt_seg = Vref*(ecg_filt2(1250:2250)./4095); 
ts = (0:length(ecg_filt_seg)-1)/(fs);

figure('Color',[1,1,1]);
plot(ts,ecg_filt_seg);
title('ECG signal (Filtered)');
ylim([0 3.12]);
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


