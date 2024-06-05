%JSON file data extract for Bayesian analysis
%folder path with JSON files that you want
data_files = ("C:\Users\katyn\Desktop\Lab Work\Cognitive Flexibility\DREADDsACC X CognitiveFlex Cohort 2\Baseline Session Raw Data GFP Mice");
%create directory
CF_data = dir(data_files +"\*.json");
%empty dictionary
data_structure = struct;
%initialize list for subject numbers
subject_number_list = [];


for i=1:length(CF_data)
    CF_data(i).name
    %using name of the file, split by 
    split_by_space = split(CF_data(i).name);
    split_by_period = split(split_by_space(2), '.');
    name_of_subject = split_by_period(1);
    name_of_subject = str2num(cell2mat(name_of_subject));
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
    field1 = 'SubjectID'; value1 = data.Subject;
    field2 = 'Timer'; value2 = data.T;
    field3 = 'Trials'; value3 = data.I;
    field4 = "TrialByTrialPerformanceStage"; value4 = data.H; 
    field5 = "LightStimuli"; value5 = data.L;
    field6 = 'SoundStimuli'; value6= data.S;
    field7 = 'TrialTypeIdentifier'; value7= data.R;
    
    temp_structure = struct(field1,value1,field2,value2,field3,value3, field4,value4,field5,value5,field6,value6,field7,value7);

 % [Session 1 struct, session 2 struct, session 3 struct, ...];
    if ismember(field1, subject_number_list)
        subject_x_list = data_structure.(name_of_subject);
    else
        subject_x_list = {};
        subject_number_list(length(subject_number_list) + 1) = ...
            name_of_subject;
    end

    subject_x_list{length(subject_x_list) + 1} = temp_structure;
    data_structure.(field1) = subject_x_list;
end
% 
% 
% % How to access the mouseID dictionary and how to save the dictionary of
% % all mice across all sessions
% % subject_list = data_dictionary{136}; % [session 1, session 2, ...]
% save('TestingDataFormatting', "data_structure");
% 
