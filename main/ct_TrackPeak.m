% Tracks a peak during an ApRES time series.  Requires the spectra dataset
% (as given by calc_spectra) as an input.
%
% Optional parameter pairs:
%
%   'minamp, maxamp' (default -90, -10) Limits for amplitude plot (dB)
%
%   'vis' (default 1) 1 means monitor plot during tracking, 0 otherwise
%   (much quicker) 'vid' (default 0) If vis is 1, create video file
%
%   'search' (default 3) +/- search is window (in bins)over which routine
%   searches for a peak, or number of bins before start bin from which to
%   search for the threshold crossing.
%
%   'mu' (<=1, default = 0.01) is a multiplier that
%   determines sensitivity of tracking. A large mu means higher
%   sensitivity, which will be more likely to result in flicker as bins are
%   crossed. An mu of 1 removes the effect of the hysteresis completely, an
%   mu of zeros would mean the bin number would never change, which means
%   the peak could not be tracked past bin boundaries.
%
%   'peak' (default 1) determines whether search for peak or threshold
%
%   'interp' (default 1/12) determines interpolation interval for
%   calculated vertical velocity
%
%   out = TrackPeak(in,varargin)

function tp = ct_TrackPeak(tp,site)

% Note: conversion between phase and distance assumes that quadratic term
% in Brenan: EQ15 is small!!

if isfield(tp,'x_input')
    x_input = tp.x_input;
    xs = x_input;
    threshold = tp.threshold;
end

if isempty(tp)
    tp.peak = 1;
    tp.MaxAmp = -50;
    tp.MinAmp = -100;
    tp.vis = 0;
    tp.vid = 0;
    tp.search = 3;
    tp.mu = 0.01;
    tp.opt_plot = 1;
    tp.opt_quad = 1;
end

if isfield(tp,'opt_quad') == 0
    tp.opt_quad = 1;
end

peak = tp.peak;
MaxAmp = tp.MaxAmp;
MinAmp = tp.MinAmp;
vis = tp.vis;
vid = tp.vid;
search = tp.search;
mu = tp.mu;

