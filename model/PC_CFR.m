function y = PC_CFR(x, varargin)
% PC_CFR performs Peak Cancellation Crest Factor Reduction (PC-CFR) on
% input signal.
%
%   y = PC_CFR(x)
%   y = PC_CFR(x, Name, Value)
%
% Input Arguments:
%
%   `x` is input complex waveform
%
%   `Name` & 'Value` are Name-Value pairs to hold optional configurations
%   for this model. Valid arguments are:
%
%     `CancellationPulse`: Vector, the peak cancellation pulse. The
%       length of the pulse should be 2*n*InterpolationFactor+1
%
%     `CancellationPulseFractionLength`: Scalar, the fraction bit length
%       of cancellation pulse
%
%     `CancellationPulseWordLength`: Scalar, the total bit length
%       of cancellation pulse
%
%     `ClippingThreshold`: Scalar, threshold of peak clipping
%
%     `CoeFractionLength`: Scalar, half-band filter coefficients fraction
%       bit length
%
%     `CoeFractionLength`: Scalar, half-band filter coefficients total
%       bit length
%
%     `DetectionThreshold`: Scalar, threshold of peak detection
%
%     `HB1`: Vector, coefficient for first half-band filter
%
%     `HB2`: Vector, coefficient for second half-band filter
%
%     `InterpolationFactor`: 1, 2 or 4. Interpolation factor before perform
%       peak detection
%
%     `RoundMode`: 'Truncate', 'PositiveInfinity' or 'None'. Rounding mode
%       for both half-band filter and cancellation waveform generation 
%
%     `XFractionLength`: Scalar, the fraction bit length of input and
%       output signal
%
%     `XFractionLength`: Scalar, the total bit length of input and
%       output signal
%
%  Output Arguments:
%
%     `y` is complex waveform after clipping
%
% See also CFR_HARDCLIPPING.

% Copyright 2020 kele14x

%% Parse Arguments
p = inputParser;

addParameter(p, 'CancellationPulse', [], @(x)(isnumeric(x) && isvector(x)));
addParameter(p, 'CancellationPulseFractionLength', 14, @(x)(isnumeric(x) && isscalar(x)));
addParameter(p, 'CancellationPulseWordLength', 16, @(x)(isnumeric(x) && isscalar(x)));
addParameter(p, 'ClippingThreshold', [], @(x)(isnumeric(x) && isscalar(x)));
addParameter(p, 'CoeFractionLength', 15, @(x)(isnumeric(x) && isscalar(x)));
addParameter(p, 'CoeWordLength', 16, @(x)(isnumeric(x) && isscalar(x)));
addParameter(p, 'DetectionThreshold', [], @(x)(isnumeric(x) && isscalar(x)));
addParameter(p, 'HB1', [], @(x)(isnumeric(x) && isvector(x)));
addParameter(p, 'HB2', [], @(x)(isnumeric(x) && isvector(x)));
addParameter(p, 'InterpolationFactor', 2, @(x)(ismember(x, [1, 2, 4])));
addParameter(p, 'NumberOfCPG', 6, @(x)(isnumeric(x) && isscalar(x)));
addParameter(p, 'PeakDetectWindow', 3, @(x)(isnumeric(x) && isscalar(x) && rem(x, 2) == 1));
addParameter(p, 'RoundMode', 'PositiveInfinity', @(x)(ismember(x, {'Truncate', 'PositiveInfinity', 'None'})));
addParameter(p, 'XFractionLength', 15, @(x)(isnumeric(x) && isscalar(x)));
addParameter(p, 'XWordLength', 16, @(x)(isnumeric(x) && isscalar(x)));

parse(p, varargin{:});

%% Configuration & Constants
CancellationPulse = p.Results.CancellationPulse;
CancellationPulseFractionLength = p.Results.CancellationPulseFractionLength;
CancellationPulseWordLength = p.Results.CancellationPulseWordLength;
ClippingThreshold = p.Results.ClippingThreshold;
CoeFractionLength = p.Results.CoeFractionLength;
CoeWordLength = p.Results.CoeWordLength;
DetectionThreshold = p.Results.DetectionThreshold;
HB1 = p.Results.HB1;
HB2 = p.Results.HB2;
InterpolationFactor = p.Results.InterpolationFactor;
NumberOfCPG = p.Results.NumberOfCPG;
PeakDetectWindow = p.Results.PeakDetectWindow;
RoundMode = p.Results.RoundMode;
XFractionLength = p.Results.XFractionLength;
XWordLength = p.Results.XWordLength;

assert(isvector(x));
input_is_row = false;
if isrow(x)
    input_is_row = true;
    x = x.';
end
L = length(x);

