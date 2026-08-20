clear
clc

% Ask user how they want to select files
choice = questdlg('Select input type:', ...
    'File Selection', ...
    'Folder','Multiple Files','Folder');

switch choice
    case 'Folder'
        datapath = uigetdir([],'Select Data Directory');

        if isequal(datapath,0)
            disp("No folder selected.");
            return;
        end

        d = dir(fullfile(datapath,'*.txt'));
        files = {d.name};

    case 'Multiple Files'
        [files, datapath] = uigetfile({'*.txt', 'Text Files'}, ...
            'Select Files','MultiSelect','on');

        if isequal(files,0)
            disp("No files selected.");
            return;
        end

        % ensure cell array
        if ischar(files)
            files = {files};
        end
end


%% Initialize tracking variables

Out = {};
addedFiles = {};
skippedFiles = {};
skipReasons = {};

numSelected = numel(files);

fprintf('\n============================================\n');
fprintf('Number of files selected: %d\n',numSelected);
fprintf('============================================\n');


%% Loop over files to generate cell array of sessions

for i = 1:numel(files)

    txt_file = fullfile(datapath,files{i});

    fprintf('\n--------------------------------------------\n');
    fprintf('Processing file %d of %d:\n%s\n', ...
        i,numSelected,files{i});

    try

        [fid,msg] = fopen(txt_file,'rt');

        %--------------------------------------------------------------
        % Could not open file
        %--------------------------------------------------------------
        if fid < 0

            fprintf('NOT ADDED: Could not open file.\n');
            fprintf('Reason: %s\n',msg);

            skippedFiles{end+1} = files{i};
            skipReasons{end+1} = 'Could not open file';

            continue;
        end

        out = struct();

        %--------------------------------------------------------------
        % YOUR ORIGINAL EXTRACTION CODE
        %--------------------------------------------------------------
        while ~feof(fid)

            pos = ftell(fid);
            str = strtrim(fgetl(fid));

            if numel(str)

                spl = strsplit(str,':');
                spl = strtrim(spl);

                if numel(spl) < 2
                    continue;
                end

                % disp(spl);

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

                    val = NaN;

                end

            end

        end

        fclose(fid);


        %--------------------------------------------------------------
        % Check whether extraction produced anything
        %--------------------------------------------------------------
        if isempty(fieldnames(out))

            fprintf('NOT ADDED: No data extracted from file.\n');

            skippedFiles{end+1} = files{i};
            skipReasons{end+1} = 'No data extracted';

            continue;
        end


        %--------------------------------------------------------------
        % Check MSN field
        %--------------------------------------------------------------
        if ~isfield(out,'MSN')

            fprintf('NOT ADDED: Field out.MSN not found.\n');

            skippedFiles{end+1} = files{i};
            skipReasons{end+1} = 'MSN field not found';

            continue;
        end


        %--------------------------------------------------------------
        % Display MSN
        %--------------------------------------------------------------
        fprintf('MSN before cleaning: "%s"\n',string(out.MSN));


        %--------------------------------------------------------------
        % Clean accidental spaces in MSN
        %
        % This does NOT change your extraction logic.
        % It only cleans the MSN after extraction.
        %--------------------------------------------------------------
        if ischar(out.MSN) || isstring(out.MSN)

            cleanMSN = strtrim(string(out.MSN));

            % Remove all spaces
            cleanMSN = strrep(cleanMSN,' ','');

            out.MSN = cleanMSN;

        else

            fprintf('NOT ADDED: MSN is not text.\n');

            skippedFiles{end+1} = files{i};
            skipReasons{end+1} = 'MSN is not text';

            continue;

        end


        fprintf('MSN after cleaning: "%s"\n',out.MSN);


        %--------------------------------------------------------------
        % Check for empty matrices
        %
        % Look through fields in out and identify empty numeric arrays.
        %--------------------------------------------------------------
        fieldNames = fieldnames(out);
        emptyFieldFound = false;

        for j = 1:numel(fieldNames)

            thisField = out.(fieldNames{j});

            if isnumeric(thisField) && isempty(thisField)

                fprintf('NOT ADDED: Empty matrix in field "%s".\n', ...
                    fieldNames{j});

                skippedFiles{end+1} = files{i};
                skipReasons{end+1} = ...
                    sprintf('Empty matrix in field %s',fieldNames{j});

                emptyFieldFound = true;
                break;

            end

        end

        if emptyFieldFound
            continue;
        end


        %--------------------------------------------------------------
        % Inspect MSN
        %--------------------------------------------------------------
        whos out.MSN
        disp(out.MSN)


        %--------------------------------------------------------------
        % Check whether this is a Set Shifting session
        %--------------------------------------------------------------
        permissibleStrings = ["setShift","setShifting","shifting"];
        if contains(out.MSN, permissibleStrings,'IgnoreCase',true)

            Out{end+1} = out;

            addedFiles{end+1} = files{i};

            fprintf('>>> ADDED TO allOut <<<\n');

        else

            fprintf('NOT ADDED: MSN does not contain "setshifting".\n');

            skippedFiles{end+1} = files{i};
            skipReasons{end+1} = 'MSN does not contain setshifting';

        end


    catch ME

        % Make sure file is closed if an error occurs
        if exist('fid','var') && fid >= 0
            fclose(fid);
        end

        fprintf('NOT ADDED: Error processing file.\n');
        fprintf('Error: %s\n',ME.message);

        skippedFiles{end+1} = files{i};
        skipReasons{end+1} = ME.message;

        continue;

    end

end


%% Final output

allOut = Out;


%% Summary

fprintf('\n\n');
fprintf('============================================\n');
fprintf('                 SUMMARY\n');
fprintf('============================================\n');

fprintf('Files selected:       %d\n',numSelected);
fprintf('Files added to allOut: %d\n',numel(allOut));
fprintf('Files not added:      %d\n',numel(skippedFiles));

fprintf('============================================\n');


%% Files that were added

fprintf('\nFILES ADDED:\n');
fprintf('--------------------------------------------\n');

if isempty(addedFiles)

    fprintf('None\n');

else

    for k = 1:numel(addedFiles)
        fprintf('%d. %s\n',k,addedFiles{k});
    end

end


%% Files that were not added

fprintf('\nFILES NOT ADDED:\n');
fprintf('--------------------------------------------\n');

if isempty(skippedFiles)

    fprintf('None\n');

else

    for k = 1:numel(skippedFiles)

        fprintf('%d. %s\n',k,skippedFiles{k});
        fprintf('   Reason: %s\n',skipReasons{k});

    end

end


fprintf('\n============================================\n');


%% Keep useful variables

clearvars -except allOut addedFiles skippedFiles skipReasons files datapath
save("behaviorComputerAllOutBackup2026.