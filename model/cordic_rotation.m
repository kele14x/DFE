function vecy = cordic_rotation(vecx, ang, conf)
% CORDIC_ROTATION rotates the vector (complex number) through the angle to yield
% a new vector using CORDIC algorithm.
%
%   VECY = CORDIC_ROTATION(VECX, ANG)
%   VECY = CORDIC_ROTATION(VECX, ANG, CONF)
%
% Inputs:
%
%   VECX is the complex matrix represents the vector before the rotation
%
%   ANG is the angle in radian to rotate. If ANG is positive, the rotation is
%   counterclockwise, else the rotation is clockwise.
%
%   CONF is a structure to hold confurations for this model. Valid fields are:
%     TODO: Add valid fields for CONF
%
% Outputs:
%
%   VECY is the complex matrix represents the output after the rotation
%
% See also CORDIC_TRANSLATE.

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
X = real(vecx);
Y = imag(vecx);
% ANG should be within the range [-pi, pi) this should be naturally for hardware 
ang = rem((ang + pi), 2*pi) - pi;

% Coarse rotation expends input to all the circle (if not, input vector is
% required within range [-99.883, 99.883] degree). To to coarse rotation, we
% need to know which quadrant the angle is lie on.
if conf.CoarseRotation
    % If angle is at left quadrant, do coare rotation. Coarse rotation  is
    % rotate the vector for pi angle. The direction is not important, since
    % rotate for pi is rotate for -pi (reverse vector direction)
    q2 = ang >= pi / 2;
    q3 = ang < -pi / 2;
    X(q2 | q3) = -X(q2 | q3);
    Y(q2 | q3) = -Y(q2 | q3);
    ang(q2) = ang(q2) - pi;
    ang(q3) = ang(q3) + pi;
end

for i = (0:conf.Iterations)
    % Rotation direction is -sgn(err). No speical handle is need for err is zero
    d = (ang >= 0) * 2 - 1;
    % Rseudo rotation is micro rotation without the length factor K
    temp = X;
    % Simulation the hardware truncate rounding mode
    % TODO: Add more rounding mode
    X = (X - d .* Y / 2^i);
    Y = (Y + d .* temp / 2^i);
    % TODO: Add more angle format, should be one to represent hardware optimaze
    ang = ang - d .* atan(1 / 2^i);
end

disp(ang * 180 / pi);
%% Output

vecy = X + 1j * Y;

if conf.CompensationSacling
    K = prod(1./sqrt(1+2.^(-2*(0:conf.Iterations))));
    vecy = K * vecy;
end

end
