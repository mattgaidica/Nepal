function i_rowwise = transposeSubplotOrder(M,N,i_colwise)

% Conversion function
[jj,ii] = ind2sub([N,M],i_colwise);
i_rowwise = sub2ind([M,N],ii,jj); % This is the ordering MATLAB expects (row-wise)