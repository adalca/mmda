function modalityMeasure2csv(obj, modality, measures, file, varargin)
% MODALITYMEASURE2CSV write some measures of a modality to a csv file
%   modalityMeasure2csv(obj, modality, measures, file) write some measures (cell array of 
%       handles for functions that take in a nifti) of a modality (string) to a csv file.
%   
%   modalityMeasure2csv(obj, modality, measures, file, param1, value1, ...) allows for specification
%   of subset of medical dataset via param/value pairs taken by subjectSubset().
%
%   Example:
%       measures = {@niiMask2voxCount, @niiMask2ccCount};
%       md.modalityMeasure2csv('wmhCallInFlair', measures, 'volumes.csv');
%
% Project: Analysis of clinical datasets
% Authors: Adrian Dalca, Ramesh Sridharan
% Contact: {adalca,rameshvs}@csail.mit.edu

    % extract subset of subjects to extract information on
    subset = obj.subjectSubset(varargin{:});

    % prepare file to write to
    fid = fopen(file, 'w');
    
    vi = verboseIter(subset, obj.verbose);
    msg = '';
    while vi.hasNext()
        s = vi.next(msg);

        nii = loadNii(obj.getModality(modality, s));

        vals = zeros(numel(measures), 1);
        for m = 1:numel(measures)
            measure = measures{m};
            vals(m) = measure(nii);
        end
        
        valsstr = sprintf('%3.2f,', vals);
        msg = sprintf('%s, %s\n', obj.sids{s}, valsstr(1:end-1));
        fprintf(fid, msg);
    end

    fclose(fid);
    vi.close();
    