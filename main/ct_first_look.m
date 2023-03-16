% Process files and get a structure containing the spectra at this site
% Check clipping and other burst characteristics which may indicate falty
% bursts

%--------------------------------------------------------------
% Define/load processing parameters and dalculate derived constant
cfg = ct_site_param_processing_first_look;
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
%[FileList,BurstList] = ct_load_filelist(cfg);
cfg.myDir
cfg.first_burst_infile_only = 1;
FileDir = dir(fullfile(cfg.myDir,'*.DAT'));
ind = find(strcmp({cfg.burst_subset_first_file},{FileDir.name}) == 1);
FileList(1,:) = FileDir(ind).name;
ind = find(strcmp({cfg.burst_subset_last_file},{FileDir.name}) == 1);
FileList(2,:) = FileDir(ind).name;
ct_disp(cfg,'Extracting list of bursts from filelist')
BurstList = CreateBurstList(FileList,'firstonly',cfg.first_burst_infile_only,'cfg',cfg);

%--------------------------------------------------------------
% Calculate spectra for all bursts: needed for either approach
site = ct_calc_all_spectra(cfg,BurstList,FileList);

%--------------------------------------------------------------
% Plots

% Check clipping
ct_plot_clipping(site.cfg)

% Plot return amplitude
figure
plot(site.cfg.Rcoarse,20*log10(abs(site.spec_cor(1,:)')),'r'); hold on
plot(site.cfg.Rcoarse,20*log10(abs(site.spec_cor(end,:)')),'b'); hold on
legend('first','last')
xlabel('Depth (m)')
ylabel('dB')
axis tight; grid on

