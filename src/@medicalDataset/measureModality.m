function meas = measureModality(obj, modality, distMethod, varargin)
% MEASUREMODALITY compute a measure for each medicalDataset subject
%   meas = measureModality(obj, modality, distMethods) compute measure given by distMethods 
%   (function handle) for the subjects in the medicalDataset on modality given by string modality. 
%   Optionally, the measure can be done comparing each subject to an atlas, and/or can be done 
%   within given labels (see below)
%
%   meas = measureModality(obj, modality, distMethods, param1, value1) allows optional parameters:
%       atlasFile - a nifti atlas file if the measure is 2d (subject-atlas)
%       labelFile - a nifti label file if we want the measure done within label masks
%       distLabels - if we use labelFile, can specify specific labels we care about
%       any param/value pair supported by subjectSubset
%
%   2-vector methodHandle examples: @ssd, @msd, @mutualinfo
%   1-vector methodHandle examples: @mean
%
%   Author: Adrian V. Dalca
    
    % check inputs
    [modality, distMethod, inputs, useLabels, useAtlas, subset] = ...
        checkInputs(obj, modality, distMethod, varargin{:});
    nSubjects = numel(subset);

    % get the label images
    if useLabels && numel(inputs.distLabels) == 0
        labelMasks = nii2labelMasks(labelFile);
    elseif useLabels
        labelMasks = nii2labelMasks(inputs.labelFile, inputs.distLabels);
    else
        labelMasks = [];
    end
    
    % load atlas
    if useAtlas
        atlasNii = loadNii(inputs.atlasFile);
        atlas = double(atlasNii.img);
    end
    
    % initiate distances
    meas = zeros(nSubjects, numel(labelMasks));
    
    % go through all of the subjects
    msg = sprintf('measure (%s)', func2str(distMethod));
    vi = verboseIter(subset, obj.verbose, msg);
    while vi.hasNext()
        s = vi.next();
        
        % load nifti
        nii = loadNii(obj.getModality(modality, s));
        img = double(nii.img);
       
        % compute the volumes for the measure
        vols = {img(:)};
        if useAtlas
            vols = [vols, {atlas(:)}]; %#ok<AGROW>
        end
        
        % compute the measure
        if useLabels
            distance = labelwiseMeasure(vols, labelMasks, distMethod);
        else
            distance = distMethod(vols{:});
        end
        meas(s, :) = reshape(distance, [1, numel(labelMasks)]);
    end
    
    % display progress
    vi.close();
end

function [modality, distMethods, inputs, useLabels, useAtlas, subset] = ...
    checkInputs(obj, modality, distMethods, varargin)

    % parse inputs
    narginchk(3, inf);
    p = inputParser();
    p.addRequired('modality', @ischar);
    p.addRequired('distMethods', @(x) isa(x, 'function_handle'));
    p.addParamValue('atlasFile', '', @isstr);
    p.addParamValue('labelFile', '', @isstr);
    p.addParamValue('distLabels', [], @isnumeric);
    p.KeepUnmatched = true;
    p.parse(modality, distMethods, varargin{:});
    inputs = p.Results;
    
    % check inputs, and set defaults
    useLabels = exist(p.Results.labelFile, 'file') == 2;
    useAtlas = exist(p.Results.atlasFile, 'file') == 2;
    
    % get the desired subjects
    subset = obj.subjectSubset(varargin{:});
end
