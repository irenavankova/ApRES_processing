function [ind,b] = ct_fit_quad(x_in,y_in,w_in,drnf,opt_fit)
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
    w = w_in(ind); w = reshape(w,length(w),1);
end

% Do nonlinear fit

% startingVals = [10e-3 10e-5 10e-10]; % try with any other starting values. 
startingVals = [10e-3 10e-5 10e-2]; % try with any other starting values. 
modelFun = @(p,xx) p(1)+xx.*p(2)+xx.^2.*p(3); % Quadratic fit

if strcmp(opt_fit,'robust')
    opts.RobustWgtFun = 'bisquare';
    [b,~,~,~,~,ErrorModelInfo] = nlinfit(x,y, modelFun, startingVals, opts);
    
elseif strcmp(opt_fit,'lsq_weighted')
    [b,~,~,~,~,ErrorModelInfo] = nlinfit(x,y, modelFun, startingVals, 'Weights',w);
end

%[y] = ct_tide_compute_quadratic(x,b)

