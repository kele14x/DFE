function y = freq_trans(x, Fs, f, d)
% Frequency translation of digtial signal
%
%   y = freq_trans(x, Fs, f);
%   y = freq_trans(x, Fs, f, d);
%
% Input Arguments:
%
%   `x` is input signal.
%
%   `Fs` is sample frequency of x. 
%   
%   `f` is frequency shift value.
%
%   `d` is optional init phase (in rad) of NCO. If provide as a scalar, the
%   complex phase of NCO will be set to `d` at the start.
%
% Output Arguments:
%
%  `y` is signal after frequency translation

input_is_row = false;

if isrow(x)
    x = x.';
    input_is_row = true;
end

if nargin < 4
    d = 0;
end

% Size of input
n = size(x, 1);

tv = ((0:n - 1)).' / Fs;

y = x .* exp(2j*pi*tv*f) * exp(2j*d);

if input_is_row
    y = y.';
end

end
