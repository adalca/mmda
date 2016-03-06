function files2folders(srcpath, regex, dstpath)
% FILES2FOLDERS copy files from single folder to folder structured for medicalDataset()
%   files2folders(srcpath, regex, dstpath) copy files from original single folder srcpath to a
%   folder that will be structured for medicalDataset. regex, a regular expression, will determine 
%   how the files will be broken down into the hierarchy. 
%
%   Best illustrated by an example:
%   We have subject files subj1.nii.gz, subj1_seg.nii.gz, subj2.nii.gz, subj2_seg.nii.gz, etc
%   in folder /data/original. We want to prepare these files for the medicalDataset() folder 
%   structure, and put them in /data/md. In folder /data/original we also have some extra, files
%   that are not useful for us here, like 'data_summary.txt'.
% 
%   Running:
%   >> medicalDataset.files2folders('/data/original', 'subj\d*', '/data/md');
%
%   We get the output:
%   Skipped .
%   Skipped ..
%   Skipped data_summary.txt
%   
%   And we'll have the following folder structure:
%   /data/md/subj1/subj1.nii.gz
%   /data/md/subj1/subj1_seg.nii.gz
%   /data/md/subj1/subj2.nii.gz
%   /data/md/subj1/subj2_seg.nii.gz
%   ...
%
%   See also: medicalDataset
%
%   Author: adalca@mit
    
    % process inputs
    narginchk(3, 3);
    if ~isdir(dstpath)
        mkdir(dstpath);
    end

    % get the files that match the regexp
    d = dir(srcpath);
    [regstarts, regends] = regexp({d.name}, regex);
    match = find(~cellfun(@isempty, regstarts));
    
    % compute the filenames and the unique file names (which will be our folders)
    fn = @(x, s, e) x(s:e);
    fnames = cellfunc(fn, {d(match).name}, regstarts(match), regends(match));
    ufnames = unique(fnames);
    
    % iterate over the new folders.
    vi = verboseIter(ufnames);
    while vi.hasNext();
        foldername = vi.next();

        % get filenames
        idx = strcmp(fnames, foldername{1});
        files = {d(match(idx)).name};
        
        % set up destination
        dst = fullfile(dstpath, foldername{1});
        ifelse(~isdir(dst), 'mkdir(dst)', '''''', true);
        
        % copy files
        success = cellfun(@(x) copyfile(fullfile(srcpath, x), dst), files);
        assert(all(success), 'Copy of file %s failed', files{find(~success, 1)});
        
    end
    vi.close();

    % output skipped values
    nonmatchidx = find(cellfun(@isempty, regstarts));
    for i = nonmatchidx
        fprintf(2, 'Skipped %s\n', d(i).name);
    end
