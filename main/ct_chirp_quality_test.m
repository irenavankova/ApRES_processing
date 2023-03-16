function cq = ct_chirp_quality_test(cfg,v)
% Test chirp quality based on manual settings
% If chirp passes test, return 1, otherwise 0

%Default value is to pass the test
cq = 1;

if strcmp(cfg.chirp_quality_test.type,'std') == 1
    if std(v) > max(cfg.chirp_quality_test.range) || std(v) < min(cfg.chirp_quality_test.range)
        cq = 0;
    end
elseif strcmp(cfg.chirp_quality_test.type,'extrema') == 1
    n = cfg.chirp_quality_test.tol_num_over;
    vsort = sort(v(50:end-1),'ascend');
    vsort_min = vsort(n);
    vsort_max = vsort(end-n+1);
    %[vsort_max max(cfg.chirp_quality_test.range) vsort_min min(cfg.chirp_quality_test.range)]
    if vsort_max > max(cfg.chirp_quality_test.range) || vsort_min < min(cfg.chirp_quality_test.range)
        cq = 0;
    end
end
