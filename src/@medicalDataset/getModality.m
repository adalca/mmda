function file = getModality(obj, modality, idx)
% return the modality file for the given index.

    if numel(idx) == 1
        file = obj.files(idx).(modality);
    else
        file = {obj.files(idx).(modality)};
    end
    