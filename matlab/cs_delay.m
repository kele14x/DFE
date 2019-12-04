function waveform = cs_delay(waveform, delay)
	% waveform is a sampled complex input signal.
	% delay is the desired delay in samples (can be fractional).
	% neg've delay = advance.

	s = size(waveform);
	waveform=waveform(:);                       % convert to a row array.
	n = numel(waveform);


	nCyc = delay / n;

	f = (0:(n - 1))';
	f = f + floor(n / 2);
	f = mod(f, n);
	f = f - floor(n / 2);

	phase = -2 * pi * f * nCyc;                 % calculate linear phase shift vs freq corresponding to delay
	rot = exp(1i*phase);                        

	waveform_fd = fft(waveform);                % convert waveform to freq-domain
	waveform_fd_shifted = waveform_fd .* rot;   % apply linear phase shift to FD waveform
	waveform = ifft(waveform_fd_shifted);       % convert shifted FD waveform to TD 

	waveform = reshape(waveform,s); % preserve the row or column dimension of the input

return