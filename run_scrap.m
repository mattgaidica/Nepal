figure;
for iSig = 5:size(curData,1)
    polarplot(sigphase(iSig,:),sigamp(iSig,:));
    hold on;
end
polarplot(median(sigphase),mean(sigamp),'LineWidth',3);