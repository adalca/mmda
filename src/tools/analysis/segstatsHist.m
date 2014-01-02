function [limits, h1, h2] = segstatsHist(stats, k, verbose)
% requires stats to have: modCallVec and modNonCallVec, callVolumes, modSelections, segmentations
%
% TODO - is first method the same as k = 1 ?

    % Method 1. Simply plot overall (is this equivalent to k = 1?)
    if verbose, figure(); end
    [limits, h1, h2] = histSeg(stats.modCallVec, stats.modNonCallVec, [1 0 0 0 0 1], verbose);

    % Methods 2. Do some volume clustering and select each.
%     if nargin >= 2
%         meanVolume = mean(stats.callVolumes);
%         stdVolume = std(stats.callVolumes);
%         initMat = linspace(meanVolume - stdVolume, meanVolume + stdVolume, k);
%         
%         warning('using fixed percentiles instead of kmeans');
%         [idx, ~] = kmeans(stats.callVolumes, k, 'start', initMat');
%         
% 
%         % TODO plot lines @ means
%         
%         cols = [autumn(k), winter(k)];
%         for i = 1:k
%             figure(); hold on;
%             [modCallVec, modNonCallVec] = ...
%                 vols2vox(stats.modSelections(idx == i), stats.segmentations(idx == i));
%             histSeg(modCallVec, modNonCallVec, cols(k, :), verbose);
%             fprintf('Number of subjects in cluser %d: %d/%d\n', k, sum(idx == i), numel(idx));
%         end 
%     end
end


function [pos, neg] = vols2vox(vols, masks)
% given cell array of original volumes and call masks, gather all of the 'call' voxels and
% 'non-call' voxels.
    
    pos = [];
    neg = [];
    for i = 1:numel(vols)
        modVolWithinMask = vols{i};
        pos = [pos; modVolWithinMask(masks{i})]; %#ok<*AGROW>
        neg = [neg; modVolWithinMask(~masks{i})];
    end

end

function [limits, h1, h2] = histSeg(modCallVec, modNonCallVec, col, verbose)

    % plot overall histogram
    minLim = min([modCallVec; modNonCallVec]);
    maxLim = max([modCallVec; modNonCallVec]);
    
    % build the histograms.
    warning('segstatsHist:histSeg: the number of bins is fixed for now to 250');
    limits = linspace(minLim, maxLim, 250);
    h1 = hist(double(modCallVec), limits);
    h2 = hist(double(modNonCallVec), limits);
    
    % plot 
    if verbose
        subplot(1, 2, 1); hold on; 
        title('MLish');
        plot(limits, h1./sum(h1), '.', 'Color', col(1:3));
        plot(limits, smooth(h1./sum(h1)), '-', 'Color', col(1:3));
        plot(limits, h2./sum(h2), '.', 'Color', col(4:6));
        plot(limits, smooth(h2./sum(h2)), '-', 'Color', col(4:6));

        subplot(1, 2, 2); hold on; 
        title('MAPish');
        plot(limits, h1, '.r'); 
        plot(limits, smooth(h1), '-r'); 
        plot(limits, h2, '.b');
        plot(limits, smooth(h2), '-b'); 
    end
end
    
