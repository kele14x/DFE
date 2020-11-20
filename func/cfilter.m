function y = cfilter(b, x)
% y = cfilter(b, x) 
%   circular filter of signal x using numerator coefficients b

row = false;

if isrow(x)
    x = x.';
    row = true;
end

tnum = size(x, 1);
dn = length(b);

x = [x(end-dn+1:end, :); x; x(1:dn, :)];
x = filter(b, 1, x);

y = x(dn+(1:tnum),:);

if row
    y = y.';
end 

end
