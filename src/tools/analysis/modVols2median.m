function m = modVols2median(vols)
% vols should be nSubjects x nModalities
% in median, we'll do a median subject-wise (for each voxel) after summing modality-wise

    % clean aggVol in caller to make space for [revols{:}];
    evalin('caller', 'clear aggVol');

    if size(vols, 2) > 1
        revols = cell(1, numel(vols));
        for i = 1:numel(vols)
            revols{i} = sum([vols{i, :}], 2);
            vols{i, :} = [];
        end

        m = median([revols{:}], 2);
    else
        m = median([vols{:}], 2);
    end
