function [ct,ct2] = ct_dejump_xcor_tseries(opt_plot,opt_save)
% Remove jumps larger than jump_tol (if empty or undifined jump_tol_default = 0.05 in ct_remove_jumps_xcor)
jump_tol = [];
if nargin < 1
    opt_plot = 0;
end
if nargin < 2
    opt_save = 0;
end

load sitename.mat
load([sitename '_ts_fine.mat']);

if opt_plot == 1
    ct_plot_xcor_vs_uwrp_lines(ct)
    ct_plot_xcor_vs_uwrp_colapsed(ct)
end

ct2 = ct_remove_jumps_xcor_all(ct,opt_plot,jump_tol);

if opt_plot == 1
    ct_plot_xcor_vs_uwrp_lines(ct2)
    ct_plot_xcor_vs_uwrp_colapsed(ct2)
end

if opt_save == 1
    ct = ct2;
    save([sitename '_ts_fine_dejumped.mat'],'ct');
end


