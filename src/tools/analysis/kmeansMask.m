function varargout = kmeansMask(features, k, maskfile) 
% KMEANSMASK cluster subjects on given features using k-means.
%   idx = kmeansMask(features, k) k-means clustering of subjects based on
%       given features matrix (nSubjects x nFeatures) and given k.
%   [idx, niis] = kmeansMask(features, k, maskfile) if given the maskfile
%       used in the feature collection, mean cluster niftis are also computed
%       (niis). 
%
%   TODO: centroids instead of means.
%
%   Contact: Stroke project, http://www.mit.edu/~adalca/stroke/ 
    


    % use k-means to compute clusters of sunjects.. 
    %     idx = kmeans(features', k);
    idx = litekmeans(features, k);
    varargout{1} = idx;
    
    % is maskfile is given, compute centroid based on it. 
    if nargin == 3
        
        % get mean images
        orignii = loadNii(maskfile);
        mask = orignii.img > 0;
        niis(k) = orignii;
        niis(k).img = niis(k).img * 0;
        for i = 1:k;
            niis(i) = orignii; 
            niis(i).img(mask) = mean(features(:, idx == i), 2);
        end
        varargout{2} = niis;
    end
end
