function vol = loadVolume(md, modality, s, varargin)

    vol = nii2vol(md.loadModality(modality, s, varargin{:}));
    