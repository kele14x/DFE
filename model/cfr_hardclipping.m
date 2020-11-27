function y = cfr_hardclipping(x, threshold, varargin)
% CFR_HARDCLIPPING performs brick-wall dynamic range limiting to input. Dynamic
% range limiting suppresses the signal that cross a given threshold. Those
% signal are hard clipped without matian the spectrum.
%
%   y = cfr_hardclipping(x, threshold)
%   y = cfr_hardclipping(x, threshold, Name, Value)
%
% See also CFR.

% Copyright 2020 kele14x

%% Configuration
CompensationScaling = true;
Iterations = 7;
PhaseFormat = 'Binary';
RoundMode = 'Truncate';

%% Hard Clipping
% To know which sample to clip, we need conver IQ to magnitude and angle
[theta, r] = cordic_translate(real(x), imag(x), ...
    'CompensationScaling', CompensationScaling, ...
    'Iterations', Iterations, ...
    'PhaseFormat', PhaseFormat, ...
    'RoundMode', RoundMode); 

% Sample points index that over threshold
idx = r > threshold;

% Magnitude that over threshold
exceed = zeros(size(x));
exceed(idx) = r(idx) - threshold;

% Generate the clipping waveform
[cr, ci] = cordic_rotation(exceed, 0, theta, ...
    'CompensationScaling', CompensationScaling, ...
    'Iterations', Iterations, ...
    'PhaseFormat', PhaseFormat, ...
    'RoundMode', RoundMode);
c = complex(cr, ci);

% Clipping is orignal signal minus clipping signal, this ensure CORDIC will not
% impact signal EVM
y = round(x - c);

end
