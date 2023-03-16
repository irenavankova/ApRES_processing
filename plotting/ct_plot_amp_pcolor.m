function ct_plot_amp_pcolor(site)
%Transform new structure style on old structure style
in.t = site.time;
in.spc = site.spec_cor.';
in.range = site.cfg.Rcoarse;

figure
imagesc(in.t,in.range,20*log10(abs(in.spc)))
colormap jet
set(gca,'Fontsize',8)
axis tight
datetick('x','mmm/yy','keeplimits'); xlabel('Date');ylabel('Range (m)')
title('Amplitude','FontWeight','normal');
colorbar
