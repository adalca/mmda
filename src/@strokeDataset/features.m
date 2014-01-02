function [features, canCompute] = features(obj, featureList, varargin)
% FEATURES compute subject features for stroke project features
%   md.features(featureList) compute features struct for all the subjects 
%   in this medical dataset
%   
%   md.features(featureList, optName, optVal) allows for
%   options as follows:
%       maskFile = the path to a brain mask. If used, many features
%       are only computed within this brain mask (see each feature
%       implementation)
%       brainSize = the size of the images used - 
%           TODO: I'm working on removing this, but for now it's required. e.g. [256, 256, 256]
%       parcFile = the parcelation file, if using any of the parcel-based features
%       parcNamesFile = the file with parcel names, in the format of 
%           parcelNr    parcelName
%
%   for predfined available features, see featSpec construction below.
%
%   TODO: fix the need for brainSize, fix parcNamesFile handling
%   TODO: make part of medicalDataset
%   TODO: allow for input feature spec?
%
%   Required: Files to be aligned. 
%
%   Contact: Stroke project, http://www.mit.edu/~adalca/stroke/ 

    % check the right inputs
    inputs = subjectFeaturesInput(featureList, varargin{:});
    % TODO - assert featList is from the allowed list of features
    if isfield(inputs, 'mask');
        nSelVoxels = sum(inputs.mask(:));
    else
        nSelVoxels = 1;
    end
    
    if isfield(inputs, 'parcs');
        nParcVoxels = numel(inputs.parcs);
    else
        nParcVoxels  = 1;
    end
    
    % potential features (implemented in this file)
    % TODO - do loadNiiMemoized in the loop only for the modalities specified here.
    % TODO - note what can't be done because 'parcs' or 'mask' are missing
    featSpec = superStruct('name', 'class', 'len', 'modalities');
    featSpec.addEntry('wmhBW', @false, nSelVoxels, {'WMHLReg', 'WMHRReg'});
    featSpec.addEntry('wmhCallBW', @false, nSelVoxels, {'wmhCallInAtlas'});
    featSpec.addEntry('flair', @zeros, nSelVoxels, {'flairReg'});
    featSpec.addEntry('t1', @zeros, nSelVoxels, {'t1Reg'});
    featSpec.addEntry('wmhBW_mean', @zeros, 1, {'WMHLReg', 'WMHRReg'});
    featSpec.addEntry('wmhBW_parc', @zeros, nParcVoxels, {'WMHLReg', 'WMHRReg'});
    featSpec.addEntry('wmhBlur', @zeros, nSelVoxels, {'WMHLReg', 'WMHRReg'});
    featSpec.addEntry('wmhBWSDT', @zeros, nSelVoxels, {'WMHLReg', 'WMHRReg'});
    featSpec.addEntry('wmhHemiDiff', @zeros, 1, {'WMHLReg', 'WMHRReg'});
    featSpec.addEntry('lesionBW', @false, nSelVoxels, {'lesionReg'});
    featSpec.addEntry('strokeCallBW', @false, nSelVoxels, {'strokeCallInAtlas'});
    featSpec.addEntry('lesionBW_mean', @zeros, 1, {'lesionReg'});
    featSpec.addEntry('lesionBlur', @zeros, nSelVoxels, {'lesionReg'});
    featSpec.addEntry('lesionHemiDiff', @zeros, 1, {'lesionReg'});
    
    % extract the feature set specified by the user
    chosenFeatSet = featSpec.getEntries('name', inputs.featureList);
    
    % prepare the canCompute and features structures
    %   canCompute.featName (nFiles x 1) - logical - which files can compute feature featName.
    %   features.featName   preallocates the matrices necessary for feature featName.
    allModalities = {};
    allFiles = obj.files;
    nFiles = numel(allFiles);
    for i = 1:numel(chosenFeatSet);
        featName = chosenFeatSet(i).name;
        featClass = chosenFeatSet(i).class;
        featCount = chosenFeatSet(i).len;
        modalities = chosenFeatSet(i).modalities;

        % prepare the files and features for this feature type.
        [~, canCompute.(featName)] = obj.fileSubset(modalities, modalities);
        features.(featName) = featClass(featCount, numel(canCompute.(featName)));
        
        % update all of the modalities needed
        allModalities = union(allModalities, modalities);
    end
    
    
    assert(nFiles > 0);
    % go through all of the subjects and populate features structure for specified features
    for i = 1:nFiles
        tic
        fprintf(1, 'Subject: %i (%s)', i, obj.sids{i});
        fileRec = allFiles(i);
        niis = [];
         
        assert(~ismember('SubjectIDs', inputs.featureList));
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Compute Features
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Feature: Simple WMH logical image
        if ismember('wmhBW', inputs.featureList) && canCompute.wmhBW(i)
            niis = getNiiMemoized(fileRec, 'WMHLReg', niis);
            niis = getNiiMemoized(fileRec, 'WMHRReg', niis);
            wmhBWimg = (niis.WMHLReg.img > 0) | (niis.WMHRReg.img > 0);
            features.wmhBW(:, i) = wmhBWimg(inputs.mask);
        end
        
        if ismember('wmhCallBW', inputs.featureList) && canCompute.wmhCallBW(i)
            niis = getNiiMemoized(fileRec, 'wmhCallInAtlas', niis);
            wmhCallBWimg = (niis.wmhCallInAtlas.img > 0);
            features.wmhCallBW(:, i) = wmhCallBWimg(inputs.mask);
        end
        
        % Feature: Simple flair image
        if ismember('flair', inputs.featureList) && canCompute.flair(i)
            niis = getNiiMemoized(fileRec, 'flairReg', niis);
            features.flair(:, i) = niis.flairReg.img(inputs.mask);
        end
        
        % Feature: Simple t1 image
        if ismember('t1', inputs.featureList) && canCompute.t1(i)
            niis = getNiiMemoized(fileRec, 't1Reg', niis);
            features.t1(:, i) = niis.t1Reg.img(inputs.mask);
        end
        
        % Feature: Simple WMH average within brain mask
        if ismember('wmhBW_mean', inputs.featureList) && canCompute.wmhBW_mean(i)
            niis = getNiiMemoized(fileRec, 'WMHLReg', niis);
            niis = getNiiMemoized(fileRec, 'WMHRReg', niis);
            wmhBWimg = (niis.WMHLReg.img > 0) | (niis.WMHRReg.img > 0);
            features.wmhBW_mean(:, i) = mean(wmhBWimg(inputs.mask));
        end
        
        % Feature: Simple WMH summary by parcelation
        if ismember('wmhBW_parc', inputs.featureList) && canCompute.wmhBW_parc(i)
            niis = getNiiMemoized(fileRec, 'WMHLReg', niis);
            niis = getNiiMemoized(fileRec, 'WMHRReg', niis);
            wmhBWimg = (niis.WMHLReg.img > 0) | (niis.WMHRReg.img > 0);
            
            newFeat = zeros(numel(inputs.parcs), 1);
            newFeatNames = cell(numel(inputs.parcs), 1);
            for p = 1:numel(inputs.parcs)
                newFeat(p) = mean(wmhBWimg(inputs.parcImages{p}), 1);
                try 
                    newFeatNames{p} = inputs.parcsIds2NamesMap(inputs.parcs(p));
                catch err
                    newFeatNames{p} = 'none';
                end
            end
            features.wmhBW_parc(:, i) = newFeat;
            
            % TODO - cleaner way to do this?
            features.wmhBW_parc_names = newFeatNames;
        end
        
        % Feature: Blurred WMH intensity image (0..1)
        if ismember('wmhBlur', inputs.featureList) && canCompute.wmhBlur(i)
            % blur images and take blurred WMH features.
            niis = getNiiMemoized(fileRec, 'WMHLReg', niis);
            niis = getNiiMemoized(fileRec, 'WMHRReg', niis);
            blurL = imBlurSep(double(niis.WMHLReg.img), [3, 3, 3], 3, [1, 1, 1]);
            blurR = imBlurSep(double(niis.WMHRReg.img), [3, 3, 3], 3, [1, 1, 1]);
            wmhBlurImg = blurL - blurR;xx
            features.wmhBlur(:,i) = wmhBlurImg(inputs.mask);
        end
        %TODO - look at blurring results!
        
        % Feature: Signed Distance Transform from BW Islands
        if ismember('wmhBWSDT', inputs.featureList) && canCompute.wmhBWSDT(i)
            niis = getNiiMemoized(fileRec, 'WMHLReg', niis);
            niis = getNiiMemoized(fileRec, 'WMHRReg', niis);
            % compute a binary WMH image and a signed distance transform
            wmhBWimg = (niis.WMHLReg.img > 0) | (niis.WMHRReg.img > 0);
            sdtImg = bw2sdtrf(wmhBWimg);
            features.wmhBWSDT(:,i) = sdtImg(inputs.mask);
        end
           
        % Feature: WMH volumetric hemisphere difference 
        if ismember('wmhHemiDiff', inputs.featureList) && canCompute.wmhHemiDiff(i)
            niis = getNiiMemoized(fileRec, 'WMHLReg', niis);
            niis = getNiiMemoized(fileRec, 'WMHRReg', niis);
            leftVol = double(sum(niis.WMHLReg.img(:) > 0));
            rightVol = double(sum(niis.WMHRReg.img(:) > 0));
            features.wmhHemiDiff(:, i) =  leftVol - rightVol;
        end
        
        % Feature: Simple lesion logical image
        if ismember('lesionBW', inputs.featureList)  && canCompute.lesionBW(i)
            niis = getNiiMemoized(fileRec, 'lesionReg', niis);
            lesionBWimg = niis.lesionReg.img > 0;
            features.lesionBW(:, i) = lesionBWimg(inputs.mask);
        end
        
        if ismember('lesionCallBW', inputs.featureList)  && canCompute.lesionCallBW(i)
            niis = getNiiMemoized(fileRec, 'strokeCallInAtlas', niis);
            lesionCallBWimg = niis.strokeCallInAtlas.img > 0;
            features.lesionCallBW(:, i) = lesionCallBWimg(inputs.mask);
        end
        
        if ismember('lesionBW_mean', inputs.featureList) && canCompute.lesionBW_mean(i)
            niis = getNiiMemoized(fileRec, 'lesionReg', niis);
            lesionBWimg = niis.lesionReg.img > 0;
            features.lesionBW_mean(:, i) = mean(lesionBWimg(inputs.mask));
        end
        
        % Feature: Blurred lesion logical image (0..1)
        if ismember('lesionBlur', inputs.featureList) && canCompute.lesionBlur(i)
            niis = getNiiMemoized(fileRec, 'lesionReg', niis);
            lesionBlurImg = imBlurSep(double(niis.lesionReg.img), [3, 3, 3], 3, [1, 1, 1]);
            features.lesionBlur(:, i) = lesionBlurImg(inputs.mask);
        end
                
        % Feature: Lesion volumetric hemisphere difference 
        if ismember('lesionHemiDiff', inputs.featureList)
            error('lesionHemiDiff is not implemented since we don''t have L/R for lesions');
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Done Feature computations
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        fprintf(1, ' done: %f sec\n', toc);
    end
    
    features.sids = obj.sids;
    
    if ~isempty(inputs.saveFile)
        save(inputs.saveFile, '-v7.3', 'features', 'canCompute');
    end
    
    % TODO parcelate at end if the respective full-feature is also required? N/S
