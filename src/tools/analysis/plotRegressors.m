function figH = plotRegressors(X, xLabel, Y, yLabel, lineSpec, figH, varargin)
% PLOTREGRESSORS plot several regressors 
%   h = plotRegressors(X, xLabel, Y, yLabel, lineSpec, h, regName, regParams, regLineSpec, ...)
%   plots several regressors for data in X and Y. h is a figure handle, 
%   if a specific handle is to be used - otherwise just use []. 
%   lineSpec is matlab line specification (e.g. 'b.') . Below we detail the
%   regressors supported and the parameters passed:
%       
%
%   regName = 'kernel-gauss' (kernel regression with h bandwith)
%       regParams = h - the bandwith parameter for kernel regression    
%       regPlotStyle = matlab lineSpec for this regressor. 
%   regName = 'linear' (Lienar regression using polyfit)
%       regParams = empty
%       regPlotStyle = matlab lineSpec for this regressor. 
%   regName = 'glm' (generalized GLM)
%       regParams = struct with two fields:
%           glmfit = a cell array of the params to pass to glmfit
%           glmval = a cell array of the params to pass to glmval
%       regPlotStyle = matlab lineSpec for this regressor. 
%
%   returns h, the figure handle;
%
%   Example:
%   x = linspace(0, 1, 100);
%   y = exp(x)  + normrnd(0, 0.01, 1, 100);
%   plotRegressors(x, 'x', y, 'y', [], ...
%       'kernel-gauss', 0.05, 'r-', ...
%       'kernel-gauss', 0.1, 'k-', ...
%       'linear', [], 'g-', ...
%       'glm', struct('glmfit', {{'normal', 'log'}}, 'glmval', {{'log'}}), 'c-');
%   
%   Example: (stroke project)
%   plotRegressors(age, 'age', lesionBW_mean, 'Lesion Volume', ...
%       'kernel-gauss', 2, 'r-', ...
%       'kernel-gauss', 3, 'k-', ...
%       'linear', [], 'g-', ...
%       'glm', struct('glmfit', {{'normal', 'log'}}, 'glmval', {{'log'}}), 'c-');
%
%   TODO - force KSR x to be aligned with the general x
%
%   See Also: polyfit, glmfit, glmval, LineSpec



    % plot the data
    if numel(figH) == 0
        figH = figure(); clf; hold on;
    else
        figH = figure(figH); hold on;
    end
    plot(X, Y, lineSpec); 
    legendNames = {'measurements'};

    for reg = 1:3:(nargin - 6)
        x = linspace(min(X), max(X), 100);
        
        switch varargin{reg}
            case 'kernel-gauss'
                h = varargin{reg + 1};
                r = ksr(X, Y, h);
                
                plotStyle = varargin{reg + 2};
                plot(r.x, r.f, plotStyle); hold on
                title = sprintf('kernel h=%2.3f', h);
            case 'linear'
                p = polyfit(X, Y, 1);
                y = polyval(p, x);
                plotStyle = varargin{reg + 2};
                plot(x, y, plotStyle);
                title = 'linear';
                
            case 'glm'
                args = varargin{reg + 1};
                b = glmfit(X, Y, args.glmfit{:});
                yfit = glmval(b, x, args.glmval{:});
                
                whos yfit
                
                plotStyle = varargin{reg + 2};
                plot(x, yfit, plotStyle);
                
                title = ['glm-', args.glmval{1}];
                if numel(args.glmfit) > 0
                    title = [title, '-', args.glmfit{1}];
                end
                
            case 'im'
                images = varargin{reg + 1};
                coords = varargin{reg + 2};
                
                xlims = xlim();
                xdiff = (xlims(2) - xlims(1))/numel(images)/4;
                ylims = ylim();
                ydiff = (ylims(2) - ylims(1))/numel(images)/2.5;
                
                for i = 1:numel(images)
                    image(coords(i, 1) + xdiff*[-1, 1], ...
                        coords(i, 2) + ydiff*[-1, 1], ...
                        images{i});
                    colormap(gray)
                end
                title = 'images';
                
            otherwise
                error('Stroke:plotRegressors: Unknown regressor.');
        end
                
        legendNames = {legendNames{:}, title};
    end

    xlabel(xLabel);
    ylabel(yLabel);
    legend(legendNames);
end
