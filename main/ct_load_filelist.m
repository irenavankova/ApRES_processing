function [FileList,BurstList] = ct_load_filelist(cfg)

% Get list of all files to be processed
ct_disp(cfg,'Getting list of files for processing')
FileDir = dir(fullfile(cfg.myDir,'*.DAT'));
for j = 1:length(FileDir)
    FileList(j,:) = FileDir(j).name;
end
if isempty(FileDir) == 1
    error('Empty filelist, could not locate any .DAT files in the provided directory (cfg.myDir). Check folder structure.');
end

if cfg.burst_subset_end_files == 1
    for j = 1:size(FileList,1)
        if strcmp(FileList(j,:),cfg.burst_subset_first_file)
            i1 = j;
        end
        if strcmp(FileList(j,:),cfg.burst_subset_last_file)
            i2 = j;
            break;
        end        
    end
    FileList = FileList(i1:i2,:);
end

% Extract list of bursts from the list of files above
ct_disp(cfg,'Extracting list of bursts from filelist')
BurstList = CreateBurstList(FileList,'firstonly',cfg.first_burst_infile_only,'cfg',cfg);

% Select a subset of bursts if desired
if cfg.burst_subset_on == 1
    a = cfg.burst_start_index;
    b = cfg.burst_spacing;
    c = cfg.burst_end_index;
    
    if c > size(BurstList,1)
        c = size(BurstList,1);
    end
    
    % At least two bursts
    if b > c-a
        b = c-a;
    end

    BurstList = BurstList(a:b:c,:);
end
    