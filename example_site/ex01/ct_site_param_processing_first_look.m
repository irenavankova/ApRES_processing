function cfg = ct_site_param_processing_first_look

cfg = ct_site_param_processing;

% Subset of bursts limited by first and last file to consider
cfg.burst_subset_end_files = 1;
cfg.burst_subset_first_file = 'DATA2016-01-16-1428.DAT';
cfg.burst_subset_last_file = 'DATA2016-01-25-1728.DAT';
