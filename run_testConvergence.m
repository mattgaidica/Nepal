r2s = [];
altitude = [2860 2630 2350 2920 4130 2310 1780];
kk = 1;
plotVals = [];
for ii = 1:100
    for jj=1:100
        [~,gof1] = fit(rand(7,1),altitude','poly1');
        [~,gof2] = fit(rand(7,1),altitude','poly1');
        r2s(kk) = mean([round(gof1.rsquare,3),round(gof2.rsquare,3)]);
    end
    disp(ii);
    plotVals(ii) = mean(r2s);
    kk = kk + 1;
end
figure;
plot(plotVals);