load("BaselineData.mat");

numberSetShifts = calculateAverage(data_dictionary,"AttentionalSetsCompleted");
disp("AttentionalSetsCompleted");
printDictionaryData(numberSetShifts);

numberTrials = calculateAverage(data_dictionary,"Trials");
disp("Number of Trials By Session");
printDictionaryData(numberTrials);

numberNoInitiations = calculateAverage(data_dictionary,"NoInitiations");
disp("Number of No Initiations Per Session");
printDictionaryData(numberNoInitiations); 


attentionalSetSEM = calculateSEM(data_dictionary,"AttentionalSetsCompleted");
disp("AttentionalSetSEM");
printDictionaryData(attentionalSetSEM);

trialperformance = calculateAverageTrialPerf(data_dictionary);
disp("TrialPerformance");
printDictionaryData(trialperformance);

latency = calculateAverage(data_dictionary,"Latency");
disp("Latency");
printDictionaryData(latency);

latencySEM = calculateSEM(data_dictionary,"Latency");
disp("latencySEM");
printDictionaryData(latencySEM);


function avgDict = calculateAverage(dictParam, key)
    
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

function semDict = calculateSEM(dictParam, key)
    
    semDict = dictionary();
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
            if isConfigured(semDict)
                % then check if specific part of avgDict is initialized
                if isKey(semDict, dictionaryKeys(i))
                    tempArray = semDict{dictionaryKeys(i)};
                end
            end
            % adding mean of sessionDict's session to Calculate to
            % the end of temporary array so the index will be the same
            tempArray{length(tempArray) +1} = (std(sessionArray,"omitmissing"))/(sqrt(length(sessionArray)));

            % add new tempArray back to its spot in avgDict
            semDict{dictionaryKeys(i)} = tempArray;
        end
    end
end

function avgDict = calculateAverageTrialPerf(dictParam)

    key = "TrialPerformance";
    
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
                    fprintf("Adding %d to the average\n", insideSession(j));
                    averageArray(length(averageArray) + 1) = insideSession(j);
                end
            end

            % if averageArray is empty, then all of the elements that are
            % not the final elements of the session lists have been
            % averaged so break
            if isempty(averageArray)
                break;
            end
            fprintf("---------------\n");
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

function averageWithoutElement = addToDict(avgToAdd, averageWithoutElement, mouseID)
    tempArray = {};
    % first check if avgDict is initialized otherwise will error
    if isConfigured(averageWithoutElement)
        % then check if specific part of avgDict is initialized
        if isKey(averageWithoutElement, mouseID)
            tempArray = averageWithoutElement{mouseID};
        end
    end
    % adding mean of sessionDict's session to Calculate to
    % the end of temporary array so the index will be the same
    tempArray{length(tempArray) + 1} = avgToAdd;

    % add new tempArray back to its spot in avgDict
    averageWithoutElement{mouseID} = tempArray;
end

function printDictionaryData(dict)
    % function that prints all data inside of a dictionary according
    % to whatever it has inside
    dictionaryKeys = keys(dict);
    
    for i = 1: length(dictionaryKeys)
        fprintf("In key %d\n", dictionaryKeys(i));
        mouseArray = dict{dictionaryKeys(i)};
        fprintf("[");
        for j = 1: length(mouseArray)
            data = mouseArray(j);
            data = data{1};

            fprintf("%d,",data);
        end
        fprintf("]\n");
    end
end