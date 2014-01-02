function varargout = mapEstimation(posteriors)
% posteriors - nPoints x nMixtures
% also returns best place where second distro gets better than the first (threshold)
    
    [~, mi] = max(posteriors, [], 2);  
    varargout{1} = mi;
    
    % thr computations
    warning('assumiung specific direction in mapEstimation');
    
    % assuming there is a single major switch of maximums, other than noise. 
    % to figure this out, get all places where mi changes, and for each threhold, comptue the
    % percentage of consistency, take the max..
    
    assert(size(posteriors, 2) == 2)
    
    thresholds = find(mi(2:end) ~= mi(1:end-1));
    
    bestThr = inf;
    bestScore = -inf;
    for t = 1:numel(thresholds)
        thr = thresholds(t);
        c1 = mi(1:thr);
        c2 = mi((thr+1):end);
        
        % compute fractions TODO: fix this hardcoded directionality of 2 and 1
        frac1 = sum(c1 == 2) ./ numel(c1);
        frac2 = sum(c2 == 1) ./ numel(c2);
        
        if (frac1 + frac2) > bestScore
            bestThr = thr;
            bestScore = frac1 + frac2;
        end
    end
        
        
    varargout{2} = bestThr;
   
    
    
    
    
%     if size(posteriors, 2);
%         if mi(1) == 1
%             threshold = find(mi == 2, 1, 'first');
%         else
%             threshold = find(mi == 1, 1, 'first');
%         end
%         varargout{2} = threshold;
%     end
    