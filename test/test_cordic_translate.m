%% Configurations
clc;
clearvars;
close all;

% Paramters for model
InputWordLength = 16;
InputFractionLength = 15;
CompensationScaling = true;
CompensationBins = 8;
Iterations = 7;
PhaseFormat = 'Binary';
RoundMode = 'Truncate';

% Parameters for simulation
nPts = 1000;

%% Generate Test Input
sz = [nPts, 1];
rg = [-2^(InputWordLength-1), 2^(InputWordLength-1)-1];

rng(12345);
xin = randi(rg, sz);
yin = randi(rg, sz);

%% Test
% DUT
[theta, r] = cordic_translate(xin, yin, ...
    'CompensationScaling', CompensationScaling, ...
    'CompensationBins', CompensationBins, ...
    'Iterations', Iterations, ...
    'PhaseFormat', PhaseFormat, ...
    'RoundMode', RoundMode);
theta_rad = cordic_bin2rad(theta, Iterations);

% Referernce
vec = complex(xin, yin);
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
stem(theta_rad * 180 / pi);
theta_err = theta_ref - theta_rad;
theta_err(theta_err > pi) = theta_err(theta_err > pi) - 2 * pi;
theta_err(theta_err < -pi) = theta_err(theta_err < -pi) + 2 * pi;
stem(theta_err * 180 / pi);
title(sprintf('Angle Error (RMS = %.4f degree)', rms(theta_err) * 180 / pi));
legend('Input', 'Output', 'Error');

%% Write Text File
% Test input
writehex(xin, fullfile(dfepath(), './data/test_cordic_translate_input_xin.txt'), InputWordLength);
writehex(yin, fullfile(dfepath(), './data/test_cordic_translate_input_yin.txt'), InputWordLength);

% Golden output
writehex(theta, fullfile(dfepath(), './data/test_cordic_translate_output_thetab.txt'), Iterations+1);
writehex(r, fullfile(dfepath(), './data/test_cordic_translate_output_r.txt'), InputWordLength+1);
