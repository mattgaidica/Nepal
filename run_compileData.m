dataDir = '/Users/mattgaidica/Dropbox/Grants/2016 Harvard Travellers Club/data/export raw';
headerFiles = dir(fullfile(dataDir,'*_mg_a_Raw Data.vhdr'));

rows = length(fbands) + 1;
cols = length(headerFiles);
fbands = [0.5 4;4 7;8 12;13 30;30 150];

h1 = figure('position',[0 0 900 900]);
h2 = figure('position',[0 0 900 900]);
iSubplot = 1;
for iFile = 1:length(headerFiles)
    % create trials
    startMark = 'S  1';
    ballMark = 'B  1';
    endMark = 'E  1';

    [fs,label,meta] = bva_readheader(fullfile(dataDir,headerFiles(iFile).name));
    markers = bva_readmarker(fullfile(dataDir,meta.MarkerFile));

    trialCount = 1;
    trials = {};
    openTrial = 0;
    normalTrial = 0;
    for ii=1:length(markers{1})
        if strcmp(markers{1}{ii},startMark)
           trials(trialCount).ts = [markers{2}(ii)];
           trials(trialCount).type = 'imaginary'; % overwrite this if normal
           openTrial = 1;
        end
        if openTrial
            if strcmp(markers{1}{ii},ballMark)
                trials(trialCount).ts = [trials(trialCount).ts markers{2}(ii)];
                normalTrial = 1;
            end
            if strcmp(markers{1}{ii},endMark)
                trials(trialCount).ts = [trials(trialCount).ts markers{2}(ii)];
                if normalTrial
                    trials(trialCount).type = 'normal';
                end
                trialSamples = trials(trialCount).ts(end) - trials(trialCount).ts(1);
                if trialSamples > 1500 % 3s
                    disp(['!! Warning, trial ',num2str(ii),' is too long ',num2str(trialSamples)]);
                else
                    trialCount = trialCount + 1;
                end
                openTrial = 0;
                normalTrial = 0;
            end
        end
    end

    trialType = 'normal';
    centerEvent = 2;
    winSamples = 750;
    eegCenter = [];
    eegCount = 1;
    channel = 16;

    startToBall = [];
    ballToEnd = [];

    eeg = importdata(fullfile(dataDir,meta.DataFile));

    for iBands = 1:length(fbands);
        eegFilt = eegfilt(eeg(:,channel)',fs,fbands(iBands,1),fbands(iBands,2));
        eegFilt = artifactThresh(eegFilt,1,1000);
        eegEnv = abs(hilbert(eegFilt)); % envelope
        eegEnvMean = mean(eegEnv);
        eegEnvStd = std(eegEnv);
        for iTrial = 1:length(trials)
            if strcmp(trials(iTrial).type,trialType)
                eegData = eegEnv(trials(iTrial).ts(centerEvent) - winSamples : trials(iTrial).ts(centerEvent) + winSamples - 1);
                eegData = (eegData - eegEnvMean) / eegEnvStd;
                if max(eegData) > 15
                    disp(['Trial ',num2str(iTrial),' exceeds Z-threshold']);
                else
                    eegCenter(eegCount,:) = eegData;
                    startToBall(eegCount) = trials(iTrial).ts(2) - trials(iTrial).ts(1);
                    ballToEnd(eegCount) = trials(iTrial).ts(3) - trials(iTrial).ts(2);
                    eegCount = eegCount + 1;
                end
            end
        end

        t = linspace(-1.5,1.5,1500);

        figure(h1);
        subplot(rows,cols,transposeSubplotOrder(cols,rows,iSubplot));
        plot(t,eegCenter')
        xlim([-1.5 1.5])
        ylim([-1 10]);
        title([num2str(fbands(iBands,1)),'-',num2str(fbands(iBands,2)),' Hz']);

        figure(h2);
        subplot(rows,cols,transposeSubplotOrder(cols,rows,iSubplot));
        plot(t,mean(eegCenter))
        xlim([-1.5 1.5])
        ylim([-1 6]);
        title([num2str(fbands(iBands,1)),'-',num2str(fbands(iBands,2)),' Hz']);
        
        iSubplot = iSubplot + 1;
    end
    figure(h1);
    subplot(rows,cols,transposeSubplotOrder(cols,rows,iSubplot));
    errorbar([-mean(startToBall)/1000,mean(ballToEnd)/1000],[std(startToBall)/1000,std(ballToEnd)/1000]);
    ylim([-1.5 1.5]);
    xlim([0 3]);
    title('S-B-E');
    view([90 90]);

    figure(h2);
    subplot(rows,cols,transposeSubplotOrder(cols,rows,iSubplot));
    errorbar([-mean(startToBall)/1000,mean(ballToEnd)/1000],[std(startToBall)/1000,std(ballToEnd)/1000]);
    ylim([-1.5 1.5]);
    xlim([0 3]);
    title('S-B-E');
    view([90 90]);
    
    iSubplot = iSubplot + 1;
end