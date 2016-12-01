dataDir = '/Users/mattgaidica/Dropbox/Grants/2016 Harvard Travellers Club/data/export raw';
subject = 'mg';
headerFiles = dir(fullfile(dataDir,['*_',subject,'_*_Raw Data.vhdr']));

trialType = 'normal';
eventIdx = 2;
winSeconds = 1;
channels = [13];
fileIdxs = reshape([1:14],2,7)';

fbands = [4 7;7.5 12.5;13 30;60 80];
rows = length(fbands)+1;
cols = 7;

h1 = figure('position',[0 0 1100 900]);
allColors = get(gca,'colororder');
endToStart = [];
accelData = [];
for iDay = 1:7
    for iBand = 1:length(fbands)
        % reset averaging
        eegCenter = [];
        eegCount = 1;
        startToBall = [];
        ballToEnd = [];
        for iSession = 1:2 % a|b
            iFile = fileIdxs(iDay,iSession);
            [trials,meta,fs] = getNepalTrials(dataDir,headerFiles(iFile).name);
            eeg = importdata(fullfile(dataDir,meta.DataFile));
            winSamples = winSeconds * fs;
            t = linspace(-winSeconds,winSeconds,winSamples*2);
            eegAccel = eegfilt(eeg(:,17)',fs,0.5,20);
            for iChannel = 1:length(channels)
                channel = channels(iChannel);
                eegFilt = eegfilt(eeg(:,channel)',fs,fbands(iBand,1),fbands(iBand,2));
                eegFilt = artifactThresh(eegFilt,1,1000);
                eegEnv = abs(hilbert(eegFilt)); % envelope
                eegEnvMean = mean(eegEnv);
                eegEnvStd = std(eegEnv);
                for iTrial = 1:length(trials)
                    if strcmp(trials(iTrial).type,trialType) % need all trials for non-bifurcated endToStart
                        if trials(iTrial).locs(eventIdx) - winSamples > 0 && length(eegEnv) > trials(iTrial).locs(eventIdx) + winSamples - 1
                            sampleRange = trials(iTrial).locs(eventIdx) - winSamples : trials(iTrial).locs(eventIdx) + winSamples - 1;
                            eegEventSegment = (eegEnv(sampleRange) - eegEnvMean) / eegEnvStd;
                            if max(eegEventSegment) > 15
                                disp(['Trial ',num2str(iTrial),' exceeds Z-threshold']);
                            else
                                eegCenter(eegCount,:) = eegEventSegment;
                                startToBall(eegCount) = trials(iTrial).locs(2) - trials(iTrial).locs(1);
                                ballToEnd(eegCount) = trials(iTrial).locs(3) - trials(iTrial).locs(2);
                                accelData(eegCount,:) = eegAccel(sampleRange);
                                eegCount = eegCount + 1;
                            end
                        end
                    end
                    if iTrial > 1
                        endToStart(iDay,eegCount) = trials(iTrial).locs(1) - lastEnd;
                    end
                    lastEnd = trials(iTrial).locs(end);
                end
            end
        end
        
        iSubplot = (iBand-1)*7+iDay;
        subplot(rows,cols,iSubplot);
        hold on;
        ylimits = [-2 6];
        yMarkerPos = linspace(ylimits(1),ylimits(2),length(startToBall));
        for ii=1:length(startToBall)
            plot(-startToBall/fs,yMarkerPos,'.','markersize',2,'color','r');
            plot(ballToEnd/fs,yMarkerPos,'.','markersize',2,'color','r');
        end
        shadedErrorBar(t,mean(eegCenter),std(eegCenter),{'color',allColors(iBand,:)},1);
        plot([0 0],[-100 100],'--','color','k');
        xlim([-winSeconds winSeconds]);
        ylim(ylimits);
        if iDay == 1
            ylabel({['Z-score ',num2str(fbands(iBand,1)),'-',num2str(fbands(iBand,2)),' Hz'],'S-E Trial Marks'});
        end
        if iBand == 1 && iDay == 1
            title({['Ch',mat2str(channels),' on Ball'],['Day ',num2str(iDay),' ',subject]});
        end
        if iBand == 1 && iDay ~= 1
            title({'',['Day ',num2str(iDay),' ',subject]});
        end
    end
    
    iSubplot = (iBand)*7+iDay;
    subplot(rows,cols,iSubplot);
    shadedErrorBar(t,mean(accelData),std(accelData));
    hold on;
    plot([0 0],[-1000 1000],'--','color','k');
    xlabel('Time (s)');
    if iDay == 1
        ylabel('Accel (uV)');
    end
    xlim([-winSeconds winSeconds]);
    ylim([-400 400]);
    
end

% % endToStartMean = [];
% % endToStartStd = [];
% % for iDay = 1:7
% %     endToStartMean(iDay) = mean(endToStart(iDay,endToStart(iDay,:) > 0));
% %     endToStartStd(iDay) = std(endToStart(iDay,endToStart(iDay,:) > 0));
% % end
% % figure;
% % errorbar(endToStartMean/fs,endToStartStd/fs);
% % xlabel('day');
% % xlim([0 8]);
% % ylabel('s');
% % ylim([3 10]);
% % title('End to Start');