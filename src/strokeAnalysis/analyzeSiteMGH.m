%% Analysis of MGH Data
% Clean up of data, statistics and segmentations of site MGH.
%   
% Project: Analysis of clinical datasets
% Authors: Adrian Dalca, Ramesh Sridharan
% Contact: {adalca,rameshvs}@csail.mit.edu

%% setup
clear;

% site-specific parameters
params.siteName = 'siteMGH';
params.sdPredefinedType = 'FullMGH';
[params.basePath, params.sitePath, params.clinicalxls] = strokeDataset.predefinedSite('MGH'); 

% initialize analysis
initAnalysis;

%% copy L & R segmenatations to a LR modality
sd.joinModalities({'wmhLInFlair', 'wmhRInFlair'}, 'wmhInFlair', @modVols2sum);

%% Some clean up of FLAIR and DWI modalities. This can take a long time.
[flairDst, flairOutliers] = sd.cleanFlair(files, params.wmFlairIntensity, params.wmLabels, 'verbose', true, 'savePath', paths.UNSANDBOX);
[dwiDst, dwiOutliers] = sd.cleanDwi(files, params.wmDwiIntensity, params.wmLabels, 'verbose', true, 'savePath', paths.UNSANDBOX);
outlierSubjects = union(flairOutliers, dwiOutliers);

%% aggregate "true" registered WMH in 3 separate volumes (L,R,total);
sd.aggregateModality('wmhRInAtlas', @modVols2sum, true, 'outNiiFile', files.aggTrueWMHR);
sd.aggregateModality('wmhLInAtlas', @modVols2sum, true, 'outNiiFile', files.aggTrueWMHL);
addNiis({files.aggTrueWMHR, files.aggTrueWMHL}, files.aggTrueWMH);

%% Choose 10 subjects manually
% TODO - form train subjects from joint ranks
trainSubjects = [8, 16, 22, 31, 35, 43, 49, 61, 84, 89];

%% Train a wmh segmentation threshold
args = {'include',  trainSubjects, 'exclude', outlierSubjects, 'trueMask', 'wmhInFlair', ...
    'subjectMasks', {'wmMaskInFlair', 'strokeInFlair'}, 'subjectMasksLogicals', [true false]};
wmhTrainStats = sd.segmentModality('flairWMCorr', 'train', args{:});

% get the threshold (and plot histograms)
thr = segstats2thr(wmhTrainStats, 'MAP', sd.verbose);

%% true segmentation stats
excludeSubjects = union(outlierSubjects, trainSubjects);

args = {'exclude', excludeSubjects, 'saveSubject', false, 'trueMask', 'wmhInFlair', ...
    'subjectMasks', {'wmMaskInFlair', 'strokeInFlair'}, 'subjectMasksLogicals', [true false]};
wmhTrueStats = sd.segmentModality('flairWMCorr', 'train', args{:});

%% test segmentation stats
% TODO: make sure excluded subjects don't have a volume...
args = {'exclude', excludeSubjects, 'saveSubject', true, 'modSave', 'wmhCallInFlair', ...
    'subjectMasks', {'wmMaskInFlair', 'strokeInFlair'}, 'subjectMasksLogicals', [true false], ...
    'threshold', thr};
wmhTestStats = sd.segmentModality('flairWMCorr', 'test', args{:});

%% compare segmentations
subset = sd.subjectSubset(args{:});
sd.verbose && segstatsVolCompare(wmhTrueStats, wmhTestStats, sd.sids(subset)); %#ok<VUNUS>

%% Some experimental code for wmh analysis
experimental_stats2chronicStroke(wmhTestStats);
experimental_stats2chronicStroke2(wmhTest);

%% Train Stroke Segmentation
args = {'exclude', excludeSubjects, 'trueMask', 'strokeInDwi', ...
    'subjectMasks', {'wmMaskInDwi'}, 'subjectMasksLogicals', true};
strokeTrainStats = sd.segmentModality('dwiWMCorr', 'train', args{:});

% get the threshold (and plot histograms)
thr = segstats2thr(strokeTrainStats, 'MAP', sd.verbose);

%% true segmentation stats
args = {'exclude', excludeSubjects, 'trueMask', 'strokeInDwi', ...
    'subjectMasks', {'wmMaskInDwi'}, 'subjectMasksLogicals', true};
strokeTrueStats = sd.segmentModality('dwiWMCorr', 'train', args{:});

%% test segmentation stats
% thr = l(115); % 4118 ;; l(72) is 2565
args = {'exclude', excludeSubjects, 'threshold', thr, 'subjectMasks', {'wmMaskInDwi'}, ...
    'subjectMasksLogicals', true, 'saveSubject', true, 'modSave', 'strokeCallInDwi'};
strokeTestStats = sd.segmentModality('dwiWMCorr', 'test', args{:});

%% compare segmentations
subset = sd.subjectSubset(args{:});
sd.verbose && segstatsVolCompare(strokeTrueStats, strokeTestStats, sd.sids(subset)); %#ok<VUNUS>

%% write 'correct' calls within WM
args = {'trueMask', 'strokeInDwi', 'subjectMasks', {'wmMaskInDwi'}, ...
    'subjectMasksLogicals', true, 'saveSubject', true, 'modSave', 'strokeWithinWMInDwi'};
sd.segmentModality('dwiWMCorr', 'train', args{:});

%% some experimental code for wmh analysis
experimental_visualizeTrueStats;
experimental_visualizeTrueIntensities;
