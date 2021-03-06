function [xout, yout] = cordic_rotate(xin, yin, theta, varargin)
% CORDIC_ROTATE rotates the vector (xin, yin) through the angle theta to yield
% a new vector (xout, yout) using CORDIC algorithm.
%
%   [xout, yout] = CORDIC_ROTATE(xin, yin, theta)
%   [xout, yout] = CORDIC_ROTATE(xin, yin, theta, Name, Value)
%
% Input Arguments:
%
%   `xin` & `yin` is the vector (xin, yin) before the rotation
%
%   `theta` is the angle to rotate. If `theta` is positive, the rotation
%   is counterclockwise, else the rotation is clockwise.
%
%   `Name` & 'Value` is a Name-Value pair to hold optional configurations for
%   this model. Valid arguments are:
%
%     'Iterations': Scalar integer, number of CORDIC iterations
%
%     'CompensationScaling': T/F, do compensation for magnitude scaling during
%     pseudo-rotation before output
%
%     'PhaseFormat': 'Radians' or 'Binary'
%
%     'RoundMode': 'Truncate' or 'None'
%
% Outputs:
%
%   `xout` & `yout` is the complex matrix represents the output after the rotation
%
% See also CORDIC_TRANSLATE.

% Copyright 2020 kele14x

%% Default Parameters
p = inputParser;

addParameter(p, 'CompensationScaling', 'Multiply', @(x)(ismember(x, {'Multiply', 'AddSub', 'None'})));
addParameter(p, 'Iterations', 7, @(x)(isscalar(x) && isnumeric(x)));
addParameter(p, 'PhaseFormat', 'Radians', @(x)(ismember(x, {'Radians', 'Binary'})));
addParameter(p, 'RoundMode', 'None', @(x)(ismember(x, {'Truncate', 'None'})));

parse(p, varargin{:});

%% Coarse Rotation

if strcmp(p.Results.PhaseFormat, 'Radians')
    % Coarse rotation expends input to all the circle (if not, input `theta` is
    % required to be within the range [-99.883, 99.883] degree). To to coarse
    % rotation, we need to know which quadrant `theta` is lie on. If `theta` is at
    % left quadrant, do coarse rotation. Coarse rotation is to rotate the vector for
    % pi angle (that is, reverse the vector). The rotation direction is not
    % important, since rotate for pi is rotate for -pi.
    % theta should be within the range [-pi, pi) this should be naturally for
    % hardware implementation
    theta = rem((theta + pi), 2*pi) - pi;
    sx = ((theta > pi / 2) | (theta < -pi / 2));
    sy = (theta < 0);
    theta(sx & sy) = theta(sx & sy) + pi;
    theta(sx & ~sy) = theta(sx & ~sy) - pi;
elseif strcmp(p.Results.PhaseFormat, 'Binary')
    theta = dec2bin(theta, p.Results.Iterations+1);
    sx = (theta(:, 1) == '1');
    % We does not need sy here
end

%% Pseudo-Rotation
for i = (0:p.Results.Iterations - 1)
    % Rotation direction is sgn(theta).
    if strcmp(p.Results.PhaseFormat, 'Radians')
        d = (theta >= 0) * 2 - 1;
        theta = theta - d .* atan(1/2^i);
    elseif strcmp(p.Results.PhaseFormat, 'Binary')
        d = (theta(:, 2+i) == '1') * 2 - 1;
    end
    
    % Pseudo rotation is micro rotation without the length factor K
    temp = xin;
    if strcmp(p.Results.RoundMode, 'Truncate')
        % Simulation the hardware truncate rounding mode
        xin = xin - d .* floor(yin/2^i);
        yin = yin + d .* floor(temp/2^i);
    else
        xin = xin - d .* yin / 2^i;
        yin = yin + d .* temp / 2^i;
    end
end

%% Output
% For sx
xout = xin;
yout = yin;
xout(sx) = -xout(sx);
yout(sx) = -yout(sx);

% Compensation for vector length scaling
if strcmp(p.Results.CompensationScaling, 'Multiply')
    K = prod(1./sqrt(1+2.^(-2 * (0:p.Results.Iterations - 1))));
    xout = K * xout;
    yout = K * yout;
    if strcmp(p.Results.RoundMode, 'Truncate')
        xout = floor(xout);
        yout = floor(yout);
    end
elseif strcmp(p.Results.CompensationScaling, 'AddSub')
    if strcmp(p.Results.RoundMode, 'Truncate')
        xout = floor(xout/2) + floor(xout/8);
        xout = xout - floor(xout/32);
        yout = floor(yout/2) + floor(yout/8);
        yout = yout - floor(yout/32);
    else
        xout = xout / 2 + xout / 8;
        xout = xout - xout / 32;
        yout = yout / 2 + yout / 8;
        yout = yout - yout / 32;
    end
end

end
