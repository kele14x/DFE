function [ papr ] = papr( x )
%PAPR Summary of this function goes here
%   Detailed explanation goes here

papr = l2db(max(abs(x))^2 / rms(x)^2);

end