% Length of cancellation pulse is required to be 2*InterpolationFactor*n+1
assert(rem(length(CancellationPulse), 2 * InterpolationFactor) == 1);
n = (length(CancellationPulse) - 1) / (2 * InterpolationFactor);

% Reshape Cancellation Pulse
cPulse = [zeros(InterpolationFactor - 1, 1); CancellationPulse(:)];
cPulse = reshape(cPulse, InterpolationFactor, 2*n+1).';
cPulse = fliplr(cPulse);

%% Data Path

% Interpolate the orignal signal for "smart peak detection"
% The interpolated data is considered to be polyphase signal

if (InterpolationFactor == 1)
    x_up = x;
end

if (InterpolationFactor == 2) || (InterpolationFactor == 4)

    x_up = hb_up2(x, HB1, ...
        'XinWordLength', XWordLength, ...
        'XinFractionLength', XFractionLength, ...
        'CoeWordLength', CoeWordLength, ...
        'CoeFractionLength', CoeFractionLength, ...
        'YoutWordLength', XWordLength, ...
        'YoutFractionLength', XFractionLength, ...
        'CompensateDelay', true, ...
        'CompensatePower', false, ...
        'RoundMode', RoundMode);
end

if InterpolationFactor == 4

    x_up = hb_up2(x_up, HB2, ...
        'XinWordLength', XWordLength, ...
        'XinFractionLength', XFractionLength, ...
        'CoeWordLength', CoeWordLength, ...
        'CoeFractionLength', CoeFractionLength, ...
        'YoutWordLength', XWordLength, ...
        'YoutFractionLength', XFractionLength, ...
        'CompensateDelay', true, ...
        'CompensatePower', false, ...
        'RoundMode', RoundMode);
end

% Get the abs of signal

% CORDIC cart2pol
[x_up_theta, x_up_r] = cordic_translate(real(x_up), imag(x_up), ...
    'Iterations', 7, ...
    'CompensationScaling', 'AddSub', ...
    'PhaseFormat', 'Binary', ...
    'RoundMode', 'Truncate');

% Peak Detector

% Peak is defined as sample exceed threshold and larger than N neighbors
% TODO: there is bug that if two adjacent sample is same (though very rare,
% but it happens), below peak detection logic will not report both sample
% as peak.
N = max(InterpolationFactor-1, (PeakDetectWindow - 1)/2);

is_peak = x_up_r > DetectionThreshold;
for i = 1:N
    is_peak = is_peak & (x_up_r > circshift(x_up_r, i));
    is_peak = is_peak & (x_up_r > circshift(x_up_r, -i));
end

peak = x_up_r - ClippingThreshold;
peak(~is_peak) = 0;
[peaki, peakq] = cordic_rotate(peak, 0, x_up_theta, ...
    'Iterations', 7, ...
    'CompensationScaling', 'AddSub', ...
    'PhaseFormat', 'Binary', ...
    'RoundMode', 'Truncate');
peak = complex(peaki, peakq);

% Polyphase peak processing

% There will only be 1 is_peak for each polyphase, so we can do this
is_peak_pp = reshape(is_peak, InterpolationFactor, []).';
peak_valid = logical(is_peak_pp*ones(InterpolationFactor, 1));

% The phase of peak is defined as index of polyphase
peak_phase = is_peak_pp * (0:InterpolationFactor - 1).';

peak_pp = reshape(peak, InterpolationFactor, []).';
peak_data = peak_pp * ones(InterpolationFactor, 1);

% Peak cancellation waveform generation

cpg_usage = zeros(L+2*n, NumberOfCPG);
peak_cpg = false(L, NumberOfCPG);
idx = find(peak_valid);
for i = 1:length(idx)
    for j = 1:NumberOfCPG
        if (cpg_usage(idx(i), j) == 0)
            peak_cpg(idx(i), j) = true;
            cpg_usage(idx(i):(idx(i) + 2 * n), j) = 1;
            break;
        end
    end
end

delta = zeros(L, NumberOfCPG);
for i = 1:NumberOfCPG
    for j = 1:InterpolationFactor
        v = peak_cpg(:, i) & (peak_phase == j - 1);
        v = v .* peak_data;
        d = conv(v, cPulse(:, j), 'full');
        d = d(1:L);
        delta(:, i) = delta(:, i) + d;
    end

end

if strcmp(RoundMode, 'Truncate')
    delta = floor(delta);
elseif strcmp(RoundMode, 'PositiveInfinity')
    delta = floor(delta/2^CancellationPulseFractionLength+0.5+0.5j);
end

% Compensate the delay between cancellation waveform and signal
delta = circshift(delta, -n);

% peak cancellation
y = x - sum(delta, 2);

if input_is_row
    y = y.';
end

end
