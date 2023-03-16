% Get basal reflector timeseries using different approaches


% Pick and load site
load sitename.mat
sname = sitename;
spec = ct_site_param_tseries_base;
depthEdges = spec.depthEdges;

opt_save = 1;

if ~exist('site','var')
    load([sname '.mat'])
    %load([sname '_bed.mat'])
end


% Track peak + quad fit
% Included: eturn of basal reflector oscillates because of limited vertical resolution, fit quadratic to get a better looking timeseries
clear tp
tp = [];
tp = ct_TrackPeak(tp,site);

if opt_save == 1
    save([sname '_bed_tpq.mat'],'tp')
end

% Get base tsereis by crosscorrelating bigger chunk
bed_xcor = ct_bin_tseries_via_xcorr(site.cfg,site,[],[],depthEdges);
if opt_save == 1
    save([sname '_bed_xcor.mat'],'bed_xcor')
end

%
figure
subplot(2,1,1)
plot(tp.tim,(tp.thickness-tp.thickness(1))); hold on
plot(bed_xcor.time,(bed_xcor.dh-bed_xcor.dh(1)))
legend('track','xcor')
datetick('x')
ylabel('dh (m)')

subplot(2,1,2)
plot(tp.tim,detrend(tp.thickness-tp.thickness(1))); hold on
plot(bed_xcor.time,detrend(bed_xcor.dh-bed_xcor.dh(1)))
datetick('x')
ylabel('dh detrended (m)')

% %% PLOTS
% figure
% plot(site.cfg.Rcoarse,20*log10(abs(site.spec_cor(1,:)')),'r'); hold on
% plot(site.cfg.Rcoarse,20*log10(abs(site.spec_cor(end,:)')),'b'); hold on
% xlabel('Depth (m)'); ylabel('dB')




