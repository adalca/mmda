function files = predefinedAtlasFiles(~)
% PREDEFINEDATLASFILES 
%   files = predefinedAtlasFiles()
%   files = predefinedAtlasFiles(ver)
%

    if ~ispc
        atlasPath = '/path/to/atlases';
        files.atlas = fullfile(atlasPath, 'buckner61.nii.gz');
        files.brainMask = fullfile(atlasPath, 'buckner61_fixed_mask_from_seg.nii.gz');
        files.brainMaskBin = fullfile(atlasPath, 'buckner61_fixed_mask_from_seg_binary.nii.gz');
        files.labels = fullfile(atlasPath, 'buckner61_seg.nii.gz');
        files.wmMaskManual = fullfile(atlasPath, 'buckner61_seg_wm_region.nii.gz');
        files.parc = fullfile(atlasPath, 'freesurfer/buckner51/mri/wmparc.nii.gz');
        files.parcLabels = fullfile(atlasPath, 'freesurfer/buckner51/mri/wmparc_regions.txt');
    else
        atlasPath = 'C:\path\to\atlases\';
        files.atlas = fullfile(atlasPath, 'buckner61.nii.gz');
        files.brainMask = fullfile(atlasPath, 'buckner61_fixed_mask_from_seg.nii.gz');
        files.brainMaskBin = fullfile(atlasPath, 'buckner61_fixed_mask_from_seg_binary.nii.gz');
        files.labels = fullfile(atlasPath, 'buckner61_seg.nii.gz');
        files.wmMaskManual = fullfile(atlasPath, 'buckner61_seg_wm_region.nii.gz');
        files.parc = '';
        files.parcLabels = '';
    end
    