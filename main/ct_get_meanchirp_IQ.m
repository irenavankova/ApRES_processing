function [meanchirp,cfg] = ct_get_meanchirp_IQ(cfg,vdat)
%This averages all chirps of a given attenuator setting to produce a mean
%chirp. If something fancier is needed, create more options within this
%function, or replace it

% Need to define:
% cfg.bad_burst.tstemp
% cfg.bad_burst.chirpselect
% cfg.bad_burst.active
% cfg.num_chirps_to_process

if vdat.NAttenuators > 1
    error('IQ has too many attenuators')
end

%Process limited number of bursts
if isfield(cfg,'num_chirps_to_process')
    chmax = cfg.num_chirps_to_process*vdat.NAttenuators;
else
    chmax = vdat.ChirpsInBurst;
end

%quality check of input
if chmax > vdat.ChirpsInBurst || chmax < 1
    chmax = vdat.ChirpsInBurst;
    disp(['Reset number of chirps to vdat.ChirpsInBurst = ' num2str(vdat.ChirpsInBurst) ])
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

% Initialise the vector used to average the chirps in the burst

Ib=double(vdat.v(1:2:end));
Qb=double(vdat.v(2:2:end));
Ib = reshape(Ib,cfg.Nsamples,vdat.ChirpsInBurst);
Qb = reshape(Qb,cfg.Nsamples,vdat.ChirpsInBurst);
I = mean(Ib(:,chmin:chmax),2);
Q = mean(Qb(:,chmin:chmax),2);

size(I)
size(Q)

if cfg.IQ_process == 1
    meanchirp = complex(I,Q);
elseif cfg.IQ_process == -1
    meanchirp = I;
elseif cfg.IQ_process == -1*1i
    meanchirp = Q;
end
    

% Average the chirps from selected attenuator to a mean chirp without
% discrimination
cfg.chirp_manual_select(cfg.burst_curr) = 0;
cfg.burst_std_of_chirp_std(cfg.burst_curr) = 0;
cfg.burst_std(cfg.burst_curr) = std(I) + 1i*std(Q);
cfg.num_chirps_in_burst(cfg.burst_curr) = chmax;


% Choose chirp signal portion: take only the part of the chirp that f0 and f1 parameters indicate 
meanchirp = meanchirp(cfg.s1:cfg.s2);

% Make sure vif has even number of steps - important when padding
if mod(length(meanchirp),2) == 1
    %meanchirp = meanchirp(1:end-1); %shouldn't do this because the size of N affects other constants
    error('Chirp segment must have even number of samples')
end

meanchirp = reshape(meanchirp,1,length(meanchirp)); % Make sure it is a column vector