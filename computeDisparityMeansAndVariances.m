% Computes and saves disparity means and variances of the specified
% datasets.
% datasets is a cell array containing data set names.
function computeDisparityMeansAndVariances(datasets)
nDatasets = size(datasets, 2);

% Loop through all datasets
for i = 1:nDatasets
    computeDisparityVariance(datasets{i}, true);
end
end