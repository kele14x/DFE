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
% File: test_hb_up2.m
% Brief: Test bench for model hb_up2

%% Clear
clc;
clearvars;
close all;

%% Parameters
XinWordLength = 16;
XinFractionLength = 15;
CoeWordLength = 16;
CoeFractionLength = 15;
YoutWordLength = 16;
YoutFractionLength = 15;
RoundMode = 'PositiveInfinity';
CompensateDelay = false;
CompensatePower = false;

sz = [4096, 1];

%% Generate Test Vector
rng(12345);
rg = [-2^(XinWordLength - 1), 2^(XinWordLength - 1) - 1];
xin = randi(rg, sz);

coe = hb_design(10, 491.52e6 * 2, 149e6) * 2;
coe = round(coe * 2^CoeFractionLength);

%% Generate Golden Reference
yout_ref = conv(upsample(xin, 2), coe);
yout_ref = yout_ref(1:sz(1)*2, :);
yout_ref = yout_ref / 2^(XinFractionLength + CoeFractionLength - YoutFractionLength);
yout_ref = floor(yout_ref + 0.5);

ovf_ref = yout_ref >= 2^(YoutWordLength - 1) | ...
    yout_ref <= -2^(YoutWordLength - 1) - 1;

%% Test
[yout, ovf] = hb_up2(xin, ...
    'Coefficients', coe, ...
    'XinWordLength', XinWordLength, ...
    'XinFractionLength', XinFractionLength, ...
    'CoeWordLength', CoeWordLength, ...
    'CoeFractionLength', CoeFractionLength, ...
    'YoutWordLength', YoutWordLength, ...
    'YoutFractionLength', YoutFractionLength, ...
    'CompensateDelay', CompensateDelay, ...
    'CompensatePower', CompensatePower, ...
    'RoundMode', RoundMode);

%% Analysis Result
assert(all(yout == yout_ref));
assert(all(ovf == ovf_ref));

%% Write Text File
writehex(xin, fullfile(dfepath, './data/test_hb_up2_input_xin.txt'), XinWordLength);
writehex(coe, fullfile(dfepath, './data/test_hb_up2_input_coe.txt'), CoeWordLength);
writehex(yout, fullfile(dfepath, './data/test_hb_up2_output_yout.txt'), YoutWordLength);
writehex(ovf, fullfile(dfepath, './data/test_hb_up2_output_ovf.txt'), 1);
