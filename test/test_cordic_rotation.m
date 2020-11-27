%% Clear
clc;
clearvars;
close all;

%% Generate test input
nPts = 1000;
sz = [nPts, 1];

rng(12345);
xin = randi([-2^15, 2^15-1], sz);
yin = randi([-2^15, 2^15-1], sz);
ang = rand(sz) * 2 * pi - pi;

%% Test
[xout, yout] = cordic_rotation(xin, yin, ang);
temp = complex(xin, yin) .* exp(1j * ang);
xout_ref = real(temp);
yout_ref = imag(temp);

%% Analysis result
figure();
stem(xout);
hold on;
stem(xout_ref);
stem(xout_ref - xout);
legend('Reference', 'Output', 'Error');
% fprintf('Error RMS is %.4f%%\n', rms(xout_ref-xout)/rms(xout_ref)*100);

figure();
stem(yout);
hold on;
stem(yout_ref);
stem(yout_ref - yout);
legend('Reference', 'Output', 'Error');
% fprintf('Error RMS is %.4f%%\n', rms(yout_ref-yout)/rms(yout_ref)*100);
