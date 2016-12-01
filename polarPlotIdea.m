theta = linspace(0,2*pi,length(someData));
rho = someData.^2;
ax = polarplot(theta,rho);
ax.ThetaZeroLocation = 'bottom';
thetaticklabels({'Start','Ball','End'});
polarscatter([1 2],[1000 1000]); % for start and end