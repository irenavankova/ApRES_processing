function cfg = ct_calc_derived_constants(cfg)
% Definitions of these are found throughout the following files:
% fmcw_derive_parameters.m and fmcw_load.m
%-Changes:
%!Changed ceil to round for cfg.s1 and cfg.s2 on 2019-08-08

% Translate those that need now
c = cfg.c;
er = cfg.er;
f0 = cfg.f_range_processed(1);
f1 = cfg.f_range_processed(2);
p = cfg.pad_factor;
f0_native = cfg.f_range_native(1);
f1_native = cfg.f_range_native(2);
fs = cfg.fs;

%---------------
% Compute derived constants

% Check pad factor
p_min = ceil(mean([cfg.f_range_processed])/(abs(diff((cfg.f_range_processed)))));
if p < p_min
    disp('Pad factor too small!')
    disp(['Need at least p = ' num2str(p_min)])
    disp('press enter to continue with wrong pad factor')
    pause
end

% Some other constants needed to get the range scale correct.
cfg.fc = (f0 + f1)/2; fc = cfg.fc; % Center frequency (Hz)
cfg.B = f1 - f0; B = cfg.B; % Bandwidth of the selected segment of the chirp (Hz)
cfg.ci = c/sqrt(er); % velocity in material (ice)
cfg.lambdac = cfg.ci/cfg.fc; % Centre wavelength

cfg.m2bin = 2*sqrt(er)*p*B/c; % Conversion between meter and bin (Brenan: above EQ16)
cfg.bin2m = 1/cfg.m2bin;
cfg.rad2m_approx = cfg.ci/(4*pi*fc); % Conversion between meter and radian - needed for trackpeak
cfg.T = cfg.Nsamples/cfg.fs; % Time interval during which chirp was collected (t_end-t_start)
cfg.K = (f1_native - f0_native)/cfg.T; % Chirp gradient (ramp): slope on frequency-chirp time graph
cfg.Krad=2*pi*cfg.K; % Chirp gradient in rad/s/s (200MHz/s) (Brenan: EQ11)

% Define chirp segment portion for processing and the start/end index
% !Changed ceil to round
cfg.s1 = round((f0 - f0_native)/cfg.K * fs)+1; % First chirp index considered
cfg.s2 = round((f1 - f0_native)/cfg.K * fs); % Last chirp index considered
cfg.N = cfg.s2 - cfg.s1 + 1; % number of samples in chirp segment = length(chirp)

% Make sure that chirp segment has even number of samples (due to padding)
if mod(cfg.N,2) ~= 0
    cfg.s2 = cfg.s2-1;
    cfg.N = cfg.s2 - cfg.s1 + 1; % number of samples in chirp segment = length(chirp)
end

% Calculate reference phase (Brenan: EQ17)
m = 0:round(p*cfg.N/2-0.5)-1;
m = m/p;
cfg.m = m;
cfg.phiref=2*pi*cfg.fc.*m/B-cfg.Krad*m.*m/2/B/B; % reference phase (Brenan: EQ17)
cfg.comp = exp(-1i*(cfg.phiref)); % unit phasor with conjugate of phiref phase (Brenan: EQ17)

% Calculate coarse depth
cfg.maxbin = round(cfg.m2bin * cfg.maxRange); % Extract the maximum index, which corresponds to max desired depth
cfg.maxbin = min([cfg.maxbin p*cfg.N/2]); % In case maximum possible depth is less than desired depth
cfg.Rcoarse = cfg.bin2m * (1:cfg.maxbin); % Coarse depth (Brenan: above EQ16)
cfg.Rcoarse = reshape(cfg.Rcoarse,1,length(cfg.Rcoarse)); % Make sure it is a column vector

