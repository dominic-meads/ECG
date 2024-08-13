% Settings for ILA are 4096 samples @ fs = 20 kHz

clear all
close all
clc

SPI_data = readtable('SPI_export.csv', 'VariableNamingRule', 'preserve');
[a,b] = size(SPI_data);

data = zeros(1,40);

current_dv = 0;
previous_dv = 0;

k = 1;

for i = 2:a
    % keep track of current and previous dv states
    current_dv = SPI_data.DV(i);    
    previous_dv = SPI_data.DV(i-1);

    % if dv transitons between 0 and 1 (rising edge), keep the data.
    if (current_dv == 1) && (previous_dv == 0)    
        data(k) = SPI_data.Data(i);
        k = k+1;
    end
end

% plot data
v = 3.3*(data./4096);
fs = 500;
t = (0:length(v)-1)/(fs);
figure('Color',[1,1,1]);
plot(t,v);
xlabel('Time (s)');
ylabel('Voltage (V)');


