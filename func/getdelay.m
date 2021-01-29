function [delay, phase, y] = getdelay(ref, x, nIter)
%GETDELAY Get the delay of signal `x` compared with reference signal `ref`. The
%  reference and input signal must have same length.

assert(isvector(ref), 'getdelay: input argument `ref` must be vector');
assert(isvector(x), 'getdelay: input argument `x` must be vector');

if isrow(ref)
    ref = ref.';
end 

input_is_row = false;
if isrow(x)
    input_is_row = true;
    x = x.';
end

N = size(ref, 1);
assert(N == size(x, 1), 'getdelay: `ref` and `x` must be same length');

if nargin < 3
    nIter = 10;
end

% Delay in sample
D = zeros(1, nIter);

% Incase N is odd
fv = [0:ceil(N/2-1), ceil(-N/2):-1].' / N;

refX = fft(ref);
xX   = fft(x);

for i = 1:nIter
    t = sum(D(1:i-1));

    t1 = t - 1/2^i;
    A1 = ifft(conj(refX) .* (xX .* exp(-2j*pi*fv*t1)) / N);
    [M1, I1] = max(A1);
    
    t2 = t;
    A2 = ifft(conj(refX) .* (xX .* exp(-2j*pi*fv*t2)) / N);
    [M2, I2] = max(A2);
    
    t3 = t + 1/2^i;
    A3 = ifft(conj(refX) .* (xX .* exp(-2j*pi*fv*t3)) / N);
    [M3, I3] = max(A3);
    
    [M, idx] = max([M1, M2, M3]);

    D(i) = (idx - 2)/2^i;
end

I = [I1, I2, I3];
I = I(idx);

delay = I - 1 - sum(D);
phase = M;

y = ifft(xX .* exp(2j*pi*fv*delay) / phase);

end

