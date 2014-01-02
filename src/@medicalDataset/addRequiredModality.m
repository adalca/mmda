function obj = addRequiredModality(obj, modName, modPath, protected)
% ADDREQUIREDMODALITY add a required modality 
%   s.addRequired Modality(modName, modPath) add modality modName with relative 
%   path modPath. Use %s in modPath to indicate the name of the subject, if necessary. 
%   Any files that do not have this modality will not be included in the resulting
%   files structure. For more information, see addModality. 
%
%   s.addRequired Modality(modName, modPath, protected) allows you to specify if the modality is
%   protected (files cannot be over-written). default is true;
%
%   See Also: addModality

    if nargin == 3
        protected = true;
    end

    obj = obj.addModality(modName, modPath, true, protected);
end