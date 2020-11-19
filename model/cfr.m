function y = cfr(x, cpw, threshold)

is_peak = abs(x) > threshold;
is_peak = and(is_peak, abs(x) > abs(circshift(x, 1)));
is_peak = and(is_peak, abs(x) > abs(circshift(x, -1)));

temp = x;
temp(not(is_peak)) = 0;
temp(is_peak) = (abs(temp(is_peak)) - threshold) .* exp(1j*angle(temp(is_peak)));

cpw = cpw / max(cpw);

delta = cconv(cpw.', temp, length(temp));
delta = circshift(delta, -floor(length(cpw)/2)); 

y = x - delta;

end
