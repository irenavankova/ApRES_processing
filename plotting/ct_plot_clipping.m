function ct_plot_clipping(cfg)

%Plot clipping frequency

figure
subplot(2,1,1)
Lwide = 1; L = cfg.Nsamples;
plot(cfg.num_clipped_all/L,'k','LineWidth',Lwide); hold on
plot(cfg.num_clipped_last_34/(L*3/4),'b','LineWidth',Lwide);
plot(cfg.num_clipped_last_12/(L*1/2),'c','LineWidth',Lwide);
plot(cfg.num_clipped_last_14/(L*1/4),'r','LineWidth',Lwide);

legend(['all'],['last 3/4'],['last 1/2'],['last 1/4'],'Location','northwest');
ylabel('% of clipped points'); xlabel('Burst')
title('Clipping frequency','FontWeight','normal')
axis tight
set(gca,'Fontsize',12,'Linewidth',2)

%Plot min and max voltage over time

t0 = (cfg.f_range_processed(1)-cfg.f_range_native(1))/(cfg.f_range_native(2)-cfg.f_range_native(1));
dt = cfg.T/cfg.Nsamples;
N = length(cfg.max_meanchirp);
t = t0:dt:t0+(N-1)*dt;

dfr = (cfg.f_range_native(2)-cfg.f_range_native(1))/cfg.Nsamples;
fr = cfg.f_range_processed(1):dfr:cfg.f_range_processed(2);
fr = fr(1:length(t))/10^6;

subplot(2,1,2)

vmin = cfg.v_range(1);
vmax = cfg.v_range(2);

% plot(t,cfg.max_meanchirp,'k');hold on
% plot(t,cfg.min_meanchirp,'k');hold on
% xlabel('Chirp time (s)')

plot(fr,cfg.max_meanchirp,'k');hold on
plot(fr,cfg.min_meanchirp,'k');hold on
xlabel('Chrip frequency (MHz)')

ylabel('Voltage (V)')
title('Pointwise max and min chirp','FontWeight','normal')
axis tight; ylim([vmin vmax])
set(gca,'Fontsize',12,'Linewidth',2)
