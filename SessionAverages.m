%This function serves to calculate variable averages across sessions for
%whichever variable you are intereted in. For example, if you are
%interested in latency or stage reached averages, that would be the 'key'
%input for this function

function avgDict = SessionAverages(dictParam, key)
    
    avgDict = dictionary();
    % gets the dictionary keys for the dictionary
    % i.e. returns [136,137,138,...]
    dictionaryKeys = keys(dictParam);
    % iterate througuh mouse sessions (i.e. 137,138,...)
    for i = 1:size(dictionaryKeys)
        % iterate through sessions per mouse (i.e. 137 session 1, 137
        % session 2, ...)
        mouseArray = dictParam{dictionaryKeys(i)};
        for j = 1:length(mouseArray)
            % gets the average of the sectionToCalculate (i.e.
            % TrialPerformance)
            sessionDict = mouseArray(j);
            sessionDict = sessionDict{1};

            sessionArray = sessionDict(key);
            sessionArray = sessionArray{1};
            tempArray = {};
            % first check if avgDict is initialized otherwise will error
            if isConfigured(avgDict)
                % then check if specific part of avgDict is initialized
                if isKey(avgDict, dictionaryKeys(i))
                    tempArray = avgDict{dictionaryKeys(i)};
                end
            end
            % adding mean of sessionDict's session to Calculate to
            % the end of temporary array so the index will be the same
            tempArray{length(tempArray) + 1} = mean(...
                sessionArray, "omitnan");
            % add new tempArray back to its spot in avgDict
            avgDict{dictionaryKeys(i)} = tempArray;
        end
    end
end