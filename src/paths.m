% external utilities
if ispc
    MIAPath = 'C:\path\to\MIA';
else
    MIAPath = '/path/to/MIA/';
end
addpath(genpath(MIAPath));

[mFolder, ~, ~] = fileparts(mfilename('fullpath'));

% just add the entire source tree
addpath(genpath(fullfile(mFolder)));
