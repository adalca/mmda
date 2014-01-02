%% Analyze Clusters
% Cluster subjects based on several features
%   
% Project: Analysis of clinical datasets
% Authors: Adrian Dalca, Ramesh Sridharan
% Contact: {adalca,rameshvs}@csail.mit.edu

%% setup
clear;
initClusters;

%% Extract Features if they exist
features = struct();
if isfile(files.clusterFeatures)
    load(files.clusterFeatures, 'features');
    assert(numel(features, 2) == sd.getNumSubjects);
end

%% cluster subjects
% cluster based on subject features. 
fileargs = {'maskFile', files.brainMaskBin, 'saveFile', files.centroids};

% create 3 clusters based on wmhCallBW, and compute wmhCallBW, strokeCallBW centroids
args = [fileargs, {'centroidFeatureTypes', {'wmhCallBW', 'strokeCallBW'}}, {'features', features}];
[wmhCallBWcIdx2, wmhCallBWcentroids2, features] = sd.clusterVolumes('wmhCallBW', 2, args{:});

% create 2 clusters based on wmhCallBW, and compute wmhCallBW, strokeCallBW centroids
args = [fileargs, {'centroidFeatureTypes', {'wmhCallBW', 'strokeCallBW'}}, {'features', features}];
[wmhCallBWcIdx3, wmhCallBWcentroids3] = sd.clusterVolumes('wmhCallBW', 3, args{:});

% create 3 clusters based on strokeCallBW, and compute wmhCallBW, strokeCallBW centroids
[strokeCallBWcIdx, strokeCallBWcentroids] = sd.clusterVolumes('strokeCallBW', 3, args{:});

% create 2 clusters based on hemispheric diff, and compute wmhHemiDiff, strokeCallBW centroids
args = [fileargs, {'centroidFeatureTypes', {'wmhHemiDiff', 'strokeCallBW'}, 'features', features}]; 
[wmhHemiDiffCIdx, wmhHemiDiffCentroids] = sd.clusterVolumes('wmhHemiDiff', 2, args{:});

% save computed features
save(files.clusterFeatures, '-v7.3', 'features');

%% Extract features per parcelation
% Extract subject features based on a parcelation
args = {'brainSize', [256, 256, 256], 'parcFile', files.parc};
[parcFeatures, parcCanCompute] = sd.features({'wmhCallBW', 'strokeCallBW'}, args{:});
save(fullfile(SANDBOX, 'subjFeatures2.mat'), '-v7.3', 'subjFeatures', 'canCompute');

