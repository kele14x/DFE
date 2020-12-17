function b = fir_design(N, Fs, Fp, Fstp, Wpass, method)
% Sub-bandinf filter (FIR) design
%   b = fir_design(N, Fs, Fpass, Fstop);

if ~exist('Wpass', 'var') || isempty(Wpass)
    Wpass = 1;
end

if ~exist('method', 'var') || isempty(method)
    method = 'pm';
end

Wstop = 1;

% Calculate the coefficients using the FIRPM function.
if strcmp(method, 'pm')
    b = firpm(N, [0, Fp, Fstp, Fs / 2]/(Fs / 2), [1, 1, .0, .0], [Wpass, Wstop]);
elseif strcmp(method, 'ls')
    b = firls(N, [0, Fp, Fstp, Fs / 2]/(Fs / 2), [1, 1, 0, 0], [Wpass, Wstop]);
else
    error('Unspported method');
end

if nargout < 1

    nPts = Fs / 30e3;
    [h, f] = freqz(b, 1, nPts, Fs);

    passband = h(f <= Fp);
    ripple = 20 * log10(max(abs(passband))-min(abs(passband))+1);
    stopband = h(f >= Fstp);
    rejection = 20 * log10(max(abs(stopband)));

    plot(f/1e6, 20*log10(abs(h)));
    grid on;
    xlim([0, Fs / 2e6]);
    title('FIR Filter');
    txt = sprintf('Fs = %.2f MHz\nFp = %.2f MHz\nFstp = %.2f MHz\nNtaps = %d\n)', ...
        Fs/1e6, Fp/1e6, Fstp/1e6, N+1);
    txt = [txt, sprintf('Ripple = %.2f dB\nRejection = %.2f dB', ripple, rejection)];
    annotation('textbox', 'String', txt, 'BackgroundColor', 'w', 'FaceAlpha', .6);
    xlabel('Frequency (MHz)');
    ylabel('Response (dB)');

    xline(Fp/1e6, '--r');
    xline(Fstp/1e6, '--r');

end

end
