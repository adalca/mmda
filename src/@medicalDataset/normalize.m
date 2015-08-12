function normalize(md, inputModality, normVal, outputModality, varargin)
    % TODO combine with linearEqualization, etc. Have one function for normalizing images in one of
    % several ways.

    md.applyfun(@(x, y) normalizeNii(x, y, normVal), {inputModality, outputModality}, varargin{:});
end



