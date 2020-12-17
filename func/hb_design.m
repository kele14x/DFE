function b = hb_design(N, Fs, Fpass)
% Halfband Filter (HB) design.
%   b = hb1_design(N, Fs, Fpass);
%
% N is filter order (filter tap is N + 1)
% Fs is sample frequency
% Fpass is passband frequency

% Calculate the coefficients using the firhalfband function.
b = firhalfband(N, Fpass/(Fs / 2));

if nargout < 1

    Npts = Fs / 30e3;

    [h, f] = freqz(b, 1, Npts, Fs);

    passband = h(f <= Fpass);
    ripple = 20 * log10(max(abs(passband))) - 20 * log10(min(abs(passband)));
    stopband = h(f >= Fs/2-Fpass);
    rejection = 20 * log10(max(abs(stopband)));

    plot(f/1e6, 20*log10(abs(h)));
    grid on;
    title('Halfband Filter');
    txt = sprintf('Fs = %.2f MHz\nFp = %.2f Mhz\nNtaps = %d\nRipple = %.2f dB\nRejection = %.2f dB', ...
        Fs/1e6, Fpass/1e6, N+1, ripple, rejection);
    annotation('textbox', 'String', txt, 'BackgroundColor', 'w', 'FaceAlpha', .6);
    xlabel('Frequency (MHz)');
    ylabel('Response (dB)');
    xlim([0, Fs / 2e6]);

    xline(Fpass/1e6, '--r');
    xline(Fs/1e6/2-Fpass/1e6, '--r');
end

end
