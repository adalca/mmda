function plotClinicalDataset(data, SANDBOX)
% plot histograms and discrete plots from the clinical dataset DATA. 
% The plots will be displayed and saved in SANDBOX
    
    % setup input
    narginchk(1, 2);
    if nargin == 1
        SANDBOX = '/path/to/adalca/sandbox';
    end
        
    % do some histograms
    fields = get(data, 'VarNames');
    for f = 1:numel(fields)
        vec = data.(fields{f});
        if isnumeric(vec);
            h = figure();
            hist(double(vec), min(vec):max(vec));
            title(fields{f});
            saveas(h, [SANDBOX, filesep, fields{f}, '.fig']);
            saveas(h, [SANDBOX, filesep, fields{f}, '.jpg']);
        end
    end

    % some visualizations of age.
    % TODO - save in SANDBOX
    plotDiscreteDataset(data, 'Age', 'NIHSS', SANDBOX);
    plotDiscreteDataset(data, 'Age', 'FUMRS', SANDBOX);
    