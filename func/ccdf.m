function [y, n] = ccdf(x, power)
% CCDF plot the CCDF (Complementary Cumulative Distribution Function) of a
% given signal. CCDF measures the probability of a signal's instantaneous
% power being X dBs above its average power.

input_is_row = false;
if isrow(x)
    input_is_row = true;
    x = x.';
end

inst_power = abs(x).^2;

% If user does not specify average power, measure the average power of
% signal
if nargin < 2
    average_power_db = 10*log10(mean(inst_power));
end

inst_power_db = 10*log10(inst_power);

y = inst_power_db(inst_power_db > average_power_db) - average_power_db;
y = sort(y);

n = (length(y):-1:1)/length(x);

if nargout < 1
   semilogy(y, n);
   grid on;
   title('CCDF');
   xlabel('Power above average power (dB)');
   ylabel('Possiablity');
end

end