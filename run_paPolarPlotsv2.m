subject = 'jc';
channels = [5;9;13];
days = 7;
rticks = [0 2*pi];

if strcmp(subject,'mg')
    allZData = allZDataMG_event2;
    allData = allDataMG_event2;
    allAccelData = allAccelDataMG;
else
    allZData = allZDataJC_event2;
    allData = allDataJC_event2;
    allAccelData = allAccelDataJC;
end

colormapIm = imread('/Users/mattgaidica/Documents/MATLAB/Nepal/helpers/colorscale-GYR.png');
cda = zeros(4,1000);
% cda(1:3,:) = 255*othercolor('Set13',1000)';
cda(1:3,:) = squeeze(colormapIm(1,:,:))';

for iDay = 1:7
    h1 = figure('position',[0 0 900 900]);
    curAccelData = allAccelData{1,iDay};
    
    accelSig = [];
    sigCount = 1;
    for iCh = 1:size(channels,1)
        for ii = 1:size(curAccelData,1)
            y = hilbert(curAccelData(ii,:));
            accelSig(sigCount,:) = angle(y) + pi;
            sigCount = sigCount + 1;
        end
    end

    plvAll = [];
    for iCh = 1:size(channels,1)
        curData = allData{1,channels(iCh),iDay};
        phaseSig = [];
        for ii = 1:size(curData,1)
            y = hilbert(curData(ii,:));
            phaseSig(ii,:) = angle(y);
        end
        for iSig = 1:size(curData,1)
            polarplot(accelSig(iSig,:),plvMg(phaseSig,iSig),'Color',[.5 .5 .5 .2]);
            hold on;
        end
        plvAll(iCh,:) = plvMg(phaseSig);
    end
    
    accelSigMed = median(accelSig); % must be median
    [~,accelMedIdx] = min(sum(abs(accelSig-accelSigMed),2)); % representative phase i.e. "nearest"
    
    phaseSigMean = mean(plvAll);

    p1 = polarplot(accelSig(accelMedIdx,:),phaseSigMean,'LineWidth',15);
    drawnow;
    p1.Edge.ColorBinding = 'interpolated';
    p1.Edge.ColorData = uint8(cda);
    hold on;
    polarplot(accelSigMed(500),phaseSigMean(500),'.','Color',[0/255 24/255 255/255],'MarkerSize',150);
    set(gca,'RLim',rticks,'GridLineStyle','none','ThetaTick',[],'RTick',rticks,'RTickLabel',{'';''},'RAxisLocation',45,'ThetaZeroLocation','bottom');
    set(gca,'linewidth',1,'color',[.2 .2 .2]);
    set(gcf, 'Color', 'None');
    set(gca, 'Color', 'None');
    
    figTitle = ['polarPlotv2_',subject,'-Ch',mat2str(channels),'-Day',num2str(iDay)];
%     title(figTitle);
%     onlyfig;
    saveas(h1,fullfile('figures',[figTitle,'.png']));
    close(h1);
end