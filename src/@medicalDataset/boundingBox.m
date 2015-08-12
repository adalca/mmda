function [croppedVol, cropMask, cropArray, bBox] = ...
        boundingBox(md, inputModality, outputModality, varargin)
    % bounding boxes

    [croppedVol, cropMask, cropArray, bBox] = ...
        md.applyfun(@boundingBoxNii, {inputModality, outputModality}, varargin{:});
end
