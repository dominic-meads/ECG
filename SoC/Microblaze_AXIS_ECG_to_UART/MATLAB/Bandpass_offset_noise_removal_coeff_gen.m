%% Generates fixed-point coefficients for biquads implemented in FPGA. 
% See biquad code: https://github.com/dominic-meads/Vivado-Projects/blob/main/IIR_Direct_form_1_Biquad/iir_DF1_Biquad_AXIS.v
%
% Want to generate Bandpass filter with cuttoffs of 2 Hz and 55 Hz to
% remove DC offset (motion artifacts/baseline drift), and power line 60 Hz
% noise

close all
clear all
clc

fs = 500;

%% Pre-conditioning Bandpass filter design
% noise and offset removal
fcL = 2;
fcH = 48;
WcL = fcL/(fs/2);
WcH = fcH/(fs/2);

b = fir1(50,[WcL WcH]);
figure('Color', [1,1,1]);
freqz(b,1,2^10,fs);

%% scale the coefficients by scale_factor
% max multipler 25 bits (signed), 1 bit for sign, one bit for 1s place, 23 bits for fractional
scale_factor = 23; 
b_scaled = fix(b*(2^scale_factor));

%% Test filter with ECG data
ECG_pcb_test_table = readtable('ECG_PCB_test.csv', 'VariableNamingRule', 'preserve');
[rows,cols] = size(ECG_pcb_test_table);
ecg_pcb = ECG_pcb_test_table.Data;
x = 1:length(ecg_pcb);
figure('Color',[1,1,1]);
plot(x,ecg_pcb);
title('Raw ECG signal vs noise filtered');
xlabel('Sample');
ylabel('ECG Amplitude (12-bit number)');
hold on;
ecg_filt = filtfilt(b_scaled,1,ecg_pcb);
plot(ecg_filt);


%% Generate waveform samples to test in Vivado simulation

Ts = 1/fs;
n = 0:349;
t = n*Ts;

% test waveform 10 Hz sinusoid with 60 Hz noise and DC component
x = 1.65 + 1*sin(2*pi*10*t) + 0.2*sin(2*pi*60*t); % add 1.65 V DC offset to simulate coming from unipolar ADC
% filter should elminate DC and 60 Hz (line noise)

figure('Color',[1 1 1]);
h = plot(t,x);
title('x(t) Sampled at fs =  500 Hz');
ylabel('Signal');
xlabel('Time (s)');

% quantize x
Vref = 3.3;
bits = 16; % precision of ADC
xq = (x./Vref)*((2^(bits-1))-1); % verilog signed 16 bit reg holds max value (2^15)-1 
xq_int = cast(xq,"int16");

figure('Color',[1 1 1]);
h = plot(t,xq_int,'.');
hold on;
h = plot(t,xq_int);
title('x(t) Quantized to 16-bit Integer: Sampled at fs = 500 Hz');
ylabel('Signal');
xlabel('Time (s)');

% must put files in xsim directory for vivado
cd 'C:\Users\demea\ECG\SoC\Microblaze_AXIS_ECG_to_UART\Microblaze_AXIS_ECG_to_UART\Microblaze_AXIS_ECG_to_UART.sim\sim_1\behav\xsim';
fid1 = fopen('10Hz_sine_wave_with_60_Hz_noise.txt','w');
fprintf(fid1,"%d\n",xq_int);
fclose(fid1);
fid2 = fopen('Bandpass_impulse_response_output.txt','r'); % create output file for tb
fclose(fid2);
% return to original directory
oldFolder = cd('C:\Users\demea\ECG\SoC\Microblaze_AXIS_ECG_to_UART\MATLAB');

%% perform the filter
yq = sosfilt(sos_fixed,x);
figure('Color',[1 1 1]);
plot(yq);
title("Expected Filter Output");
xlabel("Sample");
ylabel("Amplitude")

%% expected impulse response of filter
delta = zeros(1,500);
delta(1) = 32767;
hn = sosfilt(sos_fixed,delta);
figure('Color',[1 1 1]);
plot(hn);
title("Expected Impulse Response");

%% get impulse response output of FPGA simulation

% output file in vivado xsim directory
cd 'C:\Users\demea\ECG\SoC\Microblaze_AXIS_ECG_to_UART\Microblaze_AXIS_ECG_to_UART\Microblaze_AXIS_ECG_to_UART.sim\sim_1\behav\xsim';
fid2 = fopen('Bandpass_impulse_response_output.txt','r');
% get the impulse response samples
hn_f = fscanf(fid2,"%d");
fclose(fid2);
% return to original directory
oldFolder = cd('C:\Users\demea\ECG\SoC\Microblaze_AXIS_ECG_to_UART\MATLAB');

figure('Color',[1 1 1]);
plot(hn_f);
title("Impulse Response out of fixed-point Bandpass filter");

%% take Fourier Transform of impulse response to get frequency response
% magnitude looks great, phase doesnt match up? 

f = linspace(0,fs/2,size(hn_f,1)/2);
H_f = abs(fft(hn_f)); % magnitude of fft
H_f = H_f(1:end/2);   % plot single-sided spectrum
H_f_db = mag2db(H_f);
H_f_db = H_f_db - max(H_f_db); % normalize to maximum
figure('Color',[1 1 1]);
subplot(2,1,1);
plot(f,H_f_db);
grid on;
title("Frequency Response of fixed-point Bandpass filter");
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');

% get phase response also (I dont think this is right)
phase = atan2( imag(fft(hn_f)), real(fft(hn_f)) ) * 180/pi;  % phase in degrees
phase = phase(1:end/2);   % plot single-sided phase
subplot(2,1,2);
plot(f,phase);
grid on;
title("Phase Response of fixed-point Bandpass filter");
xlabel('Frequency (Hz)');
ylabel('Phase (degrees)');