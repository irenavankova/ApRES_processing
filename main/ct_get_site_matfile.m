% Process files and get a structure containing the spectra at this site
% Check clipping and other burst characteristics which may indicate falty
% bursts


%--------------------------------------------------------------
% Define/load processing parameters and dalculate derived constant
cfg = ct_site_param_processing;
cfg = ct_calc_derived_constants(cfg);

if cfg.first_burst_infile_only ~= 0 || cfg.burst_subset_on ~= 0
    disp('Only a subset of bursts will be processed')
    disp('Check settings in ct_site_processing_param.m')
end

% Add folder to path
folderName = fullfile(cfg.myDirPath);
addpath(genpath(folderName));

%--------------------------------------------------------------
% Some settings were added into the code later. Those are manual exception handling of bad bursts and chirps.
% If these options are undefined in "ct_site_param_processing.m" all bursts and chirps are processed
cfg = ct_handle_undefined_settings(cfg);

%--------------------------------------------------------------
% Load filelist of .DAT files from a folder defined in ct_processing_param
[FileList,BurstList] = ct_load_filelist(cfg);

%--------------------------------------------------------------
% Calculate spectra for all bursts: needed for either approach
site = ct_calc_all_spectra(cfg,BurstList,FileList);

%--------------------------------------------------------------
% Save site file
save([cfg.output_mat_file_name '.mat'],'site');

% Save site file name
sitename = cfg.output_mat_file_name;
save('sitename.mat','sitename');

%--------------------------------------------------------------
% Plots

% Check clipping
ct_plot_clipping(site.cfg)

% Plot return amplitude
ct_plot_amp_pcolor(site)

% Plot burst variance
ct_plot_burst_variance(site.time,site.cfg)

%--------------------------------------------------------------
% Get timestemp of first and last time for each instrument subfolder
% This might not work for all folder structures
% try 
%     tstemp = ct_get_site_folder_timestemp(cfg.myDir);
%     save([cfg.output_mat_file_name '_first_last_tstemp.mat'],'tstemp');
% catch
%     disp('Folder structure not saved')
% end

% Remove folder from path
rmpath(genpath(folderName));
