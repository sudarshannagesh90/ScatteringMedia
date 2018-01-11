clc
close all
clear all
%% Load the PSF and test-image
%addpath('C:\Users\Sudarshan Nagesh\OneDrive\WeightedDeconvolution\PSFsFromMarina')
addpath('C:\Users\Sudarshan\OneDrive\WeightedDeconvolution\PSFsFromMarina\')
load('pinhole_tau16.7_r1000_z3000_STAND-OFF.mat','sensor_xy')
STPSF_new                  = sensor_xy;
TotalPhotons               = sum(STPSF_new(:));
NumberofPhotonsSimulation  = 1e6;
STPSF_new                  = (NumberofPhotonsSimulation/TotalPhotons)*STPSF_new;
STPSF_new                  = floor(STPSF_new);
%%
set(0,'DefaultTextFontName','Helvetica','DefaultTextFontSize',20,'DefaultAxesFontName','Helvetica','DefaultAxesFontSize',20,'DefaultLineLineWidth',2,'DefaultLineMarkerSize',6)
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
figure('units','normalized','outerposition',[0 0 1 1]), surf(STPSF_new(:,:,10)), colorbar
title(['Time-slice: ',num2str(10)])
zlim([0 maxVal])
xlim([0 106])
ylim([0 106])
export_fig('Figures/STPSF10','-png')
figure('units','normalized','outerposition',[0 0 1 1]), surf(STPSF_new(:,:,15)), colorbar
title(['Time-slice: ',num2str(15)])
zlim([0 maxVal])
xlim([0 106])
ylim([0 106])
export_fig('Figures/STPSF15','-png')
%%
set(0,'DefaultTextFontName','Helvetica','DefaultTextFontSize',10,'DefaultAxesFontName','Helvetica','DefaultAxesFontSize',10,'DefaultLineLineWidth',2,'DefaultLineMarkerSize',6)
testImage = im2double(imread('cameraman.tif'));
testImage = imresize(testImage,[size(STPSF_new,1) size(STPSF_new,2)]);
testImage = testImage/max(max(testImage));

F = scatteringMediumOperator(STPSF_new,[size(STPSF_new,1) size(STPSF_new,1)],'Symmetric','Same');
scatteredimages = F*testImage;
scatteredimages = reshape(scatteredimages,size(STPSF_new));

intensifierQuantumEfficiency = 0.5;
intensifierDarkCurrent       = 0.2;
intensifierAmplifier         = 25;
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
H = CCDSensorOperator(size(STPSF_new),quantumEfficiencyCCD,darkCurrent,readNoise,exposureDuration,fullWellCapacity,saturationImageIndex,numberOfBits);
CCDImages       = H*intensifiedImage;
CCDImages       = bin2dec(CCDImages);
CCDImages12bit  = reshape(CCDImages,size(STPSF_new));
maxVals12bit    = squeeze(max(max(CCDImages12bit)));
maxVals12bit(1:20)
CCDImages8bit   = uint8(floor(CCDImages12bit*255/(2^numberOfBits-1)));
maxVals8bit     = squeeze(max(max(CCDImages8bit)));
maxVals8bit(1:20)
figure('units','normalized','outerposition',[0 0 1 1]), imshow(CCDImages8bit(:,:,1)), colorbar
export_fig('Figures/BlurryImage1','-png')
figure('units','normalized','outerposition',[0 0 1 1]), imshow(CCDImages8bit(:,:,4)), colorbar
export_fig('Figures/BlurryImage4','-png')
figure('units','normalized','outerposition',[0 0 1 1]), imshow(CCDImages8bit(:,:,10)), colorbar
export_fig('Figures/BlurryImage10','-png')
figure('units','normalized','outerposition',[0 0 1 1]), imshow(CCDImages8bit(:,:,10)), colorbar
export_fig('Figures/BlurryImage15','-png')
%%



