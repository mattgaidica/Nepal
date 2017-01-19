subject = 'mg';
analysis = 'phase';
% channels = [13];
channels = [9;5;13];
days = 7;
startTrial = 5;

phaseBand = 1;

if strcmp(subject,'mg')
    allZData = allZDataMG_event2;
    allData = allDataMG_event2;
    allAccelData = allAccelDataMG;
else
    allZData = allZDataJC_event2;
    allData = allDataJC_event2;
    allAccelData = allAccelDataJC;
end

h1 = figure('position',[0 0 1300 650]);

for iCh = 1:size(channels,1)
    for iDay = 1:days
        subplot(size(channels,1),days,iDay + (iCh-1)*days);
        curData = allData{phaseBand,channels(iCh),iDay};
        curZData = allZData{phaseBand,channels(iCh),iDay};
        if strcmp(analysis,'phase')
            sigphase = [];
            for ii=startTrial:size(curData,1)
                y = hilbert(curData(ii,:));
    %             y = hilbert(curAccelData(ii,:));
                sigphase(ii,:) = angle(y) + pi;
                plot(sigphase(ii,:),'Color',[.2 .2 .2 .2]);
                hold on;
            end
% %             shadedErrorBar(t,mean(sigphase),std(sigphase));
            ylim([0 2*pi]);
%             xlim([-.4 .2]);
        else
            sigamp = [];
            for ii=startTrial:size(curZData,1)
                y = hilbert(curZData(ii,:));
                sigamp(ii,:) = abs(y);
                plot(sigamp(ii,:));
                hold on;
            end
            ylim([0 10]);
        end
        title(['Ch',num2str(channels(iCh)),' Day',num2str(iDay),' ',subject]);
        drawnow;
    end
end