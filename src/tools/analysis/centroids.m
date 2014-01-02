function cents = centroids(clusterIdx, features, canCompute, featCell, maskfile)
    
    k = numel(unique(clusterIdx(clusterIdx> 0)));
    % get mean images
    orignii = loadNii(maskfile);
    mask = orignii.img > 0;
    
    
    
        
    for c = 1:numel(featCell)

        tmpFeats = features.(featCell{c});
        idx = canCompute.(featCell{c});
        localFeats = tmpFeats(:, idx);
        whos clusterIdx idx
        localClusterIdx = clusterIdx(idx);
        
        
        fprintf(1, 'Feature: %s\n', featCell{c});
        for i = 1:k;
            fprintf(1, '\tCluster: %i count: %i\n', i, sum(localClusterIdx == i));
            cents(c).niis(i) = orignii; 
            cents(c).niis(i).img(mask) = mean(localFeats(:, localClusterIdx == i), 2);
        end
    end
    
    
    
    
