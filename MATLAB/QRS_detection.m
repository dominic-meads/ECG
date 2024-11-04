clear all
close all
clc

%% Read in 12-bit samples from ADC
% retrieved from SPI verilog code with logic analyzer
% 4096 samples @ fs = 500 Hz

vref = 3.12; % output voltage from isolated DC-DC (ADC reference)
qtz = (2^12)-1; % quantization factor for 12 bit ADC (qtz max sample value)
fs = 500;

% read exported csv file from logic analyzer
% samples taken while sitting still not touching anything except carpet
ECG_clean_table = readtable('ECG_clean.csv', 'VariableNamingRule', 'preserve');
[rows,cols] = size(ECG_clean_table);  % rows and columns of csv file
ecg_clean = ECG_clean_table.Data;  % init samples to result in "Data" column of file
v = vref*(ecg_clean/qtz); 
t = (0:length(v)-1)/fs;
figure('Color',[1,1,1]);
plot(t,v);
title('ECG signal');
xlabel('Time (s)');
ylabel('ECG Amplitude (V)');

% samples taken while sitting down, touching metal table with power strip
ECG_noisy_60Hz_table = readtable('ECG_noisy_60Hz.csv', 'VariableNamingRule', 'preserve');
[rows,cols] = size(ECG_noisy_60Hz_table);
ecg_noisy = ECG_noisy_60Hz_table.Data;
v = vref*(ecg_noisy/qtz);
t = (0:length(v)-1)/fs;
figure('Color',[1,1,1]);
plot(t,v);
title('ECG signal (60 Hz noise)');
xlabel('Time (s)');
ylabel('ECG Amplitude (V)');

% samples taken while moving around
ECG_baseline_drift_table = readtable('ECG_baseline_drift.csv', 'VariableNamingRule', 'preserve');
[rows,cols] = size(ECG_baseline_drift_table);
ecg_bd = ECG_baseline_drift_table.Data;
v = vref*(ecg_bd/qtz);
t = (0:length(v)-1)/fs;
figure('Color',[1,1,1]);
plot(t,v);
title('ECG signal (Baseline Drift)');
xlabel('Time (s)');
ylabel('ECG Amplitude (V)');

% samples taken standing up after jumping jacks
ECG_after_exercise_table = readtable('ECG_after_exercise.csv', 'VariableNamingRule', 'preserve');
[rows,cols] = size(ECG_after_exercise_table);
ecg_fast = ECG_after_exercise_table.Data;
v = vref*(ecg_fast/qtz);
t = (0:length(v)-1)/fs;
figure('Color',[1,1,1]);
plot(t,v);
title('ECG signal (After Jumping Jacks)');
xlabel('Time (s)');
ylabel('ECG Amplitude (V)');

% samples taken while sitting down not touching anything except carpet 
% first test of data aquisition PCB
ECG_pcb_test_table = readtable('ECG_PCB_test.csv', 'VariableNamingRule', 'preserve');
[rows,cols] = size(ECG_pcb_test_table);
ecg_pcb = ECG_pcb_test_table.Data;
v = vref*(ecg_pcb/qtz);
t = (0:length(v)-1)/fs;
figure('Color',[1,1,1]);
plot(t,v);
title('ECG signal (PCB Test)');
xlabel('Time (s)');
ylabel('ECG Amplitude (V)');

%% Bandpass filter design
fcL = 5;
fcH = 12;
WcL = fcL/(fs/2);
WcH = fcH/(fs/2);

[b_bp, a_bp] = butter(4,[WcL, WcH]);  % get maximally flat passband

figure('Color', [1,1,1]);
zplane(b_bp,a_bp);
figure('Color', [1,1,1]);
freqz(b_bp,a_bp,2^10,fs);

%% Bandpass Application

% concat all data into one big ecg
ecg_test = [ecg_clean; ecg_noisy; ecg_bd; ecg_fast; ecg_pcb];

