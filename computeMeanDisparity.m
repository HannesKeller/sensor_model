% Computes mean disparity of the specified dataset.
% If saveData is true, the data is saved.
function meanDisparity = computeMeanDisparity(dataset, saveData)
if (exist(strcat('results/mean_disparity/', dataset, '.mat'), 'file') == 2)
    fprintf('[computeMeanDisparity] WARNING: Mean disparity for dataset %s has already been computed.\n', dataset);
    load(strcat('results/mean_disparity/', dataset, '.mat'));
    return;
end

fprintf('[computeMeanDisparity] Computing mean disparity for dataset %s\n', dataset);
% Load files
filePath = strcat(dataset, '/disparity/');
files = dir(strcat(filePath, '*.csv'));
nFiles = size(files, 1);

meanDisparity = zeros(480, 752);
counter = zeros(480, 752);

if (nFiles == 0)
    fprintf('[computeMeanDisparity] ERROR: No disparity data found. Exiting.\n');
    return;
else
    fprintf('[computeMeanDisparity] Found %i disparity files.\n', nFiles);
end

for i = 1:nFiles
    data = load(strcat(filePath, files(i).name));
    validPixels = (data ~= -1);
    meanDisparity = meanDisparity + data.*validPixels;
    counter = counter + validPixels;
    fprintf('[computeMeanDisparity] Processed %i of %i disparity files.\n', i, nFiles);
end

% Make sure the division works for cells that are always invalid.
counter(counter == 0) = 1;

meanDisparity = meanDisparity./counter;

if(nargin > 1 && saveData)
   save(strcat('results/mean_disparity/', dataset, '.mat'), 'meanDisparity');
   fprintf('[computeMeanDisparity] Saved mean disparity for dataset %s\n', dataset);
end

end