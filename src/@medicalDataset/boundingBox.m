function [croppedVol, cropMask, cropArray, bBox] = ...
        boundingBox(md, inputModality, outputModality, varargin)
    % bounding boxes

    mods = {inputModality};
    if nargin > 2 && ~isempty(outputModality)
        mods = {inputModality, outputModality};
    end
    
    [croppedVol, cropMask, cropArray, bBox] = ...
        md.applyfun(@boundingBoxNii, mods, varargin{:});
end
