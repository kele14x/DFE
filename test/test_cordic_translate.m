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
conf = [];
conf.Iterations = 6;
conf.CoarseRotation = true;
[mag, ang] = cordic_translate(vec, conf);

%% Analysis result
figure();
stem(abs(vec));
hold on;
stem(mag);
yyaxis right;
stem(abs(vec) - mag);
legend('Input', 'Output', 'Error');
fprintf('\n')
fprintf('Magnitude error RMS is %.4f%%\n', rms(abs(vec)-mag)/rms(abs(vec))*100);

figure();
stem(angle(vec) * 180 / pi);
hold on;
stem(ang * 180 / pi);
yyaxis right;
stem((angle(vec) - ang) * 180 / pi);
legend('Input', 'Output', 'Error');
fprintf('Angle error RMS is %.4f degree\n', rms(angle(vec)-ang) * 180 / pi);
