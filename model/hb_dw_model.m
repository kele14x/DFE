function [y] = hb_dw_model(x, num)

input_is_row = false;

if isrow(x)
    input_is_row = true;
    x = x(:);
end

y = circ_filter(num, x);
y = circshift(y, -(length(num) - 1)/2);

y = y(1:2:end, :);

if input_is_row
    y = y.';
end

end
