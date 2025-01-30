clear
clc

%import and organize every file within a selcted folder  
datapath=uigetdir([],'Select Data Directory'); 
d=dir(fullfile(datapath,'*.txt'));
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
    if isequal(out.MSN, 'CF_SetShiftingLightV4') || ...
        isequal(out.MSN, 'CF_SetShiftingSoundV4') || ...
        isequal(out.MSN, 'CF_SetShiftingLightDREADDs') || ...
        isequal(out.MSN,'CF_SetShiftingSoundDREADDs') || ...
        isequal(out.MSN,'CF_SetShiftingLightCIEMICE') || ...
        isequal(out.MSN,'CF_SetShiftingSoundCIEMICE') || ...
        isequal(out.MSN, 'CF-SetShifting07132023') || ...
        isequal(out.MSN, 'CF_SetShifting') || ...
        isequal(out.MSN, 'CF_SetShiftingV6') || ...
        isequal(out.MSN, 'CF_SetShiftingV1-1') || ... 
        isequal(out.MSN, 'CF_SetShiftingSound') || ...
        isequal(out.MSN, 'CF_SetShiftingLight') || ...
        isequal(out.MSN, 'CF_SetShiftLight')
        Out{i} = out;%variable allOut contains structure of every subject's data
    end
fclose(fid);
% allOut{i} = out;

end

allOut = Out(~cellfun(@isempty, Out)); 
clearvars -except allOut