function [Pxx, f] = mypsd(x, Fs)

N = round(Fs/30e3);
[Pxx, f] = pwelch(x, [], [], N, Fs, 'center');

if nargout == 0
    if (f(end) > 1e6)
        fp = f / 1e6;
    elseif f(end) > 1e3
        fp = f / 1e3;
    else
        fp = f;
    end
    plot(fp, 10*log10(Pxx));
    xlim([min(fp), max(fp)]);
    grid on;
end

end