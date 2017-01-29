subject = 'jc';
% channels = [13];
channels = [5];
days = 7;
rticks = [0 2*pi];
plotXcorr = false;
startTrial = 1;

phaseBand = 1;
ampBand = 1;

if subject == 'mg'
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

h1polar = figure('position',[0 0 1300 650]);
if plotXcorr
    h1corr = figure('position',[0 0 1300 650]);
end

for iCh = 1:size(channels,1)
    for iDay = 1:days
        figure(h1polar);
        subplot(size(channels,1),days,iDay + (iCh-1)*days);
        curAccelData = allAccelData{1,iDay};

        curData = allData{phaseBand,channels(iCh),iDay};
        curZData = allZData{phaseBand,channels(iCh),iDay};
        sigphase = [];
        for ii=startTrial:size(curData,1)
            y = hilbert(curAccelData(ii,:));
            sigphase(ii,:) = angle(y) + pi;
        end
        sigphaseMean = mean(sigphase);
        
        curData = allData{ampBand,channels(iCh),iDay};
        curZData = allZData{ampBand,channels(iCh),iDay};
        sigamp = [];
        for ii=startTrial:size(curData,1)
            y = hilbert(curData(ii,:));
            sigamp(ii,:) = angle(y);
        end
        
        for iSig = 1:size(sigamp,1)
            polarplot(sigphase(iSig,:),plvMg(sigamp,iSig),'Color',[0 0 0 .05]);
            hold on;
        end
        sigampMean = plvMg(sigamp);%mean(sigamp);
        
        p1 = polarplot(sigphaseMean,sigampMean,'LineWidth',3);
        drawnow;
        p1.Edge.ColorBinding = 'interpolated';
        p1.Edge.ColorData = uint8(cda);
        hold on;
        polarplot(sigphaseMean(500),sigampMean(500),'.','Color','g','MarkerSize',30);
        set(gca,'RLim',rticks,'GridLineStyle','none','ThetaTick',[0 90 180 270],'RTick',...
            rticks,'RTickLabel',{'0';['Z = ',num2str(rticks(2))]},'RColor',[.25 .25 .25],'RAxisLocation',45,'ThetaZeroLocation','bottom');
        title(['Ch',num2str(channels(iCh)),' Day',num2str(iDay),' ',subject]);
        
        if plotXcorr
            figure(h1corr);
            subplot(size(channels,1),days,iDay + (iCh-1)*days);
            [acor,lag] = xcorr(mean(sigphase),mean(sigamp));
            plot(lag,acor);
            ylim([0 5000]);
            title(['Ch',num2str(channels(iCh)),' Day',num2str(iDay),' ',subject]);
        end
    end
end
% suptitle(subject);