function varargout = applyfun(md, fn, mods, varargin)
    
    if ~iscell(mods)
        mods = {mods};
    end
    
    % transform images to be from 0 to 1
    subset = md.subjectSubset(varargin{:});
    vi = verboseIter(subset, true, funcname(1));

    % go through the volumes
    varargout = cell(1, nargout);
    while vi.hasNext()
        [s, i] = vi.next();
        
        % transform volume
        files = cell(numel(mods), 1);
        for m = 1:numel(mods)
            files{m} = md.getModality(mods{m}, s);
        end
        
        % apply function
        if nargout == 0
            fn(files{:});
        else
            v = cell(1, nargout);
            [v{:}] = fn(files{:});
            for n = 1:nargout
                varargout{n}{i} = v{n};
            end
        end
    end
    vi.close()
end
