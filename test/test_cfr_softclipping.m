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
% File: test_cfr_softclipping.m
% Brief: Test bench for function cfr_softclipping

%% Clear
clc;
clearvars;
close all;

%% Test Input
Fs = 245.76e6;
Fs2 = Fs * 2;

[x1, conf1] = nrWaveGen('100');
[x2, conf2] = nrWaveGen('100');

b = hb_design(54, Fs, 50e6);

x1 = hb_up_model(x1, b);
x2 = hb_up_model(x2, b);

x = nco_model(x1, Fs, -50e6) + nco_model(x2, Fs, 50e6);
x = x / rms(x) * sqrt(db2l(-15)) * 2^15;

threshold = sqrt(db2l(-7.5)) * 2^15;

x = x(1:245760);

%%
y = cfr_softclipping(x, threshold);

%%
evm(x, y);

figure();
plot(abs(x));
hold on;
plot(abs(y));
yline(threshold);

figure();
mypsd(x, Fs);
hold on;
mypsd(y, Fs);

%% Write Text File
writehex(real(x), fullfile(dfepath(), './data/test_cfr_softclipping_data_i_in.txt'), 16);
writehex(imag(x), fullfile(dfepath(), './data/test_cfr_softclipping_data_q_in.txt'), 16);
writehex(real(y), fullfile(dfepath(), './data/test_cfr_softclipping_data_i_out.txt'), 16);
writehex(imag(y), fullfile(dfepath(), './data/test_cfr_softclipping_data_q_out.txt'), 16);
