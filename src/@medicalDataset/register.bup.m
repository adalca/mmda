function varargout = register(sd, modalityInName, modalityOutName, regtype, configname, fixedin, varargin)
% REGISTER register volumes to a tempplate with matlab's registration functions
%
% TODO; for now, using bounding boxes!!!
% TODO - separate the registration from the feature computation
%
% note if given sources, will use tform but re-compute anything that it's asked for.
%
% sd.register('flair', 'rigid', 'monomodal', templateNiiFile);
%
% TODO this does much more than it should. some of it is quite specific to SR, like library
% construction;
    
    % fixed
    
    if sys.isfile(fixedin)
        fixed = loadNii(fixedin);
    else
        assert(isstruct(fixedin));
        fixed = fixedin;
    end

    % build optimizer
    [optimizer, metric] = imregconfig(configname);
    
    % load 
    fixedVolume = double(fixed.img);
    fixedDims = fixed.hdr.dime.pixdim(2:4);
    rFixed = imref3d(size(fixedVolume), fixedDims(2), fixedDims(1), fixedDims(3));
    
    inputs = parseinput(varargin{:});
    if ~isempty(fieldnames(inputs.sources))
        sources = inputs.sources;
    end
    
    % go through the sources
    subset = sd.subjectSubset(varargin{:});
    vi = verboseIter(subset);
        
    while vi.hasNext()
        s = vi.next();
        fname = sd.getModality(modalityOutName, s);
        
        % prep main struct
        src = struct();
        
        % get source image
        source = sd.loadModality(modalityInName, s);
        movingVolume = double(source.img);
        movingDims = source.hdr.dime.pixdim(2:4);
        rMoving = imref3d(size(movingVolume), movingDims(2), movingDims(1), movingDims(3));
        
        % compute the rigid transform and save it in src
        if isfield(inputs.sources, 'tform')
            src.tform = inputs.sources(s).tform;
        elseif inputs.useSaved
            load(fname);
        else
            src.tform = imregtform(movingVolume, rMoving, fixedVolume, rFixed, regtype, optimizer, metric); 
        end
        
        % include the registration
        if inputs.registeredVolume
            src.movingRegisteredVolume = ...
                imwarp(movingVolume, rMoving, src.tform, inputs.registeredVolumeInterp, ...
                'OutputView', rFixed);
        end
            
        % copy the actual volume
        if inputs.volume
            src.volume = movingVolume;
        end
        
        % save blur volume
        if inputs.blurredVolume
            src.blurredVolume = ...
                imBlurSep(movingVolume, inputs.blurWindow, inputs.blurSigma, movingDims);
        end
        
        if inputs.blurredRegisteredVolume
            src.blurredRegisteredVolume = ...
                imBlurSep(src.movingRegisteredVolume, inputs.blurWindow, inputs.blurSigma, fixedDims);
        end
        
        % save voxel dimensions
        if inputs.voxDims
            src.voxDims = movingDims;
        end
        
        % save voxel dimensions
        if inputs.volSize
            src.volSize = size(movingVolume);
        end
        
        % moving grid
        if inputs.registeredCoordinates
            [x, y, z] = ndgrid(1:size(movingVolume, 1), 1:size(movingVolume, 2), 1:size(movingVolume, 3));
            src.regI = imwarp(x, rMoving, src.tform, 'bicubic', 'OutputView', rFixed);
            src.regJ = imwarp(y, rMoving, src.tform, 'bicubic', 'OutputView', rFixed);
            src.regK = imwarp(z, rMoving, src.tform, 'bicubic', 'OutputView', rFixed);
        end
            
        if inputs.library
            [src.hrlib, idx] = patchlib.vol2lib(movingVolume, inputs.libraryPatchSize);
            
            idxArray = zeros(numel(movingVolume), 1);
            idxArray(idx) = 1:numel(idx);
            src.hrIdxToLib = idxArray;
            
            if ~inputs.blurredVolume
                volblur = ...
                    imBlurSep(movingVolume, inputs.blurWindow, inputs.blurSigma, movingDims);
            else
                volblur = src.blurredVolume;
            end
            [src.lrlib, idx] = patchlib.vol2lib(volblur, inputs.libraryPatchSize);
            
            idxArray = zeros(numel(movingVolume), 1);
            idxArray(idx) = 1:numel(idx);
            src.lrIdxToLib = idxArray;
        end
        
        if inputs.ref
            src.ref = rMoving;
        end
        
        % save
        save(fname, 'src');
        
        % if returning, save. If had something in sources before, then copy only what's new.
        if nargout > 0
            if exist('sources', 'var') && isfield(sources, 'tform')
                fnames = fieldnames(src);
                for f = 1:numel(fnames)
                    sources(s).(fnames{f}) = src.(fnames{f});
                end
            else
                sources(s) = src;
            end
        end
        
        if ~isempty(inputs.saveNiiModality)
            assert(inputs.registeredVolume);
            nii = make_nii(src.movingRegisteredVolume);
            nii.hdr.dime.pixdim(2:4) = fixedDims;
            sd.saveModality(nii, inputs.saveNiiModality, s);
        end
        
        % for visualization:
        % view3Dopt({fixedVolume, movingVolume, movingRegisteredVolume, ...
        %   movingRegisteredVolumeI, movingRegisteredVolumeJ, movingRegisteredVolumeK});
    end
    vi.close();
    
    if nargout > 0
        varargout{1} = sources;
    end
end


function inputs = parseinput(varargin)
    p = inputParser();
    p.addParamValue('registeredVolume', false, @islogical); 
    p.addParamValue('blurredRegisteredVolume', false, @islogical);
    p.addParamValue('registeredVolumeInterp', 'bicubic', @ischar);
    p.addParamValue('registeredCoordinates', false, @islogical);
    p.addParamValue('volume', false, @islogical);
    p.addParamValue('blurredVolume', false, @islogical);
    p.addParamValue('blurWindow', [], @isnumeric);
    p.addParamValue('blurSigma', [], @isnumeric);
    p.addParamValue('voxDims', false, @islogical);
    p.addParamValue('volSize', false, @islogical);
    p.addParamValue('rMoving', false, @islogical);
    p.addParamValue('sources', struct(), @isstruct);
    p.addParamValue('useSaved', false, @islogical);
    p.addParamValue('ref', false, @islogical);
    p.addParamValue('library', false, @islogical);
    p.addParamValue('libraryPatchSize', [], @isnumeric);
    p.addParamValue('saveNiiModality', '', @ischar);
    p.KeepUnmatched = true;
    p.parse(varargin{:});
    inputs = p.Results;
end
