function spec = getModalitySpecs(obj, modality)

    f = strcmp(modality, {obj.modalitySpecs.modalityName});
    spec = obj.modalitySpecs(f);