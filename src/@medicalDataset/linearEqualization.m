function linearEqualization(obj, inmodality, outmodality, labelFile, matchLabels, ...
    desiredLabelValue, varargin)
% md - the medicalDataset object
% inmodality - the volume input name (e.g. 'flairReg')
% outmodality - the volume output name (e.g. 'flairRegWMCorr')
% labelFile - the nifti label file (either global, if ~inSubjectSpace, or 
%   name in sd volumes if inSubjectSpace) which will help us identify the label to match
% matchLabels - the label of the volume intensities to be matched (vector)
% desiredLabelValue - the desired intensity value inside the chosen labels
%
% ParamValue
%   overallMask - the mask within which to actually perform the linear Normalization 
%   TODO - should figure this out from overallMask and subjectLabels
%
%   e.g. the matchLabels could represent the white matter, while the overallMask can be the whole
%   brain
%
% varargin - for subjectSubset()
%
% TODO: cleanup!!!
%
% Author: Adrian V. Dalca, Ramesh Sridharan

    [inmodality, outmodality, labelFile, matchLabels, desiredLabelValue, ...
        subset, inSubjectSpace, inputs] = parseInputs(obj, inmodality, outmodality, ...
        labelFile, matchLabels, desiredLabelValue, varargin{:});
    if isempty(inputs.overallMask)
        overallMaskArg = {inputs.overallMask};
    else
        overallMaskArg = {};
    end

    % load necessary label files 
    if ~inSubjectSpace
        [selMask, desiredMask] = getMasks(labelFile, matchLabels, overallMaskArg{:});
    end
    
    % go through subjects
    vi = verboseIter(subset, obj.verbose);
    while vi.hasNext()
        i = vi.next();
        
        % if everything is done in subject space
        if inSubjectSpace
            [selMask, desiredMask] = getMasks(obj.files(i).(labelFile), matchLabels, overallMaskArg{:});
        end
        
        % compute wm matching
        [niiOut, niiSubj, subjInt] = matchWM(obj.files(i).(inmodality), selMask, desiredLabelValue);
        assert(subjInt ~= 0);
        voxPrev = niiSubj.img(selMask);
        niiSubj.img(desiredMask) = niiOut.img(desiredMask);
        voxPost = niiSubj.img(selMask);
        
        % save linearly normalized value
        obj.saveModality(niiSubj, outmodality, i);
        
        % plotting - this should be temporary
        if inputs.verbose
            fname = fullfile(inputs.savePath, sprintf('hist_%d_%d.png', inSubjectSpace, i));
            plotLinearEq(voxPrev, voxPost, subjInt, desiredLabelValue, fname);
        end
        
    end
    
    % display progress
    vi.close();

end

function [selMask, desiredMask] = getMasks(labelFile, matchLabels, overallMask)

    labelMasks = nii2labelMasks(labelFile, matchLabels);
    selMask = any(cat(4, labelMasks{:}), 4);

    % get the overall mask to apply matched result to
    if nargin == 3
        nii = loadNii(overallMask);
        desiredMask = nii.img > 0;
    else
        desiredMask = true(size(selMask));
    end
end

function [inmodality, outmodality, labelFile, matchLabels, desiredLabelValue, ...
    subset, inSubjectSpace, inputs] = parseInputs(obj, inmodality, outmodality, ...
    labelFile, matchLabels, desiredLabelValue, varargin)

    % check the right number of inputs
    narginchk(6, inf);

    p = inputParser();
    p.addRequired('obj', @(x) isa(x, 'medicalDataset'));
    p.addRequired('inmodality', @ischar);
    p.addRequired('outmodality', @ischar);
    p.addRequired('labelFile', @ischar);
    p.addRequired('matchLabels', @isvector);
    p.addRequired('desiredLabelValue', @isscalar);
    p.addParamValue('overallMask', '', @ischar);
    p.addParamValue('verbose', false, @islogical);
    p.addParamValue('savePath', tempdir, @ischar);
    p.KeepUnmatched = true;
    p.parse(obj, inmodality, outmodality, labelFile, matchLabels, desiredLabelValue, varargin{:});
    inputs = p.Results;
    
    subset = obj.subjectSubset(varargin{:});
    
    inSubjectSpace = obj.ismodality(labelFile) && obj.ismodality(inputs.overallMask);
    
end

function plotLinearEq(voxPrev, voxPost, subjInt, desiredLabelValue, name)
    h = figure(1); clf;
    subplot(121);
    plotMeanShift(voxPrev, subjInt)
    subplot(122);
    plotMeanShift(voxPost, desiredLabelValue)
    saveas(h, name);
    pause(0.001);
end

function plotMeanShift(vox, subjInt)

    vox = double(vox);
    vox = vox - min(vox(:));
    bins = linspace(1, 2 * subjInt, 1000);
    hs = hist(vox, bins); 
    plot(bins, hs); hold on;
    plot(ones(1, 100) * subjInt, linspace(0, max(hs) + 1, 100), 'r.');
end





