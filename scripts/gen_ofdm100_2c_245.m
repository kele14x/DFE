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
% File: gen_ofdm100_2c_245.m
% Brief: Generate a 2x OFDM100 waveform with sampling rate 245.76 Msps

%% Main
% Get OFDM100 waveform using nrWaveGen function
rng(12345);
[x1, conf1] = nrWaveGen('100');
[x2, ~] = nrWaveGen('100');

Fs = conf1 * 2;

% OFDM100 will use 122.88 Msps sampling rate, we need upsample to 2x. So we need
% a halfband lowpass filter
b = hb_design(54, Fs, 50e6);

% Filter and compensate the filter delay
c1 = cfilter(b, upsample(x1, 2));
c2 = cfilter(b, upsample(x2, 2));
c1 = circshift(c1, -(length(num) - 1)/2);
c2 = circshift(c2, -(length(num) - 1)/2);

% Frequecy shift and combine of two carriers
waveform = nco_model(c1, Fs, -50e6) + nco_model(c2, Fs, 50e6);

% Power normalization
waveform = waveform / rms(waveform) * sqrt(db2l(-15)) * 2^15;
waveform = round(waveform);

% Save to file so we will not be slow next time
save(fullfile(dfepath(), './data/ofdm100_2c_245.mat'), 'waveform', 'Fs')
