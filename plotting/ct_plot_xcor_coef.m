function ct_plot_xcor_coef(dts_xcor)
% Plot correlation coeficient resulting from xcor timeseries call

% All and bold line is mean
figure
s1 = subplot(1,2,1);
plot(dts_xcor.phsCor,dts_xcor.dhRange); hold on
plot(mean(dts_xcor.phsCor),dts_xcor.dhRange,'k','LineWidth',2)
set(gca,'YDir','reverse','Fontsize',12,'Linewidth',1)
axis tight
title('Phase xcor coef','FontWeight','normal')
ylabel('Depth (m)')

s2 = subplot(1,2,2);
plot(dts_xcor.ampCor,dts_xcor.dhRange); hold on
plot(mean(dts_xcor.ampCor),dts_xcor.dhRange,'k','LineWidth',2)
set(gca,'YDir','reverse','Fontsize',12,'Linewidth',1)
axis tight
title('Amp xcor coef','FontWeight','normal')

linkaxes([s1;s2],'xy')


% Pcolor to see evolution
t = dts_xcor.time - dts_xcor.time(1);
t = t(1:end-1);

figure
subplot(1,2,1)
pcolor(t,dts_xcor.dhRange,dts_xcor.phsCor')
shading flat; colorbar
set(gca,'YDir','reverse','Fontsize',12,'Linewidth',1)
title('Phase xcor coef','FontWeight','normal')
ylabel('Depth (m)')

subplot(1,2,2)
pcolor(t,dts_xcor.dhRange,dts_xcor.ampCor')
shading flat; colorbar
set(gca,'YDir','reverse','Fontsize',12,'Linewidth',1)
title('Amp xcor coef','FontWeight','normal')

linkaxes([s1;s2],'xy')