ecg_bp = filtfilt(b_bp,a_bp,ecg_test);

t = (0:length(ecg_bp)-1)/fs;
figure('Color',[1,1,1]);
plot(t,ecg_test,"Color",[0.6 0.87 1]);
hold on;
plot(t,ecg_bp,"Color",[1 0.3 0.3]);
ylabel("Amplitude");
xlabel("Time (s)");
legend({'ECG Raw','BP Filtered'});


%% Derivative Design

% diff in matlab implements y(n) = x(n) - x(n-1)
ecg_diff = diff(ecg_bp);

%% Derivative Application

figure('Color',[1,1,1]);
plot(t,ecg_test,"Color",[0.6 0.87 1]);
hold on;
plot(t,ecg_bp,"Color",[1 0.3 0.3]);
hold on;
plot(t,[ecg_diff; 0],"Color",[0 0.6 0]);
ylabel("Amplitude");
xlabel("Time (s)");
legend({'ECG Raw','BP Filtered', 'Derivative'});

%% Squaring Function Application

ecg_sqr = ecg_diff.^2;

figure('Color',[1,1,1]);
plot(t,ecg_test,"Color",[0.6 0.87 1]);
hold on;
plot(t,ecg_bp,"Color",[1 0.3 0.3]);
hold on;
plot(t,[ecg_diff; 0],"Color",[0 0.6 0],"LineWidth",0.8);
hold on;
plot(t,[ecg_sqr; 0],"Color",[1 0.1 0.7]);
ylabel("Amplitude");
xlabel("Time (s)");
legend({'ECG Raw','BP Filtered', 'Derivative', 'Squared'});

%% Moving Average Filter Design

window_length = 0.150; % 150 ms window length
n_ma = fs*window_length;
b_ma = (1/n_ma)*ones(1,n_ma);

%% Moving Average Filter Application

ecg_ma = filtfilt(b_ma,1,ecg_sqr);

figure('Color',[1,1,1]);
plot(t,ecg_test,"Color",[0.6 0.87 1]);
hold on;
plot(t,ecg_bp,"Color",[1 0.3 0.3]);
hold on;
plot(t,[ecg_diff; 0],"Color",[0 0.6 0],"LineWidth",0.8);
hold on;
plot(t,[ecg_sqr; 0],"Color",[1 0.1 0.7]);
hold on;
plot(t,[ecg_ma; 0],"Color",[0.6 0.4 1]);
ylabel("Amplitude");
xlabel("Time (s)");
legend({'ECG Raw', 'BP Filtered', 'Derivative', 'Squared', strcat(num2str(n_ma), '-Point Moving Average')});

%% QRS detection 

dif_int = diff(ecg_ma);  % get slope of MA-filtered ECG

% detect points inbetween min of derivative and max of derivative
a = dif_int;
L = length(dif_int);
idmax = find((a(1:L-2)<a(2:L-1))&(a(2:L-1)>a(3:L)))+1;
idmin = find((a(1:L-2)>a(2:L-1))&(a(2:L-1)<a(3:L)))+1;

ppi = zeros(1,numel(idmax));

for k = 1:numel(idmax)
    i_start = idmax(k);

    if k < numel(idmin)  % if the interval end is greater than the length of signal, just use the end of signal
        i_end = idmin(k+1);
    else
        i_end = numel(dif_int);
    end

    x_intrvl = ecg_test(i_start:i_end);
    pp = find(x_intrvl==max(x_intrvl),1);
    ppi(k) = pp+i_start-1;
end

figure('Color',[1,1,1]);
plot(t,[ecg_ma; 0],"Color",[0.6 0.4 1]);
hold on;
plot(t,[dif_int; 0; 0]);
ylabel("Amplitude");
xlabel("Time (s)");

figure('Color',[1,1,1]);
plot(t,ecg_test);
hold on; 
h = plot(ppi/fs,ecg_test(ppi),'r*');
set(h,'MarkerSize',5); 


