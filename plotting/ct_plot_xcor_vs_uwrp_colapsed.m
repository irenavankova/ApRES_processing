function ct_plot_xcor_vs_uwrp_colapsed(ct,drange)
% Visually compare varibility around the means state of ApRES displacement timeseries produced by different techniques

cfg = ct.cfg;
dts_xcor = ct.dts_xcor;
dts_uwrp = ct.dts_uwrp;

if nargin < 2
    drange = [dts_uwrp.dhRange(1) dts_uwrp.dhRange(end)];
end

dmin = drange(1);
dmax = drange(2);

%--------------------------------------------------------------
% Plot all timeseries at coarse chunk depths
% By default positive displacement is aways from the radar
% To make it look like positive displacement is towards radar do set(gca,'YDir','reverse')

[~,bl] = min(abs(dts_uwrp.dhRange-dmin)); % Top layer as a reference
[~,n] = min(abs(dts_uwrp.dhRange-dmax));
d1 = dts_uwrp.dhRange(bl);
d2 = dts_uwrp.dhRange(n);

% Do a test run to see what remove the top reference layer does

% Plot all
figure;
h = [];
for k = 1:2
    subplot(2,1,k)
    if k == 1
        % Xcorr timeseries
        ts = dts_xcor;
    else
        % Unwrapped-phase timeseries
        ts = dts_uwrp;
    end
    t = ts.time;
    cmap_jet = colormap(jet(n-bl+1));
    for j = bl:n
        tsind = n-(j-bl);
        y = ts.dh(:,tsind); % Start plotting with deepest tseries
        y = detrend(y);
        plot(t,y,'color',cmap_jet(j-bl+1,:)); hold on
    end
    set(gca,'YDir','reverse','Fontsize',12,'Linewidth',2) % This makes it look like positive displacement is towards radar 
    datetick('x','keeplimits'); ylabel('Depth (m)');
    if k == 2
        xlabel('Date');
    end
    axis tight
    title([ts.name ': ' num2str(d1) '-' num2str(d2) ' m'])
    h = [h;gca];
end
linkaxes(h,'xy')