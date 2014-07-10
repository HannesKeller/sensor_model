function plotDisparityMeanAndVariance(dataset)
% Check for file existence.
fileExistence = exist(strcat('results/disparity_variance/', dataset, '.mat'), 'file') == 2 && ...
                exist(strcat('results/mean_disparity/', dataset, '.mat'), 'file') == 2;

if (~fileExistence)
    fprintf('[plotDisparityMeanAndVariance] ERROR: Mean or variance for dataset %s has not yet been computed.\n', dataset);
    return;
end

% Load data
load(strcat('results/mean_disparity/', dataset, '.mat'));
load(strcat('results/disparity_variance/', dataset, '.mat'));

% % Filter data for third plot
% sigma = 3;
% sz = 2*ceil(2.6 * sigma) + 1;
% mask = fspecial('gauss', sz, sigma);
% disparityVariance_f = conv2(disparityVariance, mask, 'same');

figure();

% Plot mean, variance and smoothed variance
subplot(211);
imagesc(meanDisparity, [0 128]);
colorbar();
axis([0 752 0 480]);
title('Mean disparity');

subplot(212);
imagesc(disparityVariance, [0 0.5]);
colorbar();
axis([0 752 0 480]);
title('Disparity variance')

% subplot(313);
% imagesc(disparityVariance_f, [0 0.5]);
% colorbar();
% axis([0 752 0 480]);
% title('Smoothed disparity variance');
end