function [dst, allHists] = pairwiseHistDist2(obj, vol, binSpacing, mask)
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
    narginchk(2,4);
    files = obj.files;
    nFiles = numel(files); 
    if ~exist('binSpacing', 'var'), binSpacing = 1/1000; end
    if ~exist('mask', 'var'), mask = []; end
    
    % learn a global histogram to get an idea of the range of all of the images
    hists = cell(nFiles, 1);
    maxDomain = [];
    for i = 1:nFiles;
        fprintf(1, 'Subject: %i\n', i);

        voxels = nii2vox(obj.getModality(vol, i), obj.getModality(mask, i));
        voxels = voxels ./ prctile(voxels, 99);
        
        histBins = 0:binSpacing:max(voxels);
        
        maxDomain = ifelse(numel(histBins) > numel(maxDomain), histBins, maxDomain);
        hists{i} = hist(voxels, histBins);
        hists{i} = hists{i} ./ norm(hists{i}, 1);
        
%         figure(1); bar(histBins, hists{i}); axis([min(maxDomain), max(maxDomain), 0, 0.005]);
%         pause();
    end
    
    % put the histograms in a large matrix
    allHists = zeros(nFiles, numel(maxDomain));
    for i = 1:nFiles
        localHist = hists{i};
        allHists(i, 1:numel(localHist)) = localHist ./ norm(localHist, 1);
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
