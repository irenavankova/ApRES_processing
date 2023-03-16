% Check for site struct
if ~exist('site','var')
    % Load site file name
    load sitename.mat
    load([sitename '.mat'])
    if ~exist('site','var')
        error('Load site matfile manually')
    end
end

%--------------------------------------------------------------
% Load coarse tseries settings in addition to site settings
cfg = site.cfg;

if ~exist('tseries_type','var')
    tseries_type = 'fine';
end

if strcmp(tseries_type,'coarse')
    cfg = ct_site_param_tseries_coarse(cfg);
    outfile = cfg.output_mat_fname_tseries_coarse;
elseif strcmp(tseries_type,'fine')
    cfg = ct_site_param_tseries_fine(cfg);
    outfile = cfg.output_mat_fname_tseries_fine;
end

% Downsample site, in accordance with "ct_site_param_tseries" settings
site_reduced = ct_site_downsample(cfg,site);

%--------------------------------------------------------------
% Unwrap phase to produce displacement timeseries
[dts_uwrp] = ct_tseries_via_unwrap(cfg,site_reduced);

%--------------------------------------------------------------
% Use spectra to produce displacement timeseries using complex correlation
if ~isfield(cfg,'return_xcorrelation_coef')
    cfg.return_xcorrelation_coef = 0;
end
[dts_xcor] = ct_tseries_via_xcorr(cfg,site_reduced);

%--------------------------------------------------------------
% Subsample or depth-average unwraped-phase timeseries to compare
[dts_uwrp] = ct_reduce_unwrap_tseries(cfg,dts_uwrp,dts_xcor);
dts_uwrp = rmfield(dts_uwrp,'dh_fine');

%--------------------------------------------------------------
% Save in matfile
ct.dts_uwrp = dts_uwrp;
ct.dts_uwrp.name = 'uwrp';
ct.dts_xcor = dts_xcor;
ct.dts_xcor.name = 'xcor';
ct.cfg = cfg;

save(outfile,'ct');

%--------------------------------------------------------------
% Plot and compare pcolor
ct_plot_xcor_vs_uwrp_pcolor(ct)
% Plot and compare lines at depth
ct_plot_xcor_vs_uwrp_lines(ct)
% Plot and compare detrended lines
ct_plot_xcor_vs_uwrp_colapsed(ct)

%Plot correlation coef timeseries
if cfg.return_xcorrelation_coef == 1
    ct_plot_xcor_coef(ct.dts_xcor)
end
