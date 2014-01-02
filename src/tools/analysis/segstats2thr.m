function thr = segstats2thr(stats, method, verbose, varargin)
% methods: ML, MAP, percentile
% TODO: think about best use of mapEstiamtion () and segstats2Hist

    [limits, h1, h2] = segstatsHist(stats, 3, verbose);
    
    switch method
        % MAP
        case 'MAP'
            [~, thrIdx] = mapEstimation([h1(:), h2(:)]);
            thr = limits(thrIdx);
    
        % ML estimateion
        case 'ML'
            [~, thrIdx] = mapEstimation([h1(:)/sum(h1), h2(:)/sum(h2)]);
            thr = limits(thrIdx);
            
        % percentile
        case 'percentile'
            thr = prctile(stats.modCallVec, varargin{1});
            
        % find first threhold index to be past some given threhold
        % TODO - fix choice of threshold 
        % this is having no more than 10 % error. This is equivalent to prctile(stats.modCallVec, 10);
        % thrIdx = find(fliplr(cumsum(fliplr(h1)))/sum(h1) < train.prctile/100, 1, 'first');
        % thr = limits(thrIdx);
    end
end
