function [y, ovf] = hb_up2(x, num, varargin)
% HB_UP2 upsample the signal by factor of 2, followed by a halfband
% lowpass filter.
%
%   y = hb_up2(x, num)
%   y = hb_up2(x, num, Name, Value)
%
% Input Arguments:
%
%   `x` is the input signal
%
%   `Name` & 'Value` are Name-Value pairs to hold optional configurations
%   for this model. Valid arguments are:
%
%     `CompensateDelay`: T/F, compensate the delay caused by filter. If true
%     the output signal is shift to "zero delay"
%
%     `CompensatePower`: T/F, compensate the power reduce caused by upsample
%      (6 dB)
%
%     `RightShiftBits`: Scalar integer arithmetic right shift bits on
%     output
%
%     `RoundMode`: 'Truncate', 'PositiveInfinity' or 'None'
%
%  Output Arguments:
%
%     `y` is upsampled signal
%
% See also UP_DW2.

% Copyright 2020 kele14x

%% Parse Arguments
p = inputParser;

addParameter(p, 'XinWordLength', 0, @(x)(isscalar(x) && isnumeric(x)));
addParameter(p, 'XinFractionLength', 0, @(x)(isscalar(x) && isnumeric(x)));
addParameter(p, 'CoeWordLength', 0, @(x)(isscalar(x) && isnumeric(x)));
addParameter(p, 'CoeFractionLength', 0, @(x)(isscalar(x) && isnumeric(x)));
addParameter(p, 'YoutWordLength', 0, @(x)(isscalar(x) && isnumeric(x)));
addParameter(p, 'YoutFractionLength', 0, @(x)(isscalar(x) && isnumeric(x)));
addParameter(p, 'CompensateDelay', true, @(x)(islogical(x)));
addParameter(p, 'CompensatePower', true, @(x)(islogical(x)));
addParameter(p, 'RoundMode', 'None', ...
    @(x)(ismember(x, {'Truncate', 'PositiveInfinity', 'None'})));

parse(p, varargin{:});

%% Input Reshape
input_is_row = false;

if isrow(x)
    input_is_row = true;
    x = x(:);
end

%% Upsample and Filter
x = upsample(x, 2);

y = conv(x, num);

if p.Results.CompensatePower
    y = y * 2;
end

latency = 0;
if p.Results.CompensateDelay
    latency = (length(num) - 1) / 2;
end

y = y(latency+(1:size(x, 1)));

sra = p.Results.XinFractionLength + p.Results.CoeFractionLength - ...
    p.Results.YoutFractionLength;
y = y / 2^sra;

if strcmp(p.Results.RoundMode, 'Truncate')
    y = floor(y);
elseif strcmp(p.Results.RoundMode, 'PositiveInfinity')
    y = floor(y+0.5);
end

ovf = y >= 2^(p.Results.YoutWordLength - 1) | ...
    y <= -2^(p.Results.YoutWordLength - 1) - 1;

%% Output Reshape
if input_is_row
    y = y.';
end

end
