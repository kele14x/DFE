% ---
% File   : rcf_poly_print.m
% Author : Niantong DU
% Date   : 5/19/2020
% ---

% Print a RCF (Rate Change Filter)'s polynomial, which is:
%
%   y[n] = {h[.]} * {x[.]}
%
% where:
%   {h[.]} is a series of h[k]
%   {x[.]} is a series of x[m]
%   * is 1D Convolution

%%
clc;
clearvars;
close all;

% RCF Up/Down factor
%   `Down` points of input will produce `Up` points of output
%   Output stream loops each `Down` samples, input stream loops each `Up` samples
%
% The RCF factor table for DOT is:
%   153.6 -> 107.52 :  7 / 10
%   153.6 ->  86.016: 14 / 25
%   153.6 ->  71.68 :  7 / 15
%   153.6 ->  53.76 :  7 / 20
%   153.6 ->  43.008:  7 / 25

Up   = 7;       % Interpolation factor
Down = 25;      % Decimation factor

% Sample frequency change
Fs_in  = 153.6e6;
Fs_out = Fs_in * Up / Down;

% Coefficients
N     = 6*10*Up; % Number of coefficients, better (n * k * Up) points long
Phase = 0;      % Initial phase of convolution, 0 <= Phase < Up

% Print polynomial items
fprintf("---\n");
for row = (0 : (Up * 2 - 1))
    fprintf("y[%2d] = ", row);

    % x index start from
    x_start = floor(row * Down / Up);
    % h index start from
    h_start = rem((row * Down + Phase), Up);
    % Number of polynomial terms
    n = ceil((N - h_start) / Up); 

    % All x index
    x_idx = (x_start : -1 :  x_start - n + 1);
    % All h index
    h_idx = (h_start : Up : h_start + n * Up - Up);

    for i = (1: n)
        fprintf("h[%3d]", h_idx(i));
        fprintf("*");
        fprintf("x[%4d]", x_idx(i));
        if (i < n)
            fprintf(" + ");
        end
    end

    fprintf("\n");
    if (rem(row, Up) == Up - 1)
        fprintf("---\n");
    end
end 