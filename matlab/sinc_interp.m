function y = sinc_interp(x, M)
% sinc_interp perform ideal bandlimited interpolation of a signal.
%
%   y = sinc_interp(x, M);
%
% x is input signal. M is interpolate factor. y is output signal. This function
% append M-1 interpolated sample points at each origial point.

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