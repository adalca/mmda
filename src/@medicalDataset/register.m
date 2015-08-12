function varargout = register(sd, movingModality, fixedVol, regtype, varargin)
% REGISTER register volumes to a tempplate with matlab's registration functions
%   movedVols = sd.register(movingModality, fixedVol, regtype)
%
%   movedVols = sd.register(movingModality, fixedVol, regtype, configname)
%
%   movedVols = sd.register(..., Param, Value)
%       saveModality modality to save to.
%       savetformModality modality
%       loadtformModality modality to load tform. tform will not be computed - and images will only
%           be warped.
%       performWarp (true by default). if false, movedVols is empty.
%       registeredVolumeInterp (linear by default)
%
%   [movedVols, tforms] = sd.register(...)
%
% Author: adalca@mit
    
    
    % handle inputs
    [inputs, parseableVargs] = parseinput(varargin{:});
    
    % build optimizer for registration
    [optimizer, metric] = imregconfig(inputs.configname);
    optimizer.GradientMagnitudeTolerance = inputs.GradientMagnitudeTolerance;
    
    % load fixed volume
    if sys.isfile(fixedVol)
        fixed = loadNii(fixedVol);
    else
        assert(isstruct(fixedVol));
        fixed = fixedVol;
    end
    fixedVol = double(fixed.img);
    fixedDims = fixed.hdr.dime.pixdim(2:4);
    rFixed = imref3d(size(fixedVol), fixedDims(2), fixedDims(1), fixedDims(3));
    
    % go through the sources
    subset = sd.subjectSubset(parseableVargs{:});
    vi = verboseIter(subset);
    while vi.hasNext()
        s = vi.next();
        
        % get source image
        source = sd.loadModality(movingModality, s);
        movingVol = double(source.img);
        movingDims = source.hdr.dime.pixdim(2:4);
        rMoving = imref3d(size(movingVol), movingDims(2), movingDims(1), movingDims(3));
        
        % compute the rigid transform and save it in src
        if ~isempty(inputs.loadtformModality)
            tformFile = sd.getModality(inputs.loadtformModality, s);
            tformFileContents = load(tformFile);
            tform = tformFileContents.tform;
        else
            tform = imregtform(movingVol, rMoving, fixedVol, rFixed, regtype, optimizer, metric, ...
                'DisplayOptimization', inputs.DisplayOptimization, ...
                'PyramidLevels', inputs.PyramidLevels); 
        end
        
        % include the registration
        if inputs.performWarp
            movedVol = imwarp(movingVol, rMoving, tform, inputs.registeredVolumeInterp, ...
                'OutputView', rFixed);
        else
            movedVol = [];
        end
            
        % save tform if necessary        
        if ~isempty(inputs.savetformModality)
            save(sd.getModality(inputs.savetformModality, s), 'tform');
        end
        
        % save registered volume if necessary
        if ~isempty(inputs.saveModality)
            assert(inputs.performWarp, ...
                'performWarp needs to be true if saveModality provided')
            nii = make_nii(movedVol);
            nii.hdr.dime.pixdim(2:4) = fixedDims;
            sd.saveModality(nii, inputs.saveModality, s);
        end
        
        
        if nargout >= 1
            varargout{1}{s} = movedVol;
            varargout{2}{s} = tform;
        end
    end
    vi.close();
end


function [inputs, varargin] = parseinput(varargin)
    
    configname = 'monomodal';
    if isodd(numel(varargin))
        configname = varargin{1};
        varargin = varargin(2:end);
    end
    
    p = inputParser();
    p.addParamValue('saveModality', [], @ischar);
    p.addParamValue('savetformModality', [], @ischar);
    p.addParamValue('loadtformModality', [], @ischar);
    p.addParamValue('registeredVolumeInterp', 'linear', @ischar);
    p.addParamValue('performWarp', true, @islogical); 
    p.addParamValue('GradientMagnitudeTolerance', 1e-2, @isscalar); 
    p.addParamValue('DisplayOptimization', true, @islogical); 
    p.addParamValue('PyramidLevels', 4, @isscalar); 
    p.KeepUnmatched = true;
    p.parse(varargin{:});
    inputs = p.Results;
    inputs.configname = configname;
end
