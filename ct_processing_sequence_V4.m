%% START

% Create a new folder and put the following files in there (copy them from the example foulder and modify as needed:
ct_site_param_processing_first_look
ct_site_param_processing
ct_site_param_tseries_fine
ct_site_param_tseries_base

% Call all functions from this new folder!


%% CALCULATE SPECTRA

edit ct_site_param_processing

% Define at least the following parameters in "ct_site_param_processing.m"
% cfg.myDirPath ....... path to directory where all the .DAT files are located
% cfg.output_mat_file_name ....... site name for structure name
% cfg.attenuator ..... in case more than 1 attenuator were used, pick the one you want to process 
% cfg.maxRange ....... max depth to process data to
% cfg.f_range_processed ....... frequency range for processing
% cfg.pad_factor ..... depends on bandwidth and should be at least: ceil(mean([cfg.f_range_processed])/(abs(diff((cfg.f_range_processed)))))
% cfg.burst_subset_first_file ..... name of first file to look at
% cfg.burst_subset_last_file ..... name of second file to look at

edit ct_site_param_processing_first_look

% Put 2 file names in there to compare and plot with ct_first_look.m , this is useful to have a
% sense of the location of the basal reflector, and to detect any clipping,
% both of those plots are output
% cfg.burst_subset_first_file ..... name of first file to look at
% cfg.burst_subset_last_file ..... name of second file to look at

% Then run ct_first_look

ct_first_look

% This plots
% -first plot is to identify signal clipping - helps pick cfg.f_range_processed
% -second plot is the return amplitude - helps pick cfg.maxRange

% This will process just the end bursts so you can get a feel if you are
% happy with the above specs.
% If you are happy with those, run ct_get_site_matfile to calcualte spectra and to save matfile with spectra
% This matfile contains the structure 'site' which is used from here on 

ct_get_site_matfile

% Plots
% -first plot is to identify signal clipping - helps pick cfg.f_range_processed
% -second plot is the return amplitude - if there are vertical stripes then
% attenuator settings might not have been correctly picked up at times -
% this will create jumps in time series, and the data might need to be analyzed in segments 
% -third plot shows chirp and burst variance over time - can help identify
% bad chirps, and also changes in chirp characteristics over time, if jumps in amplitude are present, 
% they will likely be synchronized with burst variance jumps

% Tips
% -If signal clipped, repeat all with different cfg.f_range_processed
% -If jumps in amplitude or burst characteristics analyze in segments (need
% new folder and set of mat files for each segment)
% -If bad chirps, exclude them
% Repeat until happy with the three plots

% Output
% -This creates a matfile name.mat with the complex signal as a function of
% range for each time shot

%% CREATE XCORRELATION TIMESERIES 

% Get fine timeseries (use all shots, no skipping)
% Specify fine tseries processing parameters in "ct_site_param_tseries_fine.m"

edit ct_site_param_tseries_fine

% These are Craig's xcorrelation options reduced to (almost) minimum
% It is generally safe to run default options:

ct_get_site_tseries_TT

% The basic xcorrelation timeseries are saved in the matfile [sitename '_ts_fine.mat']

% Plots
% -first three plots show the displacement time series in different ways
% (lines at corresponding depths, detrended lines overlapped, pcolor plot)
% both xcorrelated and unwrapped timeseries are included - there should be
% a general agreement!! (except xcorrelated time series might have lots of
% jumps - fix that next)
% -fourth plot is the xcorrelation coefficient and its time evalution -
% gives indication of timeseries quality

% Output
% name_ts_fine_TT.mat is the output and it contains displacement timeseries
% together with crosscorrelation values, at specified range spacing


%% CREATE BASAL REFLECTOR TIMESERIES

% This can be done in many different ways and each can be appropriate at different ocassion, below are two methods:
% define a range bit that contains the basal reflector throughout the whole record in

edit ct_site_param_tseries_base

% and then run:

ct_get_basal_timeseries

% This will first run Keith's track that requires graphical user input - pick manually the basal reflector (there are optional parameters that can be given to ct_TrackPeak - but that has to be done manually)
% The basal reflector timeseries is saved in the matfile [sitename '_bed_tpq.mat']
% Then in runs the crosscorraltion and saves output in [sitename '_bed_xcor.mat']
% Plots - different stages of the creation of the timeseries (maybe not so
% interesting)
% Repeat until happy with your choice of base 
% The polyfit warnings are not relevant to the displacement time series and
% are fine to be ignored

%% PRELIMINARY PLOTS WITH THE PROCESSED DATA

edit ct_plot_prelim_V4.m

%and run segment by segment or all together. These are just some basic
%plots that can be then modified to look at the data in more detail.
