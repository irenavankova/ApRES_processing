function ct_disp(cfg,text) % Only diplay output if cfg.verbose on
%global cfg
if cfg.verbose
    disp(text)
end