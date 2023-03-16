function r = ct_phase2range(cfg,phi,Rcoarse)
% Convert phase difference to range for FMCW radar (Brenan: EQ15, EQ13 and two-way travel time formula for tagret range combined)
% Gives distance from centre of coarse range bin to effective reflector
%
% args:
% phi: phase (radians), must be of spectrum after bin centre correction
% Rcoarse: coarse range of bin centre (m)
%
% The struct cfg contains these fields:
% lambdac: wavelength (m) at centre frequency
% K = chirp gradient (rad/s/s)
% ci = propagation velocity in material (m/s)


lambdac = cfg.lambdac;
K = cfg.K;
ci = cfg.ci;

r = phi./((4*pi/lambdac) - (4*Rcoarse*K/ci^2));

% Rcoarse = repmat(Rcoarse',1,size(phi,1))'; % Repmat to same size as the
% time dimension of phi  - may need to do this in older versions

% % Craig uses first order method in fmcw_melt, but there is no obious advantage to using it since the precise one isn't hard to compute
% r = lambdac*phi./(4*pi);