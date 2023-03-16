function ct2 = ct_remove_jumps_xcor_all(ct,opt_plot,jump_tol)
if ~exist('opt_plot','var')
    opt_plot = 0;
end

jump_tol_default = 0.05;
if nargin < 3 
    jump_tol = jump_tol_default;
elseif isempty(jump_tol)
    jump_tol = jump_tol_default;
end
    
% For all
ct2 = ct;
if opt_plot == 1; figure; end
for j = 1:length(ct.dts_xcor.dhRange)
    clear ij y yd
    disp([num2str(j) ' of ' num2str(length(ct.dts_xcor.dhRange))])
    y = ct.dts_xcor.dh(:,j);
    yd = abs(diff(y));
    ij = find(yd > jump_tol);
    % Dejump with extrapolation/fill gaps
    for k = 1:length(ij)
        ijump = ij(k);
        y = ct_glue_jump_V2(y,ijump,0,1);
    end
    ct2.dts_xcor.dh(:,j) = y;
    if opt_plot == 1
        clf('reset')
        plot(ct.dts_xcor.dh(:,j)); hold on
        plot(ct2.dts_xcor.dh(:,j));
        drawnow
        title(num2str(ct.dts_xcor.dhRange(j)))
        hold off
    end
end
if opt_plot == 1
    ct_plot_xcor_vs_uwrp_lines(ct2)
    ct_plot_xcor_vs_uwrp_colapsed(ct2)
end

ct2.cfg.dejumped.jump_tol = jump_tol;
end