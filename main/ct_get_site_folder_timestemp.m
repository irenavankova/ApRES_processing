function tstemp = ct_get_site_folder_timestemp(myDir)
% Read files from each folder and record timestemp of first and last burst in that
% folder
% This is useful to identify potential coases of discontinuities in
% timeseries
% The required folder structure in "myDir" is to have data from each site organized
% in folders by season and then by the instrument
% e.g. myDir = '/Users/irenavankova/Google Drive/Research/DOVuFRIS/Fris_Apres/Fris_data/R03/data/';


%--------------------------------------------------------------
% Get first layer of subfolders: Season

% Get a list of all files and folders in this folder.
files = dir(myDir);
% Get a logical vector that tells which is a directory.
dirFlags = [files.isdir];
% Extract only those that are directories.
files = files(dirFlags);
% Print folder names to command window.
ctr = 0;
for k = 1:length(files) % Hidden folders start with "." so ignore those
	if strcmp(files(k).name(1),'.') == 0
        ctr = ctr + 1;
        season(ctr) = files(k);
    end
end

%--------------------------------------------------------------
% Get first and last index for each DAT file

ctr = 0;
ctr_seas = 0;
% Go through each season
for s = 1:length(season)
    % Get a timestemp of the first and last file in each subfolder 
    seasDir = [myDir season(s).name,'/'];
    files = dir(fullfile(seasDir,'DIR*'));
    for k = 1:length(files)
        subdir = [seasDir files(k).name,'/'];
        datfiles = dir(fullfile(subdir,'*.DAT')); % Read all files with this format
        % Get a timestemp of the first and last file in each subfolder 
        ctr = ctr + 1;
        tstemp.subseas.first_name(ctr,:) = datfiles(1).name;
        tstemp.subseas.last_name(ctr,:) = datfiles(end).name;
        tstemp.subseas.first(ctr) = ct_get_timestemp_from_filename(datfiles(1).name);
        tstemp.subseas.last(ctr) = ct_get_timestemp_from_filename(datfiles(end).name);
        % Get a timestemp of the first and last file in each season 
        if k == 1
            ctr_seas = ctr_seas + 1;
            tstemp.seas.first_name(ctr_seas,:) = tstemp.subseas.first_name(ctr,:);
            tstemp.seas.first(ctr_seas) = tstemp.subseas.first(ctr);
        end
        if k == length(files)
            tstemp.seas.last_name(ctr_seas,:) = tstemp.subseas.last_name(ctr,:);
            tstemp.seas.last(ctr_seas) = tstemp.subseas.last(ctr);
        end
    end
end


%--------------------------------------------------------------
% This works also, keeping it here as a backup
% ctr = 0;
% % Go through each season
% for s = 1:length(season)
%     % Get a timestemp of the first and last file in each subfolder 
%     seasDir = [myDir season(s).name,'/'];
%     files = dir(fullfile(seasDir,'DIR*'));
%     %files = dir(seasDir);
%     %dirFlags = [files.isdir];
%     %files = files(dirFlags);
%     for k = 1:length(files) % Hidden folders start with "." so ignore those
%         %if length(files(k).name) > 2
%             %if strcmp(files(k).name(1:3),'DIR') == 1
%                 subdir = [seasDir files(k).name,'/'];
%                 datfiles = dir(fullfile(subdir,'*.DAT'));
%                 % Get a timestemp of the first and last file in each subfolder 
%                 ctr = ctr + 1;
%                 tstemp.first_name(ctr,:) = datfiles(1).name;
%                 tstemp.last_name(ctr,:) = datfiles(end).name;
%                 tstemp.first(ctr) = ct_get_timestemp_from_filename(datfiles(1).name);
%                 tstemp.last(ctr) = ct_get_timestemp_from_filename(datfiles(end).name);
%             %end
%         %end
%     end
% end
