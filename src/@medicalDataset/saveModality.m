function saveModality(obj, nii, modality, s, varargin)
% write given modality for subject s with saveNii, if medical dataset allows it

    file = obj.getModality(modality, s);

    % if it's protected, can't write
    specs = obj.getModalitySpecs(modality);
    isProtected = specs.isProtected;
    if isProtected
        error('Modality %s is protected by the medical dataset object', modality);
    end
    
    % if it's not protected, but exists already, overwrite should be turned on
    if exist(file, 'file') == 2 && ~obj.overwrite
        error('File exists, but over-write is turned off by the medical dataset object: %s', file);
    end
    
    % finally, write
    saveNii(nii, obj.getModality(modality, s), varargin{:});
    