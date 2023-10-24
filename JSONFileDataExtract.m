%Open JSON data files and save as structures for each mouse 

data_files = ("C:\Users\katyn\Desktop\Lab Work\Cognitive Flexibility\CognitiveFlexibility x CIE Mice\Cognitive Flexibility Data Files\GithubRepo\Raw Data\SetShiftingBaselineData");

CF_data = dir(data_files +"\*.json");

data_dictionary = dictionary();

subject_number_list = [];

for i=1:length(CF_data)
    CF_data(i).name
    
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
    fields = ["Timer", "Trials", "NoInitiations", "CorrectResponses",...
        "IncorrectResponses", "TrialPerformance", "AttentionalSetsCompleted",...
        "MissedResponses", "LeftTrials", "RightTrials", "Latency", ...
        "TrialbyTrialStimulus", "LightStimuli","SoundStimuli"];
    %groups counts output array order is 0, .... N, NaN
    values = {data.T, data.I, data.N, data.G.', data.W.', groupcounts(data.H.'), data.V,...
        data.M.', data.J.', data.O.', data.D.', data.F.', data.L.', data.S.'};

    % char_array = 'hello world';
    % char_array = ['h','e','l','l','o',...]
    % SAME THING

    check_fields_values_same_dim = length(fields) == length(values);
    
    temp_dictionary = dictionary(fields, values);
    % [Session 1 struct, session 2 struct, session 3 struct, ...];
    if ismember(name_of_subject, subject_number_list)
        subject_x_list = data_dictionary{name_of_subject};
    else
        subject_x_list = {};
        subject_number_list(length(subject_number_list) + 1) = ...
            name_of_subject;
    end
    
    subject_x_list{length(subject_x_list) + 1} = temp_dictionary;
    data_dictionary{name_of_subject} = subject_x_list;
end

% How to access the mouseID dictionary and how to save the dictionary of
% all mice across all sessions
% subject_list = data_dictionary{136}; % [session 1, session 2, ...]
save('BaselineData.mat', "data_dictionary");
 
