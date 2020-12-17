function y = cs_delay(x, delay)
% cs_delay delay the input signal for desired sample point.
%
%   y = cs_delay(x, delay);
%
% x is a sampled complex input signal. delay is the desired delay in samples
% (can be fractional). If negative delay is assigned, it advances the signal.

% Test if input is row vector
if isrow(x)
    x = x.';
    row = 1;
else
    row = 0;
end

n = size(x, 1);

nCyc = delay / n;

% Frequecy vector of fft result
f = (0:(n - 1)).';
f = f + floor(n/2);
f = mod(f, n);
f = f - floor(n/2);

% Calculate linear phase shift vs freq corresponding to delay
phase = exp(-2i*pi*f*nCyc);

% Convert x to freq-domain
xfft = fft(x);
% Apply linear phase shift to xfft
yfft = xfft .* phase;
% Convert shifted xfft to time domain
y = ifft(yfft);

% Preserve the row or column dimension of the input
if (row)
    y = y.';
end

return