end    


function inputs = subjectFeaturesInput(featureList, varargin)

    isfile = @(x) exist(x, 'file') == 2;

    p = inputParser();
    p.addRequired('featureList', @iscell);
    p.addParamValue('maskFile', '', isfile);
    p.addParamValue('brainSize', [], @isnumeric);
    p.addParamValue('parcFile', '', isfile);
    p.addParamValue('parcNamesFile', '', isfile);
    p.addParamValue('saveFile', '', @isstr);
    p.KeepUnmatched = true;
    p.parse(featureList, varargin{:});
    fprintf('Features: could not match %d input arguments\n', numel(fieldnames(p.Unmatched)));
    
    inputs.saveFile = p.Results.saveFile;
    inputs.featureList = p.Results.featureList;
    
    % load and process mask.
    if ~isempty(p.Results.maskFile)
        maskNii = loadNii(p.Results.maskFile);
        inputs.mask = maskNii.img > 0;
    else
        assert(~isempty(p.Results.brainSize), ...
            'Either a brainSize or a maskFile has to be specified');
        inputs.mask = true(p.Results.brainSize);
    end
    
    % process parcelation file
    if ~isempty(p.Results.parcFile)
        parcNii = loadNii(p.Results.parcFile);
        parcImg = parcNii.img;
        inputs.parcs = unique(parcImg(:));
        
        % get an image for each parcelation
        imparcs = cell(1, numel(inputs.parcs));
        for pr = 1:numel(inputs.parcs)
            imparcs{pr} = parcImg == inputs.parcs(pr);
        end
        
        inputs.parcImages = imparcs;
    end
    
    % process parcelation names file
    if isfield(p.Results,'parcNamesFile') && ~isempty(p.Results.parcNamesFile)
        fid = fopen(p.Results.parcNamesFile);
        t = textscan(fid , '%d %s');
        fclose(fid);
        ids = t{1};
        names = t{2};
        
        inputs.parcsIds2NamesMap = containers.Map(ids, names); 
    end
end
