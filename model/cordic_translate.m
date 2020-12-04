function [theta, r] = cordic_translate(x, y, varargin)
% CORDIC_TRANSLATE rotates the vector (x, y) around the circle until
% the y component equals zero using CORDIC algorithm.
%
%   [theta, r] = cordic_translate(x, y)
%   [theta, r] = cordic_translate(x, y, Name, Value)
%
% Input Arguments:
%
%   `x` & `y` is the vector (x, y)
%   `Name` & `Value` is Name-Value pair to specify optional comma-separated
%   arguments for this model. Valid arguments are:
%     'Iterations':
%       Scalar integer, number of CORDIC iterations
%     'CompensationScaling':
%       T/F, do compensation for magnitude scaling during pseudo-rotation before
%       output
%     'PhaseFormat':
%       'Radians' or 'Binary'
%     'RoundMode':
%       'Truncate' or 'None'
%
% Output Arguments:
%
%   `theta` is angle of vector (x, y)
%   `r` is magnitude of vector (x, y)
%
% See also CORDIC_ROTATION.

% Copyright 2020 kele14x

%% Parse Arguments
p = inputParser;

addParameter(p, 'CompensationScaling', true, @(x)(isscalar(x) && islogical(x)));
addParameter(p, 'Iterations', 7, @(x)(isscalar(x) && isnumeric(x)));
addParameter(p, 'PhaseFormat', 'Radians', @(x)(ismember(x, {'Radians', 'Binary'})));
addParameter(p, 'RoundMode', 'None', @(x)(ismember(x, {'Truncate', 'None'})));

parse(p, varargin{:});

%% Coarse Rotation
% If input vector is within range [-99.883, 99.883] degree, CORDIC algorithm
% will converge with no additional effort. But to expend input to all the
% circle, we need to know which quadrant the vector is lie on.
sx = x < 0;
sy = y < 0;
theta = zeros(size(x));

if strcmp(p.Results.PhaseFormat, 'Binary')
    theta = sx;
end

%% Pseudo-Rotation
for i = (0:p.Results.Iterations-1)
    % `d` is rotation direction, 1 is counterclockwise, -1 is clockwise. The
    % rotation direction is -sign(x*y). For 0, we rotate counterclockwise.
    d = xor(x < 0, y < 0);
    d = d * 2 - 1;
    % Pseudo rotation is micro rotation without the length factor K
    temp = x;
    % Simulation the hardware truncate rounding mode
    if strcmp(p.Results.RoundMode, 'Truncate')
        x = x - d .* floor(y / 2^i);
        y = y + d .* floor(temp / 2^i);
        disp(x);
%         disp(y);
    else
        x = x - d .* y / 2^i;
        y = y + d .* temp / 2^i;
    end

    % Angle Log
    if strcmp(p.Results.PhaseFormat, 'Radians')
        % If we rotate clockwise, we log positive, and vice versa
        theta = theta - d .* atan(1 / 2^i);
        disp(theta * 180 / pi);
    elseif strcmp(p.Results.PhaseFormat, 'Binary')
        %  If we rotate clockwise, we log '1', and vice versa
        theta = theta * 2 - (d - 1) / 2;
    end
end

%% Output
r = x;
r(sx) = -r(sx);
% Compensation for vector length scaling
if p.Results.CompensationScaling
    K = prod(1 ./ sqrt(1 + 2.^(-2 * (0:p.Results.Iterations - 1))));
    r = K * r;
end

% Compensation for phase angle output
if strcmp(p.Results.PhaseFormat, 'Radians')
    theta(sx & sy) = theta(sx & sy) - pi;
    theta(sx & ~sy) = theta(sx & ~sy) + pi;
end

end
