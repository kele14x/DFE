function x = gssolve(u, v)
% x = gssolve(u, v)
% 
% solve function of {u * x = v} using Gauss solving method

n = size(u, 1);

% from lower to upper
for k = n-1:-1:1
    u(1:k,1:k) = u(1:k,1:k) - repmat(u(k+1,1:k), k, 1) .* repmat(u(1:k,k+1) / u(k+1,k+1), 1, k);
    v(1:k) = v(1:k) - v(k+1) * u(1:k,k+1) / u(k+1,k+1);
end

% from upper to lower
for k = 2:n
    v(k:n) = v(k:n) - v(k-1) * u(k:n,k-1) / u(k-1,k-1);
end

m = diag(u);
x = v ./ (1e-30 + m);

end