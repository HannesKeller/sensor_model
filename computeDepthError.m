function computeDepthError(dataset)
load(strcat('results/variance_model/', dataset));
load(strcat('results/mean_disparity/', dataset));

disparityError = sqrt(varianceModel);

depthFactor = 429.311714*0.11*ones(480, 752);

depthError = depthFactor.*(disparityError./(meanDisparity.^2 + meanDisparity.*disparityError));

save(strcat('results/depth_error/', dataset), 'depthError');
imagesc(depthError, [0 0.01]);
colorbar();
end