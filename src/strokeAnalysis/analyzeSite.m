%% Analysis of a new Site.
% Clean up of data, statistics and segmentations of a new site.
%   
% Project: Analysis of clinical datasets
% Authors: Adrian Dalca, Ramesh Sridharan
% Contact: {adalca,rameshvs}@csail.mit.edu

%% setup
clear;

% site-specific parameters
params.siteName = 'site18';
params.sdPredefinedType = 'FullSite';
[params.basePath, params.sitePath, params.clinicalxls] = strokeDataset.predefinedSite('18'); 
params.initialExcludes = 48;                            % exclude subjects

% initialize analysis
initAnalysis;

%% Some clean up of FLAIR and DWI modalities. This can take a long time.
[flairDst, flairOutliers] = sd.cleanFlair(files, params.wmFlairIntensity, params.wmLabels, 'exclude', exc);
[dwiDst, dwiOutliers] = sd.cleanDwi(files, params.wmDwiIntensity, params.wmLabels, 'exclude', exc);
outlierSubjects = union(flairOutliers, [dwiOutliers; exc]);

%% Apply Previously learned threshold to segment the wmh
args = {'threshold', params.mghLearnedWMHThr, 'subjectMasks', {'wmMaskInFlair'}, ...
    'subjectMasksLogicals', true, 'saveSubject', true, 'modSave', 'wmhCallInFlair'};
wmhSegmentation = sd.segmentModality('flairWMCorr', 'test', args{:}, 'exclude', exc);

% propagate wmhCallInFlair to atlas space
! python pipeline.py

%% add the registered wmh call to the strokeDatabase
sd.addPredefinedRequiredModality('wmhCallInAtlas');
sd.build(paths.PROCESSING_PATH, [], {}, true);

%% Compute a sum of all wmh call volumes (in Atlas space)
% TODO: limit subjects to eliminate outliers
aggVol = sd.aggregateModality({'wmhCallInAtlas'}, @modVols2sum, true, 'outNiiFile', files.aggWMH, exc{:});

%% Apply Previously learned threshold to segment the stroke
args = {'exclude', outlierSubjects, ...
    'threshold', params.mghLearnedDWIThr, 'subjectMasks', {'wmMaskInDwi'}, ...
    'subjectMasksLogicals', true, 'saveSubject', true, 'modSave', 'strokeCallInDwi'};
strokeSegmentation = sd.segmentModality('dwiWMCorr', 'test', args{:});

%% Apply Previously learned threshold to segment the wmh, excluding the learned stroke.
args = {'exclude', outlierSubjects, ...
    'threshold', params.mghLearnedWMHThr, 'subjectMasks', {'wmMaskInFlair', 'strokeCallInFlair'}, ...
    'subjectMasksLogicals', [true, false], 'saveSubject', true, 'modSave', 'leukCallInFlair'};
leukSegmentation = sd.segmentModality('flairWMCorr', 'test', args{:});

%% Write volumes to a csv files
ops = {@niiMask2voxCount, @niiMask2ccCount};
sd.modalityMeasure2csv('wmhCallInFlair', ops, files.wmhCallVolumes, 'exclude', outlierSubjects);
sd.modalityMeasure2csv('leukCallInFlair', ops, files.leukCallVolumes, 'exclude', outlierSubjects);

%% flip subjects up-down; left-right.
experimental_flipFlairs
