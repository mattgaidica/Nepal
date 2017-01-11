spo2MG = [89 99 99 92 91 97 97];
spo2JC = [99 97 97 94 97 98 98];
altitude = [2860 2630 2350 2920 4130 2310 1780];
ascent = [1320 -230 -280 570 1210 -1820 -530];

% --- ENV VARIABLES START ---
subject = 'jc';
allZData = allZDataJC;
spo2 = spo2JC;
% --- ENV VARIABLES END ---

winSeconds = 1;
fs = 500;
winSamples = winSeconds * fs;
t = linspace(-winSeconds,winSeconds,winSamples*2);

fbandsNames = {'delta','theta','alpha','beta','gamma'};
days = 7;
cols = days+3;
rows = 4;
channels = 1:16;

zInt_r2table = [];
r2Count = 1;
clear h1;
dt = datestr(now,'yyyymmddHHMM');
for iBand = 1:length(fbandsNames)
    for iChannel = 1:length(channels)
        zInt = [];
        modChRow = mod(iChannel-1,rows);
        if modChRow == 0
            if exist('h1','var')
                savefig(h1,fullfile('figures',figureName));
                close(h1);
            end
            h1 = figure('position',[0 0 1100 900]);
            figureName = [dt,'_','bandChannelScatters_',subject,'_',fbandsNames{iBand},'_ch',num2str(iChannel)];
            newFig = 1;
        else
            newFig = 0;
        end
        for iDay = 1:days
            iSubplot = modChRow * cols + iDay;
            subplot(rows,cols,iSubplot);
            curZData = allZData{iBand,iChannel,iDay};
            zMean = mean(curZData);
            zErr = std(curZData);
            zMeanEnv = mean(abs(curZData'),2) - min(mean(abs(curZData'),2));
            shadedErrorBar(t,zMean',zErr');
            hold on;
            plot(t,zMeanEnv,'Linewidth',3,'color','r');
            if newFig && iDay == 1
                title({fbandsNames{iBand},['Day',num2str(iDay),' Ch',num2str(iChannel)]});
            else
                title({'',['Day',num2str(iDay),' Ch',num2str(iChannel)]});
            end
            ylim([-7 7]);
            zInt(iDay) = trapz(zMeanEnv);
        end
        
        zInt_r2table(r2Count,1) = iBand;
        zInt_r2table(r2Count,2) = iChannel;
        
        subplot(rows,cols,iSubplot+1);
        scatter(zInt,altitude,25,'k','*');
        lsline;
        [f,gof] = fit(zInt',altitude','poly1');
        rsq = round(gof.rsquare,3);
        title({'Alt vs EnvInt',['r2: ',num2str(rsq)]});
        zInt_r2table(r2Count,3) = rsq;
        
        subplot(rows,cols,iSubplot+2);
        scatter(zInt,ascent,25,'k','*');
        lsline;
        [f,gof] = fit(zInt',ascent','poly1');
        rsq = round(gof.rsquare,3);
        title({'Asc vs EnvInt',['r2: ',num2str(rsq)]});
        zInt_r2table(r2Count,4) = rsq;
        
        subplot(rows,cols,iSubplot+3);
        scatter(zInt,spo2,25,'k','*');
        lsline;
        [f,gof] = fit(zInt',spo2','poly1');
        rsq = round(gof.rsquare,3);
        title({'SpO2 vs EnvInt',['r2: ',num2str(rsq)]});
        zInt_r2table(r2Count,5) = rsq;
        
        r2Count = r2Count + 1;
    end
end
% handle last figure
savefig(h1,fullfile('figures',figureName));
close(h1);

csvwrite(fullfile('figures',[dt,'_zInt_r2table_',subject,'.csv']),zInt_r2table);