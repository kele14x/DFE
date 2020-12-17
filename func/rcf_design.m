function b = rcf_design(N, Fin, L, M, Fpass, alt, method)
% Rate Change Filter (RCF) design.
% For input, assume it is shipped with out-of-band interference.
% For output, it only ensures in-hand signal without distortion
%
%   b = rcf_design(N, Fin, L, M, Fpass);
%

% Defalut arguments

if ~exist('alt', 'var') || isempty(alt)
    alt = false;
end

if ~exist('method', 'var') || isempty(method)
    method = 'pm';
end

% Constants
Fs = Fin * L;
Fout = Fs / M;

% Cared factor
if islogical(alt) && ~alt
    Fb = Fout;
    C = M;
elseif islogical(alt) && alt
    Fb = Fin;
    C = L;
else
    error('Alt should be logical')
end


k = (1:(C - 1) / 2);

if rem(C, 2) == 0 % Even
    % List of frequency constraint points
    Fo = [[0; Fpass], [k * Fb - Fpass; k * Fb + Fpass], [Fs / 2 - Fpass; Fs / 2]];
    Fo = Fo(:).';
    Fg = Fo(2:end-1);
    % List of response constraint, save number as above
    Ao = [1, 1, repmat([0, 0], [1, C / 2])];
    % List of weight for each band
    Wo = [1, ones([1, C / 2])];
else
    % List of frequency constraint points
    Fo = [[0; Fpass], [k * Fb - Fpass; k * Fb + Fpass]];
    Fo = Fo(:).';
    Fg = Fo(2:end);
    % List of response constraint, save number as above
    Ao = [1, 1, repmat([0, 0], [1, (C - 1) / 2])];
    % List of weight for each band
    Wo = [1, ones(1, (C - 1) / 2)];
end

% Calculate the coefficients using the FIRPM function.
if strcmp(method, 'pm')
    b = firpm(N, Fo/(Fs / 2), Ao, Wo);
elseif strcmp(method, 'ls')
    b = firls(N, Fo/(Fs / 2), Ao, Wo);
else
    error('Unspported method');
end

if nargout < 1
    [h, f] = freqz(b, 1, Fs/30e3, Fs);

    plot(f/1e6, 20*log10(abs(h)));
    grid on;
    xlim([0, Fs / 2e6]);

    passband = h(f <= Fpass);
    ripple = 20 * log10(max(abs(passband))) - 20 * log10(min(abs(passband)));
    stopband = h(f >= Fs/2-Fpass);
    rejection = 20 * log10(max(abs(stopband)));

    title(sprintf('RCF (Fs = %.2f (%.2f -> %.2f, %d/%d) MHz, Fp = %.2f MHz, Ntaps = %d)', ...
        Fs / 1e6, Fin / 1e6, Fout / 1e6, L, M, Fpass / 1e6, N + 1));
    subtitle(sprintf('Ripple = %.2f dB, rejection = %.2f dB', ripple, rejection));
    xlabel('Frequency (MHz)');
    ylabel('Response (dB)');

    for i = 1:length(Fg)
        xline(Fg(i)/1e6, '--r');
    end

end

end
