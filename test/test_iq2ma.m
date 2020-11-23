%% Clear
clc;
clearvars;
close all;

%% Generate test input
nPts = 1000;

rng(12345);
vec = round((2^15 - 1) * (rand([nPts, 1]) * 2 - 1));
vec = vec + 1j * round((2^15 - 1) * (rand([nPts, 1]) * 2 - 1));

%% Test
N = 6;
[mag, corse, fine] = iq2ma(vec, N);

%% Analysis result

K = cordic_factor(6);
mag_ref = abs(vec);

