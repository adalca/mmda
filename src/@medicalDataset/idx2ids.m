function sids = idx2ids(obj, idx)

    if islogical(idx)
        assert(numel(idx) == obj.getNumSubjects, ...
            'Size of idx (%i) doesn''t match th enumebr of subjects (%i) ', ...
            numel(idx), obj.getNumSubjects);
    else
        assert(max(idx) <= obj.getNumSubjects, ...
            'Largest IDX (%i) is larger than nr of subjects (%i)', ...
            max(idx), obj.getNumSubjects);
    end

    sids = obj.sids(idx);
end