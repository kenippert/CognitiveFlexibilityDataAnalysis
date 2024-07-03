%JSON file data extract for Bayesian analysis

clear
clc

%folder path with JSON files that you want
data_files = ("C:\Users\katyn\Desktop\Lab Work\Cognitive Flexibility\DREADDsACC X CognitiveFlex Cohort 2\Baseline Sessions Raw Data DREADD Mice");
%create directory
CF_data = dir(data_files +"\*.json");
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
    
    date = {};
    subject = {};
    box = {};
    timer = {};
    trials = {};
    trialByTrialPerformance = {};
    lightStimuli = {};
    soundStimuli = {};
    trialTypeID = {};

    if ~isKey(subject_number_in_data_structure, name_of_subject)
        data_structure{ end + 1 } = table(date,subject,box,timer,trials,trialByTrialPerformance, lightStimuli, soundStimuli, trialTypeID);
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
    field1 = 'Date'; date = {data.StartDate};
    field2 = 'Subject'; subject = {data.Subject};
    field3 = 'Box'; box = {data.Box};
    field4 = 'Timer'; timer = {data.T};
    field5 = 'Trials'; trials = {data.I};
    field6 = "TrialByTrialPerformanceStage"; trialByTrialPerformance = {data.H}; 
    field7 = "LightStimuli"; lightStimuli = {data.L};
    field8 = 'SoundStimuli'; soundStimuli = {data.S};
    field9 = 'TrialTypeIdentifier'; trialTypeID = {data.R};
    
    newTable = table(date,subject,box,timer,trials,trialByTrialPerformance, lightStimuli, soundStimuli, trialTypeID);
    data_structure{subject_number_in_data_structure(name_of_subject)} = [data_structure{subject_number_in_data_structure(name_of_subject)};newTable];
    % temp_structure = struct(field1,value1,field2,value2,field3,value3, field4,value4,field5,value5,field6,value6,field7,value7);

 % [Session 1 struct, session 2 struct, session 3 struct, ...];
    %if ismember(name_of_subject, subject_number_list)
    %    disp("if");
    %    subject_x_list = data_structure.(name_of_subject);
    %else
    %    disp("else")
    %    subject_x_list = {};
    %    subject_number_list(length(subject_number_list) + 1) = ...
    %        name_of_subject;
    %end
    %fprintf("appending to the end of the list\nlength of list: %d\n",numel(subject_x_list));
    %subject_x_list{end + 1} = temp_structure;
    %setfield(data_structure,name_of_subject, subject_x_list);
end
% 
% 
% % How to access the mouseID dictionary and how to save the dictionary of
% % all mice across all sessions
% % subject_list = data_dictionary{136}; % [session 1, session 2, ...]
save('TestingDataFormattinginTable', "data_structure");
% 
