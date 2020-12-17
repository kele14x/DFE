function e = evm(r, x)

if length(r) ~= length(x)
    error('Reference and input signal must have same length')
end

if ~isvector(r) || ~isvector(x)
    error('Reference and input must be vector');
end

r = r(:);
x = x(:);

% Todo: align delay/phase of reference and input

e = rms(r-x) / rms(r);

if nargout < 1
    fprintf('EVM = %.2f%%\n', e*100);
end

end
