function [mag, ang] = cordic_translate(vec, varargin)
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
%   `mag` is magnitude of VEC
%   `ang` is angle of VEC
%
% See also CORDIC_ROTATION.

% Copyright 2020 kele14x

%% Parse Arguments
p = inputParser;

addParameter(p, 'CoarseRotation', true, @(x)(isscalar(x) && islogical(x)));
addParameter(p, 'CompensationScaling', true, @(x)(isscalar(x) && islogical(x)));
addParameter(p, 'Iterations', 6, @(x)(isscalar(x) && isnumeric(x)));

parse(p, varargin{:});

%% Pseudo-Rotation
% Coarse rotation expends input to all the circle (if not, input vector is
% required within range [-99.883, 99.883] degree). To to coarse rotation, we
% need to know which quadrant the vector is lie on. Then there are many ways to
% do coarse rotation, way we did here is reverse the direction of vector at 2nd
% and 3rd quadrant.
if p.Results.CoarseRotation
    q2 = (real(vec) < 0 & imag(vec) >= 0);
    q3 = (real(vec) < 0 & imag(vec) <  0);
    vec(q2 | q3) = -vec(q2 | q3);
end

% Init iteration
mag = real(vec);
err = imag(vec);
ang = 0;

for i = (0:p.Results.Iterations)
    % Rotation direction is -sgn(err). No speical handle is need for err is zero
    d = -2 * (err >= 0) + 1;
    % Rseudo rotation is micro rotation without the length factor K
    temp = mag;
    % Simulation the hardware truncate rounding mode
    % TODO: Add more rounding mode
    mag = floor(mag - d .* err / 2^i);
    err = floor(err + d .* temp / 2^i);
    % TODO: Add more angle format, should be one to represent hardware optimaze
    ang = ang - d .* atan(1 / 2^i);
end

%% Output
% Comensation for vector length scaling
if p.Results.CompensationScaling
    K = prod(1./sqrt(1+2.^(-2*(0:p.Results.Iterations))));
    mag = K * mag;
end

% If we do coarse rotation at input, we need to reverse the effect
if p.Results.CoarseRotation
    ang(q2) = ang(q2) + pi;
    ang(q3) = ang(q3) - pi;
end

end
