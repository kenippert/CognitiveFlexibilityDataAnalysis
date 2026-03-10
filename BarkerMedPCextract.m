clear
clc

%% for selecting entire folders
% %import and organize every file within a selcted folder  
datapath=uigetdir([],'Select Data Directory'); 
d=dir(fullfile(datapath,'*.txt'));

%% for selecting mulitple files
% [files,datapath] = uigetfile({'*.txt', 'Text Files'}, "MultiSelect","on");

% %if user cancels
% if isequal(files,0)
%     disp("No files selected.");
%     return;
% end

%if multiple files selected, files is returns as a cell array of character
%vectors such as files = {'file1.txt', 'file2.txt'};

%if only one file is selected, files is returned as a character array (not
%cell array) such as" files = 'file1.txt'; this becomes a problem when you
%try to loop in the next section. To avoid this, ensure that files is
%always a cell array even if it contains only 1 file
% if ischar(files)
%     files = {files};
% end

%% loop over files to generate cell array of sessions
for i=1:numel(d)
  txt_file = fullfile(datapath,d(i).name);
    [fid,msg] = fopen(txt_file,'rt');
    assert(fid>=3,msg)
    out = struct();
    while ~feof(fid)
	pos = ftell(fid);
	str = strtrim(fgetl(fid));
	if numel(str)
		spl = regexp(str,':','once','split');
		spl = strtrim(spl);
		if isnan(str2double(spl{1}))
			fnm = strrep(spl{1},' ','');
			val = str2double(spl{2});
			if isnan(val)
				out.(fnm) = spl{2};
			else
				out.(fnm) = val;
			end
		else
			fseek(fid,pos,'bof');
			vec = fscanf(fid,'%*d:%f%f%f%f%f',[1,Inf]);
			out.(fnm) = vec;
        end
    end

    end
      if contains(out.MSN,'CF_SetShift')
          % || ...
          % contains(out.MSN, 'CF_1') || ...
          % contains(out.MSN, 'CF_2') || ...
          % contains(out.MSN, 'CF_3') || ...
          % contains(out.MSN, 'CF_4') || ...
          % contains(out.MSN, 'CF_SD')
        Out{i} = out;%variable allOut contains structure of every subject's data
     end
fclose(fid);
allOut{i} = out;
end
allOut = Out(~cellfun(@isempty, Out)); 
clearvars -except allOut