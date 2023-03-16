function cfg = ct_handle_undefined_settings(cfg)
% Some settings were added into the code later. Those are manual exception handling of bad bursts and chirps.
% If these options are undefined in "ct_site_param_processing.m" all bursts
% and chirps are processed without discrimination
% However some default/empty definitions need to take place so that is take
% care of here.

% Handle exception if bad_burst options are undefined.
% In that case all chirps are used in averaging
if isfield(cfg,'bad_burst') == 0
    cfg.bad_burst.filename = [];
    cfg.bad_burst.burst_in_file = [];
    cfg.bad_burst.chirpselect = [];
end

% One can discriminate chirps based on several options, e.g std, extreme
% values, but defaul is 'none'
if isfield(cfg,'chirp_quality_test') == 0
    cfg.chirp_quality_test.type = 'none';
    cfg.chirp_quality_test.range = [];
    cfg.chirp_quality_test.tol_num_over = 0;
end

% Choose subset of files based on filename
if isfield(cfg,'burst_subset_end_files') == 0
    cfg.burst_subset_end_files = 0;
    cfg.burst_subset_first_file = [];
    cfg.burst_subset_last_file = [];
end

% % Fill gaps for localized small clippings
% if isfield(cfg,'extrap_clipped_bursts') == 0
%     cfg.extrap_clipped_bursts = 0;
% end