%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Demo of Plug-and-Play ADMM for image deblurring
%
% S. H. Chan, X. Wang, and O. A. Elgendy
% "Plug-and-Play ADMM for image restoration: Fixed point convergence
% and applications", IEEE Transactions on Computational Imaging, 2016.
% 
% ArXiv: https://arxiv.org/abs/1605.01710
% 
% Xiran Wang and Stanley Chan
% Copyright 2016
% Purdue University, West Lafayette, In, USA.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
clc

addpath(genpath('./utilities/'));

%add path to denoisers
addpath(genpath('./denoisers/BM3D/'));

%read test image
z = im2double(imread('./data/House256.png'));
z = imresize(z,[106 106]);

%initialize a blurring filter
h = fspecial('gaussian',[106 106],1);

%reset random number generator
rng(0);

%set noies level
noise_level = 10/255;

%calculate observed image
y = imfilter(z,h,'circular')+noise_level*randn(size(z));
y = proj(y,[0,1]);

%parameters
method = 'BM3D';
switch method
    case 'RF'
        lambda = 0.0005;
    case 'NLM'
        lambda = 0.005;
    case 'BM3D'
        lambda = 0.001;
    case 'TV'
        lambda = 0.01;
end

%optional parameters
opts.rho     = 1;
opts.gamma   = 1;
opts.max_itr = 20;
opts.print   = true;

%main routine
out = PlugPlayADMM_deblur(y,h,lambda,method,opts);

%display
PSNR_output = psnr(out,z);
fprintf('\nPSNR = %3.2f dB \n', PSNR_output);

figure;
subplot(121);
imshow(y);
title('Input');

subplot(122);
imshow(out);
tt = sprintf('PSNR = %3.2f dB', PSNR_output);
title(tt);
