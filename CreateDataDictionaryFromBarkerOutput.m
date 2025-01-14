%Barker struct extract for classical ASST analysis
%must run folder with the .txt data files you want and clearall except the
%allout variable which contains a 1xN 

data_dictionary = dictionary();
%initialize list for subject numbers
subject_number_list = [];


for i=1:length(allOut)
    name_of_subject = allOut{i}.Subject;

    fields = ["Timer", "Trials", "NoInitiations", "CorrectResponses",...
        "IncorrectResponses","TrialByTrialPerformance", "TrialsToCriterion", "AttentionalSetsCompleted",...
        "MissedResponses", "LeftTrials", "RightTrials", "Latency", ...
        "TrialbyTrialStimulus", "LightStimuli","SoundStimuli","TrialTypeIdentifier"];
    %groups counts output array order is 0, .... N, NaN
    values = {allOut{i}.T, allOut{i}.I, allOut{i}.N, allOut{i}.G.', ...
        allOut{i}.W.',allOut{i}.H.', groupcounts(allOut{i}.H), allOut{i}.V,...
        allOut{i}.M.', allOut{i}.J.', allOut{i}.O.', allOut{i}.D.', ...
        allOut{i}.F.', allOut{i}.L.', allOut{i}.S.', allOut{i}.R.'};
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
save('DREADDsACCxCFCohort2SetShiftTraining.mat', "data_dictionary");
 
