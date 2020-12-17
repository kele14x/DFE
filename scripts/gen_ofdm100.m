%% Generate Test Input
[waveform, conf] = nrWaveGen('100');

waveform = waveform / rms(waveform) * sqrt(db2l(-15)) * 2^15;
waveform = round(waveform);

Fs = conf.Fs;

save(fullfile(dfepath(), './data/ofdm100.mat'), 'waveform', 'Fs')
