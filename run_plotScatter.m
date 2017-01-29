analysis = 'phase';
channels = [5;9;13];
altitude = [2860 2630 2350 2920 4130 2310 1780];
spo2MG = [89 99 99 92 91 97 97];
spo2JC = [99 97 97 94 97 98 98];
altitude = [2860 2630 2350 2920 4130 2310 1780];
ascent = [1320 -230 -280 570 1210 -1820 -530];

y = altitude;

switch analysis 
    case 'amplitude'
        r2tableMG = csvread('/Users/mattgaidica/Documents/MATLAB/Nepal/figures/201701231624_r2table_mg_amplitude.csv');
        r2tableJC = csvread('/Users/mattgaidica/Documents/MATLAB/Nepal/figures/201701231628_r2table_jc_amplitude.csv');
    case 'phase'
        r2tableMG = csvread('/Users/mattgaidica/Documents/MATLAB/Nepal/figures/201701280854_r2table_mg_phase.csv');
        r2tableJC = csvread('/Users/mattgaidica/Documents/MATLAB/Nepal/figures/201701281021_r2table_jc_phase.csv');
    otherwise
        warning('invalid anaylsis');
end

% plotScatter(r2tableMG,r2tableJC,analysis,channels,y);
plotScatterMean(r2tableMG,r2tableJC,analysis,channels,y);

function plotScatterMean(r2tableMG,r2tableJC,analysis,channels,y)
    color2 = [254/255 203/255 10/255];
    color1 = [24/255 65/255 109/255];
    lineWidth = 10;
    markerSize = 1300;
    
    figure('position',[0 0 900 900]);
    
    x = mean(r2tableMG(channels,5:11),1);
    scatter(x,y,markerSize,color1,'filled');
    [r2MG,pMG] = r2p(x,y);
    
    hold on;
    x = mean(r2tableJC(channels,5:11),1);
    scatter(x,y,markerSize,color2,'filled');
    [r2JC,pJC] = r2p(x,y);
    
    legend({'mg','jc'},'Location','southoutside');
    h = lsline;
    set(h(1),'color',color1,'linestyle','--','linewidth',lineWidth);
    set(h(2),'color',color2,'linestyle','--','linewidth',lineWidth);
    set(gca,'TickDir','out')
    
    figTitle = {[analysis,' ch',mat2str(channels)]...
        ['MG r2: ',num2str(r2MG),', p: ',num2str(pMG)],...
        ['JC r2: ',num2str(r2JC),', p: ',num2str(pJC)]};
    title(figTitle);
    
    switch analysis
        case 'amplitude'
            ylim([1500 4500]);
        case 'phase'
            xlim([0.6 1.8]);
            ylim([1500 4500]);
    end
% %     onlyfig;
% %     print(fullfile('figures',['scatter_',figTitle{1}]),'-dpng','-r300');  
end

function plotScatter(r2tableMG,r2tableJC,analysis,channels,x)
    figure('position',[0 0 900 300]);
    
    for iChannel = 1:length(channels)
        subplot(1,length(channels),iChannel);
        channel = channels(iChannel);
        x = r2tableMG(channel,5:11);
        scatter(x,altitude,50,'b','filled');
        hold on;
        x = r2tableJC(channel,5:11);
        scatter(x,altitude,50,'r','filled');

        legend({'mg','jc'},'Location','southoutside');
        lsline;

        title({[analysis,' ch',num2str(channel)]...
            ['MG r2: ',num2str(r2tableMG(channel,3)),', p: ',num2str(r2tableMG(channel,4))],...
            ['JC r2: ',num2str(r2tableJC(channel,3)),', p: ',num2str(r2tableJC(channel,4))]});
    end
end