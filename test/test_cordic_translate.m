%% Clear
clc;
clearvars;
close all;

%% Generate test input
nPts = 100;
sz = [nPts, 1];

rng(12345);
vec = complex(randi([-2^15, 2^15-1], sz), randi([-2^15, 2^15-1], sz));

%% Test
CompensationScaling = true;
Iterations = 7;
PhaseFormat = 'Binary';
RoundMode = 'None';

[thetab, r] = cordic_translate(real(vec), imag(vec), ...
    'CompensationScaling', CompensationScaling, ...
    'Iterations', Iterations, ...
    'PhaseFormat', PhaseFormat, ...
    'RoundMode', RoundMode);
theta = cordic_bin2rad(thetab, Iterations);

theta_ref = angle(vec);
r_ref = abs(vec);

%% Analysis result
figure();
stem(r_ref);
hold on;
stem(r);
stem(r_ref - r);
title(sprintf('Magnitude Error (RMS = %.4f%%)', rms(r_ref-r)/rms(r_ref)*100));
legend('Input', 'Output', 'Error');

figure();
stem(theta_ref * 180 / pi);
hold on;
stem(theta * 180 / pi);
stem((theta_ref - theta) * 180 / pi);
title(sprintf('Angle Error (RMS = %.4f degree)', rms(theta_ref-theta) * 180 / pi));
legend('Input', 'Output', 'Error');
