analysis = 'phase';

switch analysis 
    case 'integral'
        r2tableMG = csvread('/Users/mattgaidica/Documents/MATLAB/Nepal/figures/201701162139_r2table_mg_integral.csv');
        r2tableJC = csvread('/Users/mattgaidica/Documents/MATLAB/Nepal/figures/201701162142_r2table_jc_integral.csv');
    case 'phase'
        r2tableMG = csvread('/Users/mattgaidica/Documents/MATLAB/Nepal/figures/201701162147_r2table_mg_phase.csv');
        r2tableJC = csvread('/Users/mattgaidica/Documents/MATLAB/Nepal/figures/201701162150_r2table_jc_phase.csv');
    otherwise
        warning('invalid anaylsis');
end

plotReport(r2tableMG,r2tableJC,analysis);

function plotReport(r2tableMG,r2tableJC,analysis)
    figure('position',[0 0 500 1000]);
    fbandsNames = {'delta','theta','alpha','beta','gamma'};
    rows = 5;
    cols = 1;
    
    r2col = 3;
    r2rows = {3:8;9;13;11;14};
    r2rowLabels = {'ch3-8','ch9 (ipsi S1)','ch13 (contraS1)','ch11 (ipsi M1)','ch14 (contra M1)'};
    for ir2Rows = 1:size(r2rows,1)
        subplot(rows,cols,ir2Rows);
        plotData = [];
        for iBand=1:length(fbandsNames)
            plotData(1,iBand) = mean(r2tableMG(r2rows{ir2Rows}+(16*(iBand-1)),r2col));
            plotData(2,iBand) = mean(r2tableJC(r2rows{ir2Rows}+(16*(iBand-1)),r2col));
        end
        ax = formatAxes(plotData,fbandsNames,r2rowLabels{ir2Rows});
    end
    legend(ax,{'MG','JC'},'Location','southoutside');
    suptitle(analysis);
end

function ax = formatAxes(plotData,fbandsNames,plotTitle)
    y = mean(plotData);
    yerr = std(plotData);
    errorbar(y,yerr,'ko','LineWidth',2);
    hold on;
    ax(1) = plot(plotData(1,:),'b*');
    ax(2) = plot(plotData(2,:),'r*');
    xticks(1:length(fbandsNames));
    xticklabels(fbandsNames);
    xlims = [0 length(fbandsNames)+1];
    xlim(xlims);
    ylim([0 1]);
    title(plotTitle);
    hold on;
    plot(xlims,[0.15 0.15],'k--');
    grid on;
end