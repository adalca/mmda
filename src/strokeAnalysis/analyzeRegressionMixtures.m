%% Regression Mixture Analysis 
% Run several regression mixture analysis on our data (mostly for entire images/masks)
%   
% Project: Analysis of clinical datasets
% Authors: Adrian Dalca, Ramesh Sridharan
% Contact: {adalca,rameshvs}@csail.mit.edu

%% setup
% whether or not to allow reloading of existing files
clear;
initRegressionMixtures;

%% WM linear equalization of FLAIR in reg space, and median
steps = {'linearEqualizationInAtlas', 'medianImage', 'ssdMedianDistance', 'tukey'};
% steps = {'loadssdMedianDistance', 'loadTukey'};
% TODO: change modality, don't have "load" have just normal ssdMedian and overwrite? or something
% like that. So that you load *if* modality is computed, etc...?
[flairDst, flairOutliers] = sd.cleanFlair(files, params.wmFlairIntensity, params.wmLabels, 'steps', steps{:});

%% Extract Features
% Extract subject features based on a brain mask
if ~(exist(files.regressionFeatures, 'file') == 2)
    [regFeatures, regCanCompute] = sd.features({'wmhBW'}, 'brainSize', [256, 256, 256]);
    regFeatures.Age = [sd.factors(:).Age];
    save(files.regressionFeatures, '-v7.3', 'regFeatures', 'regCanCompute');
else
    load(files.regressionFeatures, 'regFeatures', 'regCanCompute');
end

%% Subject Pruning 
assert(all(regCanCompute.wmhBW));
goodSubjects = regFeatures.Age(:) < params.ageThr;
age = regFeatures.Age(goodSubjects);
wmhBW = sparse(regFeatures.wmhBW(:, goodSubjects));
fprintf(1, 'Total subjects after pruning: %i\n', numel(goodSubjects));

%% Mask Regression 
% Run kernel regression on WMH Mask

% each image shown here is an 'average' image, with weights determined by a gaussian kernel
% centered at the respective age.
figureH = figure('units', 'pixels', 'outerposition', [0 0 1500 800]);
figureH = kernelRegressImages(age(:), 'age', wmhBW', 'WMH Volume', ...
    [256 256 256], 10, 3, 'b.', figureH);


%% Regression Mixtures
% Find regression mixtures (in this case, simply based on linear regression),
wmhMean = full(mean(wmhBW,  1));
[cIdx, h] = clusterLinearRegression(age', wmhMean', 2);
xlabel('age');
ylabel('WMH Volume');

%% Kernel Regression on Regression Mixtures
% run kernel regression (each interpolating image $I^x$ is an average of the given images with 
%   a kernel $K_h(x)$ centered at position x. We do this on each mixture.

clusterH = figure('units', 'pixels', 'outerposition', [0 0 1500 800]);
axis([min(age)-5, max(age)+5, -0.1*max(full(wmhMean)), max(full(wmhMean))*1.1]);

regressX = linspace(min(age), max(age), 7);
regressX = regressX(2:end-1);

[clusterH, ~, plotImagesC1] = kernelRegressImages(age(cIdx==1)', 'age', wmhBW(:, cIdx==1)', 'WMH Volume', ...
    [256 256 256], regressX, 11, 'b.', clusterH, ATLAS_FILE);

[clusterH, ~, plotImagesC2] = kernelRegressImages(age(cIdx==2)', 'age', wmhBW(:, cIdx==2)', 'WMH Volume', ...
    [256 256 256], regressX, 11, 'r.', clusterH, ATLAS_FILE);


figure('units', 'pixels', 'outerposition', [0 0 1500 800]); 
p2 = [plotImagesC2{:}]; for i = 1:3, p2(:,:,i) = flipud(p2(:,:,i)); end
p1 = [plotImagesC1{:}]; for i = 1:3, p1(:,:,i) = flipud(p1(:,:,i)); end
bigim = im2double([p2; p1]);
bigim = bigim ./ max(bigim(:));
image(bigim);

legend off
