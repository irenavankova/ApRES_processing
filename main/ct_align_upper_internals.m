function [AB,f,g] = ct_align_upper_internals(cfg,f,g)
% This is subset of Craig's fmcw_melt
% This function takes two ApRES chirps and alligns them vertically by
% amplitude correlation - and it is a subset of fmcw_melt.
% This is useful when the chirps are well separated in time, and when there
% have been significant changes at the surface (melt, accumulation, etc.)


% ALIGN BULK: Bulk Align upper internals (to keep the search window smaller for the fine scale correlation)

% Allign internal layers to account for changes in cable length surface
% accumulation and firn compaction using xcor. Note this only offsets to
% the closest integer range bin.
if cfg.verbose == 1
    disp(['Co-registering profiles using amplitude cross-correlation'])
    disp(['> depth range: ' mat2str(cfg.bulkAlignRange)])
    disp(['> max offset : ' mat2str(cfg.maxOffsetM)])
end
fi = find((f.rangeCoarse>=min(cfg.bulkAlignRange) & f.rangeCoarse<max(cfg.bulkAlignRange))); % depth bins to use (f)
maxlag = ceil(cfg.maxOffsetM/cfg.bin2m); % max bin lags
[~,AB.ampCor,~,AB.lags] = fmcw_xcorr(f.specCor,g.specCor,fi,maxlag);
[AB.maxCor,ii] = max(AB.ampCor); % get index (mci) of best amplitude correlation
AB.n = AB.lags(ii); % n is the number of steps a2 should be shifed right to match a1
dr = mean(diff(cfg.Rcoarse));
AB.shift = AB.n*dr;

%disp(['correlation =  ' num2str(AB.maxCor) ])
if AB.maxCor < cfg.goodCorrCutoff
    disp(['Warning: poor correlation in bulk internal allignment - check files'])
    disp('No offset was executed')
    disp(' ')
end
% Apply the offset to shot 2 to make this match shot 1
if AB.n==0
    disp('Internals match - no offset required')
    disp(' ')
else
    disp(['Shifting profile 2, ' int2str(AB.n) ' steps left to align internals. (' num2str(AB.n*dr) 'm)'])
    disp(' ')
    g.specRawUnshifted = g.specCor; % keep a copy of g.specCor for plotting
    g.specCorUnshifted = g.specCor; % keep a copy of g.specCor for plotting
    try
        g.specRaw = circshift(g.specRaw,[0 -AB.n]); % lagg offset
    end
    g.specCor = circshift(g.specCor,[0 -AB.n]); % lagg offset
    try
        g.rangeFine = circshift(g.rangeFine,[0 -AB.n]); % lagg offset
    end

    if cfg.doPlotAlignBulk || cfg.doPlotAll
        % plot before and after offset
        figure
        plot(f.rangeCoarse,dB(abs(f.specCor)),'r');
        hold on
        plot(g.rangeCoarse,dB(abs(g.specCorUnshifted)),'b');
        plot(g.rangeCoarse,dB(abs(g.specCor)),'k');
        legend('shot1','shot2','shot2 shifted')
        title(['Profile bulk co-registration, depth range: ' mat2str(cfg.bulkAlignRange) ' m'])
        set(gca,'xlim',cfg.bulkAlignRange)
%            set(gcf,'pos',[232 554 560 420])
    end
end
