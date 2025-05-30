%This function serves to produce cell arrays of target variables where a
%cell array for each session is nested below a cell arrayfor each subject


function [allSubjectValues] = SessionData(dictParam, key, key2, key3)
    allSubjectValues = {};
    singleSessionValues = {};
    dateArray = {};
    subjectID = {};
    % gets the dictionary keys for the dictionary
    % i.e. returns [136,137,138,...]
    sortedKeys = containers.Map(dictParam.keys,dictParam.values);
    dictionaryKeys = keys(sortedKeys);
    display(dictionaryKeys);
    % iterate through mice (i.e. subject 137,138,...)
    for i = 1:length(dictionaryKeys)
        % iterate through sessions (i.e. 137 session 1, 137
        % session 2, ...)
        sessions = dictParam{dictionaryKeys{1,i}};
        for j = 1:length(sessions)
            %iterate through sessions. The "key" field value for that session is stored in a
            %1xnumber of sessions cell array called singleSessionValues
            singleSessionValues{j} = sessions{1,j}{key};
            dateArray{j} = sessions{1,j}{key2};
            subjectID{j} = sessions{1,j}{key3};
        end

    %store cell array containing values from each sessions as a cell array
    %for that animal, this is a 1xnumber of animals cell 
    allSubjectValues{1,i} = [singleSessionValues;dateArray;subjectID];
   
    singleSessionValues = {};
    dateArray = {};
    subjectID = {};
    end
    
 end