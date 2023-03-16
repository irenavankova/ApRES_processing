function [ind,p,rmse,se] = ct_fit_line(x_in,y_in,w_in,drnf,opt_fit)
% Linear fit
% drnf = Do not consider the following depth ranges for fitting (drnf - depth range not to fit)

% Define depths to calculate tidal fit over
x = x_in;
y = y_in;
ind = find(isnan(x) == 0);
ind = intersect(ind,find(isnan(y) == 0));

% Go through the drnf array and exclude specified points from fitting
for j = 1:size(drnf,1)
    if drnf(j,1) > drnf(j,2)
        disp(['Badly defined depth range, skipping ' num2str(drnf(j,1)) '-' num2str(drnf(j,2))])
    else
        ind = intersect(ind,find(x <= drnf(j,1) | x >= drnf(j,2)));
    end
end

ind = unique(ind);
x = x(ind); x = reshape(x,length(x),1);
y = y(ind); y = reshape(y,length(y),1);
if ~isempty(w_in)
    w = w_in(ind); %w = reshape(w,length(w),1);
end

if strcmp(opt_fit,'robust')
    [p,stats] = robustfit(x,y,'bisquare');
    p = flipud(p);
    rmse = stats.robust_s;
    %rmse = stats.ols_s;
    se = flipud(stats.se);
elseif strcmp(opt_fit,'lsq_weighted')
    % Make sure x and y vectors have orientation consistent with lscov
    x = reshape(x,1,length(x)); 
    y = reshape(y,1,length(y));
    A = [x' ones(length(x),1)];
    if ~isempty(w_in)
        w = reshape(w,1,length(w));
        [p,se,mse] = lscov(A,y',w');
    else
        [p,se,mse] = lscov(A,y');
    end
    rmse = sqrt(mse);
end

