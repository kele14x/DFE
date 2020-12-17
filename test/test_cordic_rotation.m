%% Configurations
clc;
clearvars;
close all;

InputWordLength = 16;
InputFractionLength = 15;
CompensationScaling = 'AddSub';
Iterations = 7;
PhaseFormat = 'Binary';
RoundMode = 'Truncate';

nPts = 1000;

%% Generate Test Input
sz = [nPts, 1];

rng(12345);
xin = randi([-2^(InputWordLength - 1), 2^(InputWordLength - 1) - 1], sz);
yin = randi([-2^(InputWordLength - 1), 2^(InputWordLength - 1) - 1], sz);
theta = rand(sz) * 2 * pi - pi;
thetab = cordic_rad2bin(theta, Iterations);

%% Gold Result
temp = complex(xin, yin) .* exp(1j*theta);
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
stem(xout_ref-xout);
legend('Reference', 'Output', 'Error');
title(sprintf('Error RMS is %.4f%%\n', rms(xout_ref - xout) / rms(xout_ref) * 100));

figure();
stem(yout);
hold on;
stem(yout_ref);
stem(yout_ref-yout);
legend('Reference', 'Output', 'Error');
title(sprintf('Error RMS is %.4f%%\n', rms(yout_ref - yout) / rms(yout_ref) * 100));

%% Write Text File
% Test input
writehex(xin, fullfile(dfepath(), './data/test_cordic_rotation_input_xin.txt'), InputWordLength);
writehex(yin, fullfile(dfepath(), './data/test_cordic_rotation_input_yin.txt'), InputWordLength);
writehex(thetab, fullfile(dfepath(), './data/test_cordic_rotation_input_theta.txt'), Iterations+1);

% Golden output
writehex(xout, fullfile(dfepath(), './data/test_cordic_rotation_output_xout.txt'), InputWordLength+2);
writehex(yout, fullfile(dfepath(), './data/test_cordic_rotation_output_yout.txt'), InputWordLength+2);
