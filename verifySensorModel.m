function verifySensorModel(datasets, params)
nDatasets = size(datasets, 2);

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

% Loop through each pair of datasets
imageCenters = zeros(1, nDatasets/2);
nominalImageCenters = zeros(1, nDatasets/2);
meanDisparities = zeros(1, nDatasets/2);
p1 = zeros(nDatasets, 1);
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
    nominalImageCenters(i) = params(3)*meanDisparities(i) + params(4);
    
    p1(2*i-1) = mean(mean(variances{2*i-1}(indices_y, indices_x)));
    p1(2*i) = mean(mean(variances{2*i}(indices_y, indices_x)));
    
    disp('Image center offset (absolute error):');
    modelOffset = imageCenters(i) - nominalImageCenters(i)
    disp('Image center offset (relative error):');
    relativeModelOffset = modelOffset/imageCenters(i)
    disp('Offset from the ideal model:');
    idealModelOffset = imageCenters(i) - 0.5*meanDisparities(i) - 376
    disp('Offset from the ideal model (relative):');
    relativeIdealModelOffset = idealModelOffset/imageCenters(i)
end

newp1 = mean(p1);

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
    distancesToCenter{k} = sqrt((center_y - I).^2 + (params(3)*means{k} + params(4) - J).^2);
    
    % Create ring-shaped sets and extract variance peaks
    variancePoints = zeros(1, nSets);
    for i = 1:nSets
        ind = (distancesToCenter{k} >= dstep*(i-1)) & (distancesToCenter{k} < dstep*i);
        d = variances{k}(ind);
        variancePoints(i) = mean(d(:)) + std(d(:));
    end
    
    x_peaks = (dstep/2):dstep:(nSets*dstep);
    ind = x_peaks < d_crit;
    modelCoefs{k} = polyfit(x_peaks(ind), variancePoints(ind), 1);
    modelCoefs{k}(2) = p1(k);
end

%save('modelCoefs_v.mat', 'modelCoefs');

nominalModelCoefs = cell(nDatasets/2, 1);
meanModelCoefs = cell(nDatasets/2, 1);
for k = 1:(nDatasets/2)
    nominalModelCoefs{k} = [params(5)*meanDisparities(k) + params(2), params(1)];   
    meanModelCoefs{k} = (modelCoefs{2*k-1} + modelCoefs{2*k})./2;
    nominalModelCoefs{k}
    meanModelCoefs{k}
    fprintf('Difference to model of (p5*d + p2, p1) for dataset %i:\n', k);
    coefError = nominalModelCoefs{k} - meanModelCoefs{k}
    relativeCoefError = coefError./meanModelCoefs{k}
end

end