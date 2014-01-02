function sd = predefinedFullSite(sd)

    sd.addPredefinedRequiredModality('flairInAtlas');
    sd.addPredefinedRequiredModality('dwiInAtlas');
    sd.addPredefinedModality('flairWMCorrInAtlas');
    sd.addPredefinedModality('dwiWMCorrInAtlas');
    sd.addPredefinedModality('wmhCallInAtlas');
    sd.addPredefinedModality('leukCallInAtlas');
    
    % % FLAIR space
    sd.addPredefinedRequiredModality('flair');
    sd.addPredefinedModality('flairWMCorr');
    sd.addPredefinedModality('strokeCallInFlair');
    sd.addPredefinedModality('wmhCallInFlair');
    sd.addPredefinedModality('leukCallInFlair');
    sd.addPredefinedRequiredModality('atlasInFlair');
    sd.addPredefinedRequiredModality('labelsInFlair');
    sd.addPredefinedRequiredModality('brainMaskInFlair');
    sd.addPredefinedRequiredModality('dwiInFlair');
    sd.addPredefinedRequiredModality('wmMaskInFlair');

    % % DWI space
    sd.addPredefinedRequiredModality('dwi');
    sd.addPredefinedModality('dwiWMCorr');
    sd.addPredefinedModality('strokeCallInDwi');
    sd.addPredefinedRequiredModality('atlasInDwi');
    sd.addPredefinedRequiredModality('labelsInDwi');
    sd.addPredefinedRequiredModality('brainMaskInDwi');
    sd.addPredefinedModality('flairInDwi');
    sd.addPredefinedModality('flairInDwiWMCorr');
    sd.addPredefinedRequiredModality('wmMaskInDwi');
    sd.addPredefinedModality('strokeWithinWMInDwi');
