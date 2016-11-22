function [trials,meta,fs] = getNepalTrials(dataDir,headerFile)
startMark = 'S  1';
ballMark = 'B  1';
endMark = 'E  1';

[fs,~,meta] = bva_readheader(fullfile(dataDir,headerFile));
markers = bva_readmarker(fullfile(dataDir,meta.MarkerFile));

trialCount = 1;
trials = {};
openTrial = 0;
normalTrial = 0;
for ii=1:length(markers{1})
    if strcmp(markers{1}{ii},startMark)
       trials(trialCount).locs = [markers{2}(ii)];
       trials(trialCount).type = 'imaginary'; % overwrite this if normal
       openTrial = 1;
    end
    if openTrial
        if strcmp(markers{1}{ii},ballMark)
            trials(trialCount).locs = [trials(trialCount).locs markers{2}(ii)];
            normalTrial = 1;
        end
        if strcmp(markers{1}{ii},endMark)
            trials(trialCount).locs = [trials(trialCount).locs markers{2}(ii)];
            if normalTrial
                trials(trialCount).type = 'normal';
            end
            trialSamples = trials(trialCount).locs(end) - trials(trialCount).locs(1);
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