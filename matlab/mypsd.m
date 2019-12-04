function [Pxx, f] = mypsd(X, Fs, spectrumType)
% MYPSD Power Spectral Density (PSD) estimate via simple FFT method.
%
%       [Pxx, f] = psd(X);
%       [Pxx, f] = psd(X, Fs);
%       [Pxx, f] = psd(X, Fs, sepectrumType);
%       [Pxx, f] = psd(X, [], sepectrumType);
%
%    Input:
%     * X: The discrete-time signal, could be vector or matrix. If X is 
%       a matrix, each column is treated as a channel.
%     * Fs: A scalar that tells the sample frequcy of X. If not given,
%       normailzed sample frequency is used.
%     * sepectrumType: choose the PSD is scale by frequency resolution of
%       not. Could be:
%          'psd' - Scale by frequency resolution
%          'power' - Not scale by frequency resolution
%   Output:
%     * Pxx: The Power Spectral Density (PSD) estimate
%     * f: The frequency index vector
%
%    Niantong DU
%    v1.0
%    2019/1/17

% If no sample frequency is given, we use normalized frequency (-pi to pi)
if nargin < 2 || isempty(Fs)
    normFreq = true;
    Fs = 2;
else
    normFreq = false;
end 

% If no spectrum type is given, we use power method (not scale by frequcy 
% resolution).
if nargin < 3 || isempty(spectrumType)
    spectrumType = 'power'; 
end

% Make X a column vector, or left as it is if X is matrix
if isrow(X)
    X = X.';
end

% Get length of sample
N = size(X, 1);

% Frequency resolution
Fres = Fs / N;

% The frequecy index vector, should take care if N is odd
f = (-floor(N/2):ceil(N/2)-1).' * Fres;

% PSD estimation using FFT
Pxx = abs(fftshift(fft(X))/N).^2;

% Scale by frequency resolution
if strcmp(spectrumType, 'psd')
    Pxx = Pxx * N / Fs;
end

% Plot the figure if no output arguments
if (nargout == 0)

    figure();
    plot(f, 10*log10(abs(Pxx)));
    
    % Format the figure;
    title(sprintf('PSD, nFFT = %d', N));
    
    % X axis
    if normFreq
        xlabel('Normalized Frequency (\pi rad/s)')
    else
        xlabel('Frequency (Hz)');
    end
    xlim([-Fs/2, Fs/2]);
    
    % Y axis
    if strcmp(spectrumType, 'power')
        ylabel('Power (dB/Sample)')
    else
        ylabel('Power (dB/Hz)')
    end

    grid on;
end

end
