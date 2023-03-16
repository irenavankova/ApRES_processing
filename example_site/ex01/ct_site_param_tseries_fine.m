function cfg = ct_site_param_tseries_fine(cfg)
% Define subset of bursts used for the coarse timeseries, make it ~0.5-1
% month

% Subset of bursts to use
cfg.tseries_burst_first = 1; % Index of first burst
cfg.tseries_burst_spacing = 1;  % Spacing between processed bursts
cfg.tseries_burst_last = cfg.NBursts; % Index of last burst (put cfg.Nbursts if you want them all)

% Return correlation coef option

cfg.return_xcorrelation_coef = 1;

% Name of file to save (can overwrite default)
% Default = cfg.output_mat_fname_tseries_coarse = [cfg.output_mat_file_name '_ts_coarse'];

%--------------------------------------------------------------
% Phase unwrapping does not require any additional parameters
% fmcw_melt-like displacement timeseries parameters are defined next,
% they should be motivated by initial fmcw_melt test run
%--------------------------------------------------------------

% Bulk allignment lag matching (co-registration) - relevant for ct_align_upper_internals.m
cfg.doBulkAllignment = 0; % Yes = 1 or no = 0
cfg.bulkAlignRange = [40 80]; % Depth to amplitude correlate and allign over
cfg.maxOffsetM = 10; % 10m recoverable offset near surface
cfg.goodCorrCutoff = 0.8; % Good correlation cutoff, give warning if lower than this and do nothing

% Coarse chunk lag matching (depth-dependent co-registration) - allign coarse
% segments - relevant for ct_align_coarse.m
% Note that coarse allignment is only relevant when cfg.doUseCoarseOffset = 1
cfg.minDepth = 10; % to avoid breakthrough and cables etc (cables 2m in 2013, 5m in 2013).
cfg.bedBuffer = 10; % m buffer to exclude spectral leakage from bed return
cfg.coarseChunkWidth = 15; % long segments more uniquely define lag - except if there is high strain
cfg.maxStrain = 0.005; % maximum strain magnitude to search for 0.005
cfg.minAmpCor = 0.9; % Minimum amplitude correlation to use
cfg.minAmpCorProm = 0.05; % Minimum difference between max correlation and next best local maximum

% Fine chunk lag matching (Chunk phase difference) - allign coarse
% segments - relevant for ct_align_fine.m
cfg.doUseCoarseOffset = 1; % uses coarse offset determined above to specify rough lag for fine offset (otherwise 
cfg.doPolySmoothCoarseOffset = 1; % otherwise does interp1
cfg.polyOrder = 1; % Order of polynomial fit through the lags in allign coarse
cfg.chunkWidth = 4; % between 4 to 8 is a good compromise

% % Error estimation param needed for ct_align_coarse.m, but no other
% option than 0 is implemented
cfg.getCoarseErrorEstimate = 0; % Decide whether want to compute that or not
cfg.getFineErrorEstimate = 0; % Decide whether want to compute that or not

% cfg.errorMethod = 'assumedNoiseFloor'; % 'empirical' 'assumedNoiseFloor'
% cfg.noiseFloordB = -100; % Assumed level of noise
%
% % Line fitting parameters
% cfg.mvsr_linear_fit = 'LeastSquares';

% Plots (all)
cfg.doPlotAll = 0; % plot lots of other stuff

% Individual control of all plots
cfg.doPlotAlignBulk = 0;
cfg.doPlotAlignCoarse = 0;
cfg.doPlotAlignFine = 0;