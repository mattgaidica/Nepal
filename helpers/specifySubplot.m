function pos = specifySubplot(subplotSizeXY,desiredSubplotXY)
% ex. 4 row, 7 col subplot
% subplotSizeXY = [4 7];
% want second row third col pos
% desiredSubplotXY = [2 3];
% pos should equal 10

totalSubplots = subplotSizeXY(1) * subplotSizeXY(2);
subplotGrid = reshape(1:totalSubplots,fliplr(subplotSizeXY))';
pos = subplotGrid(desiredSubplotXY(1),desiredSubplotXY(2));

