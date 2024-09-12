%% Implements a Pan-Thompkins QRS Detection with FIR Filters

clc
close all
clear

ECG_pcb_test_table = readtable('ECG_PCB_test.csv', 'VariableNamingRule', 'preserve');
[a,b] = size(ECG_pcb_test_table);
ecg_pcb = zeros(1,a);
ecg_pcb = ECG_pcb_test_table.Data;

Vref = 3.12;
v = Vref*(ecg_pcb./4095);
fs = 500;
t = (0:length(v)-1)/(fs);
figure('Color',[1,1,1]);
plot(t,v);
title('ECG signal (PCB Test)');
xlim([0 8]);
xlabel('Time (s)');
ylabel('ECG Amplitude (V)');


%% Actual BP Filter (as described in paper)

% Low Pass Filter Transfer Function
%
%         (1-z^-5)^2
% H(z) = ------------
%         (1-z^-1)^2

bl = [1 0 0 0 0 -2 0 0 0 0 1];  % z^-10 - 2*z^-5 + 1
al = [1 -2 1];                      % z^-2 - 2*z^-1 + 1
figure('Color',[1,1,1]);
freqz(bl,al,2^10,fs);

% High Pass Filter Transfer Function
%
%         (-1/32+z^-16-z^-17+z^-32)
% H(z) = ---------------------
%               (1-z^-1)

bh = [-1/32 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1/32];  
ah = [1 -1];                     
figure('Color',[1,1,1]);
freqz(bh,ah,2^10,fs);


%% 5-12 HZ Bandpass Filter

fc1 = 5;
fc2 = 12;
Wc1 = fc1/(fs/2);
Wc2 = fc2/(fs/2);
b1 = fir1(51,[Wc1 Wc2]);
figure('Color',[1,1,1]);
freqz(b1,1,2^10,fs);

fc3 = 5;
Wc3 = fc3/(fs/2);
b3 = fir1(100,Wc3,'high');
figure('Color',[1,1,1]);
freqz(b3,1,2^10,fs);

fc4 = 12;
Wc4 = fc4/(fs/2);
b4 = fir1(100,Wc4);
figure('Color',[1,1,1]);
freqz(b4,1,2^10,fs);

ecg_filt1 = filtfilt(b1,1,ecg_pcb);

ecg_filt_seg = Vref*(ecg_filt1(1250:2250)./4095); 
ts = (0:length(ecg_filt_seg)-1)/(fs);

figure('Color',[1,1,1]);
plot(ts,ecg_filt_seg);
title('ECG signal (Filtered)');
ylim([0 3.12]);
xlabel('Time (s)');
ylabel('ECG Amplitude (V)');