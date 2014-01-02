function obj = addPredefinedRequiredModality(obj, modName, varargin)
%   
% Project: Analysis of clinical datasets
% Authors: Adrian Dalca, Ramesh Sridharan
% Contact: {adalca,rameshvs}@csail.mit.edu

    modPath = obj.predefinedModalityMap(modName);
    obj = addRequiredModality(obj, modName, modPath, varargin{:});
    