function [p, ovf] = cmult(a, b, varargin)
% CMULT performs complex multiplier with the way of hareware implemented
%
%   [p, ovf] = cmult(a, b)
%   [p, ovf] = cmult(a, b, Name, Value)
%
% Input Arguments:
%
%   `a` & `b` are the complex numbers to be multiplied
%
%   `Name` & 'Value` are Name-Value pairs to hold optional configurations
%   for this model. Valid arguments are:
%
%     `RightShiftBits`: Scalar integer, arithmetic right shift bits on
%     output
%
%     `RoundMode`: 'Truncate', 'PositiveInfinity' or 'None'
%
%  Output Arguments:
%
%     `p` is complex multiply product of `a` and `b`
%
%     `ovf` is overflow indicator
%
% See also PROD.

% Copyright 2020 kele14x

%% Parse Arguments
pa = inputParser;

addParameter(pa, 'AWordLength', 16, @(x)(isscalar(x) && isnumeric(x)));
addParameter(pa, 'AFractionLength', 15, @(x)(isscalar(x) && isnumeric(x)));
addParameter(pa, 'BWordLength', 16, @(x)(isscalar(x) && isnumeric(x)));
addParameter(pa, 'BFractionLength', 15, @(x)(isscalar(x) && isnumeric(x)));
addParameter(pa, 'PWordLength', 16, @(x)(isscalar(x) && isnumeric(x)));
addParameter(pa, 'PFractionLength', 15, @(x)(isscalar(x) && isnumeric(x)));
addParameter(pa, 'RoundMode', 'None', ...
    @(x)(ismember(x, {'Truncate', 'PositiveInfinity', 'None'})));

parse(pa, varargin{:});

%% 3-Multiply Structure
s1 = (real(a) - imag(a)) .* imag(b);
s2 = (real(b) - imag(b)) .* real(a);
s3 = (real(b) + imag(b)) .* imag(a);

pr = (s1 + s2);
pi = (s1 + s3);

%% Output

sra = pa.Results.AFractionLength + pa.Results.BFractionLength - pa.Results.PFractionLength;
RND = 0;
if sra > 0 && strcmp(pa.Results.RoundMode, 'PositiveInfinity')
    RND = 2^(sra - 1);
end

pr = (pr + RND) / 2^sra;
pi = (pi + RND) / 2^sra;

if strcmp(pa.Results.RoundMode, 'Truncate') || ...
        strcmp(pa.Results.RoundMode, 'PositiveInfinity')
    pr = floor(pr);
    pi = floor(pi);
end

p = complex(pr, pi);
ovf = pr <= -2^(pa.Results.PWordLength - 1) - 1;
ovf = ovf | pr >= 2^(pa.Results.PWordLength - 1);
ovf = ovf | pi <= -2^(pa.Results.PWordLength - 1) - 1;
ovf = ovf | pi >= 2^(pa.Results.PWordLength - 1);

end
