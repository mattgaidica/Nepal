analysis = 'deltaPhase';
subject = 'mg';

channels = 1:16;
rows = 4;
days = 7;
cols = days;
phaBand = 1;
ampBands = 2:5;
iSubplot = 1;
bins = 51;
edges = linspace(-pi,pi,bins);
dt = datestr(now,'yyyymmddHHMM');

for iChannel = 1:length(channels)
    figure('position',[0 0 900 900]);
    for iDay = 1:days
        xPha = allData{phaBand,channels(iChannel),iDay};
        for iBand = 1:length(ampBands)
            phaPha = [];
            ampAmp = [];
            subplot(rows,cols,transposeSubplotOrder(iBand,iDay,iSubplot));
            xAmp = allData{ampBands(iBand),channels(iChannel),iDay};
            if size(xAmp,1) ~= size(xPha,1)
                warning('trial size mismatch');
            end
            for iTrial = 1:size(xDelta,1)
                hxPha = hilbert(xPha(iTrial,:));
                phaPha = [phaPha angle(hxPha)];
                hxAmp = hilbert(xAmp(iTrial,:));
                ampAmp = [ampAmp normalize(abs(ampAmp))];
            end
            y = [];
            for ii=1:bins-1
                idxs = find(phaPha >= edges(ii) & phaPha < edges(ii+1));
                y(ii) = mean(ampAmp(idxs));
            end
            bar(edges(1:bins-1),y,'k','EdgeColor','k');
            xlim([-pi pi]);
        end
    end
    figureName = [dt,'_','cfc_',subject,'_ch',num2str(iChannel),'_',analysis];
end
