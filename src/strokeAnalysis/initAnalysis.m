% initialize analysis

% turn off warning backtrace... 
% see http://www.mathworks.com/help/matlab/matlab_prog/change-warning-modes.html
warning off backtrace

% General paths
if ~ispc
    paths.SANDBOX = '/path/to/sandbox';
    paths.HTML_OUT_ROOT = '/path/to/public_html/analysis';
else
    paths.SANDBOX = 'C:\path\to\sandbox';
    paths.HTML_OUT_ROOT = '';
end
paths.GLSANDBOX = fullfile(paths.SANDBOX, params.siteName);
mkdir(paths.GLSANDBOX);

% atlas-related paths
files = strokeDataset.predefinedAtlasFiles();

% files that might be useful in processing
files.flairMedianFile = fullfile(paths.GLSANDBOX, 'median_flairRegWMCorr.nii.gz');
files.flairDistFile = fullfile(paths.GLSANDBOX, 'dist_flairRegWMCorr.mat');
files.dwiMedianFile = fullfile(paths.GLSANDBOX, 'median_dwiRegWMCorr.nii.gz');
files.dwiDistFile = fullfile(paths.GLSANDBOX, 'dist_dwiRegWMCorr.mat');
files.aggTrueWMHR = fullfile(paths.GLSANDBOX, 'mean_wmhR.nii.gz');
files.aggTrueWMHL = fullfile(paths.GLSANDBOX, 'mean_wmhL.nii.gz');
files.aggTrueWMH = fullfile(paths.GLSANDBOX, 'mean_wmh.nii.gz');
files.aggWMH = fullfile(paths.GLSANDBOX, 'mean_wmh_call.nii.gz');
files.wmhCallVolumes = fullfile(paths.GLSANDBOX, 'volumes_wmh.csv');
files.leukCallVolumes = fullfile(paths.GLSANDBOX, 'volumes_leuk.csv');
files.clusterFeatures = fullfile(paths.GLSANDBOX, 'cluster_features.mat');
files.centroids = fullfile(paths.GLSANDBOX, 'cluster_centroid_%s.nii.gz');
files.sd = fullfile(paths.GLSANDBOX, 'sd.mat');

% general parameters
params.verbose = true;
params.reload = false; 
params.sdOverwrite = true;
params.processingOverwrite = true;
params.wmLabels = [2, 41];
params.wmFlairIntensity = 290;      % White Matter intensity of FLAIR to match
params.wmDwiIntensity = 2000;       % White Matter intensity of DWI to match
params.mghLearnedWMHThr = 426; %373; %new:426/455 old:438;      % threshold for WMH segmentation learned from MGH site
params.mghLearnedDWIThr = 3341;     % threshold for WMH segmentation learned from DWI site. 2565?
params.trainPrctile = 90;           
params.ageThr = 90;                 

% basepath where the processing happened and clinical-related paths

paths.BASE = params.basePath;
paths.PROCESSING = params.sitePath;
paths.CLINICAL_XLS = params.clinicalxls;

% uniqueSandbox
date = datestr(now, 'yyyy-mm-dd---HH-MM-SS-FFF');
paths.UNSANDBOX = [paths.GLSANDBOX, filesep, date, filesep];
mkdir(paths.UNSANDBOX);

% build strokeDataset object
ost = struct('overwrite', params.sdOverwrite);
args = {'saveFile', files.sd, 'verbose', params.verbose, 'params', ost};
if params.reload
    args = [args {'loadFile', files.sd}];
end
sd = strokeDataset.predefined(params.sdPredefinedType, paths.PROCESSING, args{:});

% excludes
if isfield(params, 'initialExcludes')
    exc = params.initialExcludes;
else
    exc = [];
end

% for clustering:
% sd = strokeDataset();
% sd.addPredefinedModality('wmhLInAtlas');
% sd.addPredefinedModality('wmhRInAtlas');
% sd.addPredefinedRequiredModality('flairInAtlas');
% sd.addPredefinedModality('flairWMCorrInAtlas');
% sd.addRequiredFactor('Age', 'Age', -1); % could also add NIHSS, FUMRS
% params.sdPredefinedType = 'ManualInAtlas'
% get params.clinicalxls from predefinedSite

% regression mixtures
% sd = strokeDataset();
% sd.addPredefinedModality('wmhLInAtlas');
% sd.addPredefinedModality('wmhRInAtlas');
% sd.addPredefinedRequiredModality('flairInAtlas');
% sd.addPredefinedModality('flairWMCorrInAtlas');
% sd.addRequiredFactor('Age', 'Age', -1); % could also add NIHSS, FUMRS
% params.sdPredefinedType = '';
% get params.clinicalxls from predefinedSite
