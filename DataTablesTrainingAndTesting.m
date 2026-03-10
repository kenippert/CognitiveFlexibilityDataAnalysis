
%This file take allOut from the Barker medpc extract and creates
% a table containing data from all sessions of a given animal during
% training and testing
data_structure = {};
subject_number_in_data_structure = containers.Map('KeyType','int32','ValueType','int32');
%initialize list for subject numbers
subject_number_list = [];

%figure out how to get dat as field 1
for i=1:length(allOut)
    name_of_subject = allOut{i}.Subject;
    
    dateTable = {};
    subjectTable = {};
    box = {};
    level = {};
    timer = {};
    trials = {};
    totalCorrect = {};
    leftCorrect = {};
    rightCorrect = {};
    totalInc = {};
    leftInc = {};
    rightInc = {};
    trialByTrialData = {};
    stageReached = {};
    
    if ~isKey(subject_number_in_data_structure, name_of_subject)
        data_structure{ end + 1 } = table(dateTable, subjectTable, box, level, ...
            timer, stageReached, trials, totalCorrect, leftCorrect, rightCorrect, totalInc, ...
            leftInc, rightInc, trialByTrialData);
        subject_number_in_data_structure( name_of_subject ) = numel(data_structure);
    end

    dateStr = allOut{i}.StartDate;
    dateObj = datetime(dateStr, 'InputFormat', 'MM/dd/yy');
    dateNum = datenum(dateObj);
    date_fill_value = dateNum;
    length_of_array = numel(allOut{i}.D);
    %replicate date_fill_value until it matches the length of the session,
    %so this should result in a date value for each trial of a session in a
    %ntrials x 1 array
    date = repmat(date_fill_value, length_of_array, 1);
    %replicate date_fill_value until it matches the length of the session,
    %so this should result in a date value for each trial of a session in a
    %ntrials x 1 array

    %repeat with the subject number 
    subject_fill_value = allOut{i}.Subject;
    subject = repmat(subject_fill_value, length_of_array, 1);
    dateTable = {allOut{i}.StartDate};         
    subjectTable = allOut{i}.Subject; 
    box = allOut{i}.Box;
    level = convertCharsToStrings(allOut{i}.MSN);
    timer = allOut{i}.T;
    trials = allOut{i}.I;
%% Forbidden patterns are ignored, these were level names during pilot testing for Cohort 1
    forbiddenPatterns = ["CF_1-1", "CF_3-1L","CF_3-1B","CF_3-2A", "CF_3-2B","CF_3-3A" ...
        "CF_4-1A"];
    if contains(level, forbiddenPatterns)
        continue;
    end
%% Extract data from level 1 sessions
    levelOneStrings = ["CF_1-1New","CF_1", "CF_1-1Box7"];
    if contains(level, levelOneStrings)
        trialByTrialPerformance = NaN(length_of_array,1);
        lightStimuli = NaN(length_of_array,1);
        soundStimuli = NaN(length_of_array,1);
        trialTypeID = NaN(length_of_array,1);
        totalCorrect = allOut{i}.C(1,1);
        leftCorrect = allOut{i}.C(1,2);
        rightCorrect = allOut{i}.C(1,3);
        totalInc = NaN;
        leftInc = NaN;
        rightInc = NaN;
        stageReached = NaN;
    end
%% Extract data from Level 2 sessions
    levelTwoStrings = ["CF_2-1","CF_2-1Box7"];
    if contains(level, levelTwoStrings)
        %for level 2 (learning to nosepoke) the R array indicates left
        %(R=1) and right (R=2) trials. Zeros are trials with no initiation.
        trialByTrialPerformance = allOut{i}.R(1:length_of_array)';
        lightStimuli = NaN(length_of_array,1);
        soundStimuli = NaN(length_of_array,1);
        trialTypeID = NaN(length_of_array,1);
        totalCorrect = allOut{i}.C(1,2);
        leftCorrect = allOut{i}.C(1,3);
        rightCorrect = allOut{i}.C(1,4);
        totalInc = NaN;
        leftInc = NaN;
        rightInc = NaN;
        stageReached = NaN;
    end
