function h = segstatsVolCompare(trueStats, testStats, sids)

    % get volume CC measurements
    warning('Just for correlation, assuming voxels are 1mm^3, which is probably very false');
    trueStats.callVolumesCC = trueStats.callVolumes / 1000;
    testStats.callVolumesCC = testStats.callVolumes / 1000;

    % make a figure with large font
    h = figure();
    axes1 = axes('Parent', h, 'FontSize', 18);
    
    % make a scatter or log/log plot
    % scatter(wmhTest.callVolumes, wmhTrain.callVolumes);
    loglog(trueStats.callVolumesCC, testStats.callVolumesCC, '.'); hold on;
    axis equal;
    
    % plot a line to help give perspective
    maxvol = max([trueStats.callVolumesCC(:); testStats.callVolumesCC(:)]);
    minvol = min([trueStats.callVolumesCC(trueStats.callVolumesCC>0); testStats.callVolumesCC(testStats.callVolumesCC>0)]);
    lin = linspace(minvol, maxvol*1.01, 100);
    plot(lin, lin, '-r');
    axis([0, maxvol*1.01, 0, maxvol*1.01]);
    xlabel('Expert Volume (cc)', 'FontSize', 16)
    ylabel('Automatic Volume (cc)', 'FontSize', 16)
    
    % print out volumes in CC
    testCC = num2cell(testStats.callVolumesCC);
    trueCC = num2cell(trueStats.callVolumesCC);
    printcell = [sids, testCC, trueCC]'; % 
    fprintf(1, 'subject_id, automatic_cc, manual_cc\n');
    fprintf(1, '%10s, %10.5f, %10.5f\n', printcell{:});
    