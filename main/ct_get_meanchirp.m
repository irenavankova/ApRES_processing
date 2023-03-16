function [meanchirp,cfg] = ct_get_meanchirp(cfg,vdat)
%This averages all chirps of a given attenuator setting to produce a mean
%chirp. If something fancier is needed, create more options within this
%function, or replace it

% Need to define:
% cfg.bad_burst.tstemp
% cfg.bad_burst.chirpselect
% cfg.bad_burst.active
% cfg.num_chirps_to_process

%Process limited number of bursts
if isfield(cfg,'num_chirps_to_process')
    chmax = cfg.num_chirps_to_process*vdat.NAttenuators;
else
    chmax = vdat.ChirpsInBurst;
end

if isfield(cfg,'skip_first_chirp')
    if cfg.skip_first_chirp == 1
        chmin = cfg.attenuator + vdat.NAttenuators;
    else
        chmin = cfg.attenuator;
    end
else
    chmin = cfg.attenuator;
end

%quality check of input
if chmax > vdat.ChirpsInBurst || chmax < 1
    chmax = vdat.ChirpsInBurst;
    disp(['Reset number of chirps to vdat.ChirpsInBurst = ' num2str(vdat.ChirpsInBurst) ])
end

% Initialise the vector used to average the chirps in the burst
v = zeros(cfg.Nsamples,1);

% Average the chirps from selected attenuator to a mean chirp without
% discrimination
num_chirps = 0;
cfg.chirp_manual_select(cfg.burst_curr) = 0;
clear chirp_var
%for k = cfg.attenuator:vdat.NAttenuators:vdat.ChirpsInBurst % For each chirp in the burst
%for k = cfg.attenuator:vdat.NAttenuators:chmax % For each chirp in the burst
for k = chmin:vdat.NAttenuators:chmax % For each chirp in the burst
    if length(vdat.v) >= vdat.Endind(k)
        % Sum the chirps into vector v
        v_now = vdat.v(vdat.Startind(k):vdat.Endind(k));
        % Take care of old type of files which had 60000 samples, but only first 40000 belonged to the chirp
        % + Take care of old type of files which had 40001 samples - take away last datapoint
        if vdat.Nsamples > cfg.Nsamples
            v_now = v_now(1:cfg.Nsamples);
        end
        cq = ct_chirp_quality_test(cfg,v_now);
        if cq == 1
            v = v + v_now;
            num_chirps = num_chirps + 1;
            chirp_var(num_chirps) = std(v_now);
            % If in bad burst, save the manually requested chirp
            if cfg.bad_burst.active == 1
                if num_chirps == cfg.bad_burst.chirp_index
                    chirpselect = v_now;
                    cfg.chirp_manual_select(cfg.burst_curr) = 1;
                end
            end
        end
    end
end
num_chirps

%Assign NaN if there were no good chirps
if num_chirps == 0
    meanchirp = v + NaN;
    cfg.burst_std_of_chirp_std(cfg.burst_curr) = NaN;
%Average of good chirps otherwise
else
    meanchirp = double(v/num_chirps);
    cfg.burst_std_of_chirp_std(cfg.burst_curr) = std(chirp_var);
end
cfg.burst_std(cfg.burst_curr) = std(meanchirp);
cfg.num_chirps_in_burst(cfg.burst_curr) = num_chirps;


% If this is a bad burst select a only one chirp (prescribed in "ct_siete_param_processing")
if cfg.bad_burst.active == 1
    if ~exist('chirpselect','var')
        meanchirp = zeros(cfg.Nsamples,1) + NaN;
    else
        meanchirp = chirpselect;
    end
    tstemp = datevec(vdat.TimeStamp);
    ct_disp(cfg,['Bad burst prescribed at timestemp ' num2str(tstemp)])
    if cfg.verbose == 1
        figure
        plot(meanchirp)
    end
end

% % Take care of old type of files which had 40001 samples - take away last datapoint
% if vdat.Nsamples == cfg.Nsamples + 1
%     meanchirp = meanchirp(1:end-1);
% end

% Choose chirp signal portion: take only the part of the chirp that f0 and f1 parameters indicate 
meanchirp = meanchirp(cfg.s1:cfg.s2);

% Make sure vif has even number of steps - important when padding
if mod(length(meanchirp),2) == 1
    %meanchirp = meanchirp(1:end-1); %shouldn't do this because the size of N affects other constants
    error('Chirp segment must have even number of samples')
end

meanchirp = reshape(meanchirp,1,length(meanchirp)); % Make sure it is a column vector