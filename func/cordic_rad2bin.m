function bin = cordic_rad2bin(theta, nIter)
% CORDIC_RAD2BIN convert phase angle from radians format to binary format
%
%   bin = cordic_rad2bin(theta, nIter)
%
% Input Arguments:
%
%   `theta` is phase angle in radians format
%
%   `nIter` is number of iterations of CORDIC
%
% Output Arguments:
%
%   `bin` is phase angle in binary format
%
% See also CORDIC_BIN2RAD

% Copyright 2020 kele14x

% Make theta in range [-pi, pi)
theta = rem(theta+pi, 2*pi) - pi;

% If the vector is at 2nd or 3rd quadrant (not including y axis), it's
% reversed to make the angle phase be in range [-pi/2, pi/2].
idx1 = theta > pi / 2;
idx2 = theta < -pi / 2;
bin = idx1 | idx2;

theta(idx1) = theta(idx1) - pi;
theta(idx2) = theta(idx2) + pi;

for i = 0:nIter - 1
    % d = 1, rotate counterclockwise; d = -1, rotate clockwise
    d = (theta >= 0) * 2 - 1;
    theta = theta - d * atan(1/2^i);
    bin = bin * 2 + (d > 0);
end

end
