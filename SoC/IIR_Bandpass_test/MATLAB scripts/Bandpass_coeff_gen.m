%% Generates fixed-point coefficients for biquads implemented in FPGA. 
% See biquad code: https://github.com/dominic-meads/Vivado-Projects/blob/main/IIR_Direct_form_1_Biquad/iir_DF1_Biquad_AXIS.v
%
% Want to generate Bandpass filter with cuttoffs of 5 Hz and 15 Hz (corner
% frequencies defined in Pan-Thompkins QRS detection algorithm)

close all
clear all
clc

fs = 500;
fc1 = 5;
fc2 = 15;
Wc1 = fc1/(fs/2);
Wc2 = fc2/(fs/2);
[B,A] = butter(4,[Wc1,Wc2]);
filter_stable = isstable(B,A)

%% check zplane and frequency response
figure;
zplane(B,A);
title("Floating Point Coefficients Z-plane");
figure;
freqz(B,A,2^10,fs);
title("Floating Point Coefficients Frequency Response");

%% Generate fixed-point integer coefficients for FPGA

% Note embedding gain is okay here because FPGA bqiaud strcture is DF1
% gain is put into first section
[sos] = tf2sos(B,A);

% scale 
sos_scaled = (2^23)*sos;

% round to integer coefficients
sos_fixed = fix(sos_scaled)

%% Check stability of each section individually

for i = 1:size(sos_fixed,1)  % iterate for each row in sos matrix
    B_fixed = sos_fixed(i,1:3);
    A_fixed = sos_fixed(i,4:6);
    disp(['Section ', num2str(i), ' is stable?']);
    fixed_filter_stable = isstable(B_fixed,A_fixed)
    figure;
    zplane(B_fixed,A_fixed);
    title(['Section ', num2str(i), ' fixed-point zplane']);
end 

%% check frequency response and zplane of fixed-point coefficients

[B_fixed,A_fixed] = sos2tf(sos_fixed);
figure;
zplane(B_fixed,A_fixed);
title('fixed-point zplane');

%% print coefficients to file

sos_table = table();
sos_table.b0 = sos_fixed(:,1);
sos_table.b1 = sos_fixed(:,2);
sos_table.b2 = sos_fixed(:,3);
sos_table.a1 = sos_fixed(:,5);  % omit a0 coefficient
sos_table.a2 = sos_fixed(:,6);

writetable(sos_table, "fixed_point_int_coeff_4th_order_bp.csv");

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
cd 'C:\Users\demea\ECG\SoC\IIR_Bandpass_test\IIR_Bandpass_test\IIR_Bandpass_test.sim\sim_1\behav\xsim';
fid1 = fopen('10Hz_sine_wave_with_60_Hz_noise.txt','w');
fprintf(fid1,"%d\n",xq_int);
fclose(fid1);
fid2 = fopen('Bandpass_impulse_response_output.txt','w'); % create output file for tb
fclose(fid2);
% return to original directory
oldFolder = cd('C:\Users\demea\ECG\SoC\IIR_Bandpass_test\MATLAB scripts');

%% perform the filter
yq = filter(B_fixed,A_fixed,xq_int);
figure('Color',[1 1 1]);
plot(yq);
title("Expected Filter Output");
xlabel("Sample");
ylabel("Amplitude")

%% expected impulse response of filter
delta = zeros(1,500);
delta(1) = 32767;
hn = filter(B_fixed,A_fixed,delta);
figure('Color',[1 1 1]);
plot(hn);
title("Expected Impulse Response");

%% get impulse response output of FPGA simulation

% output file in vivado xsim directory
cd 'C:\Users\demea\ECG\SoC\IIR_Bandpass_test\IIR_Bandpass_test\IIR_Bandpass_test.sim\sim_1\behav\xsim';
fid2 = fopen('Bandpass_impulse_response_output.txt','r');
% get the impulse response samples
hn_f = fscanf(fid2,"%d");
fclose(fid2);
% return to original directory
oldFolder = cd('C:\Users\demea\ECG\SoC\IIR_Bandpass_test\MATLAB scripts');

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

