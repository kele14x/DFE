function [mag, ang, err] = cordic_translate(vec, conf)

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

%% Pseudo Rotation

mag = real(vec);
if conf.CoarseRotation
    coarse = mag < 0;
    mag(coarse) = -mag(coarse);
end
err = imag(vec);
ang = 0;

for i = (0:conf.Iterations)
    % Rotation direction is -sgn(mag*err). Speical handle is done for mag*err
    % is zero.
    d = -2 * (err >= 0) + 1;
    % Rseudo rotation
    temp = mag;
    mag = mag - d * err / 2^i;
    err = err + d * temp / 2^i;
    ang = ang - d * atan(1 / 2^i);
end

%% Output

if conf.CompensationSacling
    K = prod(1./sqrt(1+2.^(-2*(0:conf.Iterations))));
    mag = K * mag;
end

if conf.CoarseRotation
    ang(coarse) = pi - ang(coarse);
end

end