cfg = site.cfg;
Rcoarse = cfg.Rcoarse;
spc = site.spec_cor.'; % !! In Matlab .' is a transpose of complex number (' alone gives complex conjugate!!)
tim = site.time;

%Rcoarse = in.range(1:cfg.maxbin);
%spc = in.spc(1:cfg.maxbin,:);
%tim = in.t(1:cfg.maxbin);

m2bin = cfg.m2bin;
bin2m = cfg.bin2m; % Conversion from bin number (in depth domain) to depth in metres
rad2m = cfg.rad2m_approx; % Conversion from radians of phase to metres using approximate formula: (Brennan EQ15)
maxbin = cfg.maxbin;

% Create figure to allow us to select peak that we wish to track
fighan = figure;abshan = plot(Rcoarse,20*log10(abs(spc(:,1))));
hold

%IV: Interactive peak choosing if desired
if ~exist('x_input') 
    % Get user input from cursor to select bin nearest peak
    [x,threshold] = ginput(1);

    % Zoom in around selected peak to get a closer look, then user selects
    % again (hopefully more precisely).
    xlim([x-10,x+10]);
    [xs,threshold] = ginput(1);
    disp('x_input and threshold:')
    [xs threshold]
    tp.x_input = xs;
    tp.threshold = threshold;
else
    xlim([xs-10,xs+10]);
end
xs = xs*m2bin;
% Round cursor output to nearest bin
xs = round(xs);

if peak
    % Search for local peak and plot line to mark it
    [tmp,ind] = max(abs(spc(xs-search:xs+search,1)));
else
    % Search for threshold and plot line to mark it
    ind = find(20*log10(abs(spc(xs-search:end,1)))>threshold,1,'first');
end
linhan = plot([xs-search-1+ind,xs-search-1+ind]*bin2m,ylim,'r');

% Pause so user can check that they are happy with the peak selection. User
% must press any key to continue
%disp('Press any key to continue');
%pause

% Calculate the (absolute) bin number of the peak
x = xs-search - 1+ind;

% Delete the vertical marker line, and write time and date to the figure
%delete(linhan);
txthan = text(xs-140,-15,datestr(tim(1)));

% Make vectors to write phase, amplitude and bin number to during tracking
Phase = ones(size(spc,2),1)*nan;
Bin = Phase;
Amp = Phase;

acc = 0.0; % accumulator used in action of hysteresis

% Set up structure to record a movie
F(size(spc,2)) = struct('cdata',[],'colormap',[]);

% For each averaged burst...
for i = 1:size(spc,2)
    if peak
        % find maximum in amplitude nearest starting bin
        [Amp(i),ind] = max(20*log10(abs(spc(x-search:x+search,i))));
    else
        % find first threshold transition from start bin
        ind = find(20*log10(abs(spc(x-search:x+search,i)))>threshold,1,'first');
    end
    % Get absolute bin number for the maximum
    xnew = x-search-1+ind;
    
    % Update accumulator
    acc = acc + (xnew-x)*mu;
    
    % If magnitude of accumulator is greater than 1, it's time to switch to
    % the new bin.
    if abs(acc) > 1
        x = xnew;
        acc = 0.0; % Reset accumulator
    end
    
    % Save phase and bin number in their respective vectors
    Phase(i) = angle(spc(x,i));
    Bin(i) = x;
    
    if vis
        % Rewrite marker line, time and date, and burst amplitude
        delete([linhan,abshan]);
        delete([abshan, txthan]);
        abshan = plot(Rcoarse(1:maxbin),20*log10(abs(spc(1:maxbin,i))),'linewidth',2);
        set(gca,'ylim',[MinAmp, MaxAmp]);
        xlim([xs-150,xs+40]*bin2m);
        try
            linhan = plot([x-search-1+ind,x-search-1+ind]*bin2m,[MinAmp, MaxAmp],'r');
        catch
            keyboard
        end
        txthan = text((xs-140)*bin2m,-15,datestr(tim(i)));
        
        % Refresh figure
        drawnow
        
        if vid
            % Place figure into the movie structure
            F(i) = getframe(gcf);
        end
    end
end

% Unwrap phase
unwrapped_phase = unwrap(Phase)*rad2m;

% Remove jumps from phase

%calculate the phase range corresponding to one bin:
%calculate how many times a wavelength fits to a bin and that is how many
%phase ranges there are in a cycle (1/that)
lambdac = cfg.lambdac;
bin_phase_range = bin2m/lambdac*2*pi; %this is phi Keith talks about
jump_size_theory = (2*pi-2*bin_phase_range)*rad2m;

% Identify jumps and store in an array
diffBin = diff(Bin);
ind_jumps = find(diffBin~=0);
jumps = Bin*0;
jumps(ind_jumps+1) = 1;

% Dejump according to theory
thick_theory = unwrapped_phase;
for j = 1:length(ind_jumps)
    numbins = Bin(ind_jumps(j)+1)-Bin(ind_jumps(j));
    thick_theory(ind_jumps(j)+1:end) = thick_theory(ind_jumps(j)+1:end) - jump_size_theory*numbins;
end

% Dejump with extrapolation/fill gaps
thick_extrap = unwrapped_phase;
for j = 1:length(ind_jumps)
    ijump = ind_jumps(j)+1;
    ytemp = thick_extrap(1:ijump);
    ytemp(end) = NaN;
    yextrap = fillgaps(ytemp);
    thick_extrap(ijump:end) = thick_extrap(ijump:end) - thick_extrap(ijump) + yextrap(end);
end

%---- Plot
if tp.opt_plot == 1
    
    % FIG 1 RAW
    figure('units','normalized','position',[0.01,0.01,0.48,0.9]);
    
    %----tracked bin number
    subplot(2,1,1)
    plot(tim,Bin); datetick('x',4); h = gca;
    title('Bin number')
    axis tight

    %----unwrapped phase
    subplot(2,1,2)
    plot(tim,unwrapped_phase);datetick('x',4); h = [h,gca];
    title('Unwraped phase')
    linkaxes(h,'x');

    % FIG 2 CLEAN
    figure
    
    tim_jumps = tim;
    tim_jumps(ind_jumps) = tim_jumps(ind_jumps+1);
    tim_jumps(ind_jumps+2) = tim_jumps(ind_jumps+1);
    
    %----dejumped
    h = [];
    subplot(3,1,1)
    y = thick_theory;
    yy = jumps*(max(y)-min(y))+min(y);
    plot(tim_jumps(1:length(yy)),yy,'b'); hold on
    plot(tim,y,'k'); datetick('x',4); hold on
    plot(tim,thick_extrap,'r'); datetick('x','mm'); hold on
    title('Dejumped unwraped phase')
    legend('jumps','theory','fillgap')
    axis tight
    h = [gca];

    %----dejumped and detrended
    subplot(3,1,2)
    y = detrend(thick_theory);
    yy = jumps*(max(y)-min(y))+min(y);
    plot(tim_jumps(1:length(yy)),yy,'b'); hold on
    plot(tim,y,'k'); hold on
    plot(tim,detrend(thick_extrap),'r'); datetick('x','mm'); hold on
    title('Dejumped and detrended unwraped phase')
    legend('jumps','theory','fillgap')
    axis tight
    h = [h,gca];

    %----bed peak amp
    subplot(3,1,3)
    y = Amp;
    yy = jumps*(max(y)-min(y))+min(y);
    plot(tim_jumps(1:length(yy)),yy,'b'); hold on
    plot(tim,y,'k');datetick('x','mm'); hold on
    title('Bed peak amplitude')
    h = [h,gca];
    axis tight
    linkaxes(h,'x');
end

tp.Bin = Bin;
tp.tim = tim;
tp.unwrapped_phase = unwrapped_phase;
tp.thickness = thick_extrap;
tp.thickness = tp.thickness-tp.thickness(1);
tp.Amp = Amp;
tp.jumps = jumps;
tp.cfg = cfg;

% Add apmplitude smoothing with a quadraticd
if tp.opt_quad == 1
    npts = 1;
    for j = 1:length(tp.tim)

        ind = tp.Bin(j)-npts:1:tp.Bin(j)+npts;
        amp = 20*log10(abs(site.spec_cor(j,ind)'))';
        xc = site.cfg.Rcoarse(ind);
        p = polyfit(xc,amp,2);

%         xf = xc(1):(xc(end)-xc(1))/100:xc(end);
%         yf = p(1)*xf.^2 + p(2)*xf + p(3);
%         [mm,im] = max(yf);
%         amp_quad(j) = mm;

        amp_quad(j) = (4*p(1)*p(3)-p(2)^2)/(4*p(1)); %vertex of prabola
        thick_quad(j) = -p(2)/(2*p(1)); %x location of parabola vertex
        focal_length(j) = 1/(4*p(1));
        
        ind = tp.Bin(j)-2:1:tp.Bin(j)+2;
        amp = 20*log10(abs(site.spec_cor(j,ind)'))';
        xc = site.cfg.Rcoarse(ind);
        p = polyfit(xc,amp,2);
        amp_quad_5pt(j) = (4*p(1)*p(3)-p(2)^2)/(4*p(1)); %vertex of prabola
        thick_quad_5pt(j) = -p(2)/(2*p(1)); %x location of parabola vertex
        focal_length_5pt(j) = 1/(4*p(1));
        
        ind = tp.Bin(j)-npts:1:tp.Bin(j)+npts;
        amp = abs(site.spec_cor(j,ind)')';
        xc = site.cfg.Rcoarse(ind);
        p = polyfit(xc,amp,2);
        amp_quad_nolog(j) = 20*log10((4*p(1)*p(3)-p(2)^2)/(4*p(1))); %vertex of prabola
        thick_quad_nolog(j) = -p(2)/(2*p(1)); %x location of parabola vertex
        focal_length_nolog(j) = 1/(4*p(1));    
    end

    tp.thick_quad = (thick_quad-thick_quad(1))';
    tp.Amp_quad = amp_quad';
    tp.focal_length = focal_length';
    
    tp.thick_quad_5pt = (thick_quad_5pt-thick_quad_5pt(1))';
    tp.Amp_quad_5pt = amp_quad_5pt';
    tp.focal_length_5pt = focal_length_5pt';
    
    tp.amp_quad_nolog = amp_quad_nolog';
    tp.thick_quad_nolog = (thick_quad_nolog-thick_quad_nolog(1))';
    tp.focal_length_nolog = focal_length_nolog';
    
    if tp.opt_plot == 1
        figure
        plot(tp.tim,tp.Amp); hold on
        plot(tp.tim,amp_quad); hold on
        legend('raw','smoothed')
        
        figure
        plot(tp.tim,detrend(tp.thickness)); hold on
        plot(tp.tim,detrend(tp.thick_quad)); hold on
        plot(tp.tim,detrend(tp.thick_quad_nolog)); hold on
        legend('trackpeak','quad','quad no log')
    end
end

%delete(fighan);

return



