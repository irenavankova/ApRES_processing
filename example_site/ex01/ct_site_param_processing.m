function cfg = ct_site_param_processing

%--------------------------------------------------------------
% Spectral processing options needed for either approach
%--------------------------------------------------------------

% Directory with files to be processed
cfg.myDirPath = '/Volumes/GoogleDrive/My Drive/Research/DOVuFRIS/Fris_Apres/Fris_data/data2test_processing/ex01'; 

cfg.myDir = [cfg.myDirPath '/**/'];

cfg.output_mat_file_name = 'ex01';
cfg.output_mat_fname_tseries_fine = [cfg.output_mat_file_name '_ts_fine'];
cfg.output_mat_fname_tseries_coarse = [cfg.output_mat_file_name '_ts_coarse'];

% % Bad burst option (if not define defaults are assigned)
% % MANUAL SELECT
% cfg.bad_burst.filename = [];
% cfg.bad_burst.burst_in_file = [];
% cfg.bad_burst.chirpselect = [];
% % APPROACH
% cfg.chirp_quality_test.type = 'none';
% cfg.chirp_quality_test.range = [];
% cfg.chirp_quality_test.tol_num_over = [];
% 
% % Subset of bursts limited by first and last file to consider
% cfg.burst_subset_end_files = 0;
% cfg.burst_subset_first_file = [];
% cfg.burst_subset_last_file = [];

% Subset of bursts to choose (set options to 0 to process all bursts)
cfg.first_burst_infile_only = 0; %Set to 1 if want only first burst in each file
cfg.burst_subset_on = 0; % Set to 1 if want a limited number of bursts for processing and set the next thee parameters
cfg.burst_start_index = 1; % Index of first burst
cfg.burst_spacing = 1;  % Spacing between processed bursts
cfg.burst_end_index = 1000000; % Index of last burst (put cfg.Nbursts if you want them all)

% Tunable radar processing constants
cfg.f_range_processed = [200e6 400e6]; % Frequency reange defines which chirp segment to process
cfg.attenuator = 1; % If multiple attenuator settings choose the prefered one
cfg.pad_factor = 2; % Pad factor used in the calculation of the spectra (DEPENDS ON BANDWIDTH!! - need at least 2 for full bandwidth to get depth bin smaller than the length of one wave form cycle)
cfg.maxRange = 460; % Maximum bed range
cfg.winFun = @blackman; % Window type used during fft processing

% Info from the header in a .DAT file 
cfg.time_step = 7200; % Time step between bursts (target time, not necessary to be correct - not used for anything in the processing, but it forces one to open one of .DAT files and look at the header!)

% Embeded radar processing constants - should be the same as the header
% information in loaded with fmcw_load or LoadBurstRMB5 directly (this is crosschecked later)
cfg.fs = 40000; % Sampling frequency of a chirp
cfg.Nsamples = 40000; % Number of samples in a chirp - should be same as sampling frequency since chirp time is aiming at 1 second
cfg.f_range_native = [200e6 400e6]; % Built in frequency range 
cfg.v_range = [0 2.5]; % Chirp voltage range in Volts

% Check clipping
cfg.v_tol = 0.05; % Distance from cfg.v_range which is already considered to be clipped

% Physical constants
cfg.er = 3.18; % Assumed permittivity of ice.
cfg.c = 3e8; % Speed of light in vacuum

% Output options
cfg.save_spec_raw = 0; % When turned on the raw spectrum with the unreferenced phase is also computed and output 
cfg.verbose = 1; % display results to screen