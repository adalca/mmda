classdef medicalDataset < handle
    % MEDICALDATASET Dataset for medical clinical dataset analysis 
    %   Allows for smooth maintenance of Files and Factors for clnical project analysis. Specify
    %   which imaging modalities or factors are of interest and generate a structure of file paths 
    %   and factors for each subject. Usage Example:
    %
    %       % assuming we have a folder structure /path/of/dataset/subjID/*, and a XLS file in 
    %       % '/path/to/clinical.xls' with a column named 'SubjectID', with the same subject 
    %       % naming convention as used in the folder path.
    %       s = medicalDataset();
    %
    %       % add modality 'originalT1' with filepath 'registration/%s_t1_in_buckner51.nii.gz'.
    %       % Note the use of %s instead of the subject id.
    %       s.addModality('originalT1', 'registration/%s_t1.nii.gz');
    %
    %       % add a *required* modality 'dwi' - if the file for thid modality doesn't exist for
    %       % a subject, the subject gets omitted.
    %       s.addRequiredModality('dwi', 'preprocessed/%s_dwi.nii.gz');
    %
    %       % add a *required* factor 'Age', with 'missing value' of -1
    %       s.addRequiredFactor('Age', 'Age', -1);
    %
    %       % build s.files - the structure of interest, but exclude subject 315 and 616
    %       s.build('/path/of/dataset/', '/path/to/clinical.xls', {'subj315', 'subj616'}); 
    %
    %       % subject ids are populated based on the folders in /path/of/dataset. assuming
    %       % /path/of/dataset/subj101/ existed and '/path/to/clinical.xls' contains the clinical 
    %       % info, s(1) might be:
    %       %   s(1).files
    %       %       originalT1: '/path/of/dataset/subj101/registration/subj101_t1.nii.gz'
    %       %       dwi: '/path/of/dataset/subj101/preprocessed/subj101_dwi.nii.gz'
    %       %   s(1).sid: 'subj101' 
    %       %   s(1).Age: 73.8
    %
    %       % extract all files that have a dwi modality
    %       subStruct = s.fileSubset({'dwi'});
    %
    %   TODOs: 
    %       - provide modality-specific iterators that open the niftis and optionally apply a mask?
    %       - add genetics support
    %
    %   Author: Adrian Dalca
    %   Contact: adalca@mit.edu
    %   Last Update: November, 2013.
    
    
    
    properties
        % subject ids. 
        sids = [];
        
        %   modalitySpec - a struct with the modalities of interest. 
        %           modalitySpecs(i).modalityName - the modalityName to be assigned to the ith volume
        %               e.g. 'flair'
        %           modalitySpecs(i).fileName - the fileName in the subfolder, with '%s' 
        %               where the subject id should go
        %               e.g. 'preprocessed/padded_%s_flair.nii.gz'
        %           modalitySpecs(i).isRequired - logical on whether or not to check
        %               existance of this file.
        %           modalitySpecs(i).isProtected - logical on whether or not this modality is 
        %               protected from over-writing
        modalitySpecs = struct('modalityName', [], 'fileName', [], 'isRequired', [], 'isProtected', []);
        
        % Structure of filepaths for each subject. Fields are determined by given modalitySpecs.
        files = [];
              
        %   factorSpec - a struct with the factors of interest. 
        %           factorSpecs(i).name - the name to be assigned to the ith factor
        %               e.g. 'Age'
        %           factorSpecs(i).clinicalName - the name used in the clinical XLS file
        %               e.g. 'Age'
        %           factorSpecs(i).missingValue - the value used in the clinical dataset if
        %               that factor is missing for that subject.
        %               e.g. -1
        %           factorSpecs(i).isRequired - logical on whether or not to check
        %               a legal value (i.e. NOT missingValue) for this factor.
        factorSpecs = struct('name', [], 'clinicalName', [], 'missingValue', [], 'isRequired', []);
        
        % Structure of clinical factors for each subject. Fields are determined by given factors
        factors = [];
        
        % original Clinical Data
        originalClinicalData = [];
        
        % general verbosity while working with the md
        verbose = false;
        
        % Should we over-write non-protected modalities if they exist?
        overwrite = false;
    end
    
    properties (Hidden)
        % number of subjects
        nSubjects = 0;
        
        % number of modality specs
        nModalitySpecs = 0;
        
        % number of factor specs
        nFactorSpecs = 0;
        
        % whether the dataset has been parsed with the latest specs.
        parsed = false;
        
        % logical matrix (nSubject x nModalities) on whether file exists or not. 
        fileExists = [];
        
        % logical matrix (nSubject x nFactos) on whether factor exists or not. 
        factorExists = []; % logical matrix.
    end
    
    methods
        % build/initialization related
        obj = addRequiredModality(obj, modName, modPath, protected);
        obj = addRequiredFactor(obj, facName, facValue, missingValue);
        obj = addModality(obj, modName, modPath, required, protected);
        obj = addFactor(obj, facName, clinicalName, missingValue, required);
        obj = build(obj, subjectPath, clinicalXLSfile, excludeSubjects, verbose);
        
        % helpful small functions
        nSubjects = getNumSubjects(obj);
        idx = ids2idx(obj, ids);
        sids = idx2ids(obj, idx);
        [subset, subsetIdx] = fileSubset(obj, requiredModalities, includeModalities);
        subsetIdx = subjectSubset(obj, varargin);
        file = getModality(obj, modality, idx);
        nii = loadModality(obj, modality, idx);
        ism = ismodality(sd, modality);
        saveModality(obj, nii, s, modality, varargin);
        [min, max] = modalityMinMax(obj, modality, s);
        spec = getModalitySpecs(obj, modality);
        vol = loadVolume(md, modality, s, varargin)

        
        % larger operations on the medical dataset
        allFramesMat = modality2images(obj, modality, outPath, varargin);
        meas = measureModality(obj, modality, distMethod, varargin);
        meas = pairwiseMeasure(obj, modality, distMethod, nLoad, varargin);
        stats = segmentModality(obj, modFile, method, varargin);
        [medImg, meanImg] = medianImage(obj, vol, maskFile, varargin);
        aggVol = aggregateModality(md, modalities, varargin);
        [medians, means, modes] = linearEqualization(obj, inmodality, outmodality, ...
            labelFile, matchLabels, desiredLabelValue, overallMask, matchFunction, inSubjectSpace, varargin);
        [clusterIdx, centroidVolumes, features] = ...
            clusterVolumes(obj, clusterFeatureType, k, varargin);
        varargout = register(sd, modalityInName, modalityOutName, regtype, configname, fixedin, varargin)
        normalize(md, inputModality, normVal, outputModality, varargin);
        varargout = applyfun(md, fn, mods, varargin);
        [croppedVol, cropMask, cropArray, bBox] = ...
                boundingBox(md, inputModality, outputModality, varargin)
        boundingBoxCrop(sd, modalityInName, modalityOutName, varargin);
    end
    
    methods (Static)
        files2folders(filepath, regex, folderpath);
    end
end
