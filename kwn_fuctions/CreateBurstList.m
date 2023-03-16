% Returns two-column list of bursts present in the files whose names are
% included in the filelist input parameter. The first column is the index
% of the file in the filelist, the second column is the burst number within
% the file.
%
% Setting an optional parameter 'firstonly' as 1 causes only first burst of each file
% to be used.
%
% The filelist must be a character array
% BurstIndex = CreateBurstList(FileList [,'firstonly', {1/0}])

function BurstIndex = CreateBurstList(FileList, varargin)

%firstonly = 0;
if nargin>1
    for i = 1:2:nargin-1
        switch varargin{i}
            case 'firstonly'
                firstonly = varargin{i+1};
            case 'cfg'
                cfg = varargin{i+1};
        end
    end
end

NFiles = size(FileList,1);
h=waitbar(0,'Gathering burst numbers... ');

BurstIndex = [];
for FileNo = 1:NFiles
    waitbar(FileNo/NFiles,h);
    if firstonly
        BurstIndex = [BurstIndex;[FileNo,1]];
    else
        try
            ct_disp(cfg,FileList(FileNo,:))
        catch
            disp(FileList(FileNo,:))
        end
        vdat = fmcw_load(FileList(FileNo,:),1000);
        
        %--Assign indices: first column  = the index of the file in the filelist, second column = the burst number within the file.
        if isfield(vdat,'Burst') == 0
            BurstIndex = [BurstIndex;[FileNo,1]];
        else
            BurstIndex = [BurstIndex;[ones(vdat.Burst,1)*FileNo,(1:vdat.Burst)']];
        end
    end
%     vdat
%     firstonly
%     isfield(vdat,'Burst')
%     BurstIndex
%     pause
end
delete(h);