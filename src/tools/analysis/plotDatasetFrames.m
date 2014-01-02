function plotDatasetFrames(allFrames, frameNr, subjIds)
% plot a specific frame for several subjects in several subplots. 
% allFrames is 4D (H, W, nFrames, nIdx)
% frameNr is the frame nr in the 3rd dim
% subjIds, optional, is an array of subject ids (for printing titles)
    
    % figure initiate
    hc = figure('units', 'pixels', 'outerposition', [0 0 1500 800]);
    nSubPlotRows = ceil(sqrt(numel(order)));
    
    for idx = 1:size(allFrames, 4)
        frame = allFrames(:,:,frameNr, idx);

         % plot frame
        figure(hc);
        subplot(nSubPlotRows, nSubPlotRows, idx); 
        imshow(frame); 

        % title, if given
        if exist('subjIds', 'var')
            title(subjIds{idx});
        end
        
    end
