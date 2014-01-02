function stats = segmentModality(obj, modFile, method, varargin) 
%   SEGMENTMODALITY run threshold segmentations in a medical dataset
%   stats = segmentModality(obj, modFile, 'train', param1, value1, ...) uses threshold segmentation 
%   to segment the subjects in a medical dataset. 
%       modFile - is the main modality/volume against which the segmentation will be run
%       method - 'train' or 'test'. In training, a 'trueMask' must be provided. 
%
%   Potential param/value pairs::
%       trueMask - if training, a true mask modality string must be provided 
%       threshold - the threshold to use for testing
%       saveSubject - logical on whether to save the subject segmentations
%       modSave - if saving subjects, modality (string) to save to
%       subjectMasks - masks relevant to the segmentations (where to include or exclude segments)
%       subjectMasksLogicals - logical vector - for each mask, true to include ONLY given mask, 
%           false to exclude given mask
%       globalMask - TODO (not yet implemented)
%
% TODOs: 
%   add feature(s)
%   - get all the slices that have non-zero mask entries.
%   - for each slice, do box blurring in-slice, with aboth 3 and 5-wide filters.
%   - add those as features?
%   (during training)
%   
% Project: Analysis of clinical datasets
% Authors: Adrian Dalca, Ramesh Sridharan
% Contact: {adalca,rameshvs}@csail.mit.edu
    

    inputs = checkInputs(obj, modFile, method, varargin{:});
    nSubjects = numel(inputs.subset);
        
    % stats and saves
    stats.allowableMasks = cell(nSubjects, 1);
    stats.sizes = zeros(nSubjects, 3);
    stats.modSelections = cell(nSubjects, 1);
    stats.segmentations = cell(nSubjects, 1);
    stats.callVolumes = zeros(nSubjects, 1); % save volume of wmh.
    stats.modCallVec = [];   	% all flair foxels marked WMH
    stats.modNonCallVec = [];    % all flair foxels marked healthy
    
    % TODO: load any global mask. 
    assert(numel(inputs.globalMask) == 0, 'globalMask Not Implemented');
    
    vi = verboseIter(inputs.subset, obj.verbose);
    while vi.hasNext()
        [s, i] = vi.next();

        % load local Masks 
        %   (e.g. in WMH segmentation: wmhMaskInFlair and lesioninFlair)
        nMasks = numel(inputs.subjectMasks);
        allowableMask = true;
        for m = 1:nMasks
            maskNii = loadNii(obj.files(s).(inputs.subjectMasks{m}));
            if inputs.subjectMasksLogicals(m)
                allowableMask = allowableMask & maskNii.img(:) == 1; % used to be > 0;
            else
                allowableMask = allowableMask & maskNii.img(:) == 0;
            end
            
        end
        
        % load main modality
        modNii = loadNii(obj.files(s).(inputs.modFile));
        modVol = double(modNii.img);
        
        % put main modality within mask
        modVolWithinMask = modVol(allowableMask);
        stats.sizes(i, :) = size(modVol);

        % if training, get the true mask
        if strcmp(method, 'train')
            % load 'True' labels: WMH, etc.  
            trueNii = loadNii(obj.files(s).(inputs.trueMask));           
            callVol = trueNii.img(allowableMask) > 0;

        % testing, just 
        elseif strcmp(method, 'test')
            callVol = modVolWithinMask > inputs.threshold;
        end
    
        % get Flair within wmh and healthy
        modVolWithinCall = modVolWithinMask(callVol);
        modVolOutsideCall = modVolWithinMask(~callVol);
        
        % stats and saves
        stats.allowableMasks{i} = allowableMask;
        stats.modSelections{i} = modVolWithinMask;
        stats.segmentations{i} = callVol;
        
        % save volume of overall call volume.
        stats.callVolumes(i) = sum(callVol);

        %   add to 'WMH' and non-'WMH'.
        stats.modCallVec = [stats.modCallVec; modVolWithinCall];
        stats.modNonCallVec = [stats.modNonCallVec; modVolOutsideCall];

        
        if inputs.saveSubject
            assert(strcmp(method, 'test'));
            z = zeros(stats.sizes(i, :));
            z(allowableMask) = callVol;
            saveNii(makeNiiLike(z, modNii), obj.files(s).(inputs.modSave));
        end
    end

    % display progress
    vi.close();
    pause(0.001);
        
    stats.modCallVec = double(stats.modCallVec);
    stats.modNonCallVec = double(stats.modNonCallVec);

    
end

function [inputs, subset] = checkInputs(sd, modFile, method, varargin)
    
    p = inputParser();
    p.addRequired('sd', @(x) isa(x, 'strokeDataset'));
    p.addRequired('modFile', @isstr); % 
    p.addRequired('method', @(x) strcmp(x, 'train') || strcmp(x, 'test')); 
    p.addParamValue('trueMask', '', @ischar); 
    p.addParamValue('threshold', nan, @isscalar); 
    p.addParamValue('saveSubject', false, @islogical); 
    p.addParamValue('modSave', '', @isstr); 
    p.addParamValue('globalMask', '', @isstr); 
    p.addParamValue('subjectMasks', {}, @iscellstr); 
    p.addParamValue('subjectMasksLogicals', nan, @isvector); 
    p.KeepUnmatched = true;
    p.parse(sd, modFile, method, varargin{:})
    
    
    % additional higher level checks
    % check modFile is one of the modalities in sd
    assert(ismodality(sd, modFile)) 
    
    % if the method is train 
    %   check given trueMask is one of the modalities in sd
    if strcmp(p.Results.method, 'train')
        assert(ismodality(sd, p.Results.trueMask));
        
    % if the method is test 
    %   check that you are given a threshold (default (non-given) is nan
    else
        assert(isfield(p.Results, 'threshold') && ~isnan(p.Results.threshold));
    end
        
    % if required to save the subject results
    %   check given save modality is one of the modalities in sd
    if p.Results.saveSubject
        assert(ismodality(sd, p.Results.modSave));
    end
        
    % if global mask is required, make sure it's an actual file on the file server
    if numel(p.Results.globalMask) > 0
        assert(exist(p.Results.globalMask, 'file') == 2);
    end
        
    % if subject-level masks are required, make sure they're actually modalities in sd
    if numel(p.Results.subjectMasks) > 0
        if ischar(p.Results.subjectMasks)
            p.Results.subjectMasks = {p.Results.subjectMasks};
        end
        
        for i = 1:numel(p.Results.subjectMasks)
            assert(ismodality(sd, p.Results.subjectMasks{i}), ...
                '%s is not a recognized modality', p.Results.subjectMasks{i});
        end
        
        assert(numel(p.Results.subjectMasks) == numel(p.Results.subjectMasksLogicals));
    end
    
    % setup inputs
    inputs = p.Results;
    
    % if include
    inputs.subset = sd.subjectSubset(varargin{:});
%     nSubjects = inputs.sd.getNumSubjects;
%     inputs.subjects = 1:nSubjects;
%     if ~isnan(inputs.includeSubset)
%         assert(numel(intersect(inputs.includeSubset, inputs.excludeSubset)) == 0);
%         inputs.subjects = inputs.subjects(inputs.includeSubset);
%     end
%     inputs.subjects = setdiff(inputs.subjects, inputs.exclude);
    
end
