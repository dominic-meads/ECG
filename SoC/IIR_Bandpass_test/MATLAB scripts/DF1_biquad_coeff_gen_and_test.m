%% Generats coefficients for a direct-form I biquad implemented on an fpga
% * converts coefficients to fixed-point and tests stability. 
% * generates test stimulus waveform, and verifies impulse response of fpga
% output
%
% See biquad code: https://github.com/dominic-meads/Vivado-Projects/blob/main/IIR_Direct_form_1_Biquad/iir_DF1_Biquad_AXIS.v

close all
clear
clc

fs = 10e+06;
Ts = 1/fs;
n = 0:249;
t = n*Ts;

% test waveform 500 kHz sinusoid with 4 MHz noise
x = 1.65 + 1*sin(2*pi*500000*t) + 0.1*sin(2*pi*4000000*t); % add 1.65 V DC offset to simulate coming from unipolar ADC

figure('Color',[1 1 1]);
h = plot(t,x);
title('x(t) Sampled at fs = 10 MHz');
ylabel('Signal');

xlabel('Time (s)');

% quantize x
Vref = 3.3;
bits = 16; % precision of ADC
xq = (x./Vref)*((2^(bits-1))-1); % verilog signed 16 bit reg holds max value (2^15)-1 
xq_int = cast(xq,"int16");

% must put files in xsim directory for vivado
cd 'C:\Users\demea\ECG\SoC\IIR_Bandpass_test\IIR_Bandpass_test\IIR_Bandpass_test.sim\sim_1\behav\xsim';
fid1 = fopen('500kHz_sine_wave_with_noise.txt','w');
fprintf(fid1,"%d\n",xq_int);
fclose(fid1);
fid2 = fopen('Impulse_response_output.txt','w'); % create output file for tb
fclose(fid2);
% return to original directory
oldFolder = cd('C:\Users\demea\ECG\SoC\IIR_Bandpass_test\MATLAB scripts');


figure('Color',[1 1 1]);
h = plot(t,xq_int,'.');
hold on;
h = plot(t,xq_int);
title('x(t) Quantized to 16-bit Integer: Sampled at fs = 10 MHz');
ylabel('Signal');
xlabel('Time (s)');

%% generate filter coefficents
% LP elliptical filter cutoff @ 1.5 MHz 
% should elimate 4 MHz kHz noise and pass 500 kHz component
fc = 1.5e+6;
Wc = fc/(fs/2);
[B,A] = ellip(2,0.5,40,Wc);

figure('Color',[1 1 1]);
freqz(B,A,2^10,fs);
figure('Color',[1 1 1]);
zplane(B,A);

%% playing with embedding gain

% MATLAB SAYS NOT RECCOMENDED FOR DIRECT-FORM II, okay for Direct-form I
[sos_embedded_gain] = tf2sos(B,A) 

% proper way for DF2
[sos,g] = tf2sos(B,A)

%% multiply coefficients to get fixed point
scale_factor = 14;
Afixed = fix(A*(2^scale_factor))
Bfixed = fix(B*(2^scale_factor))

%% check stability of fixed point coefficients
figure('Color',[1 1 1]);
zplane(Bfixed, Afixed);
hold on;
title("Pole-Zero Plot After Fixed Point Conversion");

%% Step response check
step_smpls = 1000*ones(1,250);
step_fixed = filter(Bfixed,Afixed,step_smpls);
figure('Color',[1 1 1]);
plot(step_fixed,'r');
hold on;
step_rsp = filter(B,A,step_smpls);
plot(step_rsp,'b');
title("Step response fixed-point vs floating point coefficients");
legend({'Fixed-point','Floating-point'});

%% perform the filter
yq = filter(Bfixed,Afixed,xq_int);
figure('Color',[1 1 1]);
plot(yq);

%% expected impulse response of filter
delta = zeros(1,50);
delta(1) = 32767;
hn = filter(Bfixed,Afixed,delta);
figure('Color',[1 1 1]);
plot(hn);
title("Impulse Response");

%% get impulse response output of FPGA simulation

% output file in vivado xsim directory
cd 'C:\Users\demea\ECG\SoC\IIR_Bandpass_test\IIR_Bandpass_test\IIR_Bandpass_test.sim\sim_1\behav\xsim';
fid2 = fopen('Impulse_response_output.txt','r');
% get the impulse response samples
hn_f = fscanf(fid2,"%d");
fclose(fid2);
% return to original directory
oldFolder = cd('C:\Users\demea\ECG\SoC\IIR_Bandpass_test\MATLAB scripts');

figure('Color',[1 1 1]);
plot(hn_f);
title("Impulse Response out of fixed-point DF1 Biquad");

%% take Fourier Transform of impulse response to get frequency response
% magnitude looks great, phase doesnt match up? 

f = linspace(0,fs/2,size(hn_f,1)/2);
H_f = abs(fft(hn_f)); % magnitude of fft
H_f = H_f(1:end/2);   % plot single-sided spectrum
H_f_db = mag2db(H_f);
H_f_db = H_f_db - max(H_f_db); % normalize to maximum? not sure if this is okay to do
figure('Color',[1 1 1]);
subplot(2,1,1);
plot(f,H_f_db);
grid on;
title("Frequency Response of fixed-point DF1 Biquad");
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');

% get phase response also (I dont think this is right)
phase = atan2( imag(fft(hn_f)), real(fft(hn_f)) ) * 180/pi;  % phase in degrees
phase = phase(1:end/2);   % plot single-sided phase
subplot(2,1,2);
plot(f,phase);
grid on;
title("Phase Response of fixed-point DF1 Biquad");
xlabel('Frequency (Hz)');
ylabel('Phase (degrees)');




