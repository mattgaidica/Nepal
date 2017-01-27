function plvVector = plvMg(sigphase)
sigphase = sigphase(1:100,:);






trialCount = 1;
plvVector = [];
for ii = 1:size(sigphase,1)
    disp(ii);
    for jj = ii:size(sigphase,1)
        if ii == jj
            continue;
        end
        plvVector(trialCount,:) = abs(circ_dist(sigphase(ii,:),sigphase(jj,:)));
        trialCount = trialCount + 1;
    end
end
plvVector = mean(plvVector);