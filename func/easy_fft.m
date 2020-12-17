function easy_fft(x, Fs)
%EASY_FFT Summary of this function goes here
%   Detailed explanation goes here

n = length(x);

if ~exist('Fs', 'var') || isempty(Fs)
    Fs = 2;
end

if rem(n, 2) % odd
    v = (((1 - n) / 2):((n - 1) / 2)) * Fs / n;
else % even
    v = ((-n / 2):(n / 2 - 1)) * Fs / n;
end

figure();
plot(v, 20*log10(fftshift(abs(fft(x))) / n));

end
