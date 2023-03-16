function [out] = ct_tseries_via_xcorr_V2(cfg,site)
%--------------------------------------------------------------
% Use spectra to produce fmcw_melt-like timeseries
% Get displacement timeseries for each depth level between each pair of bursts
%--------------------------------------------------------------
% !!!!!!!
% V2 adds the output of amplitude and phase correlation coefficients 

h = waitbar(0,'Xcorrelating burst pairs'); %--Set up "waitbar" to indicate progress

% % Get fine range: distance from centre of coarse range bin to effective reflector: (Brenan: EQ15)
% Rfine = fmcw_phase2range(angle(site.spec_cor),cfg.lambdac,repmat(Rcoarse,size(site.spec_cor,1),1),K,ci);
NN = size(site.spec_cor,1)-1;

i1 = 1;
for j = i1:NN
    % Update the waitbar
    waitbar(j/NN,h, ['Xcorrelating burst pairs : ',num2str(round(j*100/NN),'%d%%')]);
    ct_disp(cfg,['Xcorrelating burst pair #' num2str(j) ' of ' num2str(NN)]);
    
    clear f g AC dh dhe
    
    % Define two mean chirps to compare
    f.specCor = site.spec_cor(j,:);
    f.rangeCoarse = cfg.Rcoarse;
    g.specCor = site.spec_cor(j+1,:);
    g.rangeCoarse = cfg.Rcoarse;
  
    % Do bulk allingment if desired (if there isn't much delay between the
    % two bursts used here then no need to do it)
    if cfg.doBulkAllignment == 1
        [~,f,g] = ct_align_upper_internals(cfg,f,g);
    end
    
    % Do coarse allingment (only used if cfg.doUseCoarseOffset = 1 in ct_processing_param)
    [AC,f,g] = ct_align_coarse(cfg,f,g);
    
    % Do fine allingment
    [AF,dh,~] = ct_align_fine(cfg,f,g,AC); % alternatively output [AF,dh,dhe]
    
    out.dh(j+1,:) = dh;
    out.ampCor(j,:) = AF.ampCor;
    out.phsCor(j,:) = AF.phaseCor;

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

dz = cfg.chunkWidth; % Spacing between the final depth levels
out.dhRange = cfg.minDepth + dz/2: dz: cfg.minDepth + dz/2 + dz*(size(out.dh,2)-1);
out.time = site.time;


