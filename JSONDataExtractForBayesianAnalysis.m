%JSON file data extract for Bayesian analysis

clear
clc
%import and organize every file within a selcted folder  
datapath=uigetdir([],'Select Data Directory'); 
CF_data=dir(fullfile(datapath,'*.json'));
%create directory
%CF_data = dir(data_files +"\*.json");
%empty dictionary
data_structure = {};
subject_number_in_data_structure = containers.Map('KeyType','int32','ValueType','int32');
%initialize list for subject numbers
subject_number_list = [];

%figure out how to get dat as field 1
for i=1:length(CF_data)
    CF_data(i).name
    %using name of the file, split by 
    split_by_space = split(CF_data(i).name);
    split_by_period = split(split_by_space(2), '.');
    name_of_subject = split_by_period(1);
    name_of_subject = str2num(cell2mat(name_of_subject));
    
    dateTable = {};
    subjectTable = {};
    box = {};
    timer = {};
    trials = {};
    %trialByTrialPerformance = {};
    %lightStimuli = {};
    %soundStimuli = {};
    %trialTypeID = {};
    concatenatedData = {};

    if ~isKey(subject_number_in_data_structure, name_of_subject)
        data_structure{ end + 1 } = table(dateTable, subjectTable, box,timer,trials,concatenatedData);
        subject_number_in_data_structure( name_of_subject ) = numel(data_structure);
    end
    f = fopen(CF_data(i).name,'r+');
    raw = fread(f,inf);
    str = char(raw');
    data = jsondecode(str);
    fn = fieldnames(data);
    for k = 1:numel(fn)
        field=fieldnames(data);
        fn1 = field{k};
        array = data.(fn1);
        array(array==0) = NaN;
        data.(fn1) = array;
    end
    %add start date field to structure using same format as below
    
    dateStr = data.StartDate;
    dateObj = datetime(dateStr, 'InputFormat', 'MM/dd/yy');
    dateNum = datenum(dateObj);
    date_fill_value = dateNum;
    length_of_array = numel(data.H);
    %replicate date_fill_value until it matches the length of the session,
    %so this should result in a date value for each trial of a session in a
    %ntrials x 1 array
    date = repmat(date_fill_value, length_of_array, 1);

    %repeat with the subject number 
    subject_fill_value = data.Subject;
    subject = repmat(subject_fill_value, length_of_array, 1);
    dateTable = {data.StartDate}; 
    subjectTable = {data.Subject}; 
    box = {data.Box};
    timer = {data.T};
    trials = {data.I};
    trialByTrialPerformance = {data.H}; 
    lightStimuli = {data.L};
    soundStimuli = {data.S};
    trialTypeID = {data.R};
    
    %concatenate trial by trial data, light stimuli, sound stimuli, and
    %trial type
    %need to figure out how to label these columns TBTP, LightStim,
    %SoundStim, TrialType
    concatenatedData = {horzcat(date,subject,data.H, data.L, data.S, data.R)};
    newTable = table(dateTable, subjectTable, box,timer,trials,concatenatedData);
    data_structure{subject_number_in_data_structure(name_of_subject)} = [data_structure{subject_number_in_data_structure(name_of_subject)};newTable];
    output = concatenatedData;
end
% 
% 
% % How to access the mouseID dictionary and how to save the dictionary of
% % all mice across all sessions
% % subject_list = data_dictionary{136}; % [session 1, session 2, ...]
save('TestingDataFormattinginTable', "data_structure");
% 
