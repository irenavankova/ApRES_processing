function [dts_uwrp] = ct_reduce_unwrap_tseries(cfg,dts_uwrp,dts_xcor)

zx = dts_xcor.dhRange;
dzx = mode(diff(zx));

zu = cfg.Rcoarse;

% % Find the nearest depth and  use it
% clear ind
% for j = 1:length(zx)
%     [~,ind] = min(abs(zx(j)-zu));
%     dts_uwrp.dh_nearest(:,j) = dts_uwrp.dh_fine(:,ind);
% end

% Do the simplest depth average
clear ind
d_detr = detrend(dts_uwrp.dh_fine); % Detrend along columns
for j = 1:length(zx)
    ind = find( (zx(j) - dzx) <= zu & (zx(j) + dzx) > zu);
    
    %remove outlier timeseries (entire tsereis out)
    bool_outliers = isoutlier(std(d_detr(:,ind)),'median');
    ind_out = ind(bool_outliers == 0);
    
    % Simplest depth average
    %dts_uwrp.dh_mean(:,j) = mean(dts_uwrp.dh_fine(:,ind),2);
    
    % Depth average with outliers removed
    dts_uwrp.dh(:,j) = mean(dts_uwrp.dh_fine(:,ind_out),2);
end

dts_uwrp.dhRange = dts_xcor.dhRange;

%Move the beginning of each timeseries to start at zero
dts_uwrp.dh = dts_uwrp.dh - dts_uwrp.dh(1,:);


% %Move the beginning of each timeseries to start at zero with repmat
% dts_uwrp.dhRange  = dts_uwrp.dhRange - repmat(dts_uwrp.dhRange(1,:),1,size(dts_uwrp.dhRange,2));