%% Extract data from stimulus exposure levels (3 and 4)
    if contains(level, 'CF_3') || contains(level, 'CF_4')
        trialByTrialPerformance = NaN(length_of_array,1);
        lightStimuli = NaN(length_of_array,1);
        soundStimuli = NaN(length_of_array,1);
        trialTypeID = NaN(length_of_array,1);
        totalCorrect = allOut{i}.G(1,1);
        leftCorrect = allOut{i}.G(1,2);
        rightCorrect = allOut{i}.G(1,3);
        totalInc = allOut{i}.W(1,1);
        leftInc = allOut{i}.W(1,2);
        rightInc = allOut{i}.W(1,3);
        stageReached = NaN;
    end

%% Extract data from simple discrimination sessions
    if contains(level, 'CF_SD')
        length = allOut{i}.I;
        trialByTrialPerformance = allOut{i}.K(1:length)';
        lightStimuli = NaN(length,1);
        soundStimuli = NaN(length,1);
        trialTypeID = NaN(length,1);
        totalCorrect = allOut{i}.G(1,1);
        leftCorrect = allOut{i}.G(1,2);
        rightCorrect = allOut{i}.G(1,3);
        totalInc = allOut{i}.W(1,1);
        leftInc = allOut{i}.W(1,2);
        rightInc = allOut{i}.W(1,3);
        stageReached = NaN;
    end
%% Extract data from set shifting levels
    if contains(level, 'CF_SetShifting')
        trialByTrialPerformance = allOut{i}.H(1:length_of_array)';
        lightStimuli = allOut{i}.L(1:length_of_array)';
        soundStimuli = allOut{i}.S(1:length_of_array)';
        totalCorrect = allOut{i}.G(1,1);
        leftCorrect = allOut{i}.G(1,2);
        rightCorrect = allOut{i}.G(1,3);
        totalInc = allOut{i}.W(1,1);
        leftInc = allOut{i}.W(1,2);
        rightInc = allOut{i}.W(1,3);
        stageReached = allOut{i}.V;
        trialTypeID = NaN(length_of_array, 1); % Initialize R with NaN
        if isfield(allOut{i}, 'R') && numel(allOut{i}.R) > 1 
            trialTypeID = allOut{i}.R';
        else
            for j = 1:length_of_array
                if (allOut{i}.O(j) == 1) || (allOut{i}.J(j) == 1)
                    trialTypeID(j) = 1; % Assign 1 if either O or J is 1
                elseif (allOut{i}.O(j) == 2) || (allOut{i}.J(j) == 2)
                    trialTypeID(j) = 2; % Assign 2 if either O or J is 2
                else 
                    trialTypeID(j) = NaN; % Assign NaN otherwise
                end
            end
        end
    end
    if contains(level, 'CF_SetShift')
        trialByTrialPerformance = allOut{i}.H(1:length_of_array)';
        lightStimuli = allOut{i}.L(1:length_of_array)';
        soundStimuli = allOut{i}.S(1:length_of_array)';
        totalCorrect = allOut{i}.G(1,1);
        leftCorrect = allOut{i}.G(1,2);
        rightCorrect = allOut{i}.G(1,3);
        totalInc = allOut{i}.W(1,1);
        leftInc = allOut{i}.W(1,2);
        rightInc = allOut{i}.W(1,3);
        stageReached = allOut{i}.V;
        trialTypeID = NaN(length_of_array, 1); % Initialize R with NaN
        if isfield(allOut{i}, 'R') && numel(allOut{i}.R) > 1 
            trialTypeID = allOut{i}.R';
        else
            for j = 1:length_of_array
                if (allOut{i}.O(j) == 1) || (allOut{i}.J(j) == 1)
                    trialTypeID(j) = 1; % Assign 1 if either O or J is 1
                elseif (allOut{i}.O(j) == 2) || (allOut{i}.J(j) == 2)
                    trialTypeID(j) = 2; % Assign 2 if either O or J is 2
                else 
                    trialTypeID(j) = NaN; % Assign NaN otherwise
                end
            end
        end
    end
    %concatenate trial by trial data in the form of:
    % [performance, light stimuli, sound stimuli, trial type]
    trialByTrialData = horzcat(trialByTrialPerformance,lightStimuli, ...
        soundStimuli,trialTypeID);
    % Add session-level information to table
    newRow = table({allOut{i}.StartDate}, allOut{i}.Subject, allOut{i}.Box, ...
        {level}, allOut{i}.T, stageReached, allOut{i}.I, totalCorrect, leftCorrect, ...
        rightCorrect, totalInc, leftInc, rightInc, {trialByTrialData}, ...
        'VariableNames', {'dateTable', 'subjectTable', 'box', 'level','timer', ...
        'stageReached','trials','totalCorrect','leftCorrect', 'rightCorrect', ...
        'totalInc','leftInc', 'rightInc', 'trialByTrialData'});
    newRow2 = table(allOut{i}.Subject);

    % Append to the subject-specific table
    subjectIndex = subject_number_in_data_structure(name_of_subject);
    data_structure{subjectIndex} = [data_structure{subjectIndex}; newRow];
    % output = horzcat(date,subject,data.H, data.L, data.S, data.R);
