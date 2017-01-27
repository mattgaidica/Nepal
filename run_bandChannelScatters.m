spo2MG = [89 99 99 92 91 97 97];
spo2JC = [99 97 97 94 97 98 98];
altitude = [2860 2630 2350 2920 4130 2310 1780];
ascent = [1320 -230 -280 570 1210 -1820 -530];

% --- ENV VARIABLES START ---
analysis = 'phase';
subject = 'mg';
% --- ENV VARIABLES END ---

if subject == 'mg'
    allZData = allZDataMG_event2;
    allData = allDataMG_event2;
    allAccelData = allAccelDataMG;
    spo2 = spo2MG;
else
    allZData = allZDataJC_event2;
    allData = allDataJC_event2;
    allAccelData = allAccelDataJC;
    spo2 = spo2JC;
end

fontSize = 6;
winSeconds = 1;
fs = 500;
winSamples = winSeconds * fs;
t = linspace(-winSeconds,winSeconds,winSamples*2);

% channels = 1:16;
channels = [5:8];
% fbandsNames = {'delta','theta','alpha','beta','gamma'};
fbandsNames = {'delta'};
days = 7;
cols = days+1;
rows = 5;
chPerFigure = 4;
chCount = 1;

r2table = [];
r2Count = 1;
clear h1;
dt = datestr(now,'yyyymmddHHMM');
for iBand = 1:length(fbandsNames)
    ax = [];
    for iChannel = 1:length(channels)
        fitData = [];
        for iDay = 1:days
            if chCount == 1 && iDay == 1
                h1 = figure('position',[0 0 1100 900]);
            end
            ax(chCount,iDay) = subplot(rows,cols,specifySubplot([rows cols],[chCount,iDay]));
            curData = allData{iBand,channels(iChannel),iDay};
            curZData = allZData{iBand,channels(iChannel),iDay};
            zMean = mean(curZData);
            zErr = std(curZData);
            
            switch analysis
                case 'amplitude'
                    % not sure about subtracting the min value, but keeps it
                    % zero-based
                    sigamp = [];
                    for ii=1:size(curZData,1)
                        y = hilbert(curZData(ii,:));
                        sigamp(ii,:) = abs(y);
                    end
% %                     zMeanEnv = mean(abs(curZData'),2) - min(mean(abs(curZData'),2));
                    shadedErrorBar(t,zMean',zErr');
                    sigampMean = mean(sigamp);
                    % maybe this should be built into compileData.m
                    sigampCorr = sigampMean - mean(sigampMean(1:100)); % corrected
                    shadedErrorBar(t,sigampCorr,std(sigamp));
                    hold on;
                    plot(t,sigampCorr,'Linewidth',3,'color','r');
                    ylim([-7 7]);
                    fitData(iDay) = mean(abs(sigampCorr));
                case 'peak2peak'
                    % !!! needs work
                    fitData(iDay) = peak2peak(zMean);
                case 'phase'
                    sigphase = [];
                    for ii=1:size(curData,1)
                        y = hilbert(curData(ii,:));
                        sigphase(ii,:) = angle(y);
                    end
                    shadedErrorBar(t,mean(sigphase),std(sigphase));
% %                     absPhase = abs(mean(sigphase));
% %                     hold on; plot(t,absPhase,'color','r');
% %                     zAnalysis(iDay) = trapz(absPhase);
                    plvVector = plvMg(sigphase);
                    hold on; plot(t,plvVector,'color','r');
                    fitData(iDay) = mean(plvVector(50:end-50));
                    ylim([-pi pi]);
                otherwise
                    warning('invalid analysis');
            end
            
            if chCount == 1 && iDay == 1
                title({[subject,' ',num2str(iBand),': ',fbandsNames{iBand}],['Day',num2str(iDay),', Ch',num2str(channels(iChannel))]},'FontSize',fontSize);
            else
                title({'',['Day',num2str(iDay),', Ch',num2str(channels(iChannel))]},'FontSize',fontSize);
            end
            grid on;
            if iDay == 1
                ylabel('Z');
            end
        end
        
        r2table(r2Count,1) = iBand;
        r2table(r2Count,2) = iChannel;
        
        subplot(rows,cols,specifySubplot([rows cols],[chCount,iDay])+1);
        scatter(fitData,altitude,25,'k','*');
        lsline;
        [f,gof] = fit(fitData',altitude','poly1');
        rsq = round(gof.rsquare,3);
        rmse = round(gof.rmse,3);
        lm = fitlm(fitData',altitude','linear');
        pVal = lm.Coefficients{2,4};
        title({['Alt vs ',analysis],['r2: ',num2str(rsq),' p: ',num2str(pVal)],['rmse: ',num2str(rmse)]},'FontSize',fontSize);
        r2table(r2Count,3) = rsq;
        r2table(r2Count,4) = pVal;
        r2table(r2Count,5:5+days-1) = fitData;
        
% %         subplot(rows,cols,iSubplot+2);
% %         scatter(zAnalysis,ascent,25,'k','*');
% %         lsline;
% %         [f,gof] = fit(zAnalysis',ascent','poly1');
% %         rsq = round(gof.rsquare,3);
% %         rmse = round(gof.rmse,3);
% %         title({['Asc vs ',analysis],['r2: ',num2str(rsq)],['rmse: ',num2str(rmse)]},'FontSize',fontSize);
% %         r2table(r2Count,4) = rsq;
% %         
% %         subplot(rows,cols,iSubplot+3);
% %         scatter(zAnalysis,spo2,25,'k','*');
% %         lsline;
% %         [f,gof] = fit(zAnalysis',spo2','poly1');
% %         rsq = round(gof.rsquare,3);
% %         rmse = round(gof.rmse,3);
% %         title({['SpO2 vs ',analysis],['r2: ',num2str(rsq)],['rmse: ',num2str(rmse)]},'FontSize',fontSize);
% %         r2table(r2Count,5) = rsq;
        
        if chCount == chPerFigure
            y = [];
            for iAcc = 1:days
                ax(rows,iAcc) = subplot(rows,cols,specifySubplot([rows cols],[rows iAcc]));
                shadedErrorBar(t,mean(allAccelData{iAcc}),std(allAccelData{iAcc}));
                y(iAcc) = peak2peak(mean(allAccelData{iAcc}));
                ylim([-400 400]);
                xlabel('time (s)');
                if iAcc == 1
                    ylabel('uV');
                end
                title('Accel','FontSize',fontSize);
                grid on;
                linkaxes(ax(:,iAcc),'x');
            end
            
            subplot(rows,cols,specifySubplot([rows cols],[rows cols]));
            scatter(y,altitude,25,'k','*');
            lsline;
            [f,gof] = fit(y',altitude','poly1');
            rsq = round(gof.rsquare,3);
            rmse = round(gof.rmse,3);
            title({['Alt vs AccP2P'],['r2: ',num2str(rsq)],['rmse: ',num2str(rmse)]},'FontSize',fontSize);
        
            figureName = [dt,'_','bandChannelScatters_',subject,'_band',num2str(iBand),'_ch',num2str(channels(iChannel)-chPerFigure+1),'_',analysis];
            disp(['Writing ',figureName]);
            savefig(h1,fullfile('figures',figureName),'compact');
%             saveas(h1,fullfile('figures',[figureName,'.png']));
%             print(h1,fullfile('figures',[figureName,'.png']),'-dpng');
            close(h1);
            chCount = 1;
        else
            chCount = chCount + 1;
        end
        r2Count = r2Count + 1;
    end
end

csvwrite(fullfile('figures',[dt,'_r2table_',subject,'_',analysis,'.csv']),r2table);