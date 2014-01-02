function obj = addFactor(obj, facName, clinicalName, missingValue, required)
% ADDFACTOR add a factor spec
%   s.addFactor(name, clinicalName, missingValue, required) add factor name, where the
%   original name in the XLS file was clinicalName. missingValue represents the value
%   used in the clinical dataset if it's missing for a subject. required is boolean on
%   whether this value is required for a subject to be kept in the dataset.
%
%   Required: the clinical XLS file has a column named SubjectID, and another column
%   with the name in the above clinicalName. see xls2clinical for how this file gets
%   processed.
%
%   Example:
%       % add a *required* factor 'Age', with 'missing value' of -1
%       s.addRequiredFactor('Age', 'Age', -1);
%
%       % build s.files - the structure of interest, but exclude subject 315 and 616
%       s.build('', '/path/to/clinical.xls', {'subj315', 'subj616'}); 
%
%       % subject ids are populated based on column SubjectID in XLS
%       % info, s(1) might be:
%       %   s(1).sid: 'subj101' 
%       %   s(1).Age: 73.8
%
%    See Also: addRequiredFactor, xls2clinical

    narginchk(4, 5);
    for i = 1:obj.nFactorSpecs
        assert(~strcmp(facName, obj.factorSpecs(i).name), ...
            'Factor name is not unique: %s', facName);
    end

    % add new factor name
    obj.nFactorSpecs = obj.nFactorSpecs + 1;
    obj.factorSpecs(obj.nFactorSpecs).name = facName;
    obj.factorSpecs(obj.nFactorSpecs).clinicalName = clinicalName;
    obj.factorSpecs(obj.nFactorSpecs).missingValue = missingValue;

    % if 'required' is provided, isRequired = required, otherwise isRequired = false
    obj.factorSpecs(obj.nFactorSpecs).isRequired = nargin == 5 && required;

    % force file parsing to happen (again) if a new modality is added
    obj.parsed = false;
end