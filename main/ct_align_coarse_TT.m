
function [AC,f,g] = ct_align_coarse_TT(cfg,f,g)
% This is subset of Craig's fmcw_melt, which aligns coarse segments
% The output is only used later on when cfg.doUseCoarseOffset = 1 in ct_processing_param

fit.maxDepth = cfg.maxRange;
dr = mean(diff(f.rangeCoarse));

%% ALIGN COARSE: Co-register profile segments (amplitude xcorr)
% Cross correlate internals gi segments to get vertical shift as a function of range
% xcor in big chunks to get minimum chance of wrapping errors.
AC.maxOffset = cfg.maxStrain*(fit.maxDepth-cfg.minDepth); %
AC.stepSizeM = 5; % cfg.coarseChunkWidth/2; %cfg.coarseChunkWidth/2;
binStart = [cfg.minDepth:AC.stepSizeM:fit.maxDepth-cfg.coarseChunkWidth]; % measure offset over a wider range to plot
[AC.range,AC.dh] = deal(zeros(size(binStart)));
for ii = 1:numel(binStart)
    depthRange = [binStart(ii) binStart(ii)+cfg.coarseChunkWidth];
    fi = find((f.rangeCoarse>=min(depthRange) & f.rangeCoarse<max(depthRange))); % depth bins to use (f)
    maxlag = ceil(AC.maxOffset/dr); % max bin lags
    [AC.RANGEIND(ii,:),AC.AMPCOR(ii,:),~,AC.LAGS(ii,:)] = fmcw_xcorr(f.specCor,g.specCor,fi,maxlag);
    AC.RANGE(ii,:) = interp1(1:numel(f.rangeCoarse),f.rangeCoarse,AC.RANGEIND(ii,:));
    [~,mci] = max(AC.AMPCOR(ii,:));
    AC.range(ii) = AC.RANGE(ii,mci); % bin centre range (weighted by amplitude of f.specCor.*g.specCor)
    AC.lags(ii) = AC.LAGS(ii,mci);
    AC.ampCor(ii) = AC.AMPCOR(ii,mci);
    AC.dh(ii) = dr*AC.lags(ii); % Range offset (m) between segments
    
    % Quality checks on best correlation
    % Check whether correlation is limited by maxlag
    if mci == 1 || mci == size(AC.LAGS,2) 
        AC.ampCor(ii) = 0;
    end
    % Check prominence of peak (how much better than the next match)
    if length(AC.AMPCOR(ii,:)) < 3 %findpeaks neads at least 3 arguments
        cpk = [];
    else
        [cpk,~] = findpeaks(AC.AMPCOR(ii,:),'sortstr','descend','npeaks',2);
    end
    if isempty(cpk) % no peaks!
        AC.ampCorProm(ii) = 0;
    elseif numel(cpk)==1
        AC.ampCorProm(ii) = 1; % this is the only maximum
    else
        AC.ampCorProm(ii) = cpk(1) - cpk(2); % Absolute prominence
    end
end
AC.isGood = AC.ampCor>=cfg.minAmpCor & AC.ampCorProm>=cfg.minAmpCorProm;

% Now fit a polynomial through the lags
AC.P = polyfit(AC.range(AC.isGood),AC.lags(AC.isGood),cfg.polyOrder);

if cfg.doPlotAlignCoarse || cfg.doPlotAll
    figure
    clear ax
    ax(1) = subplottight(3,1,1);
    ii = f.rangeCoarse<fit.maxDepth*1.1;
    cf_plotAmp(f,g,ii);
    title('Profile co-registration - amplitude cross-correlation')
    
    ax(2) = subplottight(3,1,2);
    %sh = surf(AC.RANGE',AC.LAGS',AC.AMPCOR','edgecol','none');
    sh = pcolor(AC.RANGE',AC.LAGS',AC.AMPCOR'); % ,'edgecol','none'
    shading interp
    view(0,90)
    caxis([0.9 1])
    ylabel('bin lag')
    ch = colorbar('East');
    ylabel(ch,'amplitude correlation')
    set(gca,'ydir','normal')
    hold on
    plot3(AC.range,AC.lags,ones(size(AC.range)),'w.') % all lags
    plot3(AC.range(AC.isGood),AC.lags(AC.isGood),ones(1,sum(AC.isGood)),'g.') % only good lags
    AC.lagsPoly = polyval(AC.P,f.rangeCoarse(ii)); % generate smoothed lags
    plot3(f.rangeCoarse(ii),AC.lagsPoly,ones(1,sum(ii)),'g') % poly fit to lags
    
    ax(3) = subplottight(3,1,3);
    plot(AC.range,AC.ampCor)
    ylabel('correlation')
    xlabel('depth')
    
    %set(gcf,'pos',[232 554 560 420])
    linkaxes(ax,'x')
    
    %keyboard
end

%% Estimate error
if cfg.getCoarseErrorEstimate == 1
    switch cfg.errorMethod
        case 'empirical'
            % Process each shot separately to get phase standard deviation at each depth
            % shot 1 (f.specCor)
            [~,~,F] = fmcw_range(f,cfg.pad_factor,cfg.maxRange,cfg.winFun);
            f.phaseStdDev = std(F)./abs(f.specCor); % phase standard deviation of the burst
            f.phaseStdError = f.phaseStdDev/sqrt(size(f.vif,1)); % phase standard error of the mean shot - using sqrt(n)
            % shot 2 (g.specCor)
            [~,~,G] = fmcw_range(g,cfg.pad_factor,cfg.maxRange,cfg.winFun);
            g.phaseStdDev = std(G)./abs(g.specCor); % phase standard deviation of the burst
            g.phaseStdError = g.phaseStdDev/sqrt(size(g.vif,1)); % phase standard error of the mean shot - using sqrt(n)
        case 'assumedNoiseFloor'
            % Error estimate by assuming a noise level and calculating phase
            % noise from this
            noiseFloor = 10.^(cfg.noiseFloordB/20);
            f.phaseStdError = noiseFloor./abs(f.specCor); % phase error shot 1
            g.phaseStdError = noiseFloor./abs(g.specCor); % phase error shot 2
    end
    f.rangeError = ct_phase2range(cfg,f.phaseStdError,f.rangeCoarse);
    g.rangeError = ct_phase2range(cfg,g.phaseStdError,g.rangeCoarse);
else
    f.phaseStdError = nan*f.specCor; % phase error shot 1
    g.phaseStdError = f.phaseStdError; % phase error shot 2
    f.rangeError = f.phaseStdError;
    g.rangeError = f.phaseStdError;
end

