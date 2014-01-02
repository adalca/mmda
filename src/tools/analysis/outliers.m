function varargout = outliers(dst, method, verbose, nStdDstCutoff)
% OUTLIERS returns outliers in dst 
%   outliersIdx = outliers(dst, 'tukey', verbose) returns indexes of
%   outliers in dst according to the tukey fence. dst should be a N x 1
%   vector of some measure/distance (higher is worse) and only *high* 
%   distances are considered outliers. if verbose, a plot will be given.
%
%   [outliersIdx, nStdDst, srt] = selectOutliers(dst, 'nrStdevs', verbose, nStdDstCutoff)
%   select outliers using a threshold of the number of standard deviations.
%
%   Authors: Adrian V Dalca, Ramesh Sridharan
%   Written for Stroke processing project.


nSubjects = numel(dst);

if strcmp(method, 'nrStdevs')
    % sort the distance
    [~, srt] = sort(dst, 'descend');

    % compute stdev
    stdDst = std(dst);

    % get distance (either absolute distance or distance from mean/median
    x = abs(dst); % x = abs(dst - median(dst));

    % get distance in terms of # of stdevs
    nStdDst = x ./ stdDst;

    % outliers. 
    outliersIdx = srt(nStdDst(srt) > nStdDstCutoff);
    
    % output
    varargout = {outliersIdx, nStdDst, srt};
else
    assert(strcmp(method, 'tukey'));
    
    % tukey fence
    t = prctile(dst, 75) + iqr(dst);
    outliersIdx = find(dst >= t);
    
    varargout = {outliersIdx};
end


% show figure if verbose
if verbose
    outliersLog = false(1, nSubjects);
    outliersLog(outliersIdx) = true;
    
    figure1 = figure();  
    axes('Parent',figure1,'FontSize',16);
    plot(1:sum(outliersLog), sort(dst(outliersLog), 'descend'), '.r');  hold on;  
    plot((sum(outliersLog)+1):nSubjects, sort(dst(~outliersLog), 'descend'), '.b');
    xlabel('Sorted subjects', 'FontSize', 14)
    ylabel('SSD Distance', 'FontSize', 14)
    legend('Outliers', 'Good registrations');
    axis([1, nSubjects, 0, max(dst)]);    
end
