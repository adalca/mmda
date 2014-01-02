function meas = pairwiseMeasure(obj, modality, distMethod, nLoad, varargin)
% MEASURE compute pairwise measures for medicalDataset subjects
%
% hardcoded number of items to load.
%     nLoad = 735;
% TODO - explain the complicated stucture rather than simple double loop


    
    % check the right number of inputs
    % check inputs
    [modality, distMethod, inputs, nLoad, useLabels, subset] = ...
        checkInputs(modality, distMethod, nLoad, varargin);
    nSubjects = numel(subset);
    
    % get the label images
    if useLabels && numel(inputs.distLabels) == 0
        labelMasks = nii2labelMasks(labelFile);
    elseif useLabels
        labelMasks = nii2labelMasks(labelFile, distLabels);
    end
    
    % some memoization
    preNiis = cell(1, nLoad);
    
    % prepare distance matrix
    meas = zeros(nSubjects, nSubjects, nLabels);
    
    % should be a really smart way to do this, but...
    for i = 1:nLoad:nSubjects;
        nMax = min(nSubjects, i+nLoad-1);
        fprintf(1, 'Main loop. Subject: %i. nMax:%i\n', i, nMax);
        
        % get all the volumes in i:i+(nLoad-1)
        for j = i:nMax
            fprintf(1, '\tpreLoading: %i\n', j);
            preNiis{j-i+1} = loadNii(obj.getModality(modality, j));
        end
        
        % do the distance for those loaded files
        for row = i:nMax
            rowVox = double(preNiis{row}.img(:));
            fprintf(1, '\tpreComp: %i\n', row);
            
            for col = (row + 1):nMax
                colVox = double(preNiis{col}.img(:));
                
                % compute distance
                if useLabels
                    lDst = labelwiseMeasure({rowVox, colVox}, labelMasks, distMethod);
                else
                    lDst = distMethod(rowVox, colVox);
                end
                meas(row, col, :) = reshape(lDst, [1, 1, nLabels]);
            end
        end
        
        
        for col = (i+nLoad):nSubjects
            fprintf(1, '\tpreComp: %i\n', col);
            
            % load the nii. 
            nii = loadNii(obj.getModality(modality, k));
            colVox = double(nii.img(:));
            
            % go through the rest
            for row = i:nMax;
                rowVox = double(preNiis{row}.img(:));
                
                % compute distance
                if useLabels
                    lDst = labelwiseMeasure({rowVox, colVox}, labelMasks, distMethod);
                else
                    lDst = distMethod(rowVox, colVox);
                end
                meas(row, col, :) = reshape(lDst, [1, 1, nLabels]);
            end
        end
    end
end

function [modality, distMethods, nLoad, inputs, useLabels, subset] = ...
    checkInputs(modality, distMethods, nLoad, varargin)

    % parse inputs
    narginchk(3, inf);
    p = inputParser();
    p.addRequired('modality', '', @isstr);
    p.addRequired('distMethods', @error, @(x) isa(x, 'function_handle'));
    p.addRequired('nLoad', 100, @isnumeric);
    p.addParamValue('labelFile', '', @isstr);
    p.addparamValue('distLabels', [], @isnumeric);
    p.KeepUnmatched = true;
    p.parse(modality, distMethods, atlasFile, varargin{:});
    inputs = p.Results;
    
    % check inputs, and set defaults
    useLabels = exist(p.Results.labelFile, 'file') == 2;
    
    % get the desired subjects
    subset = obj.subjectSubset(varargin{:});
end
