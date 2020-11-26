function [theta, r] = cordic_translate(vec, varargin)
% CORDIC_TRANSLATE rotates the vector (complex number) around the circle until
% the imaginary component equals zero using CORDIC algorithm.
%
%   [mag, ang] = cordic_translate(vec)
%   [mag, ang] = cordic_translate(vec, Name, Value)
%
% Input Arguments:
%
%   `vec` is the complex matrix represents the vector
%   `Name` & `Value` is Name-Value pair to specify optional comma-separated
%   arguments for this model. Valid arguments are:
%     'CoarseRotation'：
%       T/F, do a coarse rotation for input vector
%     'Iterations':
%       Scalar integer, number of CORDIC iterations
%     'CompensationScaling':
%       T/F, do compensation for magnitude scaling during pesudo-rotation before
%       output
%
% Output Arguments:
%
%   `theta` is angle of VEC
%   `r` is magnitude of VEC
%
% See also CORDIC_ROTATION.

% Copyright 2020 kele14x

%% Parse Arguments
p = inputParser;

addParameter(p, 'CompensationScaling', true, @(x)(isscalar(x) && islogical(x)));
addParameter(p, 'Iterations', 6, @(x)(isscalar(x) && isnumeric(x)));
addParameter(p, 'PhaseFormat', 'Radians', @(x)(ismember(x, {'Radians', 'Binary'})));
addParameter(p, 'RoundMode', 'None', @(x)(ismember(x, {'Truncate', 'None'})));

parse(p, varargin{:});

%% CoarseRota
% If input vector is within range [-99.883, 99.883] degree, CORDIC algorithm
% will converge with no additional effort. But to expend input to all the
% circle, we need to know which quadrant the vector is lie on.
sx = real(vec) < 0;
sy = imag(vec) < 0;
theta = zeros(size(vec));
    
if strcmp(p.Results.PhaseFormat, 'Binary')
    theta = sy * 2 + sx ;
end

%% Pseudo-Rotation
% Init iteration
r   = real(vec);
err = imag(vec);

for i = (0:p.Results.Iterations)
    % `d` is rotation direction, 1 is counterclockwise, -1 is clockwise. The 
    % rotation direction is -sign(err). For 0, we rotate counterclockwise.
    d = -((r >= 0) * 2 - 1) .* ((err >= 0) * 2 - 1);
    % Rseudo rotation is micro rotation without the length factor K
    temp = r;
    % Simulation the hardware truncate rounding mode
    r = r - d .* err / 2^i;
    err = err + d .* temp / 2^i;
    if strcmp(p.Results.RoundMode, 'Truncate')
        r = floor(r);
        err = floor(err);
    end

    % Angle Log
    if strcmp(p.Results.PhaseFormat, 'Radians')
        % If we rotate clockwise, we log positive, and vice versa
        theta = theta - d .* atan(1 / 2^i);
    elseif strcmp(p.Results.PhaseFormat, 'Bits')
        %  If we rotate clockwise, we log '1', and vice versa
        theta = theta * 2 - (d - 1) / 2;
    end
end

%% Output
% Comensation for vector length scaling
if p.Results.CompensationScaling
    K = prod(1./sqrt(1+2.^(-2*(0:p.Results.Iterations))));
    r = K * r;
    r(sx) = -r(sx);
end

% Comensation for phase angle output
if strcmp(p.Results.PhaseFormat, 'Radians')
    theta(sx & sy) = theta(sx & sy) - pi;
    theta(sx & ~sy) = theta(sx & ~sy) + pi;
end

end
