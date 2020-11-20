%%
clc;
clearvars;
close all;

%%
[x1, conf1] = nrWaveGen('100');
[x2, conf2] = nrWaveGen('100');
Fs = conf1.Fs * 2;

b = hb_design(54, Fs, 50e6);

x1 = hb_up_model(x1, b);
x2 = hb_up_model(x2, b);

x = nco_model(x1, Fs, -50e6) + nco_model(x2, Fs, 50e6);
x = x / rms(x) * sqrt(db2l(-15));

cpw = fir_design(126, Fs, 98e6, 101e6);

%%
y = cfr(x, cpw, sqrt(db2l(-7.5)));
y = cfr(y, cpw, sqrt(db2l(-7.4)));
evm(x, y);

figure();
plot(abs(x));
hold on;
plot(abs(y), 'LineWidth', 2);


figure();
mypsd(x, Fs);
hold on;
mypsd(y, Fs);
