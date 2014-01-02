function varargout = cleanModality(md, files, corrWMIntensity, wmLabels, varargin)
% Steps:
%   mode linear equalization in Atlas space
%   median image of equalized files, 
%   distance from median image 
%   tukey fence.
%   mode linear equalization in subject space
%
%   file needs fields:
%       .modalityInSubj
%       .modalityWMCorrInSubj
%       .labelsInSubj
%       .brainMaskInSubj
%       .modalityInAtlas
%       .modalityWMCorrInAtlas
%       .labelsInAtlas
%       .brainMaskInAtlas
%       .medianInAtlas
%       .distance
%
%   options for steps:
%       linearEqualizationInAtlas
%       medianImage
%       ssdMedianDistance / loadssdMedianDistance
%       tukey / loadTukey
%       linearEqualizationInSubj
%
%
% TODO: support subset, but for this need linear equalization to support subset
%   
% Project: Analysis of clinical datasets
% Authors: Adrian Dalca, Ramesh Sridharan
% Contact: {adalca,rameshvs}@csail.mit.edu


    % get the steps to be done.
    % note ismember wants varargin to be cellstr.
    if any(strcmp('steps', varargin))
        f = find(strcmp('steps', varargin));
        steps = varargin{f+1};
        if ischar(steps)
            steps = {steps};
        end
    else
        steps = {'linearEqualizationInAtlas', 'medianImage', 'ssdMedianDistance', 'tukey', ...
            'linearEqualizationInSubj'};
    end

    % WM linear equalization of FLAIR in reg space
    if ismember('linearEqualizationInAtlas', steps)
        md.linearEqualization(files.modalityInAtlas, files.modalityWMCorrInAtlas, ...
            files.labelsInAtlas, wmLabels, corrWMIntensity, 'overallMask', files.brainMaskInAtlas, ...
            varargin{:});
    end

    % compute median corrected flair in reg space
    if ismember('medianImage', steps)
        md.aggregateModality(files.modalityWMCorrInAtlas, @modVols2median, false, 'outNiiFile', ...
            files.medianInAtlas, varargin{:});
    end

    % compute distances to flair in atlas space
    if ismember('ssdMedianDistance', steps)
        labelArgs = {'labelFile', files.brainMaskInAtlas, 'distLabels', 1};
        meas = md.measureModality(files.modalityWMCorrInAtlas, @ssd, 'atlasFile', ...
            files.medianInAtlas, labelArgs{:}, varargin{:});
        save(files.distance, 'meas');  % '-append'
        varargout{1} = meas;
    elseif ismember('loadssdMedianDistance', steps)
        p = load(files.distance);
        meas = p.meas;
        varargout{1} = meas;
    end
    
    % compute tukey fence
    if ismember('tukey', steps)
        assert(exist('meas', 'var') == 1, 'Need to either load or compute ssdMedianDistance');
        outIdx = outliers(meas, 'tukey', true);
        save(files.distance, 'meas', 'outIdx'); 
        varargout{2} = outIdx;
    elseif ismember('loadTukey', steps)
        p = load(files.distance);
        outIdx = p.outIdx;
        varargout{2} = outIdx;
    end
    
    % do WM correction in Subject Space  
    if ismember('linearEqualizationInSubj', steps)
        md.linearEqualization(files.modalityInSubj, files.modalityWMCorrInSubj, ...
            files.labelsInSubj, wmLabels, corrWMIntensity, 'overallMask', files.brainMaskInSubj, ...
            varargin{:});
    end
    
    warning('if verbose, should do some plotting, printouts');
    