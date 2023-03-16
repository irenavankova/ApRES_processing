% Requires structure from
%  calc_spectra as an input parameter.
% Plots:
%
%  1. Log amplitude time series
%
%  2. Phase time series as a colour figure.
%
%  3. Time series of
% Optional parameter-pairs are 'tol',
% which specifies acceptable variance in the detrended, unwrapped phase,
% and 'segment' and 'offset'. Those parameters determine the length of
%
% PlotPhaseSeries(varargin)

function ct_PlotPhaseSeries(varargin)

if nargin == 0
    fprintf(['Parameters: <spc filename> [,''tol'', tolorance\n'...
        '[,''segment'',segment [,''offset'', offset\n [,''start'', start datenum'...
        '[,''finish'',finish datenum\n [,''amp'', ''on'' [,''phase'',''on'']]]]]]]\n'])
    return
end

plot_ice_motion = 0;
plot_ice_speed = 0;
plot_all_displacements = 1;
plot_phase_gradients = 1;

plot_amplitude = 1;
plot_phase = 1;

site = varargin{1};

%Transform new structure style on old structure style
in.t = site.time;
in.spc = site.spec_cor.';
in.range = site.cfg.Rcoarse;
in.maxbin = site.cfg.maxbin;
in.rad2m = site.cfg.rad2m;


tol = 1e4;
beg_datim = in.t(1);
fin_datim = in.t(end);
Seg = size(in.spc,2);
Offset = Seg;
mean_T = mean(diff(in.t));

if nargin>1
    for i=2:2:nargin-1
        switch(varargin{i})
            case 'tol'
                tol = varargin{i+1};
            case 'segment'
                Seg = round(varargin{i+1}/mean_T);
            case 'offset'
                Offset = round(varargin{i+1}/mean_T);
            case 'amp'
                plot_amplitude = varargin{i+1};
            case 'phase'
                plot_phase = varargin{i+1};
            case 'start'
                beg_datim = varargin{i+1};
            case 'finish'
                fin_datim = varargin{i+1};
            otherwise
                fprintf('Type ''PlotPhaseSeries<ret>'' for list of parameters\n')
                return
        end
    end
end

if plot_amplitude == 1
    figure
    imagesc(in.t,in.range,20*log10(abs(in.spc(1:in.maxbin,:))))
    colormap jet
    set(gca,'Fontsize',12,'Linewidth',2)
    axis tight
    datetick('x','keeplimits'); xlabel('Date');ylabel('Depth (m)')
    title('Amplitude');
    colorbar
end

a = angle(in.spc(1:in.maxbin,:));
sz = size(a);

% Unwrap along rows (time) dimension
una = unwrap(a,[],2);

%remove mean
muna = una - repmat(mean(una,2),1,sz(2));

