for iSubject = 1:2
    startElectrode = 9;
    if iSubject == 1
        A = importdata('/Users/mattgaidica/Dropbox/Grants/2016 Harvard Travellers Club/data/Beta Ball Rectify Baseline MG_Raw Data.dat',',');
        curColor = 'b';
    else
        A = importdata('/Users/mattgaidica/Dropbox/Grants/2016 Harvard Travellers Club/data/Beta Ball Rectify Baseline JC_Raw Data.dat',',');
        curColor = 'r';
    end
    B = reshape(A,[1500,14,18]);

    allAvgDays = zeros(1500,7,4);
    for iDay = 1:7
        for iSession = 1:2
            for iCh = 1:4
                nSession = (iDay*2) - 2 + iSession;
                curData = B(:,nSession,startElectrode-1+iCh);
                rms = mean(abs(curData(1:200)));
                curDataNorm = curData / rms;
                if rms > 10 || max(abs(curData)) > 200
                    continue;
                end
                if sum(curData) > 0
                    allAvgDays(:,iDay,iCh) = mean([allAvgDays(:,iDay,iCh),curData],2);
                else
                    allAvgDays(:,iDay,iCh) = curData;
                end
            end
        end
    end

    t = linspace(-1500,1500,1500);
    iSub = 1;
    if iSubject == 1
        figure;
    end
    for iDay = 1:7
        for iCh = 1:4
            subplot(7,4,iSub);
            hold on;
            plot(t,allAvgDays(:,iDay,iCh),'color',curColor);
            xlim([-1500 1500]);
            xlabel('Time (ms), Ball');
            ylim([0 50]);
            ylabel('Beta (uV)');
            title(['Day ',num2str(iDay),' - ','Channel ',num2str(startElectrode-1+iCh)]);
            iSub = iSub + 1;
        end
    end
end
legend('MG','JC');