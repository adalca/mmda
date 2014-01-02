function joinModalities(obj, inmodalities, outmodality, method, varargin)
% modalities - cell array of modality names
% example method: @modVols2sum

    subset = obj.subjectSubset(varargin{:});
    nModalities = numel(inmodalities);
    
    vi = verboseIter(subset, obj.verbose);
    while vi.hasNext()
        s = vi.next();
        
        vols = cell(nModalities, 1);
        for m = 1:nModalities
            nii = loadNii(obj.getModality(inmodalities{m}, s));
            vols{m} = nii.img;
        end
        
        % save resulting volume
        vol = method(vols{:});
        finalNii = makeNiiLike(vol, nii);
        obj.saveModality(finalNii, outmodality, s);
    end

    % display progress
    vi.close();
    