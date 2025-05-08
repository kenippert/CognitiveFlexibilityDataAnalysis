
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

    if contains(level, 'CF_1-1New')
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
    if contains(level, 'CF_2-1New')
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
        if contains(level, 'CF_2-1Box7')
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
    if strcmp(level, 'CF_2-1')
        continue;
    end
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
    if contains(level, 'CF_SD')
        trialByTrialPerformance = allOut{i}.K(1:length_of_array)';
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
    %concatenate trial by trial data, light stimuli, sound stimuli, and
    %trial type
    %need to figure out how to label these columns TBTP, LightStim,
    %SoundStim, TrialType
   
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
% 
% 
% % How to access the mouseID dictionary and how to save the dictionary of
% % all mice across all sessions
% % subject_list = data_dictionary{136}; % [session 1, session 2, ...]
save('HomecageEtOHPreprocessedData', "data_structure");
% 
