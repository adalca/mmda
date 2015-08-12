function allFramesMat = modality2images(obj, modality, outPath, varargin)
% MODALITY2IMAGES write frames from a given modality in the dataset to jpg
%   allFramesMat = modality2jpg(obj, modality, outPath) write frames from the given modality to the
%   outPath from the current medical dataset. outPath is a full path and filename, such as
%       outPath = 'path/to/jpgdump/file_%s_%i.jpg'
%   %s and %i are required, in that order. %s indicates where the frame nr will be dumped, %i where
%   the subject id will be dumped. 
%
%   allFramesMat = modality2images(obj, modality, outPath, param1, value1) 
%
%   Optional Param/Value pairs 
%       slices - the slices to be dumped. Cannot supply padMidSlices.
%       padMidSlices - the number of slices to pad the middle of the modality. Cannot supply slices.
%       resample - a ratio to resample the frames (e.g. 2 is doubleing the size image)
%       subset - the subset, (specific order maintained) of files to use. 
%           if this is not supplied, can also supply param/value pairs taken by obj.subjectSubset()
%           if none of these are supplies, 1:N is defaulted.
%       maskVol - subject-specific mask modality to draw
%       maskFile - overall mask to draw (if in common space)
%       maskStyle - 'fill' or 'contour' for how to draw the mask
%       outputNameing - 'sequence' or 'index'. 
%           for both slices and subjectNrs, do 
%               1,2,3,... (seq) or 
%               89,90,91 (if that's the subset/slices) - index
%
%   See Also: nii2images
%
%   Author: Adrian Dalca


    % parse input
    p = inputParser();
    p.addRequired('modality', @ischar);
    p.addRequired('fnameRoot', @checkOutName); 
    
    p.addParamValue('slices', 0, @isnumeric);
    p.addParamValue('padMidSlices', -1, @(x) isnumeric(x) && numel(x) == 1);
    p.addParamValue('resample', 1, @isnumeric);
    p.addParamValue('subset', [], @isnumeric); % for specific subset or subset.
    p.addParamValue('maskVol', '', @ischar); %subject-specific mask
    p.addParamValue('maskFile', '', @(x) exist(x, 'file') == 2);    % overall mask (if in common space)
    isFillOrContour = @(x) strcmp(x, 'fill') || strcmp(x, 'contour');
    p.addParamValue('maskStyle', 'fill', isFillOrContour); % how to draw mask
    isIndexOrSequence = @(x) strcmp(x, 'index') || strcmp(x, 'sequence'); 
    p.addParamValue('outputNameing', 'index', isIndexOrSequence);
    p.KeepUnmatches = true;
    
    p.parse(modality, outPath, varargin{:});
    
    % get which slices to write
    assert(~(any(p.Results.slices > 0) && p.Results.padMidSlices > -1), ...
        'Please only supply one of slices or padMidSlices');
    
    % get subset
    subset = p.Results.subset;
    if numel(subset) == 0
        subset = obj.subjectSubset(varargin{:});
    end
    nSubjects = numel(subset);
    
    % display progress
    if obj.verbose
        h = waitbar(0, 'Starting jpg write');
    end
    
    % go through
    allFrames = cell(nSubjects, 1);
    for idx = 1:nSubjects

        % get the subject number
        subjNr = p.Results.subset(idx);
        
        % prepare nii2images extra params.
        args = cell(0); %#ok<*AGROW>
        
        % mask
        if numel(p.Results.maskFile) > 0    % globalMask
            assert(numel(p.Results.maskVol) == 0, ...
                'Please don''t supply both global and subject-specific masks');
            args = [args, {'maskFile', p.Results.maskFile}]; 
        elseif numel(p.Results.maskVol) > 0
            assert(numel(p.Results.maskFile) == 0, ...
                'Please don''t supply both global and subject-specific masks');
            args = [args, {'maskFile', obj.files(subjNr).(p.Results.maskVol)}];
        end
        
        args = [args, {'maskStyle', p.Results.maskStyle}];
        args = [args, {'slices', p.Results.slices}];
        args = [args, {'padMidSlices', p.Results.padMidSlices}];
        args = [args, {'resample', p.Results.resample}];
        args = [args, {'outputNameing', p.Results.outputNameing}];
        
        % get and save midFrame
        if strcmp(p.Results.outputNameing, 'sequence')
            fname = sprintf(outPath, '%i', idx); 
        else
            fname = sprintf(outPath, '%i', subjNr); 
        end
            
        % write to jpg
        allFrames{idx} = nii2images(obj.files(subjNr).(modality), fname, args{:});

        % display progress
        if obj.verbose
            perc = idx/nSubjects;
            waitbar(perc, h, sprintf('dataset2images: %1.3f done', perc));
        end
    end
    
    % specify 4d size. Note: allFrames{1} is not alwasy 3D
    sz = [size(allFrames{1}, 1), size(allFrames{1}, 2), ...
        size(allFrames{1}, 3), numel(p.Results.subset)];
    allFramesMat = zeros(sz);
    for idx = 1:numel(p.Results.subset)
        allFramesMat(:,:,:,idx) = allFrames{idx};
    end
    
    % close progress bar
    if obj.verbose
        close(h);
    end
     
end


function t = checkOutName(outName)
    
    t = ischar(outName) && numel(strfind(outName, '%s')) == 1 && ...
        (numel(strfind(outName, '%i')) == 1 || ...
        numel(strfind(outName, '%d')) == 1);
end
