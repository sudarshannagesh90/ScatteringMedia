clc
clear all
clc
addpath(genpath('ADMMDependency\'))
addpath('altmany-export_fig-cf9417f\')
%%
z = im2double((imread('CleanImages\parrot.jpg')));
%% Load PSF corresponding to blurry observations
rng(100)
load BlurryObservation6000KM16.7taueight.jpgMediumNoise.mat 
clear STIm
clear STImNoisyBlurred

close all
figure
imshow((abs(((imresize(z,[106 106]))))),[]), 
set(gcf, 'Position', get(0, 'Screensize'));
export_fig(['Figures\GTSpatialDomain.png']);

close all
figure
FFTMatrix = log10(abs(fftshift(fft2(imresize(z,[106 106])))));
[min_val] = min(FFTMatrix(:));
[max_val] = max(FFTMatrix(:));
imshow(log10(abs(fftshift(fft2(imresize(z,[106 106]))))),[]), caxis([min_val max_val]) 
set(gcf, 'Position', get(0, 'Screensize'));
export_fig(['Figures\GTFourierDomain.png']);

randomMask = round(rand(size(STPSF_new(:,:,1))));
for ind = 1:5:25
h = STPSF_new(:,:,ind).*randomMask;
z = imresize(z,[size(h,1) size(h,2)]);
%set noies level
noise_level = 1/255;

%calculate observed image
y = imfilter(z,h,'circular')+noise_level*randn(size(z));
%y = proj(y,[0,1]);

%parameters
method = 'BM3D';
switch method
    case 'RF'
        lambda = 0.0005;
    case 'NLM'
        lambda = 0.005;
    case 'BM3D'
        lambda = 0.005;
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
out = circshift(out,[1 1]);

%display
PSNR_output = psnr(out,z);
close all
figure
imshow(out,[]), title(['PSNR: ',num2str(PSNR_output)])
set(gcf, 'Position', get(0, 'Screensize'));
export_fig(['Figures\deconvolvedCodedImage',num2str(ind),'.png']);

close all
figure
imshow(log10(abs(fftshift(fft2(y)))),[]), caxis([min_val max_val])
set(gcf, 'Position', get(0, 'Screensize'));
export_fig(['Figures\FourierDomainConvolvedCodedImage',num2str(ind),'.png']);

close all
figure
imshow(log10(abs(fftshift(fft2(out)))),[]), caxis([min_val max_val])
set(gcf, 'Position', get(0, 'Screensize'));
export_fig(['Figures\deconvolvedCodedImageFT',num2str(ind),'.png']);
end
%%
