function site = ct_calc_all_spectra(cfg,BurstList,FileList)
% This is the outer loop of Keith's calc_spectra

NBursts = size(BurstList,1);
cfg.NBursts = NBursts;
cfg.bad_burst.active = 0;

% Calculate spectra for all bursts
Nmin = 100;
if NBursts > Nmin
    h = waitbar(0,'Processing files'); %--Set up "waitbar" to indicate progress
end
ct_disp(cfg,['Starting to process ' num2str(NBursts) ' bursts'])

disp(['MHz range processed: ' num2str(cfg.f_range_processed/1e6)]);
disp(['Pad factor: ' num2str(cfg.pad_factor)]);

for burst = 1:NBursts  % for each burst
    
    cfg.burst_curr = burst;
    
    % Display file and burst information
    filename = FileList(BurstList(burst,1),:);
    burst_in_file = BurstList(burst,2);
    
    ct_disp(cfg,filename)
    ct_disp(cfg,['File #' num2str(filename) ', burst-in-file #' num2str(burst_in_file)])
        
    % Update the waitbar
    if NBursts > Nmin
        waitbar(burst/NBursts,h, ['Processing files: ',num2str(round(burst*100/NBursts),'%d%%')]);
    end

    % load the burst
    FileFormat = fmcw_file_format(filename);
    if FileFormat == 5
        vdat = LoadBurstRMB5(filename,burst_in_file,[]);
    elseif FileFormat == 4
        vdat = LoadBurstRMB4(filename,burst_in_file,[]);
    elseif FileFormat == 6
        vdat = LoadBurstRMB6(filename,burst_in_file);
    end  
    
    if vdat.Code ~= 0
        error('Problem reading file: %s Code = %d\n',FileList(BurstList(burst,1),:),vdat.Code);
    end
    
    if vdat.Nsamples ~= cfg.Nsamples && vdat.Nsamples ~= cfg.Nsamples + 1 && vdat.Nsamples ~= cfg.Nsamples*1.5 % This is here to take care of old files with 40001 and 60000 samples
        disp([num2str(vdat.Nsamples) ' vs. ' num2str(cfg.Nsamples)])
        error('Number of samples in vdat disagrees with processing settings in cfg')
    end
    
    % Check if burst is bad based on a manual select paramters
    clear lia loc loc2
    loc = find(strcmp(cfg.bad_burst.filename,{filename}));
    % Activate bad burst option
    if ~isempty(loc)
        %if burst_in_file == cfg.bad_burst.burst_in_file(loc)
            [lia,loc2] = ismember(burst_in_file,cfg.bad_burst.burst_in_file(loc));
            if lia == 1
                cfg.bad_burst.active = 1;
                cfg.bad_burst.chirp_index = cfg.bad_burst.chirpselect(loc(loc2));
            end
        %end
    end
    
    % Get chirp segment to work with
    if FileFormat == 6
        [meanchirp,cfg] = ct_get_meanchirp_IQ(cfg,vdat);
    else
        [meanchirp,cfg] = ct_get_meanchirp(cfg,vdat);
    end
    
    % Deactivate bad burst option
    cfg.bad_burst.active = 0;
    
    % Check chirp clipping
    cfg = ct_get_chirp_clipping(cfg,meanchirp);
    
%     % Extrapolate clipped bursts
%     if cfg.extrap_clipped_bursts == 1
%         [meanchirp,cfg] = ct_fill_clipped_meanchirp(cfg,meanchirp);
%         if burst == 1
%             disp('Carefull: extrapolating clipped points!!')
%         end
%     end
    
    % Calculate single chirp spectra
    if cfg.save_spec_raw == 1
        [spec_vec_raw,spec_vec_cor] = ct_calc_chirp_spectrum(cfg,meanchirp);
        site.spec_raw(burst,:) = spec_vec_raw;
    else
        [~,spec_vec_cor] = ct_calc_chirp_spectrum(cfg,meanchirp);
    end    
    site.spec_cor(burst,:) = spec_vec_cor;

    % Save the time and temperatures for the burst
    site.time(burst) = vdat.TimeStamp;
    site.T1(burst) = vdat.Temperature_1;
    site.T2(burst) = vdat.Temperature_2;    
end
site.cfg = cfg;

% Delete the wait bar
if NBursts > Nmin
    delete(h);
end