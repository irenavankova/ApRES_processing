function ct_plot_burst_variance(time,cfg)

figure
if ~isfield(cfg,'num_chirps_in_burst')
    subplot(2,1,1)
    plot(time,cfg.burst_std,'r','LineWidth',1); h = gca;
    set(gca,'Fontsize',12,'Linewidth',2)
    datetick('x','mm/yy','keeplimits'); axis tight; 
    ylabel('Burst std'); grid on
    subplot(2,1,2)
    plot(time,cfg.burst_std_of_chirp_std,'r','LineWidth',1); h = [h;gca];
    set(gca,'Fontsize',12,'Linewidth',2)
    datetick('x','mm/yy','keeplimits'); axis tight; 
    ylabel('Chirp std'); grid on
    linkaxes(h,'x')
else
    subplot(3,1,1)
    % std of meanchirp - may indicate amplitude oscillations too at times
    plot(time,cfg.burst_std,'r','LineWidth',1); h = gca;
    set(gca,'Fontsize',12,'Linewidth',2)
    datetick('x','mm/yy','keeplimits'); axis tight; 
    ylabel('Burst std'); grid on
    subplot(3,1,2)
    % std of std of chirps in a burst
    plot(time,cfg.burst_std_of_chirp_std,'r','LineWidth',1); h = [h;gca];
    set(gca,'Fontsize',12,'Linewidth',2)
    datetick('x','mm/yy','keeplimits'); axis tight; 
    ylabel('Chirp std'); grid on
    subplot(3,1,3)
    plot(time,cfg.num_chirps_in_burst,'r','LineWidth',1); hold on
    try
    ind = find(cfg.chirp_manual_select == 1);
    plot(time(ind),cfg.num_chirps_in_burst(ind),'k*','LineWidth',1); hold on
    end
    set(gca,'Fontsize',12,'Linewidth',2)
    axis tight; ylim([0 max(cfg.num_chirps_in_burst)])
    datetick('x','mm/yy','keeplimits')
    ylabel('# of chirps used'); grid on
    h = [h;gca];
    linkaxes(h,'x')
end
    