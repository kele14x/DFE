%% Clear
clc;
clearvars;
close all;

%% Generate Test Input
nPts = 1000;
sz = [nPts, 1];

CompensationScaling = true;
Iterations = 7;
PhaseFormat = 'Binary';
RoundMode = 'None';

rng(12345);
xin = randi([-2^15, 2^15-1], sz);
yin = randi([-2^15, 2^15-1], sz);
theta = rand(sz) * 2 * pi - pi;
thetab = cordic_rad2bin(theta, Iterations);

%% Gold Result
temp = complex(xin, yin) .* exp(1j * theta);
xout_ref = real(temp);
yout_ref = imag(temp);

%% Test
[xout, yout] = cordic_rotation(xin, yin, thetab, ...
    'CompensationScaling', CompensationScaling, ...
    'Iterations', Iterations, ...
    'PhaseFormat', PhaseFormat, ...
    'RoundMode', RoundMode);

%% Analysis result
figure();
stem(xout);
hold on;
stem(xout_ref);
stem(xout_ref - xout);
legend('Reference', 'Output', 'Error');
title(sprintf('Error RMS is %.4f%%\n', rms(xout_ref-xout)/rms(xout_ref)*100));

figure();
stem(yout);
hold on;
stem(yout_ref);
stem(yout_ref - yout);
legend('Reference', 'Output', 'Error');
title(sprintf('Error RMS is %.4f%%\n', rms(yout_ref-yout)/rms(yout_ref)*100));
