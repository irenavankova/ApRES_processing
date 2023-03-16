function sd = ct_site_downsample_for_correlation(cfg,site)

sd.cfg = cfg;

i1 = cfg.tseries_burst_first; %Index of first burst
di = cfg.tseries_burst_spacing; % Spacing between processed bursts
i2 = cfg.tseries_burst_last; % Index of last burst (put cfg.Nbursts if you want them all)

ind1 = i1:di:i2;
ind2 = i1+1:di:i2+1;
ind = [ind1 ind2];
ind = unique(ind);
ind = sort(ind,'ascend');

sd.time = site.time(ind);
sd.T1 = site.T1(ind);
sd.T2 = site.T2(ind);
sd.spec_cor = site.spec_cor(ind,:);