function varargout = cleanDwi(md, sitefiles, corrWMIntensity, wmLabels, varargin)
% calls cleanModality with the specific modality names expected in Stroke Study, specifically:
%
%   [dwiDst, dwiOutliers] = cleanDwi(md, sitefiles, corrWMIntensity, wmLabels, varargin)
%       outputs depends on input steps 
%
%   files fields are built from expected sd modality names as follows:
%       .modalityInSubj             = dwi
%       .modalityWMCorrInSubj       = dwiWMCorr
%       .labelsInSubj               = labelsInDwi
%       .brainMaskInSubj            = brainMaskInDwi
%       .modalityInAtlas            = dwiInAtlas
%       .modalityWMCorrInAtlas      = dwiWMCorrInAtlas
%
%   the rest of the files fields are built from sitefiles struct:
%       .labelsInAtlas              = sitefiles.labels
%       .brainMaskInAtlas           = sitefiles.brainMaskBin
%       .medianInAtlas              = sitefiles.dwiMedianFile
%       .distance                   = sitefiles.dwiDistFile
%

files = struct('modalityInSubj', 'dwi', 'modalityWMCorrInSubj', 'dwiWMCorr', ...
    'labelsInSubj', 'labelsInDwi', 'brainMaskInSubj', 'brainMaskInDwi', ...
    'modalityInAtlas', 'dwiInAtlas', 'modalityWMCorrInAtlas', 'dwiWMCorrInAtlas', ...
    'labelsInAtlas', sitefiles.labels, 'brainMaskInAtlas', sitefiles.brainMaskBin, ...
    'medianInAtlas', sitefiles.dwiMedianFile, 'distance', sitefiles.dwiDistFile);

varargout = md.cleanModality(files, corrWMIntensity, wmLabels, varargin{:});
