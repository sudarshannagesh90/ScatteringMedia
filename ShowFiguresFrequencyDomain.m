clc
clear all
close all
%% 
load BlurryObservation6000KM16.7taueight.jpgMediumNoise.mat
rng(100)
addpath('altmany-export_fig-cf9417f\')
addpath('Figures\')
randomMask = round(rand(size(STPSF_new(:,:,1))));
for ind = 1:5:25
    originalPSF = STPSF_new(:,:,ind);
    codedPSF    = originalPSF.*randomMask;
    originalPSFfft = abs(fftshift(fft2(originalPSF)));
    codedPSFfft    = abs(fftshift(fft2(codedPSF)));
    originalPSFfft = log10(originalPSFfft);
    codedPSFfft    = log10(codedPSFfft);
    minFFT         = min(min([originalPSFfft(:) codedPSFfft(:)]));
    maxFFT         = max(max([originalPSFfft(:) codedPSFfft(:)]));
    centralLineoriginalPSFfft = originalPSFfft(53,:);
    centralLinecodedPSFfft    = codedPSFfft(53,:);
    close all
    figure
    set(0,'DefaultTextFontName','Helvetica','DefaultTextFontSize',20,'DefaultAxesFontName','Helvetica','DefaultAxesFontSize',20,'DefaultLineLineWidth',2,'DefaultLineMarkerSize',6)
    imshow(originalPSF,[])
    set(gcf, 'Position', get(0, 'Screensize'));
    export_fig(['Figures\originalPSF',num2str(ind),'.png']);

    close all
    figure
    imshow(codedPSF,[])
    set(gcf, 'Position', get(0, 'Screensize'));
    export_fig(['Figures\codedPSF',num2str(ind),'.png']);

    close all
    figure
    imshow(originalPSFfft,[]), colorbar, caxis([minFFT maxFFT])
    set(gcf, 'Position', get(0, 'Screensize'));
    export_fig(['Figures\originalPSFfft',num2str(ind),'.png']);

    close all
    figure
    imshow(codedPSFfft,[]), colorbar, caxis([minFFT maxFFT])
    set(gcf, 'Position', get(0, 'Screensize'));
    export_fig(['Figures\codedPSFfft',num2str(ind),'.png']);

    close all
    figure
    set(0,'DefaultTextFontName','Helvetica','DefaultTextFontSize',40,'DefaultAxesFontName','Helvetica','DefaultAxesFontSize',40,'DefaultLineLineWidth',5,'DefaultLineMarkerSize',6)
    plot(centralLineoriginalPSFfft,'r--')
    hold on
    plot(centralLinecodedPSFfft,'b--')
    ylim([min([centralLineoriginalPSFfft(:);centralLinecodedPSFfft(:)]) max([centralLineoriginalPSFfft(:);centralLinecodedPSFfft(:)])])
    ylabel('log (dB)')
    legend('Original','Coded')
    set(gcf, 'Position', get(0, 'Screensize'));
    export_fig(['Figures\codedPSFfftvsoriginalPSFfft',num2str(ind),'.png']);
end 
    


