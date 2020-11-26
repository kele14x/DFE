%% Clear
clc;
clearvars;
close all;

%% Generate test input
nPts = 1000;
sz = [nPts, 1];

rng(12345);
vec = randi([-2^15, 2^15-1], sz) + 1j * randi([-2^15, 2^15-1], sz);

%% Test
[theta, r] = cordic_translate(vec, 'PhaseFormat', 'Radians');
theta_ref = angle(vec);
r_ref = abs(vec);

%% Analysis result
figure();
stem(r_ref);
hold on;
stem(r);
stem(r_ref - r);
legend('Input', 'Output', 'Error');
fprintf('Magnitude error RMS is %.4f%%\n', rms(r_ref-r)/rms(r_ref)*100);

%%
figure();
stem(theta_ref * 180 / pi);
hold on;
stem(theta * 180 / pi);
stem((theta_ref - theta) * 180 / pi);
legend('Input', 'Output', 'Error');
fprintf('Angle error RMS is %.4f degree\n', rms(theta_ref-theta) * 180 / pi);
