function ct_plot_xcor_vs_uwrp_lines(ct,mf,numsubplots,Hmax)
% Visually compare ApRES displacement timeseries produced by different techniques
cfg = ct.cfg;
dts_xcor = ct.dts_xcor;
%--------------------------------------------------------------
% Plot all timeseries at coarse chunk depths
figure;

if nargin < 2
    mf = 100; % Factor each timeseries is multiplied by
    Hmax = max(dts_xcor.dhRange);
end
if nargin < 3
    numsubplots = 2;
    Hmax = max(dts_xcor.dhRange);
end
if nargin < 4
    Hmax = max(dts_xcor.dhRange);
end

[~,ii] = min(abs((Hmax-dts_xcor.dhRange)));

if numsubplots == 2
    dts_uwrp = ct.dts_uwrp;
end

% Xcorr timeseries
if numsubplots == 2
    subplot(1,2,1)
end
plot(dts_xcor.time,mf*dts_xcor.dh(:,1:ii)+repmat(dts_xcor.dhRange(1:ii)',1,size(dts_xcor.dh(:,1:ii),1))','k')
set(gca,'YDir','reverse','Fontsize',8)
datetick('x','keeplimits'); xlabel('Date'); ylabel('Range (m)')
axis tight
h = gca;
%title('Complex x-corr (x 100)')
title([ct.cfg.output_mat_file_name ' xcor (x ' num2str(mf) ')'],'FontWeight','normal','Interpreter','none')

% Unwrapped-phase timeseries
if numsubplots == 2
    subplot(1,2,2)
    %plot(dts_uwrp.time,mf*dts_uwrp.dh_nearest+repmat(dts_xcor.dhRange',1,size(dts_uwrp.dh_nearest,1))','k'); hold on
    %plot(dts_uwrp.time,mf*dts_uwrp.dh_mean+repmat(dts_xcor.dhRange',1,size(dts_uwrp.dh_mean,1))','r')
    plot(dts_uwrp.time,mf*dts_uwrp.dh(:,1:ii)+repmat(dts_xcor.dhRange(1:ii)',1,size(dts_uwrp.dh(:,1:ii),1))','k')
    set(gca,'YDir','reverse','Fontsize',12,'Linewidth',2)
    datetick('x','keeplimits'); xlabel('Date');
    axis tight
    h = [h;gca];
    linkaxes(h,'xy')
    %title('Phase unwrapping (x 100)')
    title([ct.cfg.output_mat_file_name ' uwrp (x ' num2str(mf) ')'],'FontWeight','normal','Interpreter','none')
end