function plotDiscreteDataset(data, indepField, depField, savepath)
% plots dataset dep vs indep (discrete) variables with count-weighted scatter and imagesc
%   plotDiscreteDataset(data, indepField, depField) plots the dataset data with
%   (string) fields indepField and depField. Specifically, it plots a 
%   discrete data.(indepField) against data.(depField) (which gets binned). Since 
%   the independent variable is discrete, each possible point will have an
%   occurance count, which in the plot is represented as the size of the marker.
%   Also outputs a axised imagesc, where intensity of pixel is based on count at
%   each point.
%
%   TODOs: 
%       - normalize the size of the marker somehow wrt dataset.
%       - make the binning of X a parameter
%       - add save-to-filepath capabilities
%
%   Example:
%       % load file into dataset with VarNames 'Age' and 'Height'
%       data = dataset('XLSFile', datafile); 
%   
%       % create 2 useful plots
%       plotDiscreteDataset(data, 'Age', 'Height'); 
%
%   Contact: Stroke project, http://www.mit.edu/~adalca/stroke/ 



    % check inputs
    narginchk(4, 4);
    X = data.(indepField);
    Y = data.(depField);
    saveName = fullfile(savepath, [indepField, 'vs', depField]);

    % exclude entries with -1
    goodIdx = X >= 0 & Y >= 0;
    X = X(goodIdx);
    Y = Y(goodIdx);
    rX = round(X); % TODO bin in N bins, make N param

    % plot the circles proportional
    h = figure(); hold on;
    rangeX = min(rX):max(rX);
    histC = zeros(numel(rangeX), max(Y) + 1);
    meanY = zeros(numel(rangeX), 1);

    % for each X value, build a histogram of the Y values and use the values of the
    % histogram for the size of the Marker
    for i = 1:numel(rangeX)

        % get histogram
        histC(i, :) = hist(Y(rX == rangeX(i)), 0:max(Y));

        % for each point, draw a circle with the size proportional to the count
        for j = 0:max(Y)
            if histC(i, j+1) > 0
                plot(rangeX(i), j, 'o', ...
                    'MarkerSize', histC(i, j+1) * 2, ...
                    'MarkerFaceColor', [0.9, 0.9, 1], ...
                    'LineWidth',1); 
                hold on;
            end
        end

        meanY(i) = mean(Y(rX == rangeX(i)));
    end

    % plot the Y mean on top
    g = plot(rangeX, meanY, 'r.-', 'MarkerSize', 10);
    axis([rangeX(1), rangeX(end), 0, max(Y)]);
    xlabel(indepField);
    ylabel(depField);
    legend(g, 'mean');
    saveas(h, [saveName, '_plot', '.fig']);
    saveas(h, [saveName, '_plot', '.jpg']);

    % do a similar graph, but using imagesc instead of plotting circles of different sizes
    h = figure(); hold on;
    imagesc((histC')); colormap(gray); colorbar
    plot(1:numel(rangeX), meanY+1, 'r.-', 'MarkerSize', 10);
    set(gca,'xtick', 1:5:numel(rangeX), 'XTickLabel', rangeX(1):5:rangeX(end)); 
    set(gca,'ytick', 1:5:max(Y)+1, 'YTickLabel', 0:5:max(Y)); 
    axis image
    xlabel(indepField);
    ylabel(depField);
    saveas(h, [saveName, '_imagesc', '.fig']);
    saveas(h, [saveName, '_imagesc', '.jpg']);
