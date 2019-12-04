function y = evm(r, x)

l = min(length(r), length(x));
r = r(1:l);
x = x(1:l);

y = rms(r - x) / rms(r) * 100;

end 