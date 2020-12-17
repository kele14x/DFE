function y = pwr(x)
if isrow(x)
    y = l2db(x*x'/length(x));
else
    y = l2db(x'*x/length(x));
end
end