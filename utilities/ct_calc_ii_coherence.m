function ph_var = ct_calc_ii_coherence(site,ct,n,opt_plot,n1,n2)
% Calculate inter-inter coherence (see Craig's thesis for details)

if isempty('n')
    n = 100; %pick spacing of internas to include in the calculation
end
if isempty('opt_plot')
    opt_plot = 1;
end
if nargin < 5
    n1 = n;
    n2 = length(site.cfg.Rcoarse);
end

for j = 1:length(site.time)-1
    f = site.spec_cor(j,n1:n:n2);
    g = site.spec_cor(j+1,n1:n:n2);
    gamma = sum(conj(f).*g)/(sqrt(sum(abs(f).^2))*sqrt(sum(abs(g).^2)));
    N = length(f);
    ph_var(j) = 1/abs(gamma) * sqrt(1-abs(gamma)^2)/sqrt(2*N); %phase variation measure
end

%Plot
if opt_plot == 1
    figure
    s1 = subplot(2,1,1);
%     for j = 1:20
%         y = ct.dts_uwrp.dh(:,j);
%         y = y-y(1);
%         y = detrend(y);
%         plot(ct.dts_uwrp.time,y); hold on
%     end
    
    [~,i1] = min(abs(ct.dts_xcor.dhRange-site.cfg.Rcoarse(n2)));
    dh = mode(diff(ct.dts_xcor.dhRange));
    dn = floor(mode(diff(site.cfg.Rcoarse))*n/dh);
    %[~,i2] = max(abs(ct.dts_xcor.dhRange));
    [~,i2] = min(abs(ct.dts_xcor.dhRange-site.cfg.Rcoarse(n1)));
    cmap = colormap(jet(ceil((i1-i2)/dn+1)));
    ctr = 0;
    for j = i1:-dn:i2
        %ct.dts_xcor.dhRange(j)
        ctr = ctr + 1;
        y = ct.dts_uwrp.dh(:,j);
        y = y-y(1);
        y = detrend(y);
        plot(ct.dts_uwrp.time,y,'Color',cmap(ctr,:)); hold on
        %pause
    end
    
    
    datetick('x')
    axis tight
    s2 = subplot(2,1,2);
    plot(site.time(1:end-1),ph_var)
    datetick('x')
    axis tight
    linkaxes([s1;s2],'x')
end