function [meanchirp,cfg] = ct_get_meanchirp_V0(cfg,vdat)
%This averages all chirps of a given attenuator setting to produce a mean
%chirp. If something fancier is needed, create more options withing this
%function, or replace it

% Initialise the vector used to average the chirps in the burst
v = zeros(vdat.Nsamples,1);

% Average the chirps from selected attenuator to a mean chirp without
% discrimination
num_chirps = 0;
clear chirp_var
for k = cfg.attenuator:vdat.NAttenuators:vdat.ChirpsInBurst % For each chirp in the burst
    if length(vdat.v) >= vdat.Endind(k)
        % Sum the chirps into vector v
        v_now = vdat.v(vdat.Startind(k):vdat.Endind(k));
        v = v + v_now;
        num_chirps = num_chirps + 1;
        chirp_var(num_chirps) = std(v_now);
    end
end
meanchirp = double(v/num_chirps);
cfg.burst_std(cfg.burst_curr) = std(meanchirp);
cfg.burst_std_of_chirp_std(cfg.burst_curr) = std(chirp_var);

% Take care of old type of files which had 40001 samples - take away last datapoint
if vdat.Nsamples == cfg.Nsamples + 1
    meanchirp = meanchirp(1:end-1);
end

% Choose chirp signal portion: take only the part of the chirp that f0 and f1 parameters indicate 
meanchirp = meanchirp(cfg.s1:cfg.s2);

% Make sure vif has even number of steps - important when padding
if mod(length(meanchirp),2) == 1
    %meanchirp = meanchirp(1:end-1); %shouldn't do this because the size of N affects other constants
    error('Chirp segment must have even number of samples')
end

meanchirp = reshape(meanchirp,1,length(meanchirp)); % Make sure it is a column vector