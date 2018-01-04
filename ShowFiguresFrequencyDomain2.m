% g = no mask
% m = mask
g = NOMASK;
m = MASK;

log_g = log10(g);
log_m = log10(m);

% figure(1), surf(1:106,1:106,log_g);
% figure(2), surf(1:106,1:106,log_m);

minVal = min([log_g(:);log_m(:)]);
maxVal = max([log_g(:);log_m(:)]);

figure(1), imagesc(log_g,[minVal maxVal]), axis image;
figure(2), imagesc(log_m,[minVal maxVal]), axis image