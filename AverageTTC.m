%This function served to calculate average trials to criterion for each
%shift type, across sessions

function avgDict = AverageTTC(dictParam, key)

    
    avgDict = dictionary();
    % gets the dictionary keys for the dictionary
    % i.e. returns [136,137,138,...]
    dictionaryKeys = keys(dictParam);
    % iterate througuh mouse sessions (i.e. 137,138,...)
    for i = 1:size(dictionaryKeys)
        fprintf("In key %d\n", dictionaryKeys(i));
        % iterate through sessions per mouse (i.e. 137 session 1, 137
        % session 2, ...)
        mouseArray = dictParam{dictionaryKeys(i)};
        sessionDict = mouseArray(1);
        sessionDict = sessionDict{1};

        sessionArray = sessionDict(key);
        sessionArray = sessionArray{1};
        j = 1;
        while true
            % gets the average of the sectionToCalculate (i.e.
            % TrialPerformance)
            averageArray = [];
            for k = 1:length(mouseArray)
                sessionDict = mouseArray(k);
                sessionDict = sessionDict{1};
    
                insideSession = sessionDict(key);
                insideSession = insideSession{1};

                if j < length(insideSession)
                    % fprintf("Adding %d to the average\n", insideSession(j));
                    averageArray(length(averageArray) + 1) = insideSession(j);
                end
            end

            % if averageArray is empty, then all of the elements that are
            % not the final elements of the session lists have been
            % averaged so break
            if isempty(averageArray)
                break;
            end
            % fprintf("---------------\n");
            avgNum = mean(averageArray, "omitnan");
            avgDict = addToDict(avgNum, avgDict, dictionaryKeys(i));
            j = j + 1;
        end
        % get the average of all of the last elements and add to avgDict
        averageArray = [];
        for mouseSession = 1:length(mouseArray)

            sessionDict = mouseArray(mouseSession);
            sessionDict = sessionDict{1};

            insideSession = sessionDict(key);
            insideSession = insideSession{1};

            averageArray(length(averageArray) + 1) = insideSession(end);
        end
        avgDict = addToDict(mean(averageArray, "omitnan"), avgDict, ...
            dictionaryKeys(i));
    end
end