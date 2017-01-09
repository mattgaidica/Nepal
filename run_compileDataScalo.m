dataDir = '/Users/mattgaidica/Dropbox/Grants/2016 Harvard Travellers Club/data/export raw';
subject = 'mg';
headerFiles = dir(fullfile(dataDir,['*_',subject,'_*_Raw Data.vhdr']));
accelCh = 17;

plotStartEnd = false;
trialType = 'normal';
eventIdx = 2;
winSeconds = 1.5;
% channels = [13 15 5 6 8];
channels = [13];
fileIdxs = reshape([1:14],2,7)';
fpassScalo = [0.5 4];
fpassEEG = [0.5 4];
% freqList = logFreqList(fpass,30);
freqList = [fpassScalo(1):fpassScalo(2)];

days = 7;
rows = 3;

h1 = figure('position',[0 0 1100 500]);
allColors = get(gca,'colororder');
endToStart = [];
accelData = [];
for iDay = 1:days
    % reset averaging
    eegCenter = [];
    eegCenterZ = [];
    eegCount = 1;
    startToBall = [];
    ballToEnd = [];
    for iSession = 1:2 % a|b
        iFile = fileIdxs(iDay,iSession);
        [trials,meta,fs] = getNepalTrials(dataDir,headerFiles(iFile).name);
        eeg = importdata(fullfile(dataDir,meta.DataFile));
        winSamples = winSeconds * fs;
        t = linspace(-winSeconds,winSeconds,winSamples*2);
        eegAccel = eegfilt(eeg(:,accelCh)',fs,0.5,20);
        for iChannel = 1:length(channels)
            channel = channels(iChannel);
            eegFilt = eegfilt(eeg(:,channel)',fs,fpassEEG(1),fpassEEG(2));
            eegMean = mean(eegFilt);
            eegStd = std(eegFilt);
% %             eegEnv = abs(hilbert(eegFilt)); % envelope
% %             eegEnvMean = mean(eegEnv);
% %             eegEnvStd = std(eegEnv);
            for iTrial = 1:length(trials)
                if strcmp(trials(iTrial).type,trialType) % need all trials for non-bifurcated endToStart
                    if trials(iTrial).locs(eventIdx) - winSamples > 0 && length(eegEnv) > trials(iTrial).locs(eventIdx) + winSamples - 1
                        sampleRange = trials(iTrial).locs(eventIdx) - winSamples : trials(iTrial).locs(eventIdx) + winSamples - 1;
% %                         eegEventSegment = (eegEnv(sampleRange) - eegEnvMean) / eegEnvStd;
                        eegEventSegment = eegFilt(sampleRange);
                        eegEventSegmentZ = (eegFilt(sampleRange) - eegMean) / eegStd; % Z-score
                        if max(eegEventSegmentZ) > 15
                            disp(['Trial ',num2str(iTrial),' exceeds Z-threshold']);
                        else
                            eegCenter(:,eegCount) = eegEventSegment;
                            eegCenterZ(:,eegCount) = eegEventSegmentZ;
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

    subplot(rows,days,iDay);
    [W, freqList] = calculateComplexScalograms_EnMasse(eegCenterZ,'Fs',fs,'fpass',fpassScalo);
    scalo = squeeze(mean(abs(W).^2,2))';
    imagesc(t,freqList,log(scalo));
    set(gca,'YDir','normal');
    set(gca,'TickDir','out');
    colormap(jet);
    caxis([-6 0]);
    xlim([-1 1]);
    if iDay == 1
        ylabel('Freq (Hz)');
        colorbar('north');
    end
    if iDay == 1
        title({['Ch',mat2str(channels),' on Ball'],['Day ',num2str(iDay),' ',subject]});
    end
    if iDay ~= 1
        title({'',['Day ',num2str(iDay),' ',subject]});
    end

    iSubplot = days+iDay;
    subplot(rows,days,iSubplot);
    shadedErrorBar(t,mean(accelData),std(accelData));
    hold on;
    plot([0 0],[-1000 1000],'--','color','k');
    xlabel('Time (s)');
    if iDay == 1
        ylabel('Accel (uV)');
    end
    xlim([-1 1]);
    ylim([-400 400]);
    
    iSubplot = (days*2)+iDay;
    subplot(rows,days,iSubplot);
    shadedErrorBar(t,mean(eegCenterZ'),std(eegCenterZ'));
%     plot(t,eegCenterZ);
    xlabel('Time (s)');
    if iDay == 1
        ylabel('Z-score');
    end
    xlim([-1 1]);
    ylim([-7 7]);
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