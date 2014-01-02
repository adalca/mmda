function c = buildPredefinedModalityMap(ver)
% BUILDPREDEFINEDMODALITYMAP build a modalityName -> modalityPath map for the stroke project
%   c = buildPredefinedModalityMap() build a modalityName -> modalityPath map for the stroke project
%       for modalities that are usually used. These can serve like a quick and useful lookup but
%       should not limit the ability to add other modalities as usual. 
%   c = buildPredefinedModalityMap(ver) similar, but allows for the specification of versions 
%       of the map for when naming might change. Not in use right now.
%
% See also: addPredefinedModality, addPredefinedRequiredModality
%   
% Project: Analysis of clinical datasets
% Authors: Adrian Dalca, Ramesh Sridharan
% Contact: {adalca,rameshvs}@csail.mit.edu
    

    if nargin == 0
        ver = 2;
    end

    c = containers.Map;

    switch ver
        case 2
            % buckner space
            c('flairInAtlas') = 'images/%s_flair_img_prep_pad_IN_RIGID_MI32_MASKEDNONLINEAR_GAUSS_9000_0200__201x201x201_CC4__buckner61-.nii.gz';
            c('dwiInAtlas') = 'images/%s_dwi_img_prep_pad_IN_RIGID_MI32_MASKEDNONLINEAR_GAUSS_9000_0200__201x201x201_CC4__buckner61-.nii.gz';
            c('flairWMCorrInAtlas') = 'images/%s_flair_img_prep_pad_IN_RIGID_MI32_MASKEDNONLINEAR_GAUSS_9000_0200__201x201x201_CC4__buckner61-MATLAB_WM_corr2.nii.gz';
            c('dwiWMCorrInAtlas') = 'images/%s_dwi_img_prep_pad_IN_RIGID_MI32_MASKEDNONLINEAR_GAUSS_9000_0200__201x201x201_CC4__buckner61-MATLAB_WM_corr2.nii.gz';
            c('wmhCallInAtlas') = 'images/%s_flair_wmh_CALL_prep_pad-MATLAB_WM_corr_IN_RIGID_MI32_MASKEDNONLINEAR_GAUSS_9000_0200__201x201x201_CC4__buckner61-.nii.gz';
            c('wmhLInAtlas') = 'images/%s_flair_wmh_L_prep_pad_IN_RIGID_MI32_MASKEDNONLINEAR_GAUSS_9000_0200__201x201x201_CC4__buckner61-.nii.gz';
            c('wmhRInAtlas') = 'images/%s_flair_wmh_R_prep_pad_IN_RIGID_MI32_MASKEDNONLINEAR_GAUSS_9000_0200__201x201x201_CC4__buckner61-.nii.gz';
            c('wmhInAtlas') = 'images/%s_flair_wmh_prep_pad_IN_RIGID_MI32_MASKEDNONLINEAR_GAUSS_9000_0200__201x201x201_CC4__buckner61-.nii.gz';
            c('strokeInAtlas') = 'images/%s_dwi_roi_prep_pad_IN_RIGID_MI32_MASKEDNONLINEAR_GAUSS_9000_0200__201x201x201_CC4__buckner61-.nii.gz';
            c('strokeCallInAtlas') = 'images/%s_dwi_lesion_CALL_prep_pad-MATLAB_WM_corr_IN_RIGID_MI32_MASKEDNONLINEAR_GAUSS_9000_0200__201x201x201_CC4__buckner61-.nii.gz';
            c('leukCallInAtlas') = 'images/%s_flair_leuk_CALL_prep_pad-MATLAB_WM_corr_IN_RIGID_MI32_MASKEDNONLINEAR_GAUSS_9000_0200__201x201x201_CC4__buckner61-.nii.gz';

            % % FLAIR space
            c('flair') = 'images/%s_flair_img_prep_pad.nii.gz';
            c('flairWMCorr') = 'images/%s_flair_img_prep_pad-MATLAB_WM_corr.nii.gz';
            c('strokeCallInFlair') = 'images/%s_dwi_lesion_CALL_prep_pad-MATLAB_WM_corr_IN_RIGID_MI32_MASKEDRIGID_MI32_MASKED_%s_flair_img_prep_pad-.nii.gz';
            c('wmhCallInFlair') = 'images/%s_flair_wmh_CALL_prep_pad-MATLAB_WM_corr.nii.gz';
            c('leukCallInFlair') = 'images/%s_flair_leuk_CALL_prep_pad-MATLAB_WM_corr.nii.gz';
            c('atlasInFlair') = 'images/buckner61_IN_NONLINEAR_GAUSS_9000_0200__201x201x201_CC4_RIGID_MI32_MASKED_%s_flair_img_prep_pad-.nii.gz';
            c('labelsInFlair') = 'images/buckner61_seg_IN_NONLINEAR_GAUSS_9000_0200__201x201x201_CC4_RIGID_MI32_MASKED_%s_flair_img_prep_pad-.nii.gz';
            c('brainMaskInFlair') = 'images/buckner61_fixed_mask_from_seg_binary_IN_NONLINEAR_GAUSS_9000_0200__201x201x201_CC4_RIGID_MI32_MASKED_%s_flair_img_prep_pad-.nii.gz';
            c('dwiInFlair') = 'images/%s_dwi_img_prep_pad_IN_RIGID_MI32_MASKEDRIGID_MI32_MASKED_%s_flair_img_prep_pad-.nii.gz';
            c('strokeInFlair') = 'images/%s_dwi_roi_prep_pad_IN_RIGID_MI32_MASKEDRIGID_MI32_MASKED_%s_flair_img_prep_pad-.nii.gz';
            c('wmMaskInFlair') = 'images/buckner61_seg_wm_region_IN_NONLINEAR_GAUSS_9000_0200__201x201x201_CC4_RIGID_MI32_MASKED_%s_flair_img_prep_pad-.nii.gz';
            c('wmhRInFlair') = 'images/%s_flair_wmh_R_prep_pad.nii.gz';
            c('wmhLInFlair') = 'images/%s_flair_wmh_L_prep_pad.nii.gz';
            c('wmhInFlair') = 'images/%s_flair_wmh_LR_prep_pad.nii.gz';
            % c('wmMaskInFlair') = 'images/buckner61_seg_wmh_IN_NONLINEAR_GAUSS_9000_0200__201x201x201_CC4_RIGID_MI32_MASKED_%s_flair_img_prep_pad-.nii.gz';

            % % DWI space
            c('dwi') = 'images/%s_dwi_img_prep_pad.nii.gz';
            c('dwiWMCorr') = 'images/%s_dwi_img_prep_pad-MATLAB_WM_corr.nii.gz';
            c('strokeInDwi') = 'images/%s_dwi_roi_prep_pad.nii.gz';
            c('strokeCallInDwi') = 'images/%s_dwi_lesion_CALL_prep_pad-MATLAB_WM_corr.nii.gz';
            c('atlasInDwi') = 'images/buckner61_IN_NONLINEAR_GAUSS_9000_0200__201x201x201_CC4_RIGID_MI32_MASKED_%s_dwi_img_prep_pad-.nii.gz';
            c('labelsInDwi') = 'images/buckner61_seg_IN_NONLINEAR_GAUSS_9000_0200__201x201x201_CC4_RIGID_MI32_MASKED_%s_dwi_img_prep_pad-.nii.gz';
            c('brainMaskInDwi') = 'images/buckner61_fixed_mask_from_seg_binary_IN_NONLINEAR_GAUSS_9000_0200__201x201x201_CC4_RIGID_MI32_MASKED_%s_dwi_img_prep_pad-.nii.gz';
            c('flairInDwi') = 'images/%s_flair_img_prep_pad_IN_RIGID_MI32_MASKEDRIGID_MI32_MASKED_%s_dwi_img_prep_pad-.nii.gz';
            c('flairInDwiWMCorr') = 'images/%s_flair_img_prep_pad_IN_RIGID_MI32_MASKEDRIGID_MI32_MASKED_%s_dwi_img_prep_pad-MATLAB_WM_corr.nii.gz';
            c('wmMaskInDwi') = 'images/buckner61_seg_wm_region_IN_NONLINEAR_GAUSS_9000_0200__201x201x201_CC4_RIGID_MI32_MASKED_%s_dwi_img_prep_pad-.nii.gz';
            c('strokeWithinWMInDwi') = 'images/%s_dwi_roi_prep_pad_INTERSECT_buckner61_seg_wm.nii.gz';
            c('wmhRInDwi') = 'images/%s_flair_wmh_R_prep_pad_IN_RIGID_MI32_MASKED_%s_dwi_img_prep_pad-.nii.gz';
            c('wmhLInDwi') = 'images/%s_flair_wmh_L_prep_pad_IN_RIGID_MI32_MASKED_%s_dwi_img_prep_pad-.nii.gz';
            % c('strokeCallInDwi') = 'images/%s_dwi_roi_CALL_prep_pad.nii.gz';
            % c('wmMaskInDwi') = 'images/buckner61_seg_wmh_IN_NONLINEAR_GAUSS_9000_0200__201x201x201_CC4_RIGID_MI32_MASKED_%s_dwi_img_prep_pad-.nii.gz';

            % T1 Space
            c('t1') = 'images/%s_t1_img_prep_bcorr.nii.gz';
            c('atlasMaskInRigidT1') = 'images/buckner61_fixed_mask_from_seg_binary_binary_IN_RIGID_MI32__%s_t1_img_prep_bcorr-.nii.gz';

            % % temporaries
            % c('tmpDoubleFlair') = 'images/%s_tmpDoubleFlair.nii.gz';
            % c('tmpDoubleMask') = 'images/%s_tmpDoubleMask.nii.gz';
            
        case 1
            % buckner space
            c('flairInAtlas') = 'images/%s_flair_img_prep_pad_IN_RIGID_MI32_MASKEDNONLINEAR_GAUSS_45_05__201x201x201_CC4__buckner61-.nii.gz';
            c('dwiInAtlas') = 'images/%s_dwi_img_prep_pad_IN_RIGID_MI32_MASKEDNONLINEAR_GAUSS_45_05__201x201x201_CC4__buckner61-.nii.gz';
            c('flairWMCorrInAtlas') = 'images/%s_flair_img_prep_pad_IN_RIGID_MI32_MASKEDNONLINEAR_GAUSS_45_05__201x201x201_CC4__buckner61-MATLAB_WM_corr2.nii.gz';
            c('dwiWMCorrInAtlas') = 'images/%s_dwi_img_prep_pad_IN_RIGID_MI32_MASKEDNONLINEAR_GAUSS_45_05__201x201x201_CC4__buckner61-MATLAB_WM_corr2.nii.gz';
            c('wmhCallInAtlas') = 'images/%s_flair_wmh_CALL_prep_pad-MATLAB_WM_corr_IN_RIGID_MI32_MASKEDNONLINEAR_GAUSS_45_05__201x201x201_CC4__buckner61-.nii.gz';
            c('wmhLInAtlas') = 'images/%s_flair_wmh_L_prep_pad_IN_RIGID_MI32_MASKEDNONLINEAR_GAUSS_45_05__201x201x201_CC4__buckner61-.nii.gz';
            c('wmhRInAtlas') = 'images/%s_flair_wmh_R_prep_pad_IN_RIGID_MI32_MASKEDNONLINEAR_GAUSS_45_05__201x201x201_CC4__buckner61-.nii.gz';
            c('wmhInAtlas') = 'images/%s_flair_wmh_prep_pad_IN_RIGID_MI32_MASKEDNONLINEAR_GAUSS_45_05__201x201x201_CC4__buckner61-.nii.gz';
            c('strokeInAtlas') = 'images/%s_dwi_roi_prep_pad_IN_RIGID_MI32_MASKEDNONLINEAR_GAUSS_45_05__201x201x201_CC4__buckner61-.nii.gz';
            c('strokeCallInAtlas') = 'images/%s_dwi_lesion_CALL_prep_pad-MATLAB_WM_corr_IN_RIGID_MI32_MASKEDNONLINEAR_GAUSS_45_05__201x201x201_CC4__buckner61-.nii.gz';
            c('leukCallInAtlas') = 'images/%s_flair_leuk_CALL_prep_pad-MATLAB_WM_corr_IN_RIGID_MI32_MASKEDNONLINEAR_GAUSS_45_05__201x201x201_CC4__buckner61-.nii.gz';

            % % FLAIR space
            c('flair') = 'images/%s_flair_img_prep_pad.nii.gz';
            c('flairWMCorr') = 'images/%s_flair_img_prep_pad-MATLAB_WM_corr.nii.gz';
            c('strokeCallInFlair') = 'images/%s_dwi_lesion_CALL_prep_pad-MATLAB_WM_corr_IN_RIGID_MI32_MASKEDRIGID_MI32_MASKED_%s_flair_img_prep_pad-.nii.gz';
            c('wmhCallInFlair') = 'images/%s_flair_wmh_CALL_prep_pad-MATLAB_WM_corr.nii.gz';
            c('leukCallInFlair') = 'images/%s_flair_leuk_CALL_prep_pad-MATLAB_WM_corr.nii.gz';
            c('atlasInFlair') = 'images/buckner61_IN_NONLINEAR_GAUSS_45_05__201x201x201_CC4_RIGID_MI32_MASKED_%s_flair_img_prep_pad-.nii.gz';
            c('labelsInFlair') = 'images/buckner61_seg_IN_NONLINEAR_GAUSS_45_05__201x201x201_CC4_RIGID_MI32_MASKED_%s_flair_img_prep_pad-.nii.gz';
            c('brainMaskInFlair') = 'images/buckner61_fixed_mask_from_seg_IN_NONLINEAR_GAUSS_45_05__201x201x201_CC4_RIGID_MI32_MASKED_%s_flair_img_prep_pad-.nii.gz';
            c('dwiInFlair') = 'images/%s_dwi_img_prep_pad_IN_RIGID_MI32_MASKEDRIGID_MI32_MASKED_%s_flair_img_prep_pad-.nii.gz';
            c('strokeInFlair') = 'images/%s_dwi_roi_prep_pad_IN_RIGID_MI32_MASKEDRIGID_MI32_MASKED_%s_flair_img_prep_pad-.nii.gz';
            c('wmMaskInFlair') = 'images/buckner61_seg_wm_region_IN_NONLINEAR_GAUSS_45_05__201x201x201_CC4_RIGID_MI32_MASKED_%s_flair_img_prep_pad-.nii.gz';
            c('wmhRInFlair') = 'images/%s_flair_wmh_R_prep_pad.nii.gz';
            c('wmhLInFlair') = 'images/%s_flair_wmh_L_prep_pad.nii.gz';
            c('wmhInFlair') = 'images/%s_flair_wmh_LR_prep_pad.nii.gz';
            % c('wmMaskInFlair') = 'images/buckner61_seg_wmh_IN_NONLINEAR_GAUSS_45_05__201x201x201_CC4_RIGID_MI32_MASKED_%s_flair_img_prep_pad-.nii.gz';

            % % DWI space
            c('dwi') = 'images/%s_dwi_img_prep_pad.nii.gz';
            c('dwiWMCorr') = 'images/%s_dwi_img_prep_pad-MATLAB_WM_corr.nii.gz';
            c('strokeInDwi') = 'images/%s_dwi_roi_prep_pad.nii.gz';
            c('strokeCallInDwi') = 'images/%s_dwi_lesion_CALL_prep_pad-MATLAB_WM_corr.nii.gz';
            c('atlasInDwi') = 'images/buckner61_IN_NONLINEAR_GAUSS_45_05__201x201x201_CC4_RIGID_MI32_MASKED_%s_dwi_img_prep_pad-.nii.gz';
            c('labelsInDwi') = 'images/buckner61_seg_IN_NONLINEAR_GAUSS_45_05__201x201x201_CC4_RIGID_MI32_MASKED_%s_dwi_img_prep_pad-.nii.gz';
            c('brainMaskInDwi') = 'images/buckner61_fixed_mask_from_seg_IN_NONLINEAR_GAUSS_45_05__201x201x201_CC4_RIGID_MI32_MASKED_%s_dwi_img_prep_pad-.nii.gz';
            c('flairInDwi') = 'images/%s_flair_img_prep_pad_IN_RIGID_MI32_MASKEDRIGID_MI32_MASKED_%s_dwi_img_prep_pad-.nii.gz';
            c('flairInDwiWMCorr') = 'images/%s_flair_img_prep_pad_IN_RIGID_MI32_MASKEDRIGID_MI32_MASKED_%s_dwi_img_prep_pad-MATLAB_WM_corr.nii.gz';
            c('wmMaskInDwi') = 'images/buckner61_seg_wm_region_IN_NONLINEAR_GAUSS_45_05__201x201x201_CC4_RIGID_MI32_MASKED_%s_dwi_img_prep_pad-.nii.gz';
            c('strokeWithinWMInDwi') = 'images/%s_dwi_roi_prep_pad_INTERSECT_buckner61_seg_wm.nii.gz';
            c('wmhRInDwi') = 'images/%s_flair_wmh_R_prep_pad_IN_RIGID_MI32_MASKED_%s_dwi_img_prep_pad-.nii.gz';
            c('wmhLInDwi') = 'images/%s_flair_wmh_L_prep_pad_IN_RIGID_MI32_MASKED_%s_dwi_img_prep_pad-.nii.gz';
            % c('strokeCallInDwi') = 'images/%s_dwi_roi_CALL_prep_pad.nii.gz';
            % c('wmMaskInDwi') = 'images/buckner61_seg_wmh_IN_NONLINEAR_GAUSS_45_05__201x201x201_CC4_RIGID_MI32_MASKED_%s_dwi_img_prep_pad-.nii.gz';

            % T1 Space
            c('t1') = 'images/%s_t1_img_prep_bcorr.nii.gz';
            c('atlasMaskInRigidT1') = 'images/buckner61_fixed_mask_from_seg_binary_IN_RIGID_MI32__%s_t1_img_prep_bcorr-.nii.gz';

            % % temporaries
            % c('tmpDoubleFlair') = 'images/%s_tmpDoubleFlair.nii.gz';
            % c('tmpDoubleMask') = 'images/%s_tmpDoubleMask.nii.gz';
            
        otherwise 
            error('unknown version');
    end