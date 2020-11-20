function [waveform, conf] = nrWaveGen(BW)
% wave = nrWaveGen(BW)
%   This script generate 1 frame (10 ms) OFDM waveform that is very like NR
%   signal. It does not contains physical channels defined in standard.
%   It can be used as test input for simulation. Parameters are automatically
%   chosen based on their default values based on bandwidth. This is for quick
%   evaluation.

%% Parameters

% Choose parameters based on BW
if strcmp('5', BW)
    % Channel Bandwidth
    CBW = 5e6;
    % Numerology
    mu = 0;
    % Number of resource blocks
    nRB = 25;
    % Guardband
    Guardband = 0.2425e6;
elseif strcmp ('10', BW)
    CBW = 10e6;
    mu = 0;
    nRB = 52;
    Guardband = 0.3125e6;
elseif strcmp ('15', BW)
    CBW = 15e6;
    mu = 0;
    nRB = 79;
    Guardband = 0.3825e6;
elseif strcmp ('20', BW)
    CBW = 20e6;
    mu = 0;
    nRB = 106;
    Guardband = 0.4525e6;
elseif strcmp ('25', BW)
    CBW = 25e6;
    mu = 0;
    nRB = 133;
    Guardband = 0.5225e6;
elseif strcmp ('40', BW)
    CBW = 40e6;
    mu = 0;
    nRB = 216;
    Guardband = 0.5225e6;
elseif strcmp ('50', BW)
    CBW = 50e6;
    mu = 0;
    nRB = 270;
    Guardband = 0.6925e6;
elseif strcmp ('60', BW)
    CBW = 60e6;
    mu = 1;
    nRB = 162;
    Guardband = 0.825e6;
elseif strcmp('80', BW)
    CBW = 80e6;
    mu = 1;
    nRB = 217;
    Guardband = 0.925e6;
elseif strcmp('100', BW)
    CBW = 100e6;
    mu = 1;
    nRB = 273;
    Guardband = 0.845e6;
else
    error('Unsupported BW')
end

% Number of frames to generate
nFrame = 1;
% Number of Subframe per frame
nSubframePerFrame = 10;
% Number of Subcarrier per RB
nSCPerRB = 12;

% Subcarrier spacing
SCS = 15e3 * 2^mu;
% FFT length
nFFT = 2^ceil(log2(CBW/SCS));
% Sample rate
Fs = SCS * nFFT;
% Insert DC null
dcNull = 1;
% Guard band subcarriers
Guard = [(nFFT-nRB*nSCPerRB)/2; (nFFT-nRB*nSCPerRB)/2-1];
% Null carrier index, including guard and DC Null
nullIdx = [1:Guard(1), nFFT/2+1, (nFFT-Guard(2)+1):nFFT].';
% Data subcarrier
nSC = nFFT-Guard(1)-Guard(2)-dcNull;

% Number of slots per subframe
nSlotPerSubframe = 2^mu;
% Number of symbol per slot (Normal CP)
nSymbolPerSlot = 14;
% Number of slots
nSlot = nSlotPerSubframe * nSubframePerFrame * nFrame;
% Number of symbols
nSym = nSymbolPerSlot * nSlot;
% Cycle Prefix length of each symbol
cplen = repmat([160, ones(1, 6) * 144] * nFFT / 2048, [1, nSlot * 2]);

% Bit per symbol
bitSym = 6;
% Modulation order
M = 2^bitSym;

%% Modulation

% Input Signal
inSig = randi([0 1], nSC*nSym*bitSym, 1);

% 64 QAM Modulation
inSym = qammod(inSig, M, 'gray', 'InputType', 'bit');
inSym = reshape(inSym, nSC, []);

% OFDM Modulation
raw_wave = ofdmmod(inSym, nFFT, cplen, nullIdx);

%% Filter

% Passband Frequency
fp = Fs/2-Guard(1)*SCS;
% Stopband Frequency
fstp = fp + Guardband;
% Passband ripple in dB
rp = 0.01;
% Stopband ripple in dB
rs = 80;
% Cutoff frequencies
f = [fp, fstp];
% Desired amplitudes
a = [1 0];
% Maximum passband error (ripple) and maximum stopband amplitude
dev = [(10^(rp/20)-1)/(10^(rp/20)+1) 10^(-rs/20)];
[n, fo, ao, w] = firpmord(f, a, dev, Fs);
% We allways want even order filter (odd taps)
if rem(n, 2)
    n = n + 1;
end

% Designer the filer
b = firpm(n, fo, ao, w);

% Filter using cconv, also compensation the filter delay
waveform = cfilter(b, raw_wave);
waveform = circshift(waveform, -(length(b)-1)/2);

conf = [];
conf.nFFT = nFFT;
conf.Fs = Fs;
conf.inSym = inSym;
conf.cplen = cplen;
conf.nullIdx = nullIdx;

end
