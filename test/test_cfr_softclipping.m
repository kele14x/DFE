%% Clear
clc;
clearvars;
close all;

%% Test Input
Fs = 245.76e6;
Fs2 = Fs * 2;

[x1, conf1] = nrWaveGen('100');
[x2, conf2] = nrWaveGen('100');

b = hb_design(54, Fs, 50e6);

x1 = hb_up_model(x1, b);
x2 = hb_up_model(x2, b);

x = nco_model(x1, Fs, -50e6) + nco_model(x2, Fs, 50e6);
x = x / rms(x) * sqrt(db2l(-15)) * 2^15;

threshold = sqrt(db2l(-7.5)) * 2^15;

x = x(1:245760);
%%
y = cfr_softclipping(x, threshold);

%%
evm(x, y);

figure();
plot(abs(x));
hold on;
plot(abs(y));
yline(threshold);

%%
figure();
mypsd(x, Fs);
hold on;
mypsd(y, Fs);
