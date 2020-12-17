function y = fir_model(x, num)

input_is_row = false;

if isrow(x)
    x = x(:);
    input_is_row = true;
end

y = circ_filter(num, x);
y = circshift(y, -(length(num) - 1)/2);

if input_is_row
    y = y.';
end

end