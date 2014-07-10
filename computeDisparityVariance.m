% Computes disparity variance of the specified dataset.
% Automatically computes mean disparity if it has not been previously
% computed.
% If saveData is true, the data is saved.
function disparityVariance = computeDisparityVariance(dataset, saveData)

if (nargin < 2)
    saveData = false;
end

if (exist(strcat('results/disparity_variance/', dataset, '.mat'), 'file') == 2)
    fprintf('[computeDisparityVariance] WARNING: Disparity variance for dataset %s has already been computed.\n', dataset);
    load(strcat('results/disparity_variance/', dataset, '.mat'));
    return;
end

fprintf('[computeDisparityVariance] Computing disparity variance for dataset %s\n', dataset);
% Load files
filePath = strcat(dataset, '/disparity/');
files = dir(strcat(filePath, '*.csv'));
nFiles = size(files, 1);

disparityVariance = zeros(480, 752);
counter = zeros(480, 752);

% Check for disparity files.
if (nFiles == 0)
    fprintf('[computeDisparityVariance] ERROR: No disparity data found. Exiting.\n');
    return;
else
    fprintf('[computeDisparityVariance] Found %i disparity files.\n', nFiles);
end

% Compute mean first if has not yet been computed.
if (exist(strcat('results/mean_disparity/', dataset, '.mat'), 'file') ~= 2)
    fprintf('[computeDisparityVariance] WARNING: Mean disparity has not yet been computed. Computing now...\n');
    meanDisparity = computeMeanDisparity(dataset, saveData);
else
    % Otherwise, load mean disparity.
    load(strcat('results/mean_disparity/', dataset, '.mat'));
end
    
validDisparityPixels = meanDisparity ~= 0;
for i = 1:nFiles
    data = load(strcat(filePath, files(i).name));
    validPixels = ((data ~= -1) .* validDisparityPixels);
    disparityVariance = disparityVariance + ((data-meanDisparity).*validPixels).^2;
    counter = counter + validPixels;
    fprintf('[computeDisparityVariance] Processed %i of %i disparity files.\n', i, nFiles);
end

% Make sure the division works for cells that are always invalid.
counter(counter == 0) = 1;

disparityVariance = disparityVariance./counter;

if(nargin > 1 && saveData)
   save(strcat('results/disparity_variance/', dataset, '.mat'), 'disparityVariance');
   fprintf('[computeDisparityVariance] Saved disparity variance for dataset %s\n', dataset);
end

end