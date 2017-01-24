analysis = 'phase';

switch analysis 
    case 'amplitude'
        r2tableMG = csvread('/Users/mattgaidica/Documents/MATLAB/Nepal/figures/201701231624_r2table_mg_amplitude.csv');
        r2tableJC = csvread('/Users/mattgaidica/Documents/MATLAB/Nepal/figures/201701231628_r2table_jc_amplitude.csv');
    case 'phase'
        r2tableMG = csvread('/Users/mattgaidica/Documents/MATLAB/Nepal/figures/201701231600_r2table_mg_phase.csv');
        r2tableJC = csvread('/Users/mattgaidica/Documents/MATLAB/Nepal/figures/201701231608_r2table_jc_phase.csv');
    otherwise
        warning('invalid anaylsis');
end

plotScatter(r2tableMG,r2tableJC,analysis);

function plotScatter(r2tableMG,r2tableJC,analysis)
    channels = [9;5;13];
    altitude = [2860 2630 2350 2920 4130 2310 1780];
    days = 7;
    
    figure('position',[0 0 900 300]);
    fbandsNames = {'delta'};
    
    for iChannel = 1:length(channels)
        subplot(1,length(channels),iChannel);
        channel = channels(iChannel);
        y = r2tableMG(channel,5:5+days-1);
        scatter(y,altitude,50,'b','filled');
        hold on;
        y = r2tableJC(channel,5:5+days-1);
        scatter(y,altitude,50,'r','filled');

        legend({'mg','jc'},'Location','southoutside');
        lsline;

        title({[analysis,' ch',num2str(channel)]...
            ['MG r2: ',num2str(r2tableMG(channel,3)),', p: ',num2str(r2tableMG(channel,4))],...
            ['JC r2: ',num2str(r2tableJC(channel,3)),', p: ',num2str(r2tableJC(channel,4))]});
    end
end