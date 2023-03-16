% Basic plots that can start off ApRES data time series analysis

load sitename.mat
sname = sitename;
load([sname '.mat'])
load([sname '_bed_tpq.mat'])
load([sname '_bed_xcor.mat'])
load([sname '_ts_fine_TT.mat'])

% Choose which basal reflector timeseries is prefered/more reliable
%dh_base = tp.thickness;
dh_base = bed_xcor.dh;


%% TEMPERATURE
figure
subplot(2,1,1); h = gca;
plot(site.time,site.T1,'k'); hold on
plot(site.time,site.T2,'b')
axis tight; grid on
datetick('x','keeplimits')
ylabel('Temp (C)');

subplot(2,1,2); h = gca;
%plot(tp.tim, (tp.thickness) + tp.Bin(1)*tp.cfg.bin2m, 'k','LineWidth',1); hold on
plot(tp.tim, detrend(dh_base) + tp.Bin(1)*tp.cfg.bin2m, 'k','LineWidth',1);
axis tight; grid on
set(gca,'YDir','reverse')
datetick('x','keeplimits')
ylabel('Peak displ (m)');


%% BASE: See how the basal reflector changed from first to last shots
figure
subplot(1,2,1); h = gca;
imagesc(site.time,site.cfg.Rcoarse,20*log10(abs(site.spec_cor.')));hold on
axis tight
datetick('x','keeplimits')
ylabel('Depth (m)'); xlabel('date')

subplot(1,2,2); h = [h; gca];
plot(20*log10(abs(site.spec_cor(1,:)')),site.cfg.Rcoarse,'r'); hold on
plot(20*log10(abs(site.spec_cor(end,:)')),site.cfg.Rcoarse,'b'); hold on
set(gca,'YDir','reverse','Fontsize',12,'Linewidth',1)
legend('first','last','Location','northwest')
axis tight
grid on
ylabel('Depth (m)'); xlabel('dB')
linkaxes(h,'y')

%% BASE: Movie of basal reflector evolution
figure
for j = 1:10:length(site.time)
    plot(site.cfg.Rcoarse,20*log10(abs(site.spec_cor(1,:)')),'r'); hold on
    plot(site.cfg.Rcoarse,20*log10(abs(site.spec_cor(end,:)')),'b'); hold on
    plot(site.cfg.Rcoarse,20*log10(abs(site.spec_cor(j,:)')),'k','LineWidth',1)
    title(num2str(datevec(site.time(j))))
    ylim([-120 -20])
    xlim([-50 +50] + tp.x_input)
    xlabel('Depth (m)'); ylabel('dB')
    hold off
    drawnow
end

%% BASE: Visualise how well track_peak follows the basal reflector and what xcor lines do

% zoome on base
ct_plot_amp_pcolor(site); hold on
h1 = plot((tp.tim), dh_base + tp.Bin(1)*tp.cfg.bin2m, 'k','LineWidth',2);
dz_plot = 50;
[~,ind] = min(abs(tp.x_input-dz_plot-ct.dts_uwrp.dhRange));
[~,ind2] = min(abs(tp.x_input+dz_plot-ct.dts_uwrp.dhRange));
for j = ind:1:ind2
    h2 = plot(ct.dts_xcor.time, ct.dts_xcor.dhRange(j) + ct.dts_xcor.dh(:,j),'k-.','LineWidth',1);
end
ylim([tp.x_input-dz_plot min([tp.x_input+dz_plot max(site.cfg.Rcoarse)])])
legend([h1;h2],char({'basal peak';'xcor lines'}))

%% BASE: Basal reflector spectrum

% interpolate to equal timesteps
dt = tp.cfg.time_step/(3600*24); % timestep in days
t = tp.tim(1):dt:tp.tim(end);
freq_data = 1/dt;
y = interp1(tp.tim,dh_base,t);
[psd_h,f_p,pxxc] = pmtm(y,[],[],freq_data,'ConfidenceLevel',0.95);

figure
y_up = pxxc((2:end),2)';%pp(imin,2);
y_down = pxxc((2:end),1)';%pp(imax,2);
xpts = [f_p(2:end)' fliplr(f_p(2:end)')]; ypts = [y_down fliplr(y_up)];
patch(1./xpts,ypts,'k','Facealpha',0.2,'Edgecolor','none'); hold on
loglog(1./f_p,psd_h,'k','LineWidth',1); hold on
set(gca,'YScale','log','XScale','log','fontsize',8)
axis tight; grid on
title('Basal reflector spectrum','FontWeight','normal')

%% XCOR: Visualise what xcor lines look like with respect to the return amplitude

% same as above but zoome on top
ct_plot_amp_pcolor(site); hold on
[~,ind] = min(abs(0-ct.dts_uwrp.dhRange));
[~,ind2] = min(abs(350-ct.dts_uwrp.dhRange));
for j = ind:10:ind2
    h2 = plot(ct.dts_xcor.time, ct.dts_xcor.dhRange(j) + ct.dts_xcor.dh(:,j),'k-','LineWidth',1);
end
ylim([0 ct.dts_uwrp.dhRange(ind2)])
legend([h2],char({'xcor lines'}))

%% STRAIN FITTING: Plot displacement timeseries and xcor coefficient
% Use the following plot to get a first rough idea about what regions to exclude from fitting
dts_xcor = ct.dts_xcor;
mf = 100;
%--------------------------------------------------------------
% Plot all timeseries at coarse chunk depths
figure;

% xcorr timeseries - lines may cross if mf > 1!!
subplot(1,2,1); h = gca;
plot(dts_xcor.time,mf*dts_xcor.dh+repmat(dts_xcor.dhRange',1,size(dts_xcor.dh,1))','k')
set(gca,'YDir','reverse','Fontsize',12,'Linewidth',1)
datetick('x','keeplimits'); xlabel('Date'); ylabel('Depth (m)')
axis tight
title([ct.cfg.output_mat_file_name ' xcor (x ' num2str(mf) ')'],'FontWeight','normal')
% xcorr coefficient
subplot(1,2,2); h = [h;gca];
plot(mean(dts_xcor.ampCor),dts_xcor.dhRange,'k','LineWidth',1)
set(gca,'YDir','reverse','Fontsize',12,'Linewidth',1)
axis tight
title('Amp xcor coef','FontWeight','normal')
linkaxes([h],'y')

%% kwn type plot of mean vertical strain and melt
% define regions to exclude from fitting
dts_xcor = ct.dts_xcor;
spec = ct_site_param_tseries_base;
%drnf = spec.drnf_vsr;
drnf = []; % define intervals to ignore for strain fit, e.g. drnf = [36 70; 600 4000]

depth = ct.dts_xcor.dhRange;
time = ct.dts_xcor.time;

for j = 1:length(depth)
    y = ct.dts_xcor.dh(:,j); % Vertical displacement time series at a given depth
    [~,p,~,se] = ct_fit_line(time,y,[],[],'robust');
    vel(j) = p(1); % Extract the slope = velocity
    vel_se(j) = se(1); % Extract the slope error = velocity error
end

y = dh_base; % Vertical displacement time series at a given depth
[~,p,~,se] = ct_fit_line(time,y,[],[],'robust');
vel_bed = p(1); % Extract the slope = velocity

d2y = 365.25;
vel = vel*d2y;
vel_se = vel_se*d2y;
vel_bed = vel_bed*d2y;

[ind,p_best,~,se_best] = ct_fit_line(depth,vel,1./vel_se,drnf,'lsq_weighted');
[~,q_best] = ct_fit_quad(depth,vel,1./vel_se,drnf,'lsq_weighted');
yL = p_best(1)*depth + p_best(2); % Best line fit
yQ = q_best(1)+depth*q_best(2)+depth.^2.*q_best(3);
% Plot fits
figure
subplot(1,2,1); h = [gca];
errorbar(vel(ind),depth(ind),vel_se(ind)*0,vel_se(ind)*0,vel_se(ind),vel_se(ind),'.','color','c'); hold on % Plot error bars
plot(vel(),depth(),'.','color','m'); hold on % Plot segment points (yellow dots)
plot(vel(ind),depth(ind),'.','color','b'); hold on % Plot segment points (yellow dots)
plot(vel_bed,tp.x_input,'x','color','m'); hold on % Plot segment points (yellow dots)

plot(yL,depth,'-','color','k','LineWidth',1)
plot(yQ,depth,'--','color','r','LineWidth',1)

ylabel('Depth (m)'); xlabel('velocity (m/y)')

mr = vel_bed-(p_best(1)*tp.x_input + p_best(2)); % Best line fit
title(['\epsilon_t ~ ' num2str(round(p_best(1),4)) ' yr^{-1}' ', m_t ~ ' num2str(round(-mr,2)) ' m/yr'],'FontWeight','normal')
set(gca,'ydir','reverse')
axis tight; grid on
plot(xlim,[1 1]*tp.x_input,'b--')

subplot(1,2,1)
% xcorr coefficient
subplot(1,2,2); h = [h;gca];
plot(mean(dts_xcor.ampCor),dts_xcor.dhRange,'k','LineWidth',1); hold on
set(gca,'YDir','reverse')
axis tight; grid on
plot(xlim,[1 1]*tp.x_input,'b--')
title('Amp xcor coef','FontWeight','normal')
linkaxes([h],'y')








