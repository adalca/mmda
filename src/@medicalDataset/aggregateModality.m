function varargout = aggregateModality(md, modalities, aggMethod, online, varargin)
% AGGREGATEVOLUMES aggregate modality volumes into one volume
%   vol = aggregateModality(md, modalities, aggMethod, online) aggregate all of the modalities in 
%       cell array modalities for all of the subjects given through the files struct. Logical online
%       indicates whether the function can be computed "online" (i.e. in each iteration, e.g. sum)
%       in which case it will be given the passed aggregate and the new volume, or not, in which
%       case all volumes are stored (thus needing alot of memory) and computed at the end with a
%       cell array of nSubjects x nModalities. 
%   
%   vol = aggregateModality(md, modalities, param1, value1, ...) allows the following properties:
%       outNiiFile - a nifti filename to save the aggregate volume to.
%       maskNii - a modality name for a subject-specific mask. do not supply globalMaskNii
%       globalMaskNii - a file path to a global mask. do not supply maskNii
%       aggMethodEnd - if online is true, can supply a method handle to do some final clean up 
%           (e.g. division for an online mean-type function). Given the aggVol and the nSubjects
%       any param/value pair accepted by md.subjectSubset to specify a subset of subjects for this
%           operation
%
%   [vol, fullVol] = aggregateModality(...) if a global mask is provided, then fullVol(mask) = vol. 
%
% Example: 
%   vol = aggregateVolumes(files, {'WMHLReg', 'WMHRReg'}, @sum, true, ...
%           'outNiiFile', 'db_wmh_union.nii.gz')
%
% TODO: clean up the mask-loading and handling
% TODO: if no mask, should not use (mask) which vectorizes the volumes...
%
% Project: Analysis of clinical datasets
% Authors: Adrian Dalca, Ramesh Sridharan
% Contact: {adalca,rameshvs}@csail.mit.edu
    


    % check the right number of inputs
    [modalities, aggMethod, online, inputs] = ...
        parseInputs(modalities, aggMethod, online, varargin{:});
    
    % get the subset of subjects to use
    subset = md.subjectSubset(varargin{:});
    
    % get an original nifti to setup the aggregate volume.
    initiated = false;
    
    % get the mask if it's global
    mask = maskNii2mask(md, nan, inputs);
    
    % go through all of the subjects
    vi = verboseIter(subset, md.verbose);
    while vi.hasNext()
        [s, i] = vi.next();
        mask = maskNii2mask(md, s, inputs, mask);
        
        % for this subject, go through all of the modalities to aggregate
        for volIdx = 1:numel(modalities)
            vol = modalities{volIdx};
            
            % load nifti
            filename = md.getModality(vol, s);
            nii = loadNii(filename);
            if numel(mask) == 0
                mask = true(size(nii.img));
            end
            vox = nii.img(mask);
            if ~isa(vox, 'double') && ~isa(vox, 'single')
                vox = double(vox);
            end
            
            % if the aggregate volume hasn't been initiated yet, initiate now. 
            if ~initiated
                % uses inputs.online!
                aggVol = initVol(inputs, numel(subset), numel(modalities), sum(mask(:)));
                orignii = nii; 
                initiated = true;
            end          
            
            % aggregate if online
            if online
                aggVol = aggMethod(aggVol, vox);
            else
                aggVol{i, volIdx} = vox;
            end
        end
    end
    
    % display process
    vi.close();
    
    % if online, do a final step
    if online && ~isempty(inputs.aggMethodEnd)
        aggVolFinal = inputs.aggMethodEnd(aggVol, nSubjects);
    elseif online
        aggVolFinal = aggVol;
    end
    
    % aggregate
    if ~online
        aggVolFinal = aggMethod(aggVol);
    end

    
    % return the aggregate volume, and the full volume if there was a global mask
    varargout{1} = aggVolFinal;
    if numel(inputs.globalMaskFile) > 0
        if numel(aggVolFinal) == sum(mask(:))
            fullVolume = zeros(size(orignii.img));
            fullVolume(mask) = aggVolFinal;
            varargout{2} = fullVolume;
        
            if ~isempty(inputs.outNiiFile)
                saveNii(makeNiiLike(fullVolume, orignii), inputs.outNiiFile);
            end
        end
    else
        % save to nifti file
        if ~isempty(inputs.outNiiFile)
            fullVolume = reshape(aggVolFinal, size(orignii.img));
            saveNii(makeNiiLike(fullVolume, orignii), inputs.outNiiFile);
        end
    end
    

end


function [modalities, aggMethod, online, inputs] = ...
    parseInputs(modalities, aggMethod, online, varargin)

    narginchk(3, inf);

    p = inputParser();
    p.addRequired('modalities', @(x) iscellstr(x) || ischar(x));
    p.addRequired('aggMethod', @(x) isa(x, 'function_handle'));
    p.addRequired('online', @islogical);
    p.addParamValue('aggMethodEnd', []);
    p.addParamValue('outNiiFile', '', @ischar);
    p.addParamValue('maskFile', '');
    p.addParamValue('globalMaskFile', '');
    p.KeepUnmatched = true;
    p.parse(modalities, aggMethod, online, varargin{:});
    inputs = p.Results;
    
    % make sure modalities will be a cellstr
    if ischar(modalities)
        modalities = {modalities};
        inputs.modalities = {modalities};
    end
    
end

function aggVol = initVol(inputs, nSubjects, nModalities, nVoxels)
    if inputs.online
        aggVol = zeros(nVoxels, 1);
    else
        aggVol = cell(nSubjects, nModalities);
    end
end

function mask = maskNii2mask(md, s, inputs, mask)
% is s is nan, assuming global mask lookup
% if s is not nan, assuming mask is either [] (then we look for potential local mask, 
%   or a full mask (then we just check no local mask is specified)


    % only interested in global mask
    if isnan(s)
        if ~isempty(inputs.globalMaskFile)
            maskNii = loadNii(inputs.globalMaskFile);
            mask = maskNii.img(:) > 0;
        else
            mask = [];
        end
        
    % otherwise, subject-specific
    else
        if ~exist('mask', 'var') || numel(mask) == 0
            if ~isempty(inputs.maskFile)
                maskNii = loadNii(md.getModality(inputs.maskFile, s));
                mask = maskNii.img(:) > 0;
            else
                
            end
        else
            assert(isempty(inputs.maskFile));
        end
    end
end
