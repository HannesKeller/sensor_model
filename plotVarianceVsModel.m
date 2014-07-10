% Plots disparity variance, variance model, model error and error sign.
% Also computes the difference to the basic model.
% Also saves the model, the error and the sign if saveData is set to true.
function plotVarianceVsModel(dataset, params, saveData)
if nargin < 3
    saveData = false;
end

load(strcat('results/mean_disparity/', dataset));
load(strcat('results/disparity_variance/', dataset));

% Helper matrices for fast calculation
I = zeros(480, 752);
J = zeros(480, 752);

for i = 1:480
    I(i, :) = i;
    J(i, :) = 1:752;
end
x_weight = 1.0;
y_weight = 2-x_weight;
varianceModel = (params(5)*meanDisparity + params(2)).*sqrt(x_weight*(params(3)*meanDisparity + params(4) - J).^2 + y_weight*(240 - I).^2) + params(1);
varianceModel(meanDisparity == 0) = 0;
varianceModel(varianceModel < 0) = params(3);
errorSign = sign(varianceModel - disparityVariance);
modelError = abs(varianceModel - disparityVariance);

figure();
subplot(221);
imagesc(disparityVariance, [0 0.5]);
colorbar();
title('Disparity variance');
subplot(222);
imagesc(varianceModel, [0 0.5]);
colorbar();
title('Variance model');
subplot(223);
imagesc(modelError, [0 0.2]);
colorbar();
title('Absolute difference to model');
subplot(224);
imagesc(errorSign, [-1 1]);
colorbar();
title('Model sign');

if saveData
% Save model
save(strcat('results/variance_model/', dataset, '.mat'), 'varianceModel');
save(strcat('results/model_error/', dataset, '.mat'), 'modelError');
save(strcat('results/model_error_sign/', dataset, '.mat'), 'errorSign');
end

end