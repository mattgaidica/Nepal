% plv
% channelData = angle(hilbert(x));

% abs(sum(exp(1i*(channelData - compareChannelData)),2))/numTrials;

function plvVector = plv(temp)
%     plvMatrix = zeros(size(temp,1));
    trialCount = 1;
    for ii = 1:size(temp,1)
        for jj = ii:size(temp,1)
            if ii == jj
                continue;
            end
%             disp([num2str(ii),' ',num2str(jj)]);
            channelData(:,trialCount) = angle(hilbert(temp(ii,:)));
            compareChannelData(:,trialCount) = angle(hilbert(temp(jj,:)));
            trialCount = trialCount + 1;
        end
    end
    plvVector = abs(sum(exp(1i*(channelData - compareChannelData)),2))/size(channelData,2);
end