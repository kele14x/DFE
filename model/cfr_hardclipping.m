function y = cfr_hardclipping(x, threshold, varargin)
% CFR_HARDCLIPPING performs brick-wall dynamic range limiting to input. Dynamic
% range limiting suppresses the signal that cross a given threshold. Those
% signal are hard clipped without matian the spectrum.
%
%   y = cfr_hardclipping(x, threshold)
%   y = cfr_hardclipping(x, threshold, Name, Value)
%
% See also CFR_SOFTCLIPPING.

% Copyright 2020 kele14x

%% Parse Arguments
p = inputParser;

addParameter(p, 'CompensationScaling', 'AddSub', @(x)(ismember(x, {'Multiply', 'AddSub'})));
addParameter(p, 'Iterations', 7, @(x)(isscalar(x) && isnumeric(x)));
addParameter(p, 'PhaseFormat', 'Binary', @(x)(ismember(x, {'Radians', 'Binary'})));
addParameter(p, 'RoundMode', 'Truncate', @(x)(ismember(x, {'Truncate', 'None'})));

parse(p, varargin{:});

%% Hard Clipping
% To know which sample to clip, we need conver IQ to magnitude and angle
[theta, r] = cordic_translate(real(x), imag(x), ...
    'CompensationScaling', p.Results.CompensationScaling, ...
    'Iterations', p.Results.Iterations, ...
    'PhaseFormat', p.Results.PhaseFormat, ...
    'RoundMode', p.Results.RoundMode);

% Sample points index that over threshold
idx = (r >= threshold);

% Magnitude that over threshold
exceed = zeros(size(x));
exceed(idx) = r(idx) - threshold;

% Generate the clipping waveform
[cr, ci] = cordic_rotation(exceed, 0, theta, ...
    'CompensationScaling', p.Results.CompensationScaling, ...
    'Iterations', p.Results.Iterations, ...
    'PhaseFormat', p.Results.PhaseFormat, ...
    'RoundMode', p.Results.RoundMode);
c = complex(cr, ci);

% Clipping is orignal signal minus clipping signal, this ensure CORDIC will not
% impact signal EVM
y = x - c;

end
