%----------------------------------------------------------------------------
% AGC Plot for NT1065 / Microzed
% Christopher Bate
% Adapted from Ryan's code
% Instructions: Replace "filename" with the locaiton of your AGC file.
% Actions: Plots the AGC
% Note: Default AGC sampling rate in the application is 2 Hz\
% Note: Plots pure register values, not a dB conversion
%----------------------------------------------------------------------------
function resStruct = AGCplot(inputFilename, outputFilename,timezone)

if(nargin==2)
    timezone = 'America/Denver';
end

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
    
    L1 = regs(1:4:end,6)*2.779+1.9864;
    L2 = regs(4:4:end,6)*2.779+1.9864;
    GLO_L1 = regs(2:4:end,6)*2.779+1.9864;
    GLO_L2 = regs(3:4:end,6)*2.779+1.9864;
%     rf_L1 = rfagc(1:4:end);
%     rf_L2 = rfagc(4:4:end);
%     rf_GLO_L1 = rfagc(2:4:end);
%     rf_GLO_L2 = rfagc(3:4:end);

    times_L1 = times(1:4:end)/1000;
    times_L2 = times(4:4:end)/1000;
    times_G1 = times(2:4:end)/1000;
    times_G2 = times(3:4:end)/1000;

    dt_L1 = datetime(times_L1,'ConvertFrom','posixtime','TimeZone',timezone);
    dt_L2 = datetime(times_L2,'ConvertFrom','posixtime','TimeZone',timezone);
    dt_G1 = datetime(times_G1,'ConvertFrom','posixtime','TimeZone',timezone);
    dt_G2 = datetime(times_G2,'ConvertFrom','posixtime','TimeZone',timezone);
    
    pltStart1 = 1;
    numPlot = length(L1);
    if numPlot > 100
        pltStart1 = 100;
    end

    xlimits = [min(dt_L1(pltStart1:numPlot)) max(dt_L1(pltStart1:numPlot))];
    
    position = [0.1 0.7 0.8 0.2];
    subplot('Position',position);
    plot(dt_L1(pltStart1:numPlot),L1(pltStart1:numPlot), 'linewidth', 2);
    grid on;
    ylower = min(L1)-2;
    yupper = max(L1)+2;
    ylim([ylower yupper]);
    xlim(xlimits);
    %xticks([]);
    set(gca,'Xticklabel',[]);
    %hold on;
    %plot(dt_L1(pltStart1:numPlot),rf_L1(pltStart1:numPlot), 'linewidth', 2);
    %hold off;
    title(['GPS L1, Avg: ',num2str(mean(L1)),', Mode: ',num2str(mode(L1)),...
        ', Min: ',num2str(min(L1))]);
    ylabel('Levels');
    %xlabel('Time');
   
    
    position = [0.1 0.5 0.8 0.2];
    subplot('Position',position);
    plot(dt_L2(pltStart1:numPlot),L2(pltStart1:numPlot), 'linewidth', 2);
    grid on;
    %xticks([]);
    %hold on;
    %plot(dt_L2(pltStart1:numPlot),rf_L2(pltStart1:numPlot), 'linewidth', 2);
    %hold off;
    title(['GPS L2, Avg: ',num2str(mean(L2)),', Mode: ',num2str(mode(L2)),...
        ', Min: ',num2str(min(L2))]);
    set(gca,'Xticklabel',[]);
    ylabel('Levels');
    %xlabel('Time');
    ylower = min(L2)-2;
    yupper = max(L2)+2;
    xlim(xlimits);
    ylim([ylower yupper]);

    position = [0.1 0.3 0.8 0.2];
    subplot('Position',position);
    plot(dt_G1(pltStart1:numPlot),GLO_L1(pltStart1:numPlot), 'linewidth', 2);
    grid on;
    set(gca,'Xticklabel',[]);
    %hold on;
    %plot(dt_G1(pltStart1:numPlot),rf_GLO_L1(pltStart1:numPlot), 'linewidth', 2);
    %hold off;
    title(['GLO L1, Avg: ',num2str(mean(GLO_L1)),', Mode: ',num2str(mode(GLO_L1)),...
        ', Min: ',num2str(min(GLO_L1))]);
    ylabel('Levels');
    %xlabel('Time');
    ylower = min(GLO_L1)-2;
    yupper = max(GLO_L1)+2;
    xlim(xlimits);
    ylim([ylower yupper]);

    position = [0.1 0.1 0.8 0.2];
    subplot('Position',position);
    plot(dt_G2(pltStart1:numPlot),GLO_L2(pltStart1:numPlot), 'linewidth', 2);    
    grid on;
%     hold on;
%     plot(dt_G2(pltStart1:numPlot),rf_GLO_L2(pltStart1:numPlot), 'linewidth', 2);
%     hold off;
    title(['GLO L2, Avg: ',num2str(mean(GLO_L2)),', Mode: ',num2str(mode(GLO_L2)),...
        ', Min: ',num2str(min(GLO_L2))]);
    ylabel('Levels');
    xlabel('Time');
    ylower = min(GLO_L2)-2;
    yupper = max(GLO_L2)+2;
    ylim([ylower yupper]);
    xlim(xlimits);
    saveas(gcf,outputFilename);
    resStruct.msg = 'OK';
    return;
catch
    resStruct.msg = 'ERROR';
    return
end

end





