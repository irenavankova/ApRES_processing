function sd = ct_site_downsample(cfg,site)

sd.cfg = cfg;

i1 = cfg.tseries_burst_first; %Index of first burst
di = cfg.tseries_burst_spacing; % Spacing between processed bursts
i2 = cfg.tseries_burst_last; % Index of last burst (put cfg.NBursts if you want them all)

sd.time = site.time(i1:di:i2);
sd.T1 = site.T1(i1:di:i2);
sd.T2 = site.T2(i1:di:i2);
sd.spec_cor = site.spec_cor(i1:di:i2,:);