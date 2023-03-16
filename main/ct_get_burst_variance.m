function cfg = ct_get_burst_variance(cfg)

% Add folder to path
folderName = fullfile(cfg.myDirPath);
addpath(genpath(folderName));

FileDir = dir(fullfile(cfg.myDir,'*.DAT'));
for j = 1:length(FileDir)
    FileList(j,:) = FileDir(j).name;
end

% Extract list of bursts from the list of files above
ct_disp(cfg,'Extracting list of bursts from filelist')
BurstList = CreateBurstList(FileList,'firstonly',0,'cfg',cfg);
NBursts = size(BurstList,1);
h = waitbar(0,'Processing files'); %--Set up "waitbar" to indicate progress

for burst = 1:NBursts  % for each burst
    % Update the waitbar
    waitbar(burst/NBursts,h, ['Processing files: ',num2str(round(burst*100/NBursts),'%d%%')]);

    FileFormat = fmcw_file_format(FileList(BurstList(burst,1),:));
    if FileFormat == 5
        vdat = LoadBurstRMB5(FileList(BurstList(burst,1),:),BurstList(burst,2),[]);
    elseif FileFormat == 4
        vdat = LoadBurstRMB4(FileList(BurstList(burst,1),:),BurstList(burst,2),[]);
    end  
    
    
    %tstemp = datevec(vdat.TimeStamp);
    
    v = zeros(vdat.Nsamples,1);

    % Average the chirps from selected attenuator to a mean chirp without
    % discrimination
    num_chirps = 0;
    clear chirp_var
    for k = cfg.attenuator:vdat.NAttenuators:vdat.ChirpsInBurst % For each chirp in the burst
        if length(vdat.v) >= vdat.Endind(k)
            % Sum the chirps into vector v
            v_now = vdat.v(vdat.Startind(k):vdat.Endind(k));
            v = v + v_now;
            num_chirps = num_chirps + 1;
            chirp_var(num_chirps) = std(v_now);
        end
    end
    meanchirp = double(v/num_chirps);
    cfg.burst_std(burst) = std(meanchirp);
    cfg.burst_std_of_chirp_std(burst) = std(chirp_var);
end
% Delete the wait bar
delete(h);

% figure
% subplot(2,1,1)
% plot(cfg.burst_std); h = gca;
% ylabel('burst std')
% subplot(2,1,2)
% plot(cfg.burst_std_of_chirp_std); h = [h;gca];
% ylabel('chirp std')
% linkaxes(h,'x')



% Remove folder from path
rmpath(genpath(folderName));