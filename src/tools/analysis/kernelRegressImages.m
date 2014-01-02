function [figureH, regressedImages, plotImages] = kernelRegressImages(X, xLabel, allImages, yLabel, ...
    imSize, nRegressX, kernelH, plotSpec, figureH, atlasImg)
%
%   X - Nx1
%   allImages - Nxprod(imSize) - B&W images of islands of something...
%   
%

    % get new figure if not provided
    if ~exist('figureH', 'var')
        figureH = figure(); clf;
    end
    
    if numel(nRegressX) == 1
        newX = linspace(min(X), max(X), nRegressX);
    else
        newX = nRegressX;
        nRegressX = numel(newX);
    end

    atlasNii = loadNii(atlasImg);
    atlas = atlasNii.img;
    
    
    % keep only useful features
    nonEmptyVoxels = max(allImages, [], 1) > 0;
    allImagesSel = allImages(:, nonEmptyVoxels);

    % kernell regression for nRegressX X groups
    regressedImagesSel = kernelRegress(X, allImagesSel, newX, kernelH);
    
    % compute images for each X group average
    allRegressedImages = zeros(nRegressX, prod(imSize));
    allRegressedImages(:, nonEmptyVoxels) = regressedImagesSel;
    regressedImages = cell(nRegressX, 1);
    for i = 1:nRegressX
        regressedImages{i} = reshape(allRegressedImages(i, :), imSize);
    end

    % plot average volume in Images. both means are over selection domain
    initImgMean = mean(allImages, 2);
    coords = [newX(:), mean(allRegressedImages, 2)];

    plotImages = cell(size(coords, 1), 1);
    midFrame = round(imSize(3)/2)+7;
    atlasFrame = atlas(:, :, midFrame)';
    atlasFrame = repmat(atlasFrame, [1, 1, 3]);
    for i = 1:nRegressX
        plotImages{i} = uint8(255 * regressedImages{i}(:,:,midFrame))';
        
        plotImages{i} = repmat(plotImages{i}, [1, 1, 3]);
        plotImages{i}(:,:,3) = 0;
        
        plotImages{i} = atlasFrame * 0.25 + plotImages{i} * 1;
    end

    % do regressions and plotting of images
    figureH = plotRegressors(X, xLabel, initImgMean(:), yLabel, plotSpec, figureH, ....
        'kernel-gauss', 3, 'k-', ...
        'im', plotImages, coords);
    
    