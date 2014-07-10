% Computes sensor model parameters for given datasets.
% datasets has to be a cell array of strings (dataset names)
function finalParameters = computeSensorModel(datasets)
% Array for end result: [m_2, m_3, q_1, q_2, q_3]
finalParameters = zeros(5, 1);

% *********************************************************************** %
% PARAMETERS ************************************************************ %
% *********************************************************************** %

center_y = 240;                             % Vertical image center
indices_y = (center_y-50):1:(center_y+50);  % Matrix indices around center

nSets = 20;                                 % Number of sets around center
dstep = 20;                                 % Set size
d_crit = 190;                               % 'Critical' distance to center

% *********************************************************************** %
% PREPARATION *********************************************************** %
% *********************************************************************** %

nDatasets = size(datasets, 2);

% Prepare main data cell arrays
means = cell(nDatasets, 1);
variances = cell(nDatasets, 1);

% Load datasets
for i = 1:nDatasets
    load(strcat('results/mean_disparity/', datasets{i}));
    load(strcat('results/disparity_variance/', datasets{i}));
    means{i} = meanDisparity;
    variances{i} = disparityVariance;
end

% *********************************************************************** %
% STEP 1: IMAGE CENTER FUNCTION (PARAMS m2, q2) ************************* %
% *********************************************************************** %

% Loop through each pair of datasets
imageCenters = zeros(1, nDatasets/2);
meanDisparities = zeros(1, nDatasets/2);
for i = 1:(nDatasets/2)
    % Compute horizontal image center
    columnMean1 = sum(variances{2*i-1}, 1)/480;
    columnMean2 = sum(variances{2*i}, 1)/480;
    ind = 250:650;
    y1 = min(columnMean1(ind));
    y2 = min(columnMean2(ind));
    y1_1 = find(columnMean1 == y1);
    y2_1 = find(columnMean2 == y2);
    imageCenters(i) = (y1_1 + y2_1)/2;
    
    % Compute mean disparity around image center
    indices_x = (imageCenters(i)-50):1:(imageCenters(i)+50);
    m1 = mean(mean(means{2*i-1}(indices_y, indices_x)));
    m2 = mean(mean(means{2*i}(indices_y, indices_x)));
    meanDisparities(i) = (m1 + m2)/2;
end

coefs = polyfit(meanDisparities, imageCenters, 1);
finalParameters(3) = coefs(1);
finalParameters(4) = coefs(2);

% *********************************************************************** %
% STEP 2: DISTANCE TO CENTER FUNCTION (PARAMS m3, q3, q1) *************** %
% *********************************************************************** %

% Helper matrices for fast calculation
I = zeros(480, 752);
J = zeros(480, 752);

for i = 1:480
    I(i, :) = i;
    J(i, :) = 1:752;
end

distancesToCenter = cell(nDatasets, 1);
modelCoefs = cell(nDatasets, 1);
for k = 1:nDatasets
    % Compute distance to center for each pixel    
    distancesToCenter{k} = sqrt((center_y - I).^2 + (finalParameters(3)*means{k} + finalParameters(4) - J).^2);
    
    % Create ring-shaped sets and extract variance peaks
    variancePoints = zeros(1, nSets);
    for i = 1:nSets
        ind = (distancesToCenter{k} >= dstep*(i-1)) & (distancesToCenter{k} < dstep*i);
        d = variances{k}(ind);
        variancePoints(i) = mean(d(:)) + std(d(:));
    end
    
    x_peaks = dstep:dstep:(nSets*dstep);
    ind = x_peaks < d_crit;
    modelCoefs{k} = polyfit(x_peaks(ind), variancePoints(ind), 1);

%     f = @(x) modelCoefs{k}(1)*x + modelCoefs{k}(2);
%     figure();
%     hold on;
%     plot(distancesToCenter{k}(:), variances{k}(:), '.');
%     plot(x_peaks, variancePoints, 'g-');
%     plot(x_peaks, f(x_peaks), 'r-');
%     axis([0 300 0 0.5]);
    
end

q1 = 0;
for i = 1:nDatasets
    q1 = q1 + modelCoefs{i}(2);
end
finalParameters(1) = q1/nDatasets;

m1 = zeros(nDatasets/2, 1);
for i = 1:(nDatasets/2)
    m1(i) = (modelCoefs{2*i-1}(1) + modelCoefs{2*i}(1))/2;
end

coef = polyfit(meanDisparities, m1', 1);

finalParameters(5) = coef(1);
finalParameters(2) = coef(2);

end