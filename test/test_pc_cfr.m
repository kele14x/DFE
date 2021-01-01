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
x = data.waveform(1:4096);

% Sampling frequency
Fs = data.Fs;

% Hard clipping threshold
threshold_dB = -7.5;
threshold = round(sqrt(db2l(threshold_dB)) * 2^15);

% Signal Bandwidth
BW = 198e6;

% Upsampling factor
UP = 2;

% Cancellation pulse
n = 63;
cPulse = fir_design(n*2*UP, Fs*2, BW/2, BW/2+2e6, 1, 'ls');
cPulse = round(cPulse / max(cPulse) * 2^15);

% Halfband filter hb1
hb1 = hb_design(18, Fs*2, BW/2);
hb1 = round(hb1 * 2 * 2^15);

%% Test
y = PC_CFR(x, ...
    'HB1', hb1, ...
    'Threshold', threshold, ...
    'CancellationPulse', cPulse, ...
    'RoundMode', 'Truncate');

%% Analysis
evm(x, y);

figure();
plot(abs(x));
hold on;
plot(abs(y));
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
% writehex(real(x), fullfile(dfepath(), './data/test_cfr_softclipping_data_i_in.txt'), 16);
% writehex(imag(x), fullfile(dfepath(), './data/test_cfr_softclipping_data_q_in.txt'), 16);
% writehex(real(y), fullfile(dfepath(), './data/test_cfr_softclipping_data_i_out.txt'), 16);
% writehex(imag(y), fullfile(dfepath(), './data/test_cfr_softclipping_data_q_out.txt'), 16);
