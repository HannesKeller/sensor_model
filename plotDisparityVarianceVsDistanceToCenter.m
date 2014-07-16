function plotDisparityVarianceVsDistanceToCenter(dataset, params)
load(strcat('results/disparity_variance/', dataset));
load(strcat('results/mean_disparity/', dataset));

imageCenter_x = params(3)*meanDisparity + params(4);
imageCenter_y = 240;

% Helper matrices for fast calculation
I = zeros(480, 752);
J = zeros(480, 752);

for i = 1:480
    I(i, :) = i;
    J(i, :) = 1:752;
end

distanceToCenter = sqrt((imageCenter_y - I).^2 + (imageCenter_x - J).^2);

nSets = 20;
dstep = 20;
x = 0:0.01:0.5;
variancePeaks = zeros(nSets, 1);
varianceMeans = zeros(nSets, 1);
varianceDevs = zeros(nSets, 1);
for i = 1:nSets
   %subplot(nSets, 1, i);
   ind = (distanceToCenter >= dstep*(i-1)) & (distanceToCenter < dstep*i);
   d = disparityVariance(ind);
   [nelelements, centers] = hist(d, x);
   [~, peak_index] = max(nelelements);
   variancePeaks(i) = centers(peak_index);
   varianceMeans(i) = mean(d(:));
   varianceDevs(i) = std(d(:));
   %axis([0.0 0.5 0 5000]);
end

varianceMD = varianceMeans + varianceDevs;

%f = @(x) 0.0004*x + 0.03; %linear approximation for 40cm sets
x_peaks = (dstep:dstep:(nSets*dstep))';
ind = x_peaks < 200;

coefs_p = polyfit(x_peaks(ind), variancePeaks(ind), 1);
coefs_m = polyfit(x_peaks(ind), varianceMeans(ind), 1);
coefs_d = polyfit(x_peaks(ind), varianceDevs(ind), 1);
coefs_md = polyfit(x_peaks(ind), varianceMD(ind), 1);

f_p = @(x) coefs_p(1)*x + coefs_p(2);
f_m = @(x) coefs_m(1)*x + coefs_m(2);
f_d = @(x) coefs_d(1)*x + coefs_d(2);
f_md = @(x) coefs_md(1)*x + coefs_md(2);



figure();
hold on;
plot(distanceToCenter(:), disparityVariance(:), 'b.');

%plot(x_peaks, variancePeaks, 'g-');
plot(x_peaks, varianceMD, 'r-');
%plot(x_peaks, f(x_peaks), 'r-');
%plot(x_peaks, f_p(x_peaks), 'r-');
%plot(x_peaks, f_m(x_peaks), 'c-');
%plot(x_peaks, f_m(x_peaks) + f_d(x_peaks), 'm-');
%plot(x_peaks, f_m(x_peaks) - f_d(x_peaks), 'm-');
plot(x_peaks, f_md(x_peaks), 'g-');
axis([0 300 0 0.5]);
legend('Disparity Variance', 'Mean + Std', 'Fitted line');
xlabel('Distance to image center $[px]$', 'interpreter', 'latex');
ylabel('Disparity variance $[px^2]$', 'interpreter', 'latex');
title('Disparity Variance vs. Distance to Center', 'interpreter', 'latex');

xdata = {distanceToCenter(:), x_peaks, x_peaks};
ydata = {disparityVariance(:), varianceMD, f_md(x_peaks)};
xlim = [0 300];
ylim = [0 0.5];
specs = {'.b', '-r', '-g'};

save('plotData', 'xdata', 'ydata', 'xlim', 'ylim', 'specs');

%axis([0 nSets 0 0.15]);

% subplot(211);
% imagesc(distanceToCenter, [0 300]);
% subplot(212);
% imagesc(disparityVariance, [0 0.5]);

end