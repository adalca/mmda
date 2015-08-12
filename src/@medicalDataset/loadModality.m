function nii = loadModality(obj, modality, idx, varargin)
% load the modality for the given index.

    if ischar(idx)
        idx = find(strcmp(idx, obj.sids));
    end

    file = getModality(obj, modality, idx);
    nii = loadNii(file, varargin{:});
