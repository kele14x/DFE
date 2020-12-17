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
% File: test_cfr_hardclipping.m
% Brief: Test bench for function cfr_hardclipping

%% Configurations
clc;
clearvars;
close all;

% Load test input, which is a OFDM100 waveform
% formatted 16 bit, -15 dBFS
fn = fullfile(dfepath(), './data/ofdm100.mat');

if ~exist(fn, 'file')
    gen_ofdm100;
end

ofdm100 = load(fn);
x = ofdm100.waveform(1:4096);

% Sampling Frequency
Fs = ofdm100.Fs;

% Hard clipping threshold
threshold = round(sqrt(db2l(-7.5)) * 2^15);

%% Test
y = cfr_hardclipping(x, threshold);

%% Analysis Results
figure();
plot(abs(x));
hold on;
plot(abs(y), 'LineWidth', 1);
yline(threshold);

figure();
mypsd(x, Fs);
hold on;
mypsd(y, Fs);

evm(x, y);

%% Write Text File
writehex(real(x), fullfile(dfepath(), './data/test_cfr_hardclipping_data_i_in.txt'), 16);
writehex(imag(x), fullfile(dfepath(), './data/test_cfr_hardclipping_data_q_in.txt'), 16);
writehex(real(y), fullfile(dfepath(), './data/test_cfr_hardclipping_data_i_out.txt'), 16);
writehex(imag(y), fullfile(dfepath(), './data/test_cfr_hardclipping_data_q_out.txt'), 16);
