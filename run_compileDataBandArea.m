dataDir = '/Users/mattgaidica/Dropbox/Grants/2016 Harvard Travellers Club/data/export raw';
subject = 'jc';
headerFiles = dir(fullfile(dataDir,['*_',subject,'_*_Raw Data.vhdr']));

plotStartEnd = false;
trialType = 'normal';
eventIdx = 2;
winSeconds = 1;
channels = [13];
fileIdxs = reshape([1:14],2,7)';

fbands = [0.5 4;4 7;7.5 12.5;13 30;30 100];
fbandsNames = {'delta','theta','alpha','beta','gamma'};
rows = length(fbands)+1;
days = 7;

% h1 = figure('position',[0 0 1100 900]);
allColors = get(gca,'colororder');
endToStart = [];
accelData = [];
allZData = {};
for iDay = 1:days
    for iBand = 1:length(fbands)
        % reset averaging
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
            eegAccel = eegfilt(eeg(:,17)',fs,0.5,20);
            for iChannel = 1:length(channels)
                channel = channels(iChannel);
                eegFilt = eegfilt(eeg(:,channel)',fs,fbands(iBand,1),fbands(iBand,2));
%                 eegFilt = artifactThresh(eegFilt,1,1000);
                eegMean = mean(eegFilt);
                eegStd = std(eegFilt);
                for iTrial = 1:length(trials)
                    if strcmp(trials(iTrial).type,trialType) % need all trials for non-bifurcated endToStart
                        if trials(iTrial).locs(eventIdx) - winSamples > 0 && length(eegEnv) > trials(iTrial).locs(eventIdx) + winSamples - 1
                            sampleRange = trials(iTrial).locs(eventIdx) - winSamples : trials(iTrial).locs(eventIdx) + winSamples - 1;
                            eegEventSegment = eegFilt(sampleRange);
                            eegEventSegmentZ = (eegFilt(sampleRange) - eegMean) / eegStd; % Z-score
                            if max(eegEventSegmentZ) > 15
                                disp(['Trial ',num2str(iTrial),' exceeds Z-threshold']);
                            else
                                eegCenterZ(eegCount,:) = eegEventSegmentZ;
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
        allZData{iDay,iBand} = eegCenterZ;
    end
end
    