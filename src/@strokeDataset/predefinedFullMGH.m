function sd = predefinedFullMGH(sd)

    % Atlas Space
    sd.addPredefinedRequiredModality('flairInAtlas');
    sd.addPredefinedRequiredModality('dwiInAtlas');
    sd.addPredefinedModality('flairWMCorrInAtlas');
    sd.addPredefinedModality('dwiWMCorrInAtlas');
    sd.addPredefinedModality('wmhCallInAtlas');
    sd.addPredefinedRequiredModality('wmhRInAtlas');
    sd.addPredefinedRequiredModality('wmhLInAtlas');
    
    
    % FLAIR space
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
    sd.addPredefinedRequiredModality('wmhRInFlair');
    sd.addPredefinedRequiredModality('wmhLInFlair');
    sd.addPredefinedRequiredModality('strokeInFlair');
    sd.addPredefinedModality('wmhInFlair');

    % DWI space
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
    sd.addPredefinedModality('wmhRInDwi');
    sd.addPredefinedModality('wmhLInDwi');
    sd.addPredefinedRequiredModality('strokeInDwi');
    