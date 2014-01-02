function dumpFolder = visualizeOutput(title, pageMsg, varargin)
%
% Example:
%   vols = {'dwiOrig', 'dwiOrigWMCorr', 'wmMaskInDwi', 'lesionCallinDwi', 'lesioninDwiWithinWM', 'flairOrig'}
%   method1 = {'modalityList', sd, 217, vols, 1, 'wmMaskInDwi'};
%   method2 = {'modalityStack', sd, 217, vols, 2, 'wmMaskInDwi'};
%   method3 = {'Figure'
%   folder = visualizeOutput('Run #239', 'Blah description', method1, method2);
%
%
% TODO - careful with implementation    
%   TOADD - possibility make some volumes masks, so that it's outlined!!!

    
    
    % some constants
    STROKE_VIS_FOLDER = '/afs/csail.mit.edu/u/a/adalca/public_html/stroke/vis/';
    WEB_FOLDER = 'http://people.csail.mit.edu/adalca/stroke/vis/';
    
    % prepare the folder names
    folder = tempname;
    dumpFolder = [STROKE_VIS_FOLDER, folder];
    fprintf(1, 'Folder created: %s\n', dumpFolder);
    webFolder = [WEB_FOLDER, folder];
    mkdir(dumpFolder);
    
    % prepare the html files
    htmlFile = [dumpFolder, '/index.html'];
    webHtmlFile = [webFolder, '/index.html'];
    
    % open the html file
    htmlfid = fopen(htmlFile, 'w');
    assert(htmlfid > 0);
    fprintf(htmlfid, '<h1>%s</h1>\n', title);
    fprintf(htmlfid, '<p>%s</p>\n', pageMsg);
    
    
    
    % method string output - every method gets to write something (short) to the main html page entry
    nMethods = numel(varargin);
    methods = cell(nMethods, 1);
    methodStr = cell(nMethods, 1);
    for m = 1:nMethods
        v = varargin{m};
        method = v{1};
        methods{m} = method;
        methodArgs = {v{2:end}};
        switch method
            case 'modalityList'
                sd = methodArgs{1};
                subjIds = methodArgs{2};  % can be several subject ids
                vols = methodArgs{3};     % can be several modality names as given by sd
                assert(numel(vols) > 0);
                resampleFactor = methodArgs{4};
                
                % get width, height of jpg and slices to print
                % WARNING: using first subjIds to determine which slices
                %   get shown to EVERYONE!
                if numel(methodArgs) == 5
                    [slices, width, height] = getSlicesInfo(sd, subjIds(1), methodArgs{5});
                else
                    [width, height, nSlices] = getWH(sd, subjIds(1), vols{1});
                    slices = 1:nSlices;
                end
                width = width * resampleFactor;
                height = height * resampleFactor;
                
                args = {'outputNameing', 'sequence', 'resample', resampleFactor};
                
                % printing for this method:
                fprintf(htmlfid, '<h2> ModalityList </h2>');
                fprintf(htmlfid, 'Subjects:');
                for s = 1:numel(subjIds)
                    fprintf(htmlfid, '%i:<i>%s</i>', subjIds(s), sd.sids{subjIds(s)});
                end
                fprintf(htmlfid, '<br /> \n');
                fprintf(htmlfid, 'modalities: ');
                for v = 1:numel(vols)
                    fprintf(htmlfid, ' <i>%s</i> ', vols{v});
                end    
                fprintf(htmlfid, '<br /> \n');
                
                % write the tipix iframes
                for v = 1:numel(vols)
                    dumpDatasetVol(htmlfid, webFolder, dumpFolder, sd, vols{v}, subjIds, find(slices)', width, height, args{:})
                end
               
                % write the upper-level html file string
                
                methodStr{m} = sprintf('Subjects:');
                for s = 1:numel(subjIds)
                    methodStr{m} = sprintf('%s%i:<i>%s</i>', methodStr{m}, subjIds(s), sd.sids{subjIds(s)});
                end
                
                
                
            case 'modalityStack'
                sd = methodArgs{1};
                mi = methodArgs{2};
                vols = methodArgs{3};     % can be several modality names as given by sd
                assert(numel(vols) > 0);
                resampleFactor = methodArgs{4};
                
                % get width, height of jpg and slices to print
                if numel(methodArgs) == 5
                    [slices, width, height] = getSlicesInfo(sd, mi, methodArgs{5});
                else
                    [width, height, nSlices] = getWH(sd, mi, vols{1});
                    slices = 1:nSlices;
                end
                width = width * resampleFactor;
                height = height * resampleFactor;
                
                args = {'outputNameing', 'sequence', 'resample', resampleFactor};
                
                fprintf(htmlfid, '<h2> ModalityStack </h2>');
                fprintf(htmlfid, 'Subject #%i:<i>%s</i> <br/> \n', mi, sd.sids{mi});
                fprintf(htmlfid, 'modalities: ');
                for v = 1:numel(vols)
                    fprintf(htmlfid, ' <i>%s</i> ', vols{v});
                end    
                fprintf(htmlfid, '<br /> \n');
                
                for v = 1:numel(vols);
                    vol = vols{v};
                    folder = sprintf('%s/ModalityStack-%s_%i.jpg', dumpFolder, '%i', v);
                    nii2jpg(sd.files(mi).(vol), folder, 'slices', find(slices)', args{:});
                end
                
                filename = [webFolder, '/ModalityStack-$_$.jpg'];
                fprintf(htmlfid, tipixStr(filename, sum(slices), numel(vols), width, height));   
                
                methodStr{m} = sprintf('subject: %d <i>%s</i>', mi, sd.sids{mi});
                
            case 'maskedVolumes'
                % TODO_BETTER note: if want to use mask instead of two
                % modalities, use second vol as mask file 
                sd = methodArgs{1};
                mi = methodArgs{2};
                vols = methodArgs{3};     % can be several modality names as given by sd
                assert(numel(vols) == 2);
                resampleFactor = methodArgs{4};
                
                % get width, height of jpg and slices to print
                if numel(methodArgs) == 5
                    [slices, width, height] = getSlicesInfo(sd, mi(1), methodArgs{5});
                else
                    [width, height, nSlices] = getWH(sd, mi(1), vols{1});
                    slices = 1:nSlices;
                end
                width = width * resampleFactor;
                height = height * resampleFactor;
                
                args = {'outputNameing', 'sequence', 'resample', resampleFactor};
                
                fprintf(htmlfid, '<h2> maskOverlap </h2>');
                fprintf(htmlfid, 'Subjects:');
                for s = 1:numel(mi)
                    fprintf(htmlfid, '%i:<i>%s</i>', mi(s), sd.sids{mi(s)});
                end
                fprintf(htmlfid, '<br /> \n');
                fprintf(htmlfid, 'modalities: ');
                for v = 1:numel(vols)
                    fprintf(htmlfid, ' <i>%s</i> ', vols{v});
                end    
                fprintf(htmlfid, '<br /> \n');
                
               
                % if second volume is mask, jus tload once
                useMask = false;
                v = vols{2};
                if exist(v, 'file') == 2
                    nii2File = v;
                    useMask = true;
                end
                
                
                for s = 1:numel(mi)
                            
                    nii1File = sd.files(mi(s)).(vols{1});
                    if ~useMask
                        nii2File = sd.files(mi(s)).(vols{2});
                    end
                    
                    folder = sprintf('%s/maskoverlap-%s_%i.jpg', dumpFolder, '%i', s);
                    argsLocal = [args, 'maskFile', nii2File, 'maskStyle', 'contour'];
                    nii2jpg(nii1File, folder, 'slices', find(slices)', argsLocal{:});
                end
                
                filename = [webFolder, '/maskoverlap-$_$.jpg'];
                fprintf(htmlfid, tipixStr(filename, sum(slices), numel(mi), width, height));   
                
                methodStr{m} = sprintf('maskOverlap');

            case 'volumes'
                % TODO_BETTER note: if want to use mask instead of two
                % modalities, use second vol as mask file 
                sd = methodArgs{1};
                mi = methodArgs{2};
                vols = methodArgs{3};     % can be several modality names as given by sd
                assert(numel(vols) == 1);
                resampleFactor = methodArgs{4};
                
                % get width, height of jpg and slices to print
                if numel(methodArgs) == 5
                    [slices, width, height] = getSlicesInfo(sd, mi(1), methodArgs{5});
                else
                    [width, height, nSlices] = getWH(sd, mi(1), vols{1});
                    slices = 1:nSlices;
                end
                width = width * resampleFactor;
                height = height * resampleFactor;
                
                args = {'outputNameing', 'sequence', 'resample', resampleFactor};
                
                fprintf(htmlfid, '<h2> maskOverlap </h2>');
                fprintf(htmlfid, 'Subjects:');
                for s = 1:numel(mi)
                    fprintf(htmlfid, '%i:<i>%s</i>', mi(s), sd.sids{mi(s)});
                end
                fprintf(htmlfid, '<br /> \n');
                fprintf(htmlfid, 'modalities: ');
                for v = 1:numel(vols)
                    fprintf(htmlfid, ' <i>%s</i> ', vols{v});
                end    
                fprintf(htmlfid, '<br /> \n');
                                
                for s = 1:numel(mi)
                            
                    nii1File = sd.files(mi(s)).(vols{1});
                    folder = sprintf('%s/vol-%s_%i.jpg', dumpFolder, '%i', s);
                    argsLocal = [args];
                    nii2jpg(nii1File, folder, 'slices', find(slices)', argsLocal{:});
                end
                
                filename = [webFolder, '/vol-$_$.jpg'];
                fprintf(htmlfid, tipixStr(filename, sum(slices), numel(mi), width, height));   
                
                methodStr{m} = sprintf('Volume');
                
            case 'rgoverlap'
                % TODO_BETTER note: if want to use mask instead of two
                % modalities, use second vol as mask file 
                sd = methodArgs{1};
                mi = methodArgs{2};
                vols = methodArgs{3};     % can be several modality names as given by sd
                assert(numel(vols) == 2);
                resampleFactor = methodArgs{4};
                
                % get width, height of jpg and slices to print
                if numel(methodArgs) == 5
                    [slices, width, height] = getSlicesInfo(sd, mi(1), methodArgs{5});
                else
                    [width, height, nSlices] = getWH(sd, mi(1), vols{1});
                    slices = 1:nSlices;
                end
                width = width * resampleFactor;
                height = height * resampleFactor;
                
                args = {'outputNameing', 'sequence', 'resample', resampleFactor};
                
                fprintf(htmlfid, '<h2> R/G Modality Overlap </h2>');
                fprintf(htmlfid, 'Subjects:');
                for s = 1:numel(mi)
                    fprintf(htmlfid, '%i:<i>%s</i>', mi(s), sd.sids{mi(s)});
                end
                fprintf(htmlfid, '<br /> \n');
                fprintf(htmlfid, 'modalities: ');
                for v = 1:numel(vols)
                    fprintf(htmlfid, ' <i>%s</i> ', vols{v});
                end    
                fprintf(htmlfid, '<br /> \n');
                
                
                tmpNiiName = [tempname, '.nii.gz'];
                
                % if second volume is mask, jus tload once
                useMask = false;
                v = vols{2};
                if exist(v, 'file') == 2
                    nii2 = loadNii(v);
                    useMask = true;
                end
                
                
                for s = 1:numel(mi)
                            
                    nii1 = loadNii(sd.files(mi(s)).(vols{1}));
                    if ~useMask
                        nii2 = loadNii(sd.files(mi(s)).(vols{2}));
                    end
                    nii3 = nii1;
                    if size(nii3.img, 5) == 1
                        nii3.img = repmat(nii3.img, [1, 1, 1, 1, 3]);
                    end
                    
                    %normalize by 95 percentile
                    r = double(nii1.img);
                    p = prctile(r(:), 99);
                    r(r > p) = p;
                    r = r / p;
                    
                    g = double(nii2.img);
                    p = prctile(g(:), 99);
                    g(g > p) = p;
                    g = g / p;
                    
                    nii3.img(:,:,:, 1, 1) = r*255;
                    nii3.img(:,:,:, 1, 2) = g*255;
                    nii3.img(:,:,:, 1, 3) = nii3.img(:,:,:, 1, 2) * 0;
                    
                    folder = sprintf('%s/rgoverlap-%s_%i.jpg', dumpFolder, '%i', s);
                    nii2jpg(nii3, folder, 'slices', find(slices)', args{:});
                end
                
                filename = [webFolder, '/rgoverlap-$_$.jpg'];
                fprintf(htmlfid, tipixStr(filename, sum(slices), numel(mi), width, height));   
                
                methodStr{m} = sprintf('r/g');
                
            case 'figures'
                fprintf(htmlfid, '<h2> Figures </h2>');
                for hi = 1:numel(methodArgs)
                    h = methodArgs{hi};
                    fname = sprintf('figure_%d.png', hi);
                    fprintf(htmlfid, sprintf('<img src="%s/%s"> <br /> \n', webFolder, fname));
                    saveas(h, sprintf('%s/%s', dumpFolder,fname));
                end
                
                methodStr{m} = sprintf('');
        end
            
            
            
    end
            
    % close html fid
    fclose(htmlfid);
   
    % main entry
    mainfid = fopen([STROKE_VIS_FOLDER, '/index.html'], 'a');
    fprintf(mainfid, '<li><a href="%s">%s</a> %s<br />\n', webHtmlFile, datestr(now), title);
    fprintf(mainfid, '\tMethods: <ul>\n');
    for m = 1:nMethods
        fprintf(mainfid, '\t\t<li>%s (%s)</li>\n', methods{m}, methodStr{m});
    end
    fprintf(mainfid, '\t</ul>\n');
    fprintf(mainfid, '</li> <br />\n');
    fclose(mainfid);
            

end

function tstr = tipixStr(filename, yBins, xBins, width, height)
    tipixCmd = 'http://www.mit.edu/~adalca/tipiX/';

    tstr = sprintf('<iframe src="%s?path=%s&xBins=%d&nDims=2&yBins=%d&iframe=%dx%d"  width="%dpx" height="%dpx" frameborder="0"></iframe>\n', ...
        tipixCmd, filename, xBins, yBins, width, height, width, height);
end



function [slices, width, height] = getSlicesInfo(sd, mi, vol)

    % first, get all slices for which the mask is non-zero
    [width, height, nSlices, wmNii] = getWH(sd, mi, vol);
    slices = false(nSlices, 1);
    for i = 1:nSlices
        slice = wmNii.img(:,:,i);
        slices(i) = sum(slice(:)) > 0;
    end
end

function [width, height, nSlices, wmNii] = getWH(sd, mi, vol)
    if exist(vol, 'file')
        wmNii = loadNii(vol);
    else
        wmNii = loadNii(sd.files(mi).(vol));
    end
    width = size(wmNii.img, 2);
    height = size(wmNii.img, 1);
    nSlices = size(wmNii.img, 3);
end

function dumpDatasetVol(htmlfid, webFolder, dumpFolder, sd, vol, subjNrs, sliceNrs, width, height, varargin)
    fnameRoot = sprintf('%s/%s_%s_%s.jpg', dumpFolder, vol, '%s', '%i');
    dataset2jpg(sd, vol, fnameRoot, 'order', subjNrs, 'slices', sliceNrs, varargin{:});
    fnameRoot = sprintf('%s/%s_%s_%s.jpg', webFolder, vol, '$', '$');
    fprintf(htmlfid, tipixStr(fnameRoot, numel(sliceNrs), numel(subjNrs), width, height));
end


