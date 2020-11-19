function [y] = rcf_model(x, num, up, down)

input_is_row = false;

if isrow(x)
    input_is_row = true;
    x = x(:);
end 

y = circ_filter(num, upsample(x, up)) * up;
y = circshift(y, -(length(num)-1)/2);
y = y(1:down:end,:);

if input_is_row
    y = y.';
end 

end
