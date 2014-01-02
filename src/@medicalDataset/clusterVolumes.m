function [clusterIdx, centroidVolumes, features] = ...
    clusterVolumes(obj, clusterFeatureType, k, varargin)
% TODO: cleanup clusterSubjects and centroids
% Example: 
%   To get wmhBW clusters, and show the centroids with wmhBW and lesionBW:
%   args = {'features', maskFeatures, 'centroidFeatureTypes', {'wmhBW', 'lesionBW'}, ...
%       'maskFile', files.brainMaskBin, 'saveFile', files.centroids};
%   [clusterIdx, centroidVolumes, features] = clusterVolumes(obj, 'wmhBW', 3, args{:});

    p = inputParser();
    p.addRequired('clusterFeatureType', @isstr);
    p.addRequired('k', @isnumeric);
    p.addParamValue('features', struct(), @isstruct);
    p.addParamValue('centroidFeatureTypes', {}, @iscellstr);
    p.addParamValue('maskFile', '', @isstr);
    p.addParamValue('saveFile', '', @(x) ischar(x) && numel(strfind(x, '%s')) == 1); 
    p.KeepUnmatched = true;
    p.parse(clusterFeatureType, k, varargin{:});
    inputs = p.Results;
    
    % read features if they are not all given
    featTypes = union(clusterFeatureType, inputs.centroidFeatureTypes);
    needFeatTypes = setdiff(featTypes, fieldnames(inputs.features));
    if numel(needFeatTypes) > 0
        [newFeatures, newCanCompute] = obj.features(needFeatTypes, varargin{:});
        
        fn = fieldnames(newCanCompute);
        for f = 1:numel(fn)
            assert(all(newCanCompute.(fn{f})));
        end
        features = catstruct(newFeatures, inputs.features);
    else
        features = inputs.features;
    end
    
    % cluster in k clusters on wmh BW and get centroids' in wmhBW and in lesionBW
    clusterIdx = kmeansMask(features.(clusterFeatureType), k); 
    if ~isempty(inputs.centroidFeatureTypes)
        % TODO - fix 
        fn = fieldnames(features);
        for f = 1:numel(fn)
            canCompute.(fn{f}) = true(1, obj.getNumSubjects);
        end
        
        centroidVolumes = centroids(clusterIdx, features, canCompute, inputs.centroidFeatureTypes, ...
            inputs.maskFile);
    else
        centroidVolumes = [];
    end

    % save clusters
    for c = 1:numel(inputs.centroidFeatureTypes)
        for i = 1:k
            ustr = sprintf('%s_clusteredOn%s_nr%d(of%d)', ...
                clusterFeatureType, inputs.centroidFeatureTypes{c}, i, k);
            fname = sprintf(inputs.saveFile, ustr);
            saveNii(centroidVolumes(c).niis(i), fname); 
        end
    end
    