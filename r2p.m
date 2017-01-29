function [r2,p] = r2p(x,y)

[f,gof] = fit(x',y','poly1');
r2 = round(gof.rsquare,3);
lm = fitlm(x',y','linear');
p = lm.Coefficients{2,4};
