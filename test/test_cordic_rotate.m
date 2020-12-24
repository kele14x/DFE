%%
% Copyright (C) 2020 kele14x
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <https://www.gnu.org/licenses/>.

%%
% File: test_cordic_rotate.m
% Brief: Test bench for model cordic_rotate

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
[xout, yout] = cordic_rotate(xin, yin, thetab, ...
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
writehex(xin, fullfile(dfepath(), './data/test_cordic_rotate_input_xin.txt'), InputWordLength);
writehex(yin, fullfile(dfepath(), './data/test_cordic_rotate_input_yin.txt'), InputWordLength);
writehex(thetab, fullfile(dfepath(), './data/test_cordic_rotate_input_theta.txt'), Iterations+1);

% Golden output
writehex(xout, fullfile(dfepath(), './data/test_cordic_rotate_output_xout.txt'), InputWordLength+2);
writehex(yout, fullfile(dfepath(), './data/test_cordic_rotate_output_yout.txt'), InputWordLength+2);
