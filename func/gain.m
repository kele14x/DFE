function g = gain(x, y, valid)
% y = g * x

x = x(valid);
y = y(valid);

g = (y * x') / (x * x');

end