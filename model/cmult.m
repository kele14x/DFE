function p = cmult(a, b, varargin)
% CMULT performs complex multiplier with the way of hareware implemented
%
%   p = cmult(a, b)
%   p = cmult(a, b, Name, Value)
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
% See also PROD.

% Copyright 2020 kele14x

%% Parse Arguments
p = inputParser;

addParameter(p, 'RightShiftBits', 0, @(x)(isscalar(x) && isnumeric(x)));
addParameter(p, 'RoundMode', 'None', ...
    @(x)(ismember(x, {'Truncate', 'PositiveInfinity', 'None'})));

parse(p, varargin{:});

%% 3-Multiply Structure
s1 = (real(a) - imag(a)) * imag(b);
s2 = (real(b) - imag(b)) * real(a);
s3 = (real(b) + imag(b)) * imag(a);

pr = (s1 + s2) / 2^p.Results.RightShiftBits;
pi = (s1 + s3) / 2^p.Results.RightShiftBits;

if strcmp(p.Results.RoundMode, 'Truncate')
    pr = floor(pr);
    pi = floor(pi);
elseif strcmp(p.Results.RoundMode, 'PositiveInfinity')
    pr = floor(pr+0.5);
    pi = floor(pi+0.5);
end

p = complex(pr, pi);

end
