function ct_plot_variance_w_depth(ct)

figure
plot(std(ct.dts_uwrp.dh),ct.dts_uwrp.dhRange,'k','LineWidth',1); hold on
plot(std(ct.dts_xcor.dh),ct.dts_xcor.dhRange,'r','LineWidth',1); hold on
axis tight
set(gca,'LineWidth',2,'FontSize',12,'YDir','reverse')
ylabel('Depth (m)')
xlabel('std(internal)')
legend([ct.dts_uwrp.name; ct.dts_xcor.name])


