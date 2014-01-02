function sd = predefined(type, mainPath, varargin)
% PREDEFINED construct a predefined strokeDataset;
%   sd = predefined(type, mainPath) construct a predefined strokeDataset of the given type;
%   mainPath is the subjectPath of build(). If mainPath is empty, the sd will not be built, but will
%   be constructed and returned
%
%   available types:
%       flairManual
%       dwiManual
%       fullMGH
%       fullSite
%       ManualInAtlas
%
%   sd = predefined(type, mainPath, param1, value1, ...) allows for extra parameters:
%
%   param/value pairs
%       saveFile - a file to save the sd to
%       verbose - logical
%       loadFile - if present, will load sd instead of constructing it. 
%       origStrokeDataset - initial structure if not loading
%       params
%           any fields and values you want to pass to the strokeDataset obj directly 
%           (e.g. verbose, overwrite, etc)
%
%
%   TODO: allow for specifying modalities directly
%   TODO: allow for clinical data support.
%
% Project: Analysis of clinical datasets
% Authors: Adrian Dalca, Ramesh Sridharan
% Contact: {adalca,rameshvs}@csail.mit.edu
    
    % parse inputs
    p = inputParser();
    p.addParamValue('saveFile', '', @isstr);
    p.addParamValue('loadFile', '', @isstr);
    p.addParamValue('verbose', true, @islogical);
    p.addParamValue('origStrokeDataset', []);
    p.addParamValue('params', struct(), @isstruct);
    p.parse(varargin{:});
    inputs = p.Results;
    verbose = inputs.verbose;
    if isempty(inputs.verbose)
        verbose = true;
    end
    loadSD = ~isempty(inputs.loadFile);
    saveSD = ~isempty(inputs.saveFile);
    initialized = ~isempty(inputs.origStrokeDataset);
    build = ~isempty(mainPath);
    
    % load sd
    if loadSD
        loadtic = tic;
        loadedsd = load(inputs.loadFile, 'sd');
        sd = loadedsd.sd;
        verbose && fprintf('Loaded sd from file in %3.2f sec\n', toc(loadtic)); %#ok<VUNUS>
        
    % or initialize for build
    else
        
        if initialized
            sd = inputs.origStrokeDataset;
        else
            sd = strokeDataset(1);
        end
        
        % construct using the given type
        if ~isempty(type)
            fh = str2func(['strokeDataset.predefined', type]);
            sd = fh(sd);
        end
    end
    
    % fill any other fieldnames
    fields = fieldnames(inputs.params);
    for f = 1:numel(fields)
        field = fields{f};
        sd.(field) = inputs.params.(field);
    end
    
    % finally, build
    if build && ~loadSD
        assert(~isfield(inputs.params, 'verbose') || isempty(inputs.verbose));
        sd.build(mainPath, [], {}, verbose);
        
        if saveSD
            save(inputs.saveFile, 'sd');
        end
    end
