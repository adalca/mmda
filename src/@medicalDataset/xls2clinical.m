function data = xls2clinical(datafile, verbose)
% XLS2CLINICAL builds a dataset from a clinical xls file
%   data = XLS2CLINICAL(datafile) builds a dataset from the clinical
%   xls file, with specifics related to the stroke project.  
%
%   see TODOs below.
%   
%	Author:Adrian Dalca
%   'C:\Users\adalca\Dropbox\research\Stroke\data\Phenotypic Data_4_17_2013.xls'
%   Contact: Stroke project, http://www.mit.edu/~adalca/stroke/ 



    % input
    narginchk(1, 2);
    if ~exist('verbose', 'var')
        verbose = false;
    end
    
    % load dataset
    data = dataset('XLSFile', datafile);

    % make sure there is a field called SubjectID.
    assert(ismember('SubjectID', get(data, 'VarNames')));

    % clean up subject id to be consistent with pipeline
    if verbose
        fprintf(2, 'Cropping Subject IDs to 5 characters\n');
    end
    for i = 1:numel(data.SubjectID)
        data.SubjectID{i} = data.SubjectID{i}(1:5);
    end

    % clean up age. make any person with '>90' be 90.
    defAge = 90;
    if iscell(data.Age) % in windows
        age = zeros(numel(data.Age), 1);
        for i = 1:numel(data.Age)
            age(i) = str2double(data.Age{i});
        end
        data.Age = age;
    end
    
    for i = 1:numel(data.Age)
        if isnan(data.Age(i)) 
            % TODO - should verify this was >90 originally ? is substr or
            % something?
            if verbose
                fprintf(2, 'Setting age of SID %s from %s to %d\n', ...
                    data.SubjectID{i}, data.Age(i), defAge);
            end
            data.Age(i) = defAge;
        end
    end

    % clean up any values of 9999 into -1
    fields = get(data, 'VarNames');
    for f = 1:numel(fields)
        vec = data.(fields{f});
        if isnumeric(vec);
            vec(vec == 9999) = -1;
            data.(fields{f}) = vec;
        end
    end
