 function obj = addModality(obj, modName, modPath, required, protected)
% ADDMODALITY add a modality spec
%   s.addModality(modName, modPath) add modality modName with relative path modPath.
%   use %s in modPath to indicate the name of the subject, if necessary. 
%
%   s.addModality(modName, modPath, required) - logical required whether modality is required to
%   exist to list the subject. Default is false.
%
%   %   s.addModality(modName, modPath, required, protected) - logical protect whether modality is
%   protected from over-write or not by the programs using this medical dataset. Default is whatever
%   required is (so if required and protected are not provided, both default to the required
%   default)
%
%   Example:
%   assuming the path with all subjects is /path/of/dataset/, and 'subj101' has
%   modality t1 as follows:
%       '/path/of/dataset/subj101/registration/subj101_t1.nii.gz'
%   one might use:
%        s.addModality('originalT1', 'registration/%s_t1.nii.gz');
%   and, after adding all modalities:
%       s.build('/path/of/dataset/'); 
%   to get:
%       %   s(1).files
%       %       originalT1: '/path/of/dataset/subj101/registration/subj101_t1.nii.gz'
%       %   s(1).sids
%       %       sid: 'subj101'
%
%    See Also: addRequiredModality

    narginchk(3, 5);
    % check that the modality name is not a previouis name
    for i = 1:obj.nModalitySpecs
        assert(~strcmp(modName, obj.modalitySpecs(i).modalityName), ...
            'Modality name is not unique: %s', modName);
    end
    
    isRequired = nargin > 3 && required;
    
    % default for modalities is to be protected
    if ~exist('protected', 'var')
        protected = isRequired;
    end

    % add new modality name
    obj.nModalitySpecs = obj.nModalitySpecs + 1;
    obj.modalitySpecs(obj.nModalitySpecs).modalityName = modName;
    obj.modalitySpecs(obj.nModalitySpecs).fileName = modPath;

    % if 'required' is provided, isRequired = required, otherwise isRequired = false
    obj.modalitySpecs(obj.nModalitySpecs).isRequired = isRequired;
    obj.modalitySpecs(obj.nModalitySpecs).isProtected = protected;

    % force file parsing to happen (again) if a new modality is added
    obj.parsed = false;
end