function idx = ids2idx(obj, ids)
% IDS2IDX transform subject IDs to indexes from the medicalDataset.
%   idx = ids2idx(md, ids) transform subject ids ,a cell array of strings, to indexes from
%       the medicalDataset md.

    if ischar(ids)
        ids = {ids};
    end

    idx = nan(numel(ids), 1);
    for i = 1:numel(ids)
        f = find(strcmp(ids{i}, obj.sids));
        if numel(f) == 0
            warning('ids2idx: could not find subject %s', ids{i});
            continue;
        else
            assert(numel(f) == 1, ...
                'Found more than one match for subject id %s. Something is wrong.', ids{i});
        end
        idx(i) = f;
    end
    
    idx(isnan(idx)) = [];
    