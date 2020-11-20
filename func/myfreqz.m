function [h, f] = myfreqz(d,n,fs)

% Arguments
if nargin < 2
    n = 1024;
end 

if nargin < 3
    fs = 2;
end 


x = zeros(n, 1);
x(1:length(d)) = d;

h = fft(x);

f = (0:n-1) * fs/n;

k = ceil(n / 2);

if nargout < 1
    % Do ploting
    figure();
    plot(f(1:k), 20*log10(abs(h(1:k))));
    xlabel('Frequency (Hz)');
    xlim([0,fs/2]);
    ylabel('Amplitude (dB)');
    grid on;
    title('Filter Response');
end 


end