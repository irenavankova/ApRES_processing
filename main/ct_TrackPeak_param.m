

% Default:
tp.peak = 1;
tp.MaxAmp = -50;
tp.MinAmp = -100;
tp.vis = 0;
tp.vid = 0;
tp.search = 3;
tp.mu = 0.01;

% Bonus:
tp.opt_plot = 1;

% Site specific: (e.g. for R05)
%tp.x_input = 821.267281105991;
%tp.threshold = -84.1970802919708;
%out_fname = 'R05_bed.mat';

load('sitename.mat')
load([sitename '.mat'])
out_fname = [sitename '_bed.mat'];

% Find thickness:
tp = ct_TrackPeak(tp,site);
save(out_fname,'tp')

