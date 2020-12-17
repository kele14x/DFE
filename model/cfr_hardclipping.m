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
