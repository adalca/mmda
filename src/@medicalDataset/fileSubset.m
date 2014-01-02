function [subset, subsetIdx] = fileSubset(obj, requiredModalities, includeModalities)
% FILESUBSET obtain the subset of files that have the required modalities
%   s.fileSubset(requiredModalities) obtain the subset of files from
%   the clinicalFileList s that have the modalities in the requiredModalities cell.
%   
%   s.fileSubset(requiredModalities, includeModalities) behaves the same, but only
%   includes the modalities in the includeModalities cell in the output structure.
%
%   Example:
%   s.fileSubset({'t1'}) returns a files struct (as described in s.files) that includes
%   all of the files with a t1 present.
%   s.fileSubset({'t1'}, {'t1', 'dwi'}) returns a files struct that includes all of the
%   files with a t1 present, but with only the t1 and dwi fields for each file (i.e. if
%   there were other fields, like 'flair', those will be excluded;


    warning('Maybe combine subjectSubset() with fileSubset()?');

    % check that the files have been parsed
    assert(obj.parsed, 'Files have not been (re)parsed yet!');

    % default for includeModalities (all modalities), and verify that the inputs are cells
    allModalities = {obj.modalitySpecs.modalityName};
    if nargin == 2, includeModalities = allModalities; end
    if ischar(requiredModalities), requiredModalities = {requiredModalities}; end
    if ischar(includeModalities), includeModalities = {includeModalities}; end

    % go through the required modalities and find out which files have those modalities
    subsetIdx = true(obj.nSubjects, 1);
    for i = 1:numel(requiredModalities)
        % get field id for this modality
        mod = requiredModalities{i};
        id = find(strcmp(mod, allModalities));
        assert(numel(id) == 1, 'Modality %s not found', mod);

        % check which files have this modality.
        subsetIdx = subsetIdx & obj.fileExists(:, id);
    end

    % get the good files and eliminate any unwanted modalities.
    subset = obj.files(subsetIdx);
    nonModalities = setdiff(allModalities, includeModalities);
    for i = 1:numel(nonModalities)
        subset = rmfield(subset, nonModalities{i}); 
    end
end


