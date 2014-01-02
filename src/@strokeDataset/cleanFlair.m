function varargout = cleanFlair(md, sitefiles, corrWMIntensity, wmLabels, varargin)
% calls cleanModality with the specific modality names expected in Stroke Study, specifically:
%
% [flairDst, flairOutliers] = cleanFlair(md, sitefiles, corrWMIntensity, wmLabels, varargin)
%       outputs depends on input steps 
%
% files fields are built from expected sd modality names as follows:
% 	.modalityInSubj             = flair
%	.modalityWMCorrInSubj       = flairWMCorr
%	.labelsInSubj               = labelsInFlair
%	.brainMaskInSubj            = brainMaskInFlair
%	.modalityInAtlas            = flairInAtlas
%	.modalityWMCorrInAtlas      = flairWMCorrInAtlas
%
%   the rest of the files fields are built from sitefiles struct:
%	.labelsInAtlas              = sitefiles.labels
%	.brainMaskInAtlas           = sitefiles.brainMaskBin
%	.medianInAtlas              = sitefiles.flairMedianFile
%	.distance                   = sitefiles.flairDistFile
%   
% Project: Analysis of clinical datasets
% Authors: Adrian Dalca, Ramesh Sridharan
% Contact: {adalca,rameshvs}@csail.mit.edu

files = struct('modalityInSubj', 'flair', 'modalityWMCorrInSubj', 'flairWMCorr', ...
    'labelsInSubj', 'labelsInFlair', 'brainMaskInSubj', 'brainMaskInFlair', ...
    'modalityInAtlas', 'flairInAtlas', 'modalityWMCorrInAtlas', 'flairWMCorrInAtlas', ...
    'labelsInAtlas', sitefiles.labels, 'brainMaskInAtlas', sitefiles.brainMaskBin, ...
    'medianInAtlas', sitefiles.flairMedianFile, 'distance', sitefiles.flairDistFile);

varargout = md.cleanModality(files, corrWMIntensity, wmLabels, varargin{:});
