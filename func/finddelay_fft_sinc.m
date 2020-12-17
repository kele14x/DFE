function d = finddelay_fft_sinc(x, y, N)
% FINDDELAY_FFT_SINC Estimates delays between signals using fft and sinc
% interpolate method.
%
%    d = finddelay_fft_sinc(x, y);
%
%  finddelay_fft_sinc(x, y) return a estimated delay of two given signals
%  x & y. Where x is the reference. x and y should be row or column
%  vectors. If y is delayed version of x, this function return a positive
%  number. If y is advanced with repect to x, d is negative.
%

% Check inputs
narginchk(2, 3);

if ~(isvector(x) && isvector(y))
    error('Two input must be vector');
end

if ~(length(x) == length(y))
    error('Two input vector must be same length');
end

if ~(exist('N', 'var') && ~isempty(N))
    N = 256;
end

% Settings
L = 5;

n = length(x);

xfft = fft(x(:));
yfft = fft(y(:));

matched_fft = conj(xfft) .* yfft;
matched = ifft(matched_fft);
matched = real(matched);

% Coarse delay is the maximum point
[~, idx1] = max(matched);

% Find fine delay by sinc interpolation

% Only select 2L + 1 points near max
L = min(round(n / 2 - 1), L);
if (idx1 > L)
    curve = matched(idx1-L:idx1+L);
else
    curve = [matched(end -L + idx1:end); matched(1:idx1 + L)];
end

% Interpolate the curve by N
curve_int = sinc_interp(curve, N);

% Fine delay is the maximum
[~, idx2] = max(curve_int);

% Total delay in sample
d = (idx1 - 1) + (idx2 - 1) / N - L;

end
