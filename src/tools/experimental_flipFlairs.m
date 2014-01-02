% experimental_flipFlairs


%% new 12/19

sd.addModality('leukCallInFlairFlip', 'images/%s_flair_leuk_CALL_prep_pad-MATLAB_WM_corr_flip.nii.gz');
sd.addModality('flairWMCorrFlip', 'images/%s_flair_img_prep_pad-MATLAB_WM_corr_flip.nii.gz');
sd.build(paths.PROCESSING, [], {});

%%
subset = sd.subjectSubset(args{:});
vi = verboseIter(subset, sd.verbose);
while vi.hasNext()
    [s, i] = vi.next();
    
    nii = loadNii(sd.getModality('leukCallInFlair', s));
    
    % flip ud/lr
    nii.img = flipdim(nii.img, 1);
    nii.img = flipdim(nii.img, 2);
    sd.saveModality(nii, 'leukCallInFlairFlip', s);
    
    
    
    nii = loadNii(sd.getModality('flairWMCorr', s));
    
    % flip ud/lr
    nii.img = flipdim(nii.img, 1);
    nii.img = flipdim(nii.img, 2);
    sd.saveModality(nii, 'flairWMCorrFlip', s);
end

vi.close();