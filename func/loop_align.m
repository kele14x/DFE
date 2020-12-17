function s = loop_align(s)

s.ibw = ibw_est(s.tx) * s.DEF_TX_SAMPLE_RATE * (1 + s.DEF_GMP_IN2X);
s.rx = sigdelay(s.rx, -s.loop_delay);

tx = s.tx(s.valid);
rx = s.rx(s.valid);

s.txpwr = mean(abs(tx).^2);
s.rxpwr = mean(abs(rx).^2);

s.loopgain = (rx * tx') / (tx * tx');
s.rx = s.rx / s.loopgain;

s.rx = bl_fir_tor(s.rx);

s.er = s.tx - s.rx;
s.error = mean(abs(s.er(s.valid)).^2);

% fprintf(1, 'loop evm is %.6f\n', s.error / s.txpwr);
fprintf(1, '*********loop evm is %.6f  ', s.error/s.txpwr);
fprintf(1, '*********loop error is %.1f\n', s.error);

end


% band limited filter on TOR
function y = bl_fir_tor(x)
y = x;
end