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
% File: test_cordic_translate.m
% Brief: Test bench for model cordic_translate

%% Configurations
clc;
clearvars;
close all;

% Paramters for model
InputWordLength = 16;
InputFractionLength = 15;
CompensationScaling = 'AddSub';
Iterations = 7;
PhaseFormat = 'Binary';
RoundMode = 'Truncate';

% Parameters for simulation
nPts = 1000;

%% Generate Test Input
sz = [nPts, 1];
rg = [-2^(InputWordLength - 1), 2^(InputWordLength - 1) - 1];

rng(12345);
xin = randi(rg, sz);
yin = randi(rg, sz);

%% Test
% DUT
[theta, r] = cordic_translate(xin, yin, ...
    'CompensationScaling', CompensationScaling, ...
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
stem(r_ref-r);
title(sprintf('Magnitude Error (RMS = %.4f%%)', rms(r_ref - r) / rms(r_ref) * 100));
legend('Input', 'Output', 'Error');

figure();
stem(theta_ref*180/pi);
hold on;
stem(theta_rad*180/pi);
theta_err = theta_ref - theta_rad;
theta_err(theta_err > pi) = theta_err(theta_err > pi) - 2 * pi;
theta_err(theta_err < -pi) = theta_err(theta_err < -pi) + 2 * pi;
stem(theta_err*180/pi);
title(sprintf('Angle Error (RMS = %.4f degree)', rms(theta_err) * 180 / pi));
legend('Input', 'Output', 'Error');

%% Write Text File
% Test input
writehex(xin, fullfile(dfepath(), './data/test_cordic_translate_input_xin.txt'), InputWordLength);
writehex(yin, fullfile(dfepath(), './data/test_cordic_translate_input_yin.txt'), InputWordLength);

% Golden output
writehex(theta, fullfile(dfepath(), './data/test_cordic_translate_output_theta.txt'), Iterations+1);
writehex(r, fullfile(dfepath(), './data/test_cordic_translate_output_r.txt'), InputWordLength+2);
