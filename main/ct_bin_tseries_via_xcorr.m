function [out] = ct_bin_tseries_via_xcorr(cfg,site,i1,NN,depthRange)
% Get a time series by tracking changes in a single specified depth range 
% depthRange......defined by edge limits [d1 d2]


h = waitbar(0,'Xcorrelating burst pairs'); %--Set up "waitbar" to indicate progress

if ~exist('NN','var')
    NN = size(site.spec_cor,1)-1;
elseif isempty(NN)
    NN = size(site.spec_cor,1)-1;
end
    
if ~exist('i1','var')
    i1 = 1;
elseif isempty(i1)
    i1 = 1;
end

if NN < i1
    error('Not enough time shots included. Timeseries was possibly reduced too much.')
end

if ~isfield(cfg,'return_xcorrelation_coef')
    cfg.return_xcorrelation_coef = 0;
end

ctr = 0;
for j = i1:NN
    ctr = ctr + 1; %counter for correlation coef output
    
    % Update the waitbar
    waitbar(j/NN,h, ['Xcorrelating burst pairs : ',num2str(round(j*100/NN),'%d%%')]);
    %ct_disp(cfg,['Xcorrelating burst pair #' num2str(j) ' of ' num2str(NN)]);
    
    clear f g AC dh dhe
    
    % Define two mean chirps to compare
    f.specCor = site.spec_cor(j,:);
    f.rangeCoarse = cfg.Rcoarse;
    g.specCor = site.spec_cor(j+1,:);
    g.rangeCoarse = cfg.Rcoarse;
  
    % Do fine allingment
    %[AF,dh,~] = ct_align_fine_TT(cfg,f,g,AC); % alternatively output [AF,dh,dhe]
    [AF,dh,~] = ct_align_depth_range(cfg,f,g,depthRange);
    
    out.dh(j+1,:) = dh;
    
    out.ampCor(ctr,:) = AF.ampCor;
    out.phsCor(ctr,:) = AF.phaseCor;

end
% Delete the wait bar
delete(h);

out.dh(1,:) = out.dh(2,:) * 0;
% Produce displacement timeseries by adding up (cumsum) individual
% displacements over the entire time
out.dh = cumsum(out.dh,1);

% Get the depth levels appropriate for the choice of cfg.chunkWidth
% To get depth at max correlation see AF.range, however this varies from
% pair to pair so that value isn't useful to make a timeseries

dz = depthRange(:,2) - depthRange(:,1); % Spacing between the final depth levels
out.dhRange = depthRange(:,1) + dz/2;
out.depthEdges = depthRange;
out.time = site.time(i1:NN+1);

