function [y] = imdct(x, w)
% MDCT Inverse MDCT caculation.
%
%       y = imdct(x);
%       y = imdct(x, w);
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
%      * y: The inverse transformed signal
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
N = size(x, 1);

% Coefficients matrix with 2*N*N size
[n, k] = ndgrid(0:2*N-1, 0:N-1);
C = cos(pi / N .* (n + 1 / 2 + N / 2) .* (k + 1 / 2));

if strcmp(w, 'mlt')
    C = C .* sin(pi/2/N*(n + 1 / 2));
elseif strcmp(w, 'mlt2')
    C = C .* sin(pi/2*sin(pi / 2 / N * (n + 1 / 2)).^2);
end

% Dimension: [2N, N] * [N (?)]  = [2N (?)]
% Accumulation works on first dimension
y = 1 / N * C * x;

if row
    y = y.';
end
