%% Clear
clc;
clearvars;
close all;

%% Generate test input
nPts = 1000;
sz = [nPts, 1];

rng(12345);
vecx = randi([-2^15, 2^15-1], sz) + 1j * randi([-2^15, 2^15-1], sz);
ang = rand(sz) * 2 * pi - pi;

%% Test
vecy = cordic_rotation(vecx, ang);
refy = vecx .* exp(1j * ang);

%% Analysis result
figure();
stem(abs(refy));
hold on;
stem(abs(vecy));
yyaxis right;
stem(abs(vecy - refy));
legend('Reference', 'Output', 'Error');
fprintf('Error RMS is %.4f%%\n', rms(vecy-refy)/rms(refy)*100);
