% Get a thickness timeseries using track peak
% Requires user input to identify basal reflector in the first shot

load('sitename.mat')
load([sitename '.mat'])
out_fname = [sitename '_bed.mat'];

% Track peak using default paramters
tp = ct_TrackPeak([],site);
save(out_fname,'tp')