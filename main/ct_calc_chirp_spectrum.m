function [spec_raw,spec_cor] = ct_calc_chirp_spectrum(cfg,meanchirp)
%Calculate chirp spectrum, follows Keith's inner for loop of calc_spectra (but checked
%fmcw_range does the same thing, up to a factor of two in the fft scaling
%factor)
%
% spec_raw is usually just used for plotting 
% spec_cor is phase shifted to a phase reference (Brenan: EQ17) and this is
% the quantity used in fmcw_plot-type processing and also in calc_spectra
% whenever phaseref = 1 (optional parameter)

vif = meanchirp;

%-------------
% Parameters
p = cfg.pad_factor;
N = cfg.N;
comp = cfg.comp;
maxbin = cfg.maxbin;

%-------------
% Get chirp ready for fft

% De-mean signal (weight)
vif = vif - mean(vif);

% Apply pre-fft window (Blackman usually)
win = window(cfg.winFun,N);
win = reshape(win,size(vif,1),size(vif,2));
vif = vif.*win;

% Zero-pad and shift centre of deramped signal to t=0
xn = round(0.5*(N));
vifpad = zeros(1,p*N);
vifpad(1:length(vif)) = vif;
vifpad = circshift(vifpad,-xn); % signal time shifted so phase centre at start

%-------------
% Carry out the fft to convert from the time domain into the depth
% domain and insert into the spectra array.

% Take FFT and scale (note that Keith's scaling factor is bigger by a factor of two, uses N and not length(vifpad))
fftvif=(sqrt(2*p)/length(vifpad))*fft(vifpad);
fftvif = fftvif./rms(win); % Compensate for window
%fftvif = fftvif.';
spec_raw = fftvif(1:round(p*N/2-0.5)); % positive frequency half of spectrum (padding included)
spec_raw = reshape(spec_raw,1,length(spec_raw));

% Substract reference phase from positive half of the spectrum 
comp = reshape(comp,size(spec_raw,1),size(spec_raw,2));
spec_cor = spec_raw.*comp; % phase-corrected spectrum, used in Keith calc_spectra by default, see (Brenan: EQ17)

%-------------
% Crop output variables to useful depth range only
spec_raw = spec_raw(:,1:maxbin);
spec_cor = spec_cor(:,1:maxbin);
