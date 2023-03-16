function [AF,dh,dhe] = ct_align_fine_TT(cfg,f,g,AC)
% This is subset of Craig's fmcw_melt, which aligns fine segments
dr = mean(diff(cfg.Rcoarse));
fit.maxDepth = cfg.maxRange;

%% ALIGN FINE: Estimate phase shift between profile segments by complex xcor

% complex correlation: xcor in small chunks to get good depth resolution
% this also gives us the AF.coherence of the segments
stepSizeM = cfg.chunkWidth; % bin width
binStart = [cfg.minDepth:stepSizeM:fit.maxDepth-cfg.chunkWidth]; % first bin edge

%for each bin....
for ii = 1:numel(binStart)
    depthRange = [binStart(ii) binStart(ii) + cfg.chunkWidth];
    binDepth = mean(depthRange); % Depth of bin center
    %maxlag = ceil(AC.maxOffset/dr); % max bin lags (based on maximum possible prescribed strain)
    fi = find((f.rangeCoarse>=min(depthRange) & f.rangeCoarse<max(depthRange))); % indices of coarse depth levels inside the specified bin of width stepSizeM
%     
%     if cfg.getFineErrorEstimate == 1
%         [AF.RANGEIND(ii,:),AF.AMPCOR(ii,:),AF.COR(ii,:),AF.LAGS(ii,:),AF.PE(ii,:),AF.PSE(ii,:)] = fmcw_xcorr_TT(f.specCor,g.specCor,fi,maxlag,f.phaseStdError,g.phaseStdError,cfg.pad_factor);
%     else
%         [AF.RANGEIND(ii,:),AF.AMPCOR(ii,:),AF.COR(ii,:),AF.LAGS(ii,:),AF.PE(ii,:),AF.PSE(ii,:)] = fmcw_xcorr_TT(f.specCor,g.specCor,fi,maxlag);
%     end
%     AF.RANGE(ii,:) = interp1(1:numel(f.rangeCoarse),f.rangeCoarse,AF.RANGEIND(ii,:));
% 
%     if cfg.doUseCoarseOffset % Define the bin lag from the coarse correlation
%         % Get coarse offsets at bin centres
%         if cfg.doPolySmoothCoarseOffset
%             AC.dhInterp = dr*polyval(AC.P,binDepth); % generate smoothed lags
%         else
%             AC.dhInterp = interp1(AC.range,AC.dh,binDepth,'linear','extrap'); %
%         end
%         [~,AF.mci(ii)] = min(abs(AC.dhInterp/dr-AF.LAGS(ii,:))); % bin lags index
%     else
%         [~,AF.mci(ii)] = max(AF.AMPCOR(ii,:)); % use best lag from fine cor
%     end
%     [~,aaa(ii)] = min(abs(AC.dhInterp/dr-AF.LAGS(ii,:))); % bin lags index
%     [~,bbb(ii)] = max(AF.AMPCOR(ii,:));
%     size(AF.AMPCOR(ii,:))
    %pause
    [AF.RANGEIND(ii,:),AF.AMPCOR(ii,:),AF.COR(ii,:),AF.LAGS(ii,:),AF.PE(ii,:),AF.PSE(ii,:)] = fmcw_xcorr_TT(f.specCor,g.specCor,fi,0);
    AF.RANGE(ii,:) = interp1(1:numel(f.rangeCoarse),f.rangeCoarse,AF.RANGEIND(ii,:));
    AF.mci(ii) = 1;
    
%     depthRange
%     [angle(mean(g.specCor(fi))) - angle(mean(f.specCor(fi))) angle(AF.COR(ii,:))]
%     pause
%     
    
    
end
AF.PHASECOR = abs(AF.COR)./AF.AMPCOR;
AF.lagvec = AF.LAGS(1,:);

%[aaa' bbb']
%pause



% Extract values at chosen offsets
igood = AF.mci;
for ii = 1:length(igood)
    AF.cor(ii) = AF.COR(ii,igood(ii)); % complex correlation at best amp correlation point
    AF.range(ii) = AF.RANGE(ii,igood(ii)); % bin centre range (weighted by amplitude of f.specCor.*g.specCor)
    AF.lags(ii) = AF.LAGS(ii,igood(ii));
    AF.ampCor(ii) = AF.AMPCOR(ii,igood(ii));
    AF.coherence(ii) = AF.COR(ii,igood(ii));
    AF.phaseCor(ii) = AF.PHASECOR(ii,igood(ii));
    AF.pe(ii) = AF.PE(ii,igood(ii));
    AF.pse(ii) = AF.PSE(ii,igood(ii));
end

% Calculate the total depth shift from the integer bin lags and the phase shift
AF.lagdh = AF.lags*dr; % coarse depth shift
AF.phasedh = ct_phase2range(cfg,-angle(AF.cor),AF.range); % fine depth shift, note: phase changes in opposite sense to range

dh = AF.lagdh + AF.phasedh; % range change between shots % Brennan et al. eq 14 and 15;
dhe = AF.pse*(cfg.lambdac/(4*pi)); % using the standard error of the phase difference estimated across the range bin

%Note, in the above AF.phasedh and -angle(AF.cor) end up being the same sign
%[sign(AF.phasedh')+sign(-angle(AF.cor)')]
%pause

dh = reshape(dh,1,length(dh));
dhe = reshape(dhe,1,length(dhe));

if cfg.doPlotAlignFine || cfg.doPlotAll
    figure
    
    sh = surf(transpose(AF.RANGE),transpose(AF.LAGS),transpose(abs(AF.COR)),transpose(angle(AF.COR)),'edgecol','none'); % ,transpose(AF.AMPCOR)
    set(sh,'alphadata',transpose(AF.AMPCOR))
    
    view(0,90)
    ylabel('bin lag')
    xlabel('depth (m)')
    colormap jet
    set(gca,'clim',[-pi pi])
    ch = colorbar('East');
    ylabel(ch,'phase diff')
    set(gca,'ydir','normal')
    hold on
    plot3(AF.range,AF.lagvec(AF.mci),pi*ones(size(AF.range)),'k.','markersize',30); % best amp
    h(2) = plot3(AF.range,AF.lagvec(AF.mci),pi*ones(size(AF.range)),'w.','markersize',20); % best amp
    title('Phase difference from x-cor')

end

