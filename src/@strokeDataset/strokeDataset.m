classdef strokeDataset < medicalDataset
    
    properties
        predefinedModalityMap = [];
    end
    
    methods
        
        function obj = strokeDataset(varargin)
            if nargin == 0
                varargin = {2};
            end
            
            obj = obj@medicalDataset(varargin{2:end});
            obj.predefinedModalityMap = strokeDataset.buildPredefinedModalityMap(varargin{1});
        end
        
        [flairDist, outIdx] = ...
            cleanModality(md, modalityReg, modalityWMCorr, corrWMIntensity, ...
            medianFile, labelFile, wmLabels, brainMaskFile, varargin);
        [features, canCompute] = features(obj, featureList, varargin);
        obj = addPredefinedRequiredModality(obj, modName, varargin);
        obj = addPredefinedModality(obj, modName, varargin)
    end
    
    methods (Static)
        c = buildPredefinedModalityMap(~);
        sd = predefined(type, mainPath, varargin);
        sd = predefinedFullSite(sd);
        sd = predefinedFlairManual(sd);
        sd = predefinedManualInAtlas(sd);
        sd = predefinedFullMGH(sd);
        files = predefinedAtlasFiles(ver);
        [volbase, volpath, clinicalpath] = predefinedSite(site, ver);
    end
    
    
end