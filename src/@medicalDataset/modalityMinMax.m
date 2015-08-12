function [mmin, mmax] = modalityMinMax(obj, modality, subset)
% min max of the modality for the given index.
% somehow combine with include/exclude structure of general. dataset

    if nargin <= 2
        subset = md.subjectSubset();
    end

    vi = verboseIter(subset);
    mmin = zeros(numel(subset), 1);
    mmax = zeros(numel(subset), 1);
    while vi.hasNext()
        [s, si] = vi.next();
        
        nii = obj.loadModality(modality, s);
        mmin(si) = min(nii.img(:));
        mmax(si) = max(nii.img(:));
    end
    vi.close();
        
