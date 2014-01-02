function [dst, allHists] = pairwiseHistDist(obj, vol, nBins, mask)
% vol - modality
% mask - mask modality
% nBins - number of bins
%
% dst - nFiles x nFiles of histogram distances (SSD now)
% allHists - nFiles x nBins histograms
%
% TODO: Move to be part of @medicalDataset
% TODO: Combine pairwiseHistDist, pairwiseHistDist2, pairwiseHistDist3
%
% @ssd assumes P, Q normalized (are probabilities).    

    error('TODO: Need to clean up pairwiseHistDist, pairwiseHistDist2, pairwiseHistDist3');

    % check the right number of inputs
    narginchk(3,4);
    files = obj.files;
    nFiles = numel(files); 
    if ~exist('mask', 'var'), mask = []; end
    
    % learn a global histogram to get an idea of the range of all of the images
    globalHist = zeros(1, 1000);
    for i = 1:nFiles;
        fprintf(1, 'Subject: %i\n', i);

        voxels = nii2vox(obj.getModality(vol, i), obj.getModality(mask, i));
        maxVox = max(voxels);
        
        if numel(globalHist) < maxVox + 1
            globalHist(maxVox+1) = 0; % enlarge the global hist if necessary
        end
        localHist = hist(voxels, 0:maxVox);
        globalHist(1:(maxVox+1)) = globalHist(1:(maxVox+1)) + localHist;

    end

    % find the starting index of the last 0.1%. Do this to avoid having an
    % artifically long tail
    endCumHist = cumsum(flipud(globalHist(:)));
    backBinIdx = find(endCumHist >= 0.001, 1, 'first');
    binIdx = length(globalHist) - backBinIdx + 1;
    fprintf(1, 'using last bin idx of %i instead of %i\n', ...
        binIdx, length(globalHist));
    
    % get 'optimal' bin centers'
    binCenters = linspace(0, binIdx, nBins);
        
    % prepare subjects
    allHists = zeros(nFiles, nBins);
    
    % get histograms for all of the subjects given the 'optimal' binCenters
    for i = 1:nFiles;
        fprintf(1, 'Main loop. Subject: %i\n', i);

        voxels = nii2vox(obj.getModality(vol, i), obj.getModality(mask, i));
        allHists(i, :) = hist(voxels, binCenters);
        allHists(i, :) = allHists(i, :) ./ norm(allHists(i, :));
    end
    
    % compute pairwise distances 
    % TODO: use pdist2 (?)
    dst = zeros(nFiles, nFiles);
    for i = 1:nFiles;
        fprintf(1, 'Subject: %i\n', i);

        for j = (i+1):nFiles
            dst(i, j) = ssd(allHists(i, :), allHists(j, :));
            dst(j, i) = dst(i, j);
        end
    end    
end
