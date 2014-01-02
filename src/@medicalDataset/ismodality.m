function ism = ismodality(sd, modality) 
    ism = ismember(modality, {sd.modalitySpecs.modalityName});
end