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

%% 2nd Derivative design (Derivative, then smoothing)

ecg_diff_2 = diff(ecg_ma);  % get slope of MA-filtered ECG

ecg_diff_2 = ecg_diff_2.*10; % try increasing amplitude? 

n_ma_2 = 40;
b_ma_2 = (1/n_ma_2)*ones(1,n_ma_2);
ecg_diff_2_smooth = filtfilt(b_ma_2,1,ecg_diff_2); 

%% 2nd Derivative Application

figure('Color',[1,1,1]);
plot(t,ecg_test,"Color",[0.6 0.87 1]);
hold on;
plot(t,ecg_bp,"Color",[1 0.3 0.3]);
hold on;
plot(t,[ecg_diff; 0],"Color",[0 0.6 0],"LineWidth",0.8);
hold on;
plot(t,0.125*[ecg_sqr; 0],"Color",[1 0.1 0.7]);
hold on;
plot(t,[ecg_ma; 0],"Color",[0.6 0.4 1],"LineWidth",1.5);
hold on;
plot(t,[ecg_diff_2; 0; 0],"LineWidth",1.5);
hold on;
plot(t,[ecg_diff_2_smooth; 0; 0],"Color", [0.8 0 0],"LineWidth",1.5);
ylabel("Amplitude");
xlabel("Time (s)");
legend({'ECG Raw', 'BP Filtered', 'Derivative', 'Squared', strcat(num2str(n_ma), '-Point Moving Average'), '2nd Derivative', 'Smoothed 2nd Derivative'});

%% Plot Raw, 2nd Derivative (Smoothed), and MA-filtered Signals

figure('Color',[1,1,1]);
plot(t,ecg_test,"Color",[0.45 0.70 1]);
hold on;
plot(t,[ecg_ma; 0],"Color",[0.6 0.4 1],"LineWidth",1.5);
hold on;
plot(t,[ecg_diff_2_smooth; 0; 0],"Color", [0.8 0 0],"LineWidth",1.5);
ylabel("Amplitude");
xlabel("Time (s)");
legend({'ECG Raw', strcat(num2str(n_ma), '-Point Moving Average'), 'Smoothed 2nd Derivative'});

%% QRS Detection logic (Find Mx of 2nd Derivatve and Max of MA Filtered Signal)
% Peaks can be seen in between the max of the 2nd derivative and the 
% max of the moving-averaged signal. 

% find maximums of 2nd derivative signal
p = ecg_diff_2_smooth;  % rename for easier reading in the "find()" function
L = length(ecg_diff_2);
ecg_diff_2_max = find((p(1:L-2)<p(2:L-1))&(p(2:L-1)>p(3:L)))+1;  

% find maximums of moving-averaged signal
p = ecg_ma;
L = length(ecg_ma);
ecg_ma_max = find((p(1:L-2)<p(2:L-1))&(p(2:L-1)>p(3:L)))+1;

figure('Color',[1,1,1]);
plot(t,[ecg_ma; 0],"Color",[0.6 0.4 1]);
hold on;
plot(ecg_ma_max/fs,ecg_ma(ecg_ma_max),'r*')
hold on;
plot(t,[ecg_diff_2_smooth; 0; 0]);
hold on;
plot(ecg_diff_2_max/fs,ecg_diff_2(ecg_diff_2_max),'b*');
ylabel("Amplitude");
xlabel("Time (s)");

%% Intervals Inbetween each

ppi = zeros(1,numel(ecg_ma_max));

for k = 1:numel(ecg_ma_max)
    i_start = ecg_diff_2_max(k);  % interval start

    if k < numel(ecg_diff_2_max) 
        i_end = ecg_ma_max(k);  % interval end
    else
        i_end = numel(ecg_diff_2);  % if the interval end is greater than the length of signal, just use the end of signal
    end

    x_intrvl = ecg_test(i_start:i_end);
    pp = find(x_intrvl==max(x_intrvl),1);
    ppi(k) = pp+i_start-1;
end

figure('Color',[1,1,1]);
plot(t,[ecg_ma; 0],"Color",[0.6 0.4 1]);
hold on;
plot(t,[ecg_diff_2; 0; 0]);
ylabel("Amplitude");
xlabel("Time (s)");

figure('Color',[1,1,1]);
plot(t,ecg_test);
hold on; 
h = plot(ppi/fs,ecg_test(ppi),'s');
set(h,'MarkerSize',7);
set(h,'MarkerEdgeColor',[0.5,0.5,0.5]);
set(h,'MarkerFaceColor','r');


%% Display 

