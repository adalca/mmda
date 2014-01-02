function [volbase, volpath, clinicalpath] = predefinedSite(site, ~)

    % make sure site is numeric
    if isnumeric(site);
        site = num2str(site);
    end

    % get base paths
    if ~ispc
        volbase = '/path/to/processed_datasets';
        clinicalbase = '/path/to/clinical_data/Phenotypic Data_4_17_2013.xls';
    else
        volbase = 'C:\path\to\local_test\';
        clinicalbase = '';
    end


    % paths and clinical paths for each site.
    switch site
        case 'MGH'
            volspec = '2013_05_16';
            volspec = '2013_12_13/site00';
            clinicalspec = 'Phenotypic Data_4_17_2013.xls';
        case '18'
            volspec = '2013_11_07';
            clinicalspec = '';
        case '16'
            volspec = fullfile('2013_12_16', 'site16');
            clinicalspec = '';
        otherwise
            error('unknown site');
    end
    
    % final vol path for site
    volpath = fullfile(volbase, volspec);
    
    % final clinical path for site
    clinicalpath = fullfile(clinicalbase, clinicalspec);
end
