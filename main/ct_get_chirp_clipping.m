function [cfg] = ct_get_chirp_clipping(cfg,meanchirp)

% Find number of clipping points per burst for different chirp segments
vmin = cfg.v_range(1);
vmax = cfg.v_range(2);
tol = cfg.v_tol;
burst = cfg.burst_curr;

%Take care of IQ option
if isreal(meanchirp) == 0
    meanchirp = max([real(meanchirp); imag(meanchirp)],[],1);
end

cfg.num_clipped_all(burst) = length(find((vmax - meanchirp) < tol | ((meanchirp - vmin) < tol)));
cfg.num_clipped_last_34(burst) = length(find((vmax - meanchirp(floor(end/4):end)) < tol | (meanchirp(floor(end/4):end) - vmin) < tol));
cfg.num_clipped_last_12(burst) = length(find((vmax - meanchirp(floor(end/2):end)) < tol | (meanchirp(floor(end/2):end) - vmin) < tol));
cfg.num_clipped_last_14(burst) = length(find((vmax - meanchirp(floor(end/4*3):end)) < tol | (meanchirp(floor(end/4*3):end) - vmin) < tol));


% Compute pointwise (for each time stemp) max and min chirp values
if ~isfield(cfg,'max_meanchirp')
    cfg.max_meanchirp = meanchirp;
    cfg.min_meanchirp = meanchirp;
else
    cfg.max_meanchirp = max(meanchirp,cfg.max_meanchirp);
    cfg.min_meanchirp = min(meanchirp,cfg.min_meanchirp);
end