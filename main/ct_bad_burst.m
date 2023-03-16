function ct_bad_burst(cfg,fname)

% Add folder to path
folderName = fullfile(cfg.myDirPath);
addpath(genpath(folderName));

%cfg.myDir
%fname = 'DATA2017-09-22-1112.DAT'; %R02 BAD
%fname = 'DATA2016-01-21-2012.DAT'; %R05 OK
%fname = 'DATA2016-07-17-1132.DAT'; %R05 OK
%fname = 'DATA2016-03-13-0647.DAT';
%fname = 'DATA2016-03-12-1047.DAT';
%fname = 'DATA2016-03-19-0247.DAT';

FileDir = dir(fullfile(cfg.myDir,fname));
for j = 1:length(FileDir)
    FileList(j,:) = FileDir(j).name;
end
% FileDir
% FileList

% Extract list of bursts from the list of files above
ct_disp(cfg,'Extracting list of bursts from filelist')
BurstList = CreateBurstList(FileList,'firstonly',0,'cfg',cfg);
NBursts = size(BurstList,1);

for burst = 1:NBursts  % for each burst
    cfg.bad_burst.active = 0;
    figure

    FileFormat = fmcw_file_format(FileList(BurstList(burst,1),:));
    if FileFormat == 5
        vdat = LoadBurstRMB5(FileList(BurstList(burst,1),:),BurstList(burst,2),[]);
    elseif FileFormat == 4
        vdat = LoadBurstRMB4(FileList(BurstList(burst,1),:),BurstList(burst,2),[]);
    end  

    tstemp = datevec(vdat.TimeStamp);
    
    v = zeros(vdat.Nsamples,1);

    % Average the chirps from selected attenuator to a mean chirp without
    % discrimination
    num_chirps = 0;
    for k = cfg.attenuator:vdat.NAttenuators:vdat.ChirpsInBurst % For each chirp in the burst
        if length(vdat.v) >= vdat.Endind(k)
            % Sum the chirps into vector v
            v_now = vdat.v(vdat.Startind(k):vdat.Endind(k));
            v = v + v_now;
            num_chirps = num_chirps + 1;
            plot(v_now); hold on
            title(['Burst #' num2str(burst) ' at ' num2str(tstemp(3:6))])
            xlabel(num2str(std(v_now)))
            drawnow
           % max(abs(v_now))
            %pause
        end
    end
    meanchirp = double(v/num_chirps);
    plot(meanchirp,'k','LineWidth',1)
    drawnow
%     [meanchirp,~] = ct_get_meanchirp(cfg,vdat);
%     plot(meanchirp,'r','LineWidth',1)
%     [meanchirp,~] = ct_fill_clipped_meanchirp(cfg,meanchirp);
%     plot(meanchirp,'g','LineWidth',1)
%     pause
%     pause
end

% Remove folder from path
rmpath(genpath(folderName));