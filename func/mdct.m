function [y] = mdct(x, w)
% MDCT Modified Discrete Cosine Transform (MDCT) caculation.
%
%       y = mdct(x);
%       y = mdct(x, w);
%
%    Input:
%      * x: Input discrete-time signal, could be vector or matrix. If x is
%        a matrix, each column is treated as a channel.
%      * w: Window apply (multiplied) to input signal. If not specified, no
%        window is used. Coule be:
%           'none' - no window is used
%           'mlt' - mlt window w_n = sin(pi/2/n*(n+1/2))
%           'mlt2' - mlt2 window w_n = sin(pi/2*sin^2(pi/2/N*(n+1/2)))
%    Output:
%      * y: The transformed signal
%
%    Currrently the implementation is not in fast method. So complexity O(N^2).
%
%    See:
%       <https://en.wikipedia.org/wiki/Modified_discrete_cosine_transform>

if isrow(x)
    x = x.';
    row = true;
else
    row = false;
end

if nargin < 2 || isempty(w)
    w = 'none';
end

% Number of input samples
N = size(x, 1) / 2;
% which should be even

% Coefficients matrix with N*2N size
[k, n] = ndgrid(0:N-1, 0:2*N-1);

% Unwindowed coe
C = cos(pi / N .* (n + 1 / 2 + N / 2) .* (k + 1 / 2));

if strcmp(w, 'mlt')
    C = C .* sin(pi/2/N*(n + 1 / 2));
elseif strcmp(w, 'mlt2')
    C = C .* sin(pi/2*sin(pi / 2 / N * (n + 1 / 2)).^2);
end

% dimension [N 2N] * [2N (?)] = [N (?)]
% Accumulation works on first dimension
y = C * x;

if row
    y = y.';
end
