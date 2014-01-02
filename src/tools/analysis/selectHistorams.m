function [defaultHist, topHists, sortedIdx] = selectHistorams(histDistances, allHists, selRate, verbose)
% SELECTHISTOGRAMS get an average histogram from top X consistent histograms
%   [defaultHist, hists] = selectHistorams(histDistances, allHists, selRate, verbose)
%       from a pairwise distance matrix histDistances for histograms, select the top selRate (0..1)
%        histograms with the smallest distances to others, and return an average of those
%        histograms.
%
% Contact: Stroke project, http://www.mit.edu/~adalca/stroke/    



    % check inputs
    narginchk(2, 4);
    if ~exist('selRate', 'var')
        selRate = 0.3;
    end
    if ~exist('selRate', 'var')
        selRate = 0.3;
    end

    % get the median distance of each histogram to the others
    medDst = median(histDistances);
    
    % sort the medians
    [~, sortedMedDstIdx] = sort(medDst, 'ascend');
    
    % select the top X% histograms
    selIdx = sortedMedDstIdx(1:ceil(selRate*size(histDistances, 1)));

    % plot
    if verbose
        dstMin = min(histDistances(:)); 
        dstMax = max(histDistances(:));
        
        figure(); clf
        subplot(1, 3, 1); 
        imagesc(histDistances);
        caxis([dstMin, dstMax]);
        colorbar;
        axis image;
        
        subplot(1, 3, 2);
        imagesc(histDistances(sortedMedDstIdx, sortedMedDstIdx));
        caxis([dstMin, dstMax]);
        colorbar;
        axis image;
        
        subplot(1, 3, 3);
        imagesc(histDistances(selIdx, selIdx));
        caxis([dstMin, dstMax]);
        colorbar;
        axis image;
    end
    
    % get the histogram averaged over the selected histograms
    topHists = allHists(selIdx, :);
    defaultHist = mean(topHists); 
    sortedIdx = sortedMedDstIdx;
end
