function y = sinc_interp(x, M)
%SINC_INTERP perform ideal bandlimited interpolation.
%
%   y = sinc_interp(x, M);
%
% This function interpolate the real or complex samples signal x for an 
% integer factor M. It increase the sample rate of x by insert M - 1 sample
% between samples and at end. If x is a matrix, the function treats each 
% column as separate sequence.
%
% x is input signal. M is interpolate factor. y is interpolated signal.
% This function assume that the signal to interpolate, x, is 0 outside of
% the given time interval and has been sampled at Nyquist frequency.
%

    narginchk(2,2);

    % Test if input is row vector
    if isrow(x)
        x = x.';
        row = 1;
    else
        row = 0;
    end

    len = size(x, 1);

    % Original sample time
    t = 1:len;

    % Interpolated sample time
    ts = (0 : len * M - 1) / M + 1;
    
    % Ts - T the distance from interpolated time to origianl time
    [Ts, T] = ndgrid(ts, t);
    y = sinc(Ts - T) * x;

    % Restore row vector if input is row
    if (row)
        y = y.';
    end

end