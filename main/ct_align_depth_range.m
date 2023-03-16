function [AF,dh,dhe] = ct_align_depth_range(cfg,f,g,depthRange)
% follows ct_align_fine.m: Estimate phase shift between profile segments by complex xcor
% single depth range only
% depthRange......defined by edge limits [d1 d2]

dr = mean(diff(f.rangeCoarse)); %bin thickness
maxlag = 0; % max bin lags between profiles
%for each bin....
for ii = 1:size(depthRange,1)
    binDepth = mean(depthRange(ii,:)); % Depth of depth range center
    fi = find((f.rangeCoarse>=min(depthRange(ii,:)) & f.rangeCoarse<max(depthRange(ii,:)))); % indices of coarse depth levels inside the specified bin of width stepSizeM
    [AF.RANGEIND(ii,:),AF.AMPCOR(ii,:),AF.COR(ii,:),AF.LAGS(ii,:),AF.PE(ii,:),AF.PSE(ii,:)] = fmcw_xcorr(f.specCor,g.specCor,fi,maxlag);
    AF.RANGE(ii,:) = interp1(1:numel(f.rangeCoarse),f.rangeCoarse,AF.RANGEIND(ii,:));
    %[~,AF.mci(ii)] = max(AF.AMPCOR(ii,:)); % use best lag from fine cor
    AF.mci(ii) = 1;
end
AF.PHASECOR = abs(AF.COR)./AF.AMPCOR;
AF.lagvec = AF.LAGS(1,:);

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

dh = reshape(dh,1,length(dh));
dhe = reshape(dhe,1,length(dhe));
