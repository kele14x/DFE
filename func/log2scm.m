function [m, s] = log2scm(A, depth)

m = -inf(1, depth+1);
s = zeros(1, depth+1);

if A >= 0
    s(1) = 1;
else
    s(1) = -1;
end

m(1) = round(log2(s(1) * A));
A = A / 2^m(1);

for i = 2:(depth + 1)
    if A == 1
        return;
    elseif A > 1
        m(i) = round(log2(A - 1));
        s(i) = 1;
        A = A / (1 + 2^m(i));
    else
        m(i) = round(log2(1 - A));
        s(i) = -1;
        A = A / (1 - 2^m(i));
    end

end


end