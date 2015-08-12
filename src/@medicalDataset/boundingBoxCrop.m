function boundingBoxCrop(md, modalityInName, modalityOutName, varargin) 
% computing the bounding box of each volume in modalityInName and write in modalityOutName
    
    subset = md.subjectSubset(varargin{:});
    vi = verboseIter(subset);
    
    % go through the volumes 
    while vi.hasNext()
        s = vi.next();
        
        % load volume
        nii = md.loadModality(modalityInName, s);
        
        % get the bounding boxed volume
        nii.img = boundingBox(nii.img);
        
        % save resulting volume
        nii.hdr.dime.dim(2:4) = size(nii.img);
        md.saveModality(nii, modalityOutName, s);
        
    end
    vi.close();
    
