function dwi2mask(md, defaultHistFile)
% extract loose brain mask from dwi images
%   DWI2MASK(md) extracts loose brain mask from dwi images. md is a medicalDataset 
%   structure as returned by medicalDataset(), with (at least) fields
%   dwiVolFile, sid and dwiMaskOutFile. The first DWI file is used as a
%   default histogram to which all DWI files will be histogram matched.
%
%   DWI2MASK(md, defaultHistFile) alllows specifying a histogram
%   nifti filename. If this is not provided, the first DWI file is used.
%
%   Algorithm:
%       - learn a 2-component k-means from the main histogram
%       - for every dwi file in files:
%           - do histogram equalization with the main histogram
%           - use the learned threshold to label voxels as potential brain
%           - blur resulting mask
%           - use the highest connected component as the 'brain'
%           - fill in any holes in the brain
%           - save mask
%
%   TODO: put in new framework, allowing for subsets, and obption blur parameters. 
%
%   Author: Adrian Dalca, adalca.mit.edu



    % some blurring parameters
    % note: for blurPixDims, more 'correct' would be to use the 
    %   hdr.dime.pixdim(2:4), but we are using the bluring as a heuristic
    %   for transforming semi-holes into holes, so we can use [1, 1, 1];
    blurPixDims = [1, 1, 1];    % in mm
    blurKernelSize = 5;         % in mm
    blurWindowSize = [5, 5, 5];
    
    % files
    nSubjects = md.getNumSubjects;
    
    % histogram input check
    if nargin == 1
        defaultHistFile = md.files(1).dwiVolFile;
    end
    
    % get main histogram
    nii = loadNii(defaultHistFile);
    img = double(nii.img(:));
    lsp = linspace(0, 1, 100);
    voxels = img(:) ./ max(img(:));
    hst = hist(voxels, lsp);
    
    % find threshold
    thr =  getThr(img(:), lsp);
    fprintf(1, 'Using threshold %f', thr);
    
    % go through each dwi, do hist eq, and then threhold
    for i = 1:nSubjects
        fprintf(1, 'Subject: %i. %s. ', i, md.files(i).sid);
        
        % get voxel values from DWI
        dwiNii = loadNii(md.files(i).dwiVolFile);
        imSize = size(dwiNii.img);
        voxels = double(dwiNii.img(:));
        voxelsn = voxels ./ max(voxels(:));
        newvals = histeq(voxelsn(:), hst(:));
        
        % to verify histogram distance, measure difference
        % NB - sometimes the peak at 0 gets shifted, and i'm not sure why,
        % but this causes a larger distance
        oldhst = hist(voxelsn(:), linspace(0, 1, 100));
        newhst = hist(newvals(:), linspace(0, 1, 100));
        fprintf(1, 'Newdist: %3f, Oldist: %3f ', ...
            norm(hst/sum(hst) - newhst/sum(newhst)), ...
            norm(hst/sum(hst) - newhst/sum(oldhst)));
        
        % get highest connected component (hopefully the brain)
        stats = regionprops(reshape(newvals >= thr, imSize), ...
            'Area', 'PixelIdxList');
        [aSort, aIdx] = sort([stats.Area], 'descend');
        if ~(aSort(1) > 10 * aSort(2))
            warning('DWI:MASK', 'Top CC not 10x second: %i %i', ...
                aSort(1), aSort(2));
        end
        
        % label only the highest connected comonent (brain)
        newImg = zeros(imSize);
        newImg(stats(aIdx(1)).PixelIdxList) = 1;
        
        % fill in the rest of the (hopefully) brain
        blurImg = ...
            imBlurSep(newImg, blurWindowSize, blurKernelSize, blurPixDims);
        blurImgBin = blurImg > 0;
        finalImg = imfill(blurImgBin, 'holes');
        fprintf('Total Size: %i\n', sum(finalImg(:)));
            
        
        
        dwiNii.img = finalImg;
        saveNii(dwiNii, md.files(i).dwiMaskOutFile); 
    end
    
end



function thr =  getThr(img, lsp)
    % k-means mixture
    idx = litekmeans(img(:)', 2);
    assert(numel(idx) == numel(img), 'idx count %i, voxel count %i');
    
    % normalize
    vals = img(:) ./ max(img(:));
    
    % get the small and big cluster
    [~, m] = sort([mean(vals(idx == 1)), mean(vals(idx == 2))], 'ascend');
    lowLab = m(1);
    highLab = m(2);
    hst1 = hist(vals(idx == lowLab), lsp);
    hst2 = hist(vals(idx == highLab), lsp);
    figure(1); plot(hst1, 'r'); hold on; plot(hst2, 'b');
    
    % get threshold
    thrIdxLow = find(hst1, 1, 'last');
    thrIdxHigh = find(hst2, 1, 'first');
    thr = (lsp(thrIdxHigh) + lsp(thrIdxLow))/2;
end
