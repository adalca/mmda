 function obj = addPredefinedModality(obj, modName, varargin)
 %   
% Project: Analysis of clinical datasets
% Authors: Adrian Dalca, Ramesh Sridharan
% Contact: {adalca,rameshvs}@csail.mit.edu

    modPath = obj.predefinedModalityMap(modName);
    obj = addModality(obj, modName, modPath, varargin{:});
    