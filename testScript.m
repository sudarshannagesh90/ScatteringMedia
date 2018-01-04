clc
close all
clear all
%% Load the PSF and test-image
addpath('C:\Users\Sudarshan Nagesh\OneDrive\WeightedDeconvolution\PSFsFromMarina')
load('BlurryObservation3000KM16.7taueight.jpg.mat','STPSF_new')
maxVal = max(max(max(STPSF_new)));
figure('units','normalized','outerposition',[0 0 1 1]), surf(STPSF_new(:,:,1)), colorbar
title(['Time-slice: ',num2str(1)])
zlim([0 maxVal])
xlim([0 106])
ylim([0 106])
export_fig('Figures/STPSF1','-png')
figure('units','normalized','outerposition',[0 0 1 1]), surf(STPSF_new(:,:,4)), colorbar
title(['Time-slice: ',num2str(4)])
zlim([0 maxVal])
ylim([0 106])
xlim([0 106])
export_fig('Figures/STPSF4','-png')
figure('units','normalized','outerposition',[0 0 1 1]), surf(STPSF_new(:,:,8)), colorbar
title(['Time-slice: ',num2str(8)])
zlim([0 maxVal])
xlim([0 106])
ylim([0 106])
export_fig('Figures/STPSF8','-png')
%%
testImage = im2double(imread('cameraman.tif'));
testImage = imresize(testImage,[size(STPSF_new,1) size(STPSF_new,2)]);
testImage = testImage/max(max(testImage));

F = scatteringMediumOperator(STPSF_new,[size(STPSF_new,1) size(STPSF_new,1)],'Symmetric','Same');
scatteredimages = F*testImage;
scatteredimages = reshape(scatteredimages,size(STPSF_new));

intensifierQuantumEfficiency = 0.5;
intensifierDarkCurrent       = 0.2;
intensifierAmplifier         = 1e-2;
phosphorScreenEfficiency     = 180;
exposureDuration             = 200e-12;
G = ICCDIntensifierOperator(size(STPSF_new),intensifierQuantumEfficiency,intensifierDarkCurrent,intensifierAmplifier,phosphorScreenEfficiency,exposureDuration);
intensifiedImage= G*scatteredimages;
intensifiedImage= reshape(intensifiedImage,size(STPSF_new));

quantumEfficiencyCCD        = 0.4;
darkCurrent                 = 0.2;
readNoise                   = 7;
exposureDuration            = 200e-12;
fullWellCapacity            = 500000;
saturationImageIndex        = 10;
numberOfBits                = 12;
H = CCDSensorOperator(size(STPSF_new),0.4,0.2,7,200e-12,500000,10,12);
CCDImages       = H*intensifiedImage;
CCDImages        = bin2dec(CCDImages);
CCDImages       = reshape(CCDImages,size(STPSF_new));
imshow(CCDImages(:,:,1),[])
figure, imshow(CCDImages(:,:,6),[])
figure, imshow(CCDImages(:,:,10),[])
figure, imshow(CCDImages(:,:,20),[])
%%