end
%% ================================================================
% Build a separate summary_table for all animals of number of sessions to
% proficiency for each level
% ================================================================

numAnimals = numel(data_structure);

% Preallocate cell arrays for summary
mouseID        = cell(numAnimals,1);
n_CF1          = zeros(numAnimals,1);
n_CF2          = zeros(numAnimals,1);
n_CFs          = zeros(numAnimals,1);   % CF3 + CF4 combined
n_CFSD         = zeros(numAnimals,1);
ss_to_prof     = zeros(numAnimals,1);

for m = 1:numAnimals

    T = data_structure{m};

    %% Extract mouse ID (all rows belong to one mouse)
    mouseID(m) = T.subjectTable(1);

    %% --- Sort by actual date
    try
        T.sessionDate = datetime(T.dateTable, 'InputFormat','MM/dd/yy');
    catch
        T.sessionDate = datetime(T.dateTable, 'InputFormat','MM/dd/yyyy');
    end
    T = sortrows(T, 'sessionDate');

    %% --- Count sessions per level
    lvl = string(T.level);

    n_CF1(m)  = sum(contains(lvl,"CF_1"));
    n_CF2(m)  = sum(contains(lvl,"CF_2"));
    n_CF3     = sum(contains(lvl,"CF_3"));
    n_CF4     = sum(contains(lvl,"CF_4"));
    n_CFs(m)  = n_CF3 + n_CF4;   % combined CF3/CF4
    n_CFSD(m) = sum(contains(lvl,"CF_SD"));

    %% --- Count set-shifting sessions needed for proficiency
    isSS = contains(lvl,"CF_SetShifting");
    ssTable = T(isSS,:);

    if isempty(ssTable)
        ss_to_prof(m) = NaN;   % no SS sessions
    else
        ssStage = ssTable.stageReached;
        % Convert cell array to numeric values
        ssStageNum = cellfun(@(x) double(x), ssStage);
        good = ssStageNum >= 3;

        % Find consecutive runs of stageReached >= 3
        d = diff([false; good; false]);
        starts = find(d == 1);
        ends   = find(d == -1) - 1;
        lengths = ends - starts + 1;

        idx = find(lengths >= 2, 1, 'first');

        if isempty(idx)
            ss_to_prof(m) = Inf;   % never reached proficiency
        else
            ss_to_prof(m) = starts(idx);  % count up to first passing session
        end
    end
end

%% ================================================================
% Construct summary_table as output
% ================================================================
summary_table = table(mouseID, n_CF1, n_CF2, n_CFs, n_CFSD, ss_to_prof, ...
    'VariableNames', {'mouseID','n_CF1','n_CF2','n_CFs','n_CFSD','ss_sessions_to_proficiency'});
filename = 'CIEFSSxCFC2_AllSessions.xlsx';

for m = 1:numel(data_structure)

    T = data_structure{m};

    % Get mouse ID (convert to string for sheet name)
    mouseName = string(T.subjectTable(1));

    % Excel sheet names must be <= 31 characters
    sheetName = mouseName;

    % Write table to Excel
    T_export = removevars(T, 'trialByTrialData');

    writetable(T_export, filename, 'Sheet', sheetName);
end

% Optionally also write summary table
writetable(summary_table, filename, 'Sheet', 'Summary');

% 
% 
% % How to access the mouseID dictionary and how to save the dictionary of
% % all mice across all sessions
% % subject_list = data_dictionary{136}; % [session 1, session 2, ...]
save('CIEFSSCohort1AcuteWithdrawalSessions', "data_structure");
% 
