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
%     `HB1`: Vector, coefficient for first halfband filter
%
%     `Threshold`: Scalar, threshold peak detection and clipping
%
%     `CancellationPulse`: Vector, cancellation pulse waveform
%
%     `RoundMode`: 'Truncate' or 'None'
%
%  Output Arguments:
%
%     `y` is complex waveform after clipping
%
% See also CFR_HARDCLIPPING.

% Copyright 2020 kele14x

%% Parse Arguments
p = inputParser;

addParameter(p, 'HB1', [], @(x)(isnumeric(x) && isvector(x)));
addParameter(p, 'DetectionThreshold', [], @(x)(isnumeric(x) && isscalar(x)));
addParameter(p, 'ClippingThreshold', [], @(x)(isnumeric(x) && isscalar(x)));
addParameter(p, 'NumberOfCPG', 6, @(x)(isnumeric(x) && isscalar(x)));
addParameter(p, 'CancellationPulse', [], @(x)(isnumeric(x) && isvector(x)));
addParameter(p, 'RoundMode', 'None', @(x)(ismember(x, {'Truncate', 'None'})));

parse(p, varargin{:});

%% Reshape Cancellation Pulse
cPulse = p.Results.CancellationPulse;
delay = (length(cPulse) - 2) / 4;

cPulse1 = cPulse(2:2:end);
cPulse2 = cPulse(1:2:end);

%% Data Path

% Halfband UP2
hb1 = p.Results.HB1;
x2 = hb_up2(x, hb1, ...
    'XinWordLength', 16, ...
    'XinFractionLength', 15, ...
    'CoeWordLength', 16, ...
    'CoeFractionLength', 15, ...
    'YoutWordLength', 16, ...
    'YoutFractionLength', 15, ...
    'CompensateDelay', true, ...
    'CompensatePower', false, ...
    'RoundMode', 'PositiveInfinity');

% CORDIC cart2pol
[x2_thetab, x2_r] = cordic_translate(real(x2), imag(x2), ...
    'Iterations', 7, ...
    'CompensationScaling', 'AddSub', ...
    'PhaseFormat', 'Binary', ...
    'RoundMode', 'Truncate');

% Peak Detector
detectionThreshold = p.Results.DetectionThreshold;
clippingThreshold = p.Results.ClippingThreshold;

% Peak is defined as sample exceed threshold and larger than neighbors
is_peak = x2_r > detectionThreshold;
is_peak = is_peak & (x2_r > circshift(x2_r, 1));
is_peak = is_peak & (x2_r > circshift(x2_r, -1));
is_peak_pp = reshape(is_peak, 2, []).';

% Get the peak value exceed threshold
peak = x2_r - clippingThreshold;
peak(~is_peak) = 0;
[peaki, peakq] = cordic_rotate(peak, 0, x2_thetab, ...
    'Iterations', 7, ...
    'CompensationScaling', 'AddSub', ...
    'PhaseFormat', 'Binary', ...
    'RoundMode', 'Truncate');
peak = complex(peaki, peakq);

peak = reshape(peak, 2, []).';

delta = zeros(size(peak));
delta(:, 1) = floor(cconv(cPulse1, peak(:, 1), length(peak(:, 1))) / 2^14 + 0.5 + 0.5j);
delta(:, 2) = floor(cconv(cPulse2, peak(:, 2), length(peak(:, 2))) / 2^14 + 0.5 + 0.5j);
delta = circshift(delta, -delay);

y = x;
y = y - delta(:, 1);
y = y - delta(:, 2);

end
