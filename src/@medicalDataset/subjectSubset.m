function subsetIdx = subjectSubset(obj, varargin)
% SUBJECTSUBSET obtain a subset of subjects from various inclusion/exclusion rules. 
%
%   s.subjectSubset() returns the subject of desired subjects, in this case (no inputs) all of the
%   subjects (i.e. 1:s.getNumSubjects);
%
%   s.subjectSubset(ruleName, ruleParam, ...) use the given rules to return a subset of subjects
%
% Rules:
%   'include' - a vector of subject indexes to include. The default is everyone. 
%   'exclude' - a vector of subject indexes to exclude. The default is none.
%   'includeIds' - a cell array of subject ids to include. The default is everyone. 
%   'excludeIds' - a cell array of subject ids to exclude. The default is none. 
%   'decide' - if a subject is both included and excluded, decide on 'include' or 'exclude'. 
%       default is 'include'.
%
%   Example:
%   subset = s.subjectSubset('include', [3, 4, 5, 6], 'excludeSids', {'subj2013_6', 'subj2013_7'}) ;
%       if idx 6 maps to subject ID 'subj2013_6', then 
%
%   TODOs: maybe use inputParser? problem with the fact that we don't want 1:N to be the default
%       inclusion, but rather 1:N \ excludedIdx. Whereas if you have an intersection in the included
%       and excluded voxels, we may decide to keep them or not depending on 'decide' param. Also,
%       careful: we want to allow other parameters (which we don't use) for ease of use of this
%       function

    warning('Maybe combine subjectSubset() with fileSubset()?');

    % check that the files have been parsed
    assert(obj.parsed, 'Files have not been (re)parsed yet!');
    
    % get explicit includes
    include = false;
    includeIdx = [];
    f = find(strcmp('include', varargin));
    if numel(f) > 0
        assert(numel(f) == 1);
        include = true;
        idx = varargin{f+1};
        includeIdx = [includeIdx; idx];
    end
    
    f = find(strcmp('includeIds', varargin));
    if numel(f) > 0
        assert(numel(f) == 1);
        include = true;
        idx = ids2idx(obj, varargin{f+1});
        includeIdx = [includeIdx; idx];
    end
    
    % get explicit excludes
    excludeIdx = [];
    f = find(strcmp('exclude', varargin));
    if numel(f) > 0
        assert(numel(f) == 1);
        idx = varargin{f+1};
        excludeIdx = [excludeIdx; idx];
    end
    
    f = find(strcmp('excludeIds', varargin));
    if numel(f) > 0
        assert(numel(f) == 1);
        idx = ids2idx(obj, varargin{f+1});
        excludeIdx = [excludeIdx; idx];
    end 
        
    % if not given anything to include, include all but the excluded idx
    if ~include
        includeIdx = 1:obj.getNumSubjects;
        includeIdx = setdiff(includeIdx, excludeIdx);
    end
    
    % union
    f = find(strcmp('decide', varargin));
    if numel(f) > 0
        assert(numel(f) == 1);
        priority = varargin{f+1};
    else
        priority = 'include';
    end
    
    % exclude any intersecting indexes
    int = intersect(includeIdx, excludeIdx);
    if strcmp(priority, 'exclude')
        warning('%d subjects were in both the include and exclude sets', numel(int));
        includeIdx = setDiff(includeIdx, int);
    end
    
    % return
    subsetIdx = includeIdx;
end
