
function ct_plot_xcor_vs_uwrp_pcolor(ct)
% Visually compare ApRES displacement timeseries produced by different techniques
cfg = ct.cfg;
dts_xcor = ct.dts_xcor;
dts_uwrp = ct.dts_uwrp;

%--------------------------------------------------------------
% Do pcolor plot of de-meaned timeseries
figure;

% Xcorr pcolor
subplot(1,2,1)
z = dts_xcor.dh;
z = z - repmat(mean(z,1),size(z,1),1);
imagesc(dts_xcor.time,dts_xcor.dhRange,z'); colormap jet
set(gca,'Fontsize',12,'Linewidth',2)
datetick('x','keeplimits'); xlabel('Date'); ylabel('Depth (m)'); colorbar;
axis tight
h = gca;
cmax = max(max(abs(z))); caxis([-1 1]*cmax);
title('Complex x-corr')

% Unwrapped-phase pcolor
subplot(1,2,2)
z = dts_uwrp.dh;
z = z - repmat(mean(z,1),size(z,1),1);
imagesc(dts_uwrp.time,dts_uwrp.dhRange,z'); colormap jet
set(gca,'Fontsize',12,'Linewidth',2)
datetick('x','keeplimits'); xlabel('Date'); ylabel('Depth (m)'); colorbar;
axis tight
h = [h;gca];
linkaxes(h,'xy')
caxis([-1 1]*cmax);
title('Phase unwrapping')