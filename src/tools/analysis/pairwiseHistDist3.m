function [dst, allHists] = pairwiseHistDist3(hists)
% vol - modality
% mask - mask modality
% nBins - number of bins
%
% dst - nFiles x nFiles of histogram distances (SSD now)
% allHists - nFiles x nBins histograms
%
% TODO: Move to be part of @medicalDataset
% TODO: Combine pairwiseHistDist, pairwiseHistDist2, pairwiseHistDist3. pairwiseHistDist3 seems like
%   a helpful function for the other 2? not sure.
%
% @ssd assumes P, Q normalized (are probabilities). 

    error('TODO: Need to clean up pairwiseHistDist, pairwiseHistDist2, pairwiseHistDist3');

    % check the right number of inputs
    narginchk(1, 1);
    nHists = numel(hists); 
    maxDomain = 0;
    for i = 1:nHists, 
        maxDomain = max(maxDomain, numel(hists{i})); 
    end
    
    % put the histograms in a large matrix
    allHists = zeros(nHists, maxDomain);
    for i = 1:nHists
        localHist = hists{i};
        allHists(i, 1:numel(localHist)) = localHist ./ norm(localHist, 1);
    end
    
    % compute pairwise distances 
    % TODO: use pdist2 ?
    dst = zeros(nHists, nHists);
    for i = 1:nHists;
        fprintf(1, 'Subject: %i\n', i);

        for j = (i+1):nHists
            dst(i, j) = ssd(allHists(i, :), allHists(j, :));
            dst(j, i) = dst(i, j);
        end
    end   
end
