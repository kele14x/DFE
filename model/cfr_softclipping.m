function y = cfr_softclipping(x, threshold, varargin)

%% Configurations
p = inputParser;

addParameter(p, 'Fs', 245.76e6, @(x)(isscalar(x) && isnumeric(x)));
addParameter(p, 'BandWidth', 198e6, @(x)(isscalar(x) && isnumeric(x)));
addParameter(p, 'Halfband1Order', 18, @(x)(isscalar(x) && isnumeric(x)));

addParameter(p, 'CPW', 'Radians', @(x)(ismember(x, {'Radians', 'Binary'})));
addParameter(p, 'RoundMode', 'None', @(x)(ismember(x, {'Truncate', 'None'})));

parse(p, varargin{:});

%% Genreate Internal Coefficients
Fs = p.Results.Fs;
BW = p.Results.BandWidth;
nHB1 = p.Results.Halfband1Order;

% HB1 Coefficient
hb1 = hb_design(nHB1, Fs * 2, BW/2);

% CPW Coefficient
cpw = fir_design(254, Fs, BW/2, BW/2+2e6);
cpw = cpw / max(cpw);
cpw1 = cpw(2:2:end);
cpw2 = cpw(1:2:end);
delay = (254 - 2) / 4;

%% Data Path

%
x2 = hb_up_model(x, hb1);

[x2_thetab, x2_abs] = cordic_translate(real(x2), imag(x2), ...
    'Iterations', 7, ...
    'CompensationScaling', true, ...
    'PhaseFormat', 'Binary', ...
    'RoundMode', 'None');

% Peak Detector
% Peak is defined as sample exceed threshold and larger than neighbors
is_peak = x2_abs > threshold;
is_peak = is_peak & (x2_abs > circshift(x2_abs, 1));
is_peak = is_peak & (x2_abs > circshift(x2_abs, -1));

% Get the peak value exceed threshold
peak = x2_abs - threshold;
peak(~is_peak) = 0;
[peaki, peakq] = cordic_rotation(peak, 0, x2_thetab, ...
    'Iterations', 7, ...
    'CompensationScaling', true, ...
    'PhaseFormat', 'Binary', ...
    'RoundMode', 'None');
peak = complex(peaki, peakq);
peak = reshape(peak, 2, []).';

delta = zeros(size(peak));
delta(:,1) = cconv(cpw1, peak(:,1), length(peak(:,1)));
delta(:,2) = cconv(cpw2, peak(:,2), length(peak(:,2)));
delta = sum(delta, 2);
delta = circshift(delta, -delay); 

y = x - delta;

end
