%This file take allOut from the Barker medpc extract and created a table containing cell arrays of data for Bayes analysis
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
    timer = {};
    trials = {};
    concatenatedData= {};

    if ~isKey(subject_number_in_data_structure, name_of_subject)
        data_structure{ end + 1 } = table(dateTable, subjectTable, box, timer, trials, concatenatedData);
        subject_number_in_data_structure( name_of_subject ) = numel(data_structure);
    end

    dateStr = allOut{i}.StartDate;
    dateObj = datetime(dateStr, 'InputFormat', 'MM/dd/yy');
    dateNum = datenum(dateObj);
    date_fill_value = dateNum;
    length_of_array = numel(allOut{i}.H);
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
    timer = allOut{i}.T;
    trials = allOut{i}.I;
    trialByTrialPerformance = allOut{i}.H(1:length_of_array)';
    lightStimuli = allOut{i}.L(1:length_of_array)';
    soundStimuli = allOut{i}.S(1:length_of_array)';

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
    %concatenate trial by trial data, light stimuli, sound stimuli, and
    %trial type
    %need to figure out how to label these columns TBTP, LightStim,
    %SoundStim, TrialType
   
    concatenatedData = horzcat(date,subject,trialByTrialPerformance,lightStimuli,soundStimuli,trialTypeID);
    % Add session-level information to table
    newRow = table({allOut{i}.StartDate}, allOut{i}.Subject, allOut{i}.Box, allOut{i}.T, allOut{i}.I, {concatenatedData}, ...
        'VariableNames', {'dateTable', 'subjectTable', 'box', 'timer', 'trials', 'concatenatedData'});

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
save('DREADDsACC3DCZSessionsBayesPreprocessedData', "data_structure");
% 
