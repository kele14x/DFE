function [y] = hb_up_model(x, num)

input_is_row = false;

if isrow(x)
    input_is_row = true;
    x = x(:);
end 

x = upsample(x, 2);
y = cfilter(num, x) * 2;
y = circshift(y, -(length(num)-1)/2);

if input_is_row
    y = y.';
end 

end

