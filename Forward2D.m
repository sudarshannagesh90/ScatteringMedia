function imBlurred = Forward2D(imClean,PSF,forwardModelCase)
if forwardModelCase == 1 % Has boundary artifacts
imBlurred = (ifft2((fft2(imClean).*(fft2(PSF,size(imClean,1),size(imClean,2))))));
elseif forwardModelCase == 2 % Has boundary artifacts on Wiener-Filtering
% [M,N]   = size(imClean);
% padArraySize = floor(size(PSF,1)-1);
% imClean = padarray(imClean,[padArraySize padArraySize]);
% sizePSF = size(PSF,1);
% PSF     = padarray(PSF,[ceil((size(imClean,1)-sizePSF)/2) ceil((size(imClean,1)-sizePSF)/2)]);
% if size(PSF,1)~=size(imClean,1)
%     PSF = PSF(1:end-1,1:end-1);
% end
% imBlurred  = fftshift(ifft2((fft2(imClean).*(fft2(PSF)))));
% centerPixel= floor(size(imBlurred)/2);
% imBlurred  = imBlurred(centerPixel-floor(M/2)+1:centerPixel+floor(M/2),centerPixel-floor(N/2)+1:centerPixel+floor(N/2));
elseif forwardModelCase == 3 % Has no boundary artifacts
imBlurred  = imfilter(imClean,PSF,'circular');
end