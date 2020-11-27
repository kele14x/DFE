%% Clear
clc;
clearvars;
close all;

%% Generate Test Input
[x, conf] = nrWaveGen('100');
Fs = conf.Fs;
x = x / rms(x) * sqrt(db2l(-15)) * 2^15;
x = round(x);

threshold = sqrt(db2l(-7.5)) * 2^15;
threshold = round(threshold);

%%
y = cfr_hardclipping(x, threshold);


figure();
plot(abs(x));
hold on;
plot(abs(y), 'LineWidth', 1);
yline(threshold);

figure();
mypsd(x, Fs);
hold on;
mypsd(y, Fs);

evm(x, y);
