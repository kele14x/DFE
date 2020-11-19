function [y] = nco_model(x, Fs, f, d)
% Model of NCO in FPGA/Xenon implementation
%
%   y = nco_model(x, Fs, f);
%   y = nco_model(x, Fs, f, d);
% 
% x is input signal. Fs is sample frequency of x. f is NCO shift frequency.
% d is optional reset pointe of NCO. If provide as a scalar, the complex
% phase of NCO will be reset at the time index.
%

input_is_row = false;

if isrow(x)
    x = x(:);
    input_is_row = true;
end

if nargin < 4
    d = 0;
end

% Size of input
n = size(x, 1);

tv = ((0:n-1)-d).'/Fs;

y = x .* exp(2j*pi*tv*f);

if input_is_row
    y = y.';
end 

end
