function obj = build(obj, subjectPath, clinicalXLSfile, excludeSubjects, verbose)
% BUILD builds file structure for clinical project initial analysis
%   s.build(subjectPath, clinicalXLSfile, excludeSubjects, verbose) builds a
%   struct of file and factor names for the volumes of interest of each subject. 
%   
%   inputs:
%       subjectPath - the absolute subject path of the subject ID folders.
%       clinicalXLSfile - the absolute subject path of the clinical XLS file.
%       excludeSubjects - [Optional] cell of subject ids to be excluded from the file list
%       
%   result:
%       s.files - struct with the filenames of interest for each patient
%           s.files(i).sid - the subject ID of the ith patient
%           s.files(i).modality - fileName for that modality (decide by the
%               'modalitySpecs' input.
%               e.g. s.files(i).flair = '/initpath/SUBJ_I/preproc/padded_SUBJ_I_flair.nii.gz
%
%    See Also: addModality, addRequiredModality


    % check inputs
    narginchk(3, 5);
    if ~exist('excludeSubjects', 'var');
        excludeSubjects = {};
    end
    if ~exist('verbose', 'var');
        verbose = true;
    end
    obj.verbose = verbose;
    mods = obj.modalitySpecs;
    nTypes = numel(mods);

    % ensure consistencies
    assert(obj.nFactorSpecs == 0 || ~isempty(clinicalXLSfile), ...
        'nFactorSpecs: %i, clinical file: %s', obj.nFactorSpecs, clinicalXLSfile);
    assert(obj.nModalitySpecs == 0 || ~isempty(subjectPath));

    % prepare timer
    if verbose
        loadtic = tic;
    end

    % get the subject IDs from the given path.
    subjectIDs = {};
    if obj.nModalitySpecs > 0
        dirList = dir(subjectPath);
        subjectFolders = {dirList(:).name};
        
        assert(strcmp(subjectFolders{1}, '.'))
        assert(strcmp(subjectFolders{2}, '..'))
        subjectIDs = subjectFolders(3:end);
    end

    % get the subject IDs from the clinical file.
    clinicalSIDs = {};
    if obj.nFactorSpecs > 0
        % TODO - remove hardcoded clinical XLS file?
        clinicalData = xls2clinical(clinicalXLSfile, verbose);
        obj.originalClinicalData = clinicalData;
        clinicalSIDs = clinicalData.SubjectID;
    end
    subjectIDs = union(subjectIDs, clinicalSIDs);



    % eliminate any 'exclusion' subjects.
    [intersection, idxSubj, ~] = intersect(subjectIDs, excludeSubjects);
    assert(numel(intersection) == numel(excludeSubjects), ...
        'Some of the given subjects to exclude were not in the original list.');
    subjectIDs(idxSubj) = [];
    nSubjectIDs = numel(subjectIDs);



    % process file structure
    if obj.nModalitySpecs > 0

        % construct the files struct based on the modalityNames in modalitySpecs.
        structParams = cell(2*nTypes, 1);
        structParams((1:nTypes)*2-1) = {mods.modalityName};
        obj.files = struct(structParams{:})';

        % variable to tag any subjects with missing files
        elimSubjects = false(nSubjectIDs, 1);
        obj.fileExists = false(nSubjectIDs, nTypes);

        % add files to files struct.
        obj.sids = cell(nSubjectIDs, 1);
        
        vi = verboseIter(1:nSubjectIDs);
        while vi.hasNext();
            i = vi.next();
        
            subject = subjectIDs{i};
            obj.sids{i} = subject;

            for j = 1:nTypes
                % obtain full file name and assign to the right modality in files struct
                numS = numel(strfind(mods(j).fileName, '%s'));
                subjCell = cell(1, numS);
                for f = 1:numS
                    subjCell{f} = subject;
                end
                fileName = sprintf(mods(j).fileName, subjCell{:});

                fullName = fullfile(subjectPath, subject, fileName);
                obj.files(i).(mods(j).modalityName) = fullName;

                % make sure this file exists, else warn and tag subject. 
                localFileExists = sys.isfile(fullName, verbose && mods(j).isRequired);
                obj.fileExists(i, j) = localFileExists;
                elimSubjects(i) = elimSubjects(i) || (mods(j).isRequired && ~localFileExists);
            end
        end
        vi.close();

        % eliminate tagged subjects (at least one file DNE for that subject)
        subjectIDs(elimSubjects) = [];
        nSubjectIDs = numel(subjectIDs);
        obj.files(elimSubjects) = [];
        obj.sids(elimSubjects) = [];
        obj.fileExists(elimSubjects, :) = [];
        obj.nSubjects = numel(obj.sids);
    end



    % for surviving subjects, go through factors
    if obj.nFactorSpecs > 0

        % get dictionary mapping from sid to entry.
        clinicalMap = containers.Map(clinicalData.SubjectID, 1:numel(clinicalData.SubjectID));

        % cleanup variables
        elimSubjects = false(nSubjectIDs, 1);
        obj.factorExists = true(nSubjectIDs, obj.nFactorSpecs);

        % go through subject, go from their ID to collect the needed stuff.
        obj.factors(nSubjectIDs).(obj.factorSpecs(1).name) = false;
        for i = 1:nSubjectIDs

            % get the subject index in the clinical map
            try
                subjectIdx = clinicalMap(subjectIDs{i});

            catch err % if subject doesn't exist, mark that in elimSubjects
                assert(strcmp(err.identifier, 'MATLAB:Containers:Map:NoKey'));
                for f = 1:obj.nFactorSpecs
                    if obj.factorSpecs(f).isRequired
                        elimSubjects(i) = true;
                        break;
                    end
                end     
            end

            % skip assignments if subject is already marked for elimination
            if elimSubjects(i) 
                continue;
            end

            % go through factors and assign values.
            for f = 1:obj.nFactorSpecs
                facVec = clinicalData.(obj.factorSpecs(f).clinicalName);

                if iscell(facVec)
                    obj.factors(i).(obj.factorSpecs(f).name) = facVec{subjectIdx};
                else
                    assert(isnumeric(facVec));
                    obj.factors(i).(obj.factorSpecs(f).name) = facVec(subjectIdx);
                end

                % check if the factor does not exist (value = missingValue)
                if isequal(obj.factors(i).(obj.factorSpecs(f).name), ...
                        obj.factorSpecs(f).missingValue)
                    obj.factorExists(i) = false;
                end

                % remove subject is the factor is required but doesn't exist
                if obj.factorSpecs(f).isRequired && ~obj.factorExists(i);
                    elimSubjects(i) = true;
                end

            end
        end

        % clean up structures for 
        obj.factors(elimSubjects) = [];
        obj.files(elimSubjects) = [];
        obj.sids(elimSubjects) = [];
        obj.fileExists(elimSubjects, :) = [];
        obj.factorExists(elimSubjects, :) = [];
        obj.nSubjects = numel(obj.sids);
    end

    % everythign should be column vector, for consistency
    obj.files = obj.files(:);
    obj.factors = obj.factors(:);

    % files and factors have been parsed
    obj.parsed = true;

    % print timing
    if verbose
        fprintf('sd loaded in %3.2f sec, %d subjects found\n', toc(loadtic), obj.getNumSubjects());
    end
  
end
