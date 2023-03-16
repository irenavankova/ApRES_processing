% Check for site struct
if ~exist('site','var')
    %Load site file name
    load sitename.mat
    load([sitename '.mat'])
    if ~exist('site','var')
        error('Load site matfile manually')
    end
end

%--------------------------------------------------------------
% Load coarse tseries settings in addition to site settings
cfg = site.cfg;

% Load fine settings
tseries_type = 'coarse';
cfg = ct_site_param_tseries_coarse(cfg);

% % Change spacing parameters if want
cfg.tseries_burst_first = 10; % Index of first burst
% cfg.tseries_burst_spacing = 12*10;  % Spacing between processed bursts
% cfg.tseries_burst_last = cfg.NBursts; % Index of last burst (put cfg.Nbursts if you want them all)

% Downsample site, in accordance with "ct_site_param_tseries" settings
site_reduced = ct_site_downsample_for_correlation(cfg,site);

%--------------------------------------------------------------
% Use spectra to produce displacement timeseries using complex correlation
[dts_xcor] = ct_tseries_via_xcorr_V2_for_correlation(cfg,site_reduced);


%--------------------------------------------------------------
% Save in matfile
ct.dts_xcor = dts_xcor;
ct.dts_xcor.name = 'xcor';
ct.cfg = cfg;

outfile = [sitename '_cor_coef.mat'];
save(outfile,'ct');

% %--------------------------------------------------------------
% % Plot and compare pcolor
% ct_plot_xcor_vs_uwrp_pcolor(ct)
% % Plot and compare lines at depth
% ct_plot_xcor_vs_uwrp_lines(ct)
% % Plot and compare detrended lines
% ct_plot_xcor_vs_uwrp_colapsed(ct)

figure
subplot(1,2,1)
plot(dts_xcor.phsCor,dts_xcor.dhRange); hold on
plot(mean(dts_xcor.phsCor),dts_xcor.dhRange,'k','LineWidth',2)
set(gca,'YDir','reverse')
subplot(1,2,2)
plot(dts_xcor.ampCor,dts_xcor.dhRange); hold on
plot(mean(dts_xcor.ampCor),dts_xcor.dhRange,'k','LineWidth',2)
set(gca,'YDir','reverse')

t = dts_xcor.time - dts_xcor.time(1);

figure
subplot(1,2,1)
pcolor(t,dts_xcor.dhRange,dts_xcor.phsCor')
shading flat; colorbar
set(gca,'YDir','reverse')
subplot(1,2,2)
pcolor(t,dts_xcor.dhRange,dts_xcor.ampCor')
shading flat; colorbar
set(gca,'YDir','reverse')
