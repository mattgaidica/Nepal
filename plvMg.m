function plvVector = plvMg(sigphase,varargin)

autoplv = false;
if ~isempty(varargin)
     % one-to-many plv, specifies single trial number
    autoplv = true;
    useTrial = varargin{1};
end

useMsg = false;
% % if ~autoplv && size(sigphase,1) > 50
% %     useMsg = true;
% % end

trialCount = 1;
plvVector = [];
if useMsg
    h = waitbar(0,'Working on PLV...');
end
for ii = 1:size(sigphase,1)
    if useMsg
        waitbar(ii/size(sigphase,1));
    end
    if autoplv
        jjRange = useTrial;
    else
        jjRange = ii:size(sigphase,1);
    end
    for jj = jjRange
        if ii == jj
            continue;
        end
        plvVector(trialCount,:) = abs(circ_dist(sigphase(ii,:),sigphase(jj,:)));
        trialCount = trialCount + 1;
    end
end
if useMsg
    close(h);
end
plvVector = 1./mean(plvVector);