% Interpolate to 120-minute intervals
%t = in.t(1):1/12:in.t(end);
% imuna = interp1(in.t,muna',t);
t = in.t;
imuna = muna';
% Assuming really noisy unwrapping means low signal strength, use variance
% of hpf version, with a threshold to select for 'good' records
vimuna = zeros(1,size(imuna,2));
for i = 1:size(imuna,2)
    vimuna(i) = var(detrend(imuna(:,i)));
end

% Replace noisy phase records with nan and convert from radians to metres
seluna = imuna'*in.rad2m;
%clear imuna
seluna(vimuna > tol,:) = nan;
if plot_phase == 1
    figure;imagesc(t,in.range,seluna); colormap jet
    set(gca,'Fontsize',12,'Linewidth',2)
    axis tight
    datetick('x','keeplimits'); xlabel('Date');ylabel('Depth (m)')
    caxis([-10,10]*in.rad2m);
    title('Unwrapped phase');
    colorbar
end

% Trim seluna and time to requested date range (begdatim to findatim)
ind1 = find(t>=beg_datim,1,'first'); ind2 = find(t<=fin_datim,1,'last');
seluna = seluna(:,ind1:ind2);
t = t(ind1:ind2);
if Seg>(ind2-ind1), Seg = ind2-ind1; end
if Offset>(ind2-ind1), Offset = ind2-ind1; end
if plot_all_displacements == 1
    figure;plot(t,seluna+repmat(in.range',1,size(seluna,2)))
    title('Displacement timeseries');
end

return
% Calculate slopes of unwrapped phase in each bin using linear regression.
% Divide time series into Nseg segments of length Segment, each offset from
% the last by Offset.
Nseg = floor((size(seluna,2)-Seg)/Offset)+1;
Slopes = zeros(length(in.range),Nseg);
k = 1;
for j = 1:Offset:Nseg*Offset
    A = zeros(size(seluna,1),2);
    for i=1:size(seluna,1)
        A(i,:) = polyfit(t(j:j+Seg-1)-t(j),seluna(i,j:j+Seg-1)',1);
    end
    Slopes(:,k) = A(:,1);
    k = k + 1;
end

if plot_phase_gradients == 1
    figure
    subplot(ceil(sqrt(Nseg)),ceil(sqrt(Nseg)),1);
    for j = 1:Nseg
        subplot(ceil(sqrt(Nseg)),ceil(sqrt(Nseg)),j)
        plot(in.range,Slopes(:,j)*365.25,'.');
        title([datestr(t((j-1)*Offset+1),19),' to ',datestr(t((j-1)*Offset+Seg),19)]);
    end
    ylabel('Velocity (m yr^{-1})');
    xlabel('Depth (m)');
    grid
    title('Gradients of unwrapped phase by linear regression')

    % Calculate slopes of unwrapped phase in each bin by finding median value
    % of the time derivative

    b = median(deriv(t,seluna'));
    figure;
    plot(in.range,b*365.25,'.')
    title('Gradients of unwrapped phase: median of time derivative');
    grid;
    % Calculate the time-derivative within each bin time series
    a = angle(in.spc)*in.rad2m;
    da = diff(a,1,2)./repmat(diff(in.t'),size(a,1),1)*365.25;
    mda = medfilt1(da,9,[],2);
    
    figure;
    subplot(ceil(sqrt(Nseg)),ceil(sqrt(Nseg)),1);
    for j = 1:Nseg
        subplot(ceil(sqrt(Nseg)),ceil(sqrt(Nseg)),j)
        y = mda(:,(j-1)*Offset+1:(j-1)*Offset+1+Seg-1);
        errbar(in.range, mean(y,2), std(y,[],2)/sqrt(size(y,2)));
        title([datestr(t((j-1)*Offset+1),19),' to ',datestr(t((j-1)*Offset+Seg),19)]);
    end
    ylabel('Velocity (m yr^{-1})');
    xlabel('Depth (m)');
    title('Time-averaged phase time-derivative')
    grid

end

if plot_ice_speed == 1
    figure
    imagesc(in.t(1:end-1),in.range,mda)
    datetick('x',4)
    caxis([-20,20]);
    title('Ice speed (m a^{-1})')
    ylabel('Depth (m)')
    xlabel('Month into 2015-2016')
    grid
end

if plot_ice_motion == 1
    figure
    cmda = cumsum(mda.*repmat(diff(in.t'),size(mda,1),1)/365.25,2);
    imagesc(in.t(1:end-1),in.range,cmda)
    datetick('x',4);
    title('Ice motion (m)')
    ylabel('Depth (m)')
    xlabel('Month into 2015-2016')
    grid
end

% n=20; s=1;
% fil = zeros(2*n+1,2*n+1);
% [x,y] = deal(repmat(-n:n,2*n+1,1)); y = y';
% fil = exp((-x.^2-y.^2)/(s*n));fil = fil/sum(fil(:));
% 
% figure
% imagesc(it,in.range,conv2(fdfiua',fil,'same'))
% caxis([-10 10]);
