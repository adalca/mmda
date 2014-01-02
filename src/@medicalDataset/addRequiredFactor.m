function obj = addRequiredFactor(obj, facName, facValue, missingValue)
% ADDREQUIREDFACTOR add a required factor spec
%   s.addRequiredFactor(name, clinicalName, missingValue) add required factor name, where 
%   the original name in the XLS file was clinicalName. missingValue represents the value
%   used in the clinical dataset if it's missing for a subject. 
%
%   See Also: addFactor, xls2clinical

    obj = addFactor(obj, facName, facValue, missingValue, true);
end