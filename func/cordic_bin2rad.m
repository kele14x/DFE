function [theta] = cordic_bin2rad(bin, nIter)
% CORDIC_BIN2RAD converts phase angle from radians format to binary encode which
% is suit for CORDIC algorithm.

% Know the matrix shape of input
sz = size(bin);

% Reshape to column vector
bin = bin(:);

% Convert to logic matrix
bin = (dec2bin(bin, nIter+1) == '1');

% MSB is marked as theta is reversed
reversed = bin(:,1);

% Left bits are angle in atan(1/2^i)
bin = bin(:, 2:end);

% Add left bits togather to get the theta
bin = bin * 2 - 1;
t = meshgrid(0:size(bin,2)-1, 1:size(bin,1));
theta = bin .* atan(1./2.^t);
theta = sum(theta, 2);

% Fix theta is it's reversed
idx1 = theta >= 0 & reversed;
idx2 = theta < 0 & reversed;
theta(idx1) = theta(idx1) - pi;
theta(idx2) = theta(idx2) + pi;

% Reshape to input size
theta = reshape(theta, sz);

end

