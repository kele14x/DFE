function [mag, ang] = cordic_translate(vec, conf)
% CORDIC_TRANSLATE rotates the vector around the circle until the imaginary
% component equals zero using CORDIC algorithm
%
%   [MAG, ANG] = cordic_translate(VEC)
%   [MAG, ANG] = cordic_translate(VEC, CONF)
%
% Inputs:
%
%   VEC is the complex matrix represents the vector
%
%   CONF is a structure to hold confurations for this model. Valid fields are:
%     CONF.CoarseRotation：
%       T/F, do a coarse rotation for input vector
%     CONF.Iterations:
%       Scalar integer, number of CORDIC iterations
%     CONF.CompensationSacling:
%       T/F, do compensation for magnitude scaling during pesudo-rotation before
%       output
%
% Outputs:
%
%   MAG is magnitude of VEC
%
%   ANG is angle of VEC
%
% See also CORDIC_ROTATION.

% Copyright 2020 kele14x

%% Default Parameters

if ~exist('conf', 'var')
    conf = [];
end

if ~isfield(conf, 'CoarseRotation')
    conf.CoarseRotation = true;
end

if ~isfield(conf, 'Iterations')
    conf.Iterations = 6;
end

if ~isfield(conf, 'CompensationSacling')
    conf.CompensationSacling = true;
end

%% Pseudo-Rotation
% Init iteration
mag = real(vec);
err = imag(vec);
ang = 0;

% Coarse rotation expends input to all the circle (if not, input vector is
% required within range [-99.883, 99.883] degree). To to coarse rotation, we
% need to know which quadrant the vector is lie on.
if conf.CoarseRotation
    left = mag < 0;
    mag(left) = -mag(left);
    lower = err < 0;
end

for i = (0:conf.Iterations)
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

if conf.CompensationSacling
    K = prod(1./sqrt(1+2.^(-2*(0:conf.Iterations))));
    mag = K * mag;
end

if conf.CoarseRotation
    ang(left & ~lower) =  pi - ang(left & ~lower);
    ang(left &  lower) = -pi - ang(left &  lower);
end

end
