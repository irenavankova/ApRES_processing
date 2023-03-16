function [out] = ct_tseries_via_unwrap(cfg,site)  
% spec_cor is the spectrum and time is assumed to be along the first
% dimension of the matrix

%unwrap phase
ct_disp(cfg,'Starting phase unwrapping')

out.dh_fine = unwrap(angle(site.spec_cor),[],1);
out.dh_fine = ct_phase2range(cfg,out.dh_fine,cfg.Rcoarse);

ct_disp(cfg,'Finished phase unwrapping')
out.time = site.time;

% Keith's version ignores phase correction term and reads:
% out.dh_fine = cfg.rad2m_approx*unwrap(angle(site.spec_cor),[],1);


