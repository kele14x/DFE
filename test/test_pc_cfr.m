% Copyright (C) 2020  kele14x
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

%%
% File: test_pc_cfr.m
% Brief: Test bench for model PC_CFR

%% Configurations
clc;
clearvars;
close all;

% Load test input, which is a 2C OFDM100 waveform @ 245.76 Msps
% formatted 16 bit, -15 dBFS
fn = fullfile(dfepath(), './data/ofdm100_2c_245.mat');
if ~exist(fn, 'file')
    gen_ofdm100_2c_245;
end
data = load(fn);

% Test input
% x = data.waveform(1:4096);
x = data.waveform;

% Sampling frequency
Fs = data.Fs;

% Hard clipping threshold
threshold_dB = -7.5;
threshold = round(sqrt(db2l(threshold_dB)) * 2^15);

% Signal Bandwidth
BW = 198e6;

% Upsampling factor
InterpolationFactor = 4;
NumberOfCPG = 6;

% Cancellation pulse
% Format like fi(1, 16, 14)
% The length of cancellation pulse is required to be 4n+1 length
n = 63;
cPulse = fir_design(n*2*InterpolationFactor, Fs*InterpolationFactor, BW/2, BW/2+2e6, 1, 'ls');
cPulse = round(cPulse / max(cPulse) * 2^14);

% Halfband filter hb1
hb1 = hb_design(18, Fs*2, BW/2);
hb2 = hb_design( 6, Fs*4, BW/2);
hb1 = round(hb1 * 2 * 2^15);
hb2 = round(hb2 * 2 * 2^15);

%% Test
y = PC_CFR(x, ...
    'CancellationPulse', cPulse, ...
    'CancellationPulseFractionLength', 14, ...
    'CancellationPulseWordLength', 16, ...
    'ClippingThreshold', threshold, ...
    'CoeFractionLength', 15, ...
    'CoeWordLength', 16, ...
    'DetectionThreshold', threshold, ...
    'HB1', hb1, ...
    'HB2', hb2, ...
    'InterpolationFactor', InterpolationFactor, ...
    'NumberOfCPG', NumberOfCPG, ...
    'PeakDetectWindow', 7, ...
    'RoundMode', 'PositiveInfinity', ...
    'XFractionLength', 15, ...
    'XWordLength', 16);

%% Analysis
evm(x, y);

figure();
plot(abs(x));
hold on;
plot(abs(y), '-x');
yline(threshold);
grid on;

figure();
ccdf(x);
hold on;
ccdf(y);

figure();
mypsd(x, Fs);
hold on;
mypsd(y, Fs);

%% Write Text File
% We will only do this if test vector is short (prepare for hardware
% verification)
if (length(x) <= 4096)
    writehex(real([0, cPulse, 0, 0]), fullfile(dfepath(), './data/test_pc_cfr_cancellation_pulse_i.txt'), 16);
    writehex(imag([0, cPulse, 0, 0]), fullfile(dfepath(), './data/test_pc_cfr_cancellation_pulse_q.txt'), 16);

    writehex(real(x), fullfile(dfepath(), './data/test_pc_cfr_data_i_in.txt'), 16);
    writehex(imag(x), fullfile(dfepath(), './data/test_pc_cfr_data_q_in.txt'), 16);

    writehex(real(y), fullfile(dfepath(), './data/test_pc_cfr_data_i_out.txt'), 16);
    writehex(imag(y), fullfile(dfepath(), './data/test_pc_cfr_data_q_out.txt'), 16);
end
