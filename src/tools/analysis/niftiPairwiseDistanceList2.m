function [dst, voxmat] = niftiPairwiseDistanceList2(matFile, fixedIndex, labelFile, outfile)
% vol - modality
%
% TODO - explain the complicated stucture rather than simple double loop

    % hardcoded distance
    labelDist = @labelSSD;
    
    if ischar(fixedIndex)
        fixedIndex = str2double(fixedIndex);
    end
    load(matFile, 'voxmat16');
    if exist('voxmat16', 'var')
        voxmat = double(voxmat16);
    end
    
    % check the right number of inputs
    narginchk(3,4);
    
    % load necessary label files 
    load(labelFile, 'imlabels');
    nLabels = numel(imlabels);
    nSubjects = size(voxmat, 1);
   
    dst = zeros(nSubjects, nLabels);
    for i = 1:nSubjects;
        tic;
        lDst = labelDist(voxmat(fixedIndex, :), voxmat(i, :), imlabels);
        dst(i, :) = reshape(lDst, [1, nLabels]);
        fprintf(1, 'done %i in %f sec\n', i, toc);
    end

    if exist('outfile', 'var') 
        save(outfile, 'dst');
    end
end

function d = labelSSD(im1, im2, imLabels)
    nLabels = numel(imLabels);
    d = zeros(nLabels, 1);
    
    diffImg = (im1 - im2) .^2;
    
    for i = 1:nLabels
        d(i) = mean(diffImg(imLabels{i}));
    end
end


function d = labelMI(im1, im2, imLabels)
    nLabels = numel(imLabels);
    d = zeros(nLabels, 1);
    
    
    for i = 1:nLabels
        vec1 = im1(imLabels{i});
        vec2 = im2(imLabels{i});
        d(i) = mutualinfo(vec1,vec2);
    end
end

