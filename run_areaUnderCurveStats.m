spo2 = spo2MG;
allZData = allZDataMG;
altitude = altitude;
results = [];

for ix = 1:2
    if ix == 1
        x = spo2;
    else
        x = altitude;
    end
    for iBand = 1:length(fbands)
        for iDay = 1:days
            y(iDay) = trapz(abs(mean(allZData{iDay,iBand})));
        end
        [f,gof] = fit(x,y','poly1');
        results(ix,iBand) = gof.rsquare;
    end
end
resultsMG = results;

h1 = figure('position',[0 0 1100 500]);
for iDay = 1:days
    for iBand = 1:length(fbands)
        y(iBand) = mean(abs(mean(allZData{iDay,iBand})));
%         yerr(iBand) = std(allZData{iDay,iBand},2);
    end
    subplot(1,days,iDay);
    bar(y);
    set(gca,'XTickLabel',fbandsNames);
    set(gca,'XTickLabelRotation',45);
    xlim([0 length(fbands)+1]);
    ylim([0 1]);
end

h1 = figure('position',[0 0 1100 500]);
for iBand = 1:length(fbands)
    disp(fbandsNames{iBand});
    for iDay = 1:days
        y(iDay) = trapz(abs(mean(allZData{iDay,iBand})));
        disp(num2str(y(iDay)));
%         yerr(iBand) = std(allZData{iDay,iBand},2);
    end
    subplot(1,length(fbands),iBand);
    bar(y);
    title(fbandsNames{iBand});
    xlim([0 days+1]);
%     ylim([0 .7]);
end