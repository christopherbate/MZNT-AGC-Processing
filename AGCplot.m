%----------------------------------------------------------------------------
% AGC Plot for NT1065 / Microzed
% Christopher Bate
% Adapted from Ryan's code
% Instructions: Replace "filename" with the locaiton of your AGC file.
% Actions: Plots the AGC
% Note: Default AGC sampling rate in the application is 2 Hz\
% Note: Plots pure register values, not a dB conversion
%----------------------------------------------------------------------------
function resStruct = AGCplot(inputFilename, outputFilename)
try
    filename = inputFilename;

    % Open the file and get stats
    fid = fopen(filename);
    if(fid==-1)
        disp("File not found.");
        return
    end
    fileD = dir(char(filename));
    size = fileD.bytes;
    sizeMod = mod(size,16);
    sizeAdjusted = size - mod(size,16);
    N = sizeAdjusted / 16;

    % Read in times, and register value
    times = fread(fid, N, 'uint64', 8);
    fseek(fid, 8, -1);
    regs = fread(fid, [8 N], '8*uint8', 8);
    regs = regs';
    % The first nibble in the RF agc block is the actual value.
    rfagc = bitand(regs(:,5),hex2dec('0F'));
    fclose(fid);

    L1 = regs(1:4:end,6).*2.779+1.984;
    L2 = regs(4:4:end,6);
    GLO_L1 = regs(2:4:end,6);
    GLO_L2 = regs(3:4:end,6);
    rf_L1 = rfagc(1:4:end);
    rf_L2 = rfagc(4:4:end);
    rf_GLO_L1 = rfagc(2:4:end);
    rf_GLO_L2 = rfagc(3:4:end);

    times_L1 = times(1:4:end)/1000;
    times_L2 = times(4:4:end)/1000;
    times_G1 = times(2:4:end)/1000;
    times_G2 = times(3:4:end)/1000;

    dt_L1 = datetime(times_L1,'ConvertFrom','posixtime');
    dt_L2 = datetime(times_L1,'ConvertFrom','posixtime');
    dt_G1 = datetime(times_G1,'ConvertFrom','posixtime');
    dt_G2 = datetime(times_G2,'ConvertFrom','posixtime');
    
    pltStart1 = 1;
    numPlot = length(L1)-15;
    if numPlot > 100
        pltStart1 = 100;
    end

    subplot(4,1,1);

    ylower = 5;
    yupper = 20;

    plot(dt_L1(pltStart1:numPlot),L1(pltStart1:numPlot), 'linewidth', 2);
    hold on;
    plot(dt_L1(pltStart1:numPlot),rf_L1(pltStart1:numPlot), 'linewidth', 2);
    hold off;
    title('GPS L1 AGC');
    ylabel('Levels');
    xlabel('Time');
    ylim([ylower yupper]);

    subplot(4,1,2);
    plot(dt_L2(pltStart1:numPlot),L2(pltStart1:numPlot), 'linewidth', 2);
    hold on;
    plot(dt_L2(pltStart1:numPlot),rf_L2(pltStart1:numPlot), 'linewidth', 2);
    hold off;
    title('GPS L2 AGC');
    ylabel('Levels');
    xlabel('Time');
    ylim([ylower yupper]);

    subplot(4,1,3);
    plot(dt_G1(pltStart1:numPlot),GLO_L1(pltStart1:numPlot), 'linewidth', 2);
    hold on;
    plot(dt_G1(pltStart1:numPlot),rf_GLO_L1(pltStart1:numPlot), 'linewidth', 2);
    hold off;
    title('GLO L1 AGC');
    ylabel('Levels');
    xlabel('Time');
    ylim([ylower yupper]);

    subplot(4,1,4);
    plot(dt_G2(pltStart1:numPlot),GLO_L2(pltStart1:numPlot), 'linewidth', 2);
    hold on;
    plot(dt_G2(pltStart1:numPlot),rf_GLO_L2(pltStart1:numPlot), 'linewidth', 2);
    hold off;
    title('GLO L2 AGC');
    ylabel('Levels');
    xlabel('Time');
    ylim([ylower yupper]);
    saveas(gcf,outputFilename);
    resStruct.msg = 'OK';
    return;
catch
    resStruct.msg = 'ERROR';
    return
end

end





