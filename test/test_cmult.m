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
% File: test_cmult.m
% Brief: Test bench for function cmult

%% Clear
clc;
clearvars;
close all;

%% Parameters
AWordLength = 16;
AFractionLength = 15;
BWordLength = 16;
BFractionLength = 15;
PWordLength = 16;
PFractionLength = 15;
RoundMode = 'PositiveInfinity';

sz = [4096, 1];

%% Generate Test Vector
rng(12345);
rgA = [-2^(AWordLength - 1), 2^(AWordLength - 1) - 1];
rgB = [-2^(BWordLength - 1), 2^(BWordLength - 1) - 1];

a = complex(randi(rgA, sz), randi(rgA, sz));
b = complex(randi(rgB, sz), randi(rgB, sz));

p_ref = a .* b;
p_ref = p_ref / 2^(AFractionLength + BFractionLength - PFractionLength);
if strcmp(RoundMode, 'Truncate')
    p_ref = floor(p_ref);
elseif strcmp(RoundMode, 'PositiveInfinity')
    p_ref = floor(p_ref+0.5+0.5j);
end

ovf_ref = (real(p_ref) <= -2^(PWordLength - 1) - 1) | ...
    (real(p_ref) >= 2^(PWordLength - 1)) | ...
    (imag(p_ref) <= -2^(PWordLength - 1) - 1) | ...
    (imag(p_ref) >= 2^(PWordLength - 1));

%% Test
[p, ovf] = cmult(a, b, 'AWordLength', AWordLength, ...
    'AFractionLength', AFractionLength, ...
    'BWordLength', BWordLength, ...
    'BFractionLength', BFractionLength, ...
    'RoundMode', RoundMode);

%% Analysis Result
assert(all(p == p_ref));
assert(all(ovf == ovf_ref));

%% Write Text File
writehex(real(a), fullfile(dfepath(), './data/test_cmult_input_a_real.txt'), AWordLength);
writehex(imag(a), fullfile(dfepath(), './data/test_cmult_input_a_imag.txt'), AWordLength);
writehex(real(b), fullfile(dfepath(), './data/test_cmult_input_b_real.txt'), BWordLength);
writehex(imag(b), fullfile(dfepath(), './data/test_cmult_input_b_imag.txt'), BWordLength);
writehex(real(p), fullfile(dfepath(), './data/test_cmult_output_p_real.txt'), PWordLength);
writehex(imag(p), fullfile(dfepath(), './data/test_cmult_output_p_imag.txt'), PWordLength);
writehex(ovf, fullfile(dfepath(), './data/test_cmult_output_ovf.txt'), 1);
