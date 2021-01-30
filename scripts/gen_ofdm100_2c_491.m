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
% File: gen_ofdm100_2c_491.m
% Brief: Generate a 2x OFDM100 waveform with sampling rate 491.52 Msps

%% Main
% Get OFDM100 waveform using nrWaveGen function
rng(12345);
[x1, conf1] = nrWaveGen('100');
[x2,     ~] = nrWaveGen('100');

Fs = conf1.Fs * 4;

% OFDM100 will use 122.88 Msps sampling rate, we need upsample to 4x. So we need
% a halfband lowpass filter
b1 = hb_design(54, Fs / 2, 50e6);
b2 = hb_design(10, Fs, 50e6);

% Filter and compensate the filter delay
c1 = cfilter(b1, upsample(x1, 2));
c2 = cfilter(b1, upsample(x2, 2));
c1 = cfilter(b2, upsample(c1, 2));
c2 = cfilter(b2, upsample(c2, 2));
c1 = circshift(c1, -(length(b1) + length(b2) - 2)/2);
c2 = circshift(c2, -(length(b1) + length(b2) - 2)/2);

% Frequecy shift and combine of two carriers
waveform = freq_trans(c1, Fs, -100e6) + freq_trans(c2, Fs, 100e6);

% Power normalization
waveform = waveform / rms(waveform) * sqrt(db2l(-15)) * 2^15;
waveform = round(waveform);

% Save to file so we will not be slow next time
save(fullfile(dfepath(), './data/ofdm100_2c_491.mat'), 'waveform', 'Fs')
