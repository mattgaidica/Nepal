subject = 'mg';
analysis = 'accel';
channels = [5];
% channels = [9;5;13];
days = 7;
startTrial = 2;
fs = 500;
t = linspace(-1,1,1000);
fontSize = 26;
plotMarkers = true;

phaseBand = 1;

if strcmp(subject,'mg')
    allZData = allZDataMG_event2;
    allData = allDataMG_event2;
    allAccelData = allAccelDataMG;
    allTrials = allTrialsMG;
else
    allZData = allZDataJC_event2;
    allData = allDataJC_event2;
    allAccelData = allAccelDataJC;
    allTrials = allTrialsJC;
end

% h1 = figure('position',[0 0 1300 650]);

for iCh = 1:size(channels,1)
    for iDay = 1:days
%         subplot(size(channels,1),days,iDay + (iCh-1)*days);
        h1 = figure('position',[0 0 600 600]);
        curData = allData{phaseBand,channels(iCh),iDay};
        curZData = allZData{phaseBand,channels(iCh),iDay};
        curTrialData = allTrials{iDay};
        switch analysis
            case 'phase'
                sigphase = [];
                for ii=startTrial:size(curData,1)
                    y = hilbert(curData(ii,:));
        %             y = hilbert(curAccelData(ii,:));
                    sigphase(ii,:) = angle(y) + pi;
                    plot(t,sigphase(ii,:),'Color',[0 0 0 .4]);
                    hold on;
                end
                ylim([0 2*pi]);
                yticks([0 pi 2*pi]);
                trialRange = linspace(0,2*pi,length(curTrialData));
            case 'amp'
                sigamp = [];
                for ii=startTrial:size(curZData,1)
                    y = hilbert(curZData(ii,:));
                    sigamp(ii,:) = abs(y);
                    plot(t,sigamp(ii,:),'Color',[0 0 0 .4]);
                    hold on;
                end
                ylim([0 10]);
                yticks([0 5 10]);
                ylabel('Z-score');
                trialRange = linspace(0,10,length(curTrialData));
            case 'accel'
                sigaccel = [];
                curAccelData = allAccelData{1,iDay};
                for ii=startTrial:size(curAccelData,1)
                    sigaccel(ii,:) = curAccelData(ii,:);
                    plot(t,sigaccel(ii,:),'Color',[0 0 0 .4]);
                    hold on;
                end
                ylim([-500 500]);
                trialRange = linspace(-400,400,length(curTrialData));
        end
        if plotMarkers
%                 plot([0 0],[0 2*pi],'r--'); % ball
            for iTrial = 1:length(curTrialData)
                trial = curTrialData{1,iTrial};
                plot((trial.locs(1)-trial.locs(2))/fs,trialRange(iTrial),'g.','MarkerSize',12);
                plot((trial.locs(3)-trial.locs(2))/fs,trialRange(iTrial),'r.','MarkerSize',12);
            end
        end
            
        xticks([0]);
        xlim([-1 1]);
        xlabel('Time (s)');
        set(gca,'fontsize',fontSize);
        figureTitle = ['Ch',num2str(channels(iCh)),'-Day',num2str(iDay),'-',analysis,'-',subject];
        title(figureTitle);
        
        drawnow;
        set(gca,'position',[0 0 1 1],'units','normalized');
        saveas(h1,fullfile('figures',[figureTitle,'.eps']),'epsc');
        close(h1);
    end
end