analysis = 'deltaPhase';
subject = 'mg';

if subject == 'mg'
    allData = allDataMG_event2;
else
    allData = allDataJC_event2;
end

fs = 500;
fbandsNames = {'delta','theta','alpha','beta','gamma'};
fbands = [0.5 3.5;4 8;7.5 12.5;13 30;30 100];
channels = 1:16;
rows = 4;
days = 7;
cols = days;
phaBand = 1;
ampBands = 2:5;
bins = 51;
edges = linspace(-pi,pi,bins);
dt = datestr(now,'yyyymmddHHMM');

for iChannel = 1:length(channels)
    h1 = figure('position',[0 0 900 900]);
    for iDay = 1:days
        xPha = allData{phaBand,channels(iChannel),iDay};
        for iBand = 1:length(ampBands)
            phaPha = [];
            ampAmp = [];
            subplot(rows,cols,specifySubplot([rows cols],[iBand,iDay]));
            xAmp = allData{ampBands(iBand),channels(iChannel),iDay};
            if size(xAmp,1) ~= size(xPha,1)
                warning('trial size mismatch');
            end
            pac = [];
            for iTrial = 1:size(xPha,1)
                disp(['Trial: ',num2str(iTrial)]);
                hxPha = hilbert(xPha(iTrial,:));
                phaPha = [phaPha angle(hxPha)];
                hxAmp = hilbert(xAmp(iTrial,:));
                ampAmp = [ampAmp normalize(abs(hxAmp))];
                pac(iTrial) = pac_plv(angle(hxPha),normalize(abs(hxAmp)),fbands(phaBand,:),fbands(ampBands(iBand),:),fs);
            end
            y = [];
            for ii=1:bins-1
                idxs = find(phaPha >= edges(ii) & phaPha < edges(ii+1));
                if isempty(idxs)
                    Y(ii) = 0;
                else
                    y(ii) = mean(ampAmp(idxs));
                end
            end
            
            bar(edges(1:bins-1),y,'k','EdgeColor','k');
            xlim([-pi pi]);
            ylim([0 0.7]);
            prependStr = '';
            if iDay == 1 && iBand == 1
                prependStr = ['Ch ',num2str(channels(iChannel))];
            end
            title({prependStr,['Day ',num2str(iDay)],['PAC: ',num2str(mean(pac))]});
            
            if iDay == 1
                ylabel({[fbandsNames{ampBands(iBand)},' (',num2str(ampBands(iBand)),')'],'Normal Amp'});
            end
            if iBand == length(ampBands)
                xlabel('Phase');
            end
        end
    end
    figureName = [dt,'_','cfc_',subject,'_ch',num2str(iChannel),'_',analysis];
    savefig(h1,fullfile('figures',figureName),'compact');
%     saveas(h1,fullfile('figures',[figureName,'.png']));
    close(h1);
end
