% --- ENV VARIABLES START ---
subject = 'mg';
% --- ENV VARIABLES END ---

dataDir = '/Users/mattgaidica/Dropbox/Grants/2016 Harvard Travellers Club/data/export raw';
headerFiles = dir(fullfile(dataDir,['*_',subject,'_*_Raw Data.vhdr']));
accelCh = 17;

plotStartEnd = false;
trialType = 'normal';
eventIdx = 2;
winSeconds = 1;
% channels = 1:16;
channels = 1;
fileIdxs = reshape([1:14],2,7)';

% fbands = [0.5 3.5;4 8;7.5 12.5;13 30;30 100];
fbands = [0.5 100];
fbandsNames = {'delta','theta','alpha','beta','gamma'};
rows = size(fbands,1)+1;
days = 7;

% h1 = figure('position',[0 0 1100 900]);
% allColors = get(gca,'colororder');
endToStart = [];
allAccelData = {};
allZData = {};
allData = {};
for iBand = 1:size(fbands,1)
    for iDay = 1:days
        for iChannel = 1:length(channels)
             % reset averaging
            eegCenterZ = [];
            eegCenter = [];
            eegCount = 1;
            startToBall = [];
            ballToEnd = [];
            accelData = [];
            channel = channels(iChannel);
            for iSession = 1:2 % a|b
                iFile = fileIdxs(iDay,iSession);
                [trials,meta,fs] = getNepalTrials(dataDir,headerFiles(iFile).name);
                eeg = importdata(fullfile(dataDir,meta.DataFile));
                eegFilt = eegfilt(eeg(:,channel)',fs,fbands(iBand,1),fbands(iBand,2));
                eegMean = mean(eegFilt);
                eegStd = std(eegFilt);
                eegAccel = eegfilt(eeg(:,accelCh)',fs,0.5,20);
                winSamples = winSeconds * fs;
                t = linspace(-winSeconds,winSeconds,winSamples*2);
                for iTrial = 1:length(trials)
                    if strcmp(trials(iTrial).type,trialType) % need all trials for non-bifurcated endToStart
                        if trials(iTrial).locs(eventIdx) - winSamples > 0 && length(eegFilt) > trials(iTrial).locs(eventIdx) + winSamples - 1
                            sampleRange = trials(iTrial).locs(eventIdx) - winSamples : trials(iTrial).locs(eventIdx) + winSamples - 1;
                            eegEventSegment = eegFilt(sampleRange);
                            eegEventSegmentZ = (eegEventSegment - eegMean) / eegStd; % Z-score
                            
                            % if I want to artifact detect it needs to
                            % remove the trial for all bands
                            eegCenter(eegCount,:) = eegEventSegment;
                            eegCenterZ(eegCount,:) = eegEventSegmentZ;
                            startToBall(eegCount) = trials(iTrial).locs(2) - trials(iTrial).locs(1);
                            ballToEnd(eegCount) = trials(iTrial).locs(3) - trials(iTrial).locs(2);
                            accelData(eegCount,:) = eegAccel(sampleRange);
                            eegCount = eegCount + 1;
                        end
                    end
                    if iTrial > 1
                        endToStart(iDay,eegCount) = trials(iTrial).locs(1) - lastEnd;
                    end
                    lastEnd = trials(iTrial).locs(end);
                end
                disp(['Band: ',num2str(iBand),', Ch: ',num2str(iChannel),', Day: ',num2str(iDay),', Session: ',num2str(iSession)]);
                allData{iBand,iChannel,iDay} = eegCenter;
                allZData{iBand,iChannel,iDay} = eegCenterZ;
                allAccelData{iDay} = accelData; % overwrites itself, but that's okay
            end
        end
    end
end
    