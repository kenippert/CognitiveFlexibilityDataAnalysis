load("BaselineDataDREADDs.mat");

numberSetShifts = calculateAverage(data_dictionary,"AttentionalSetsCompleted");
fprintf("AttentionalSetsCompleted\n---------------\n");
printDictionaryData(numberSetShifts);

numberTrials = calculateAverage(data_dictionary,"Trials");
fprintf("Number of Trials By Session\n---------------\n");
printDictionaryData(numberTrials);

numberNoInitiations = calculateAverage(data_dictionary,"NoInitiations");
fprintf("Number of No Initiations Per Session\n---------------\n");
printDictionaryData(numberNoInitiations); 

correctResponsesByRP = calculateAverageTTC(data_dictionary,"CorrectResponses");
fprintf("Correct Responses\n---------------\nTotalCorrect " + "LeftCorrect " + "RightCorrect\n");
printDictionaryData(correctResponsesByRP); 

incorrectResponsesByRP = calculateAverageTTC(data_dictionary,"IncorrectResponses");
fprintf("Incorrect Responses\n---------------\nTotalIncorrect " + "LeftIncorrect " + "RightIncorrect\n");
printDictionaryData(incorrectResponsesByRP); 

trialsToCriterion = calculateAverageTTC(data_dictionary,"TrialsToCriterion");
fprintf("Trials To Criterion\n---------------\nCorrectCD " + "IncCD " + "CorrectID1 " + "IncID1 " + "CorrectED1 " + "IncED1");
printDictionaryData(trialsToCriterion);

latency = calculateAverage(data_dictionary,"Latency");
fprintf("Latency\n---------------\n");
printDictionaryData(latency);

TBTP = trialType(data_dictionary,"TrialByTrialPerformance","LeftTrials", "RightTrials");


 
% latencySEM = calculateSEM(data_dictionary,"Latency");
% disp("latencySEM");
% printDictionaryData(latencySEM);

function  trialTypeDict = trialType(dictParam, key, key2, key3)
    trialTypeDict = dictionary();
    dictionaryKeys = keys(dictParam);

    for i = 1:size(dictionaryKeys)
        mouseID = dictParam{dictionaryKeys(i)};
        Sessions = size(mouseID);
        numberOfSessions = Sessions(2);
            %go inside a session
            sessionDict = dictionary();
            
            for j = 1:numberOfSessions
                CorrectSound = 0;
                IncSound = 0;
                CorrectLight = 0;
                IncLight = 0;

                session = mouseID{j};
                field = session{key};
                field2 = session{key2};
                field3 = session{key3};

                fieldDimensions = size(field);

                sessionLength = fieldDimensions(2);
                    % disp(k);
                for k = 1:sessionLength
                    if mod(field(k),2) == 0 && (field2(k) == 2 || field3(k) == 2)
                        IncLight = IncLight + 1;
                    elseif mod(field(k),2) ~= 0 && (field2(k) == 2 || field3(k) == 2)
                        CorrectLight = CorrectLight + 1;
                    elseif mod(field(k),2) == 0 && (field2(k) == 1 || field3(k) == 1)
                        IncSound = IncSound + 1;
                    elseif mod(field(k),2) ~= 0 && (field2(k) == 1 || field3(k) == 1)
                        CorrectSound = CorrectSound + 1;
                    end
                    dictFields = ["CorrectLight","IncLight", "CorrectSound", "IncSound"];
                    dictValues = [CorrectLight, IncLight, CorrectSound, IncSound];
                    sessionDict{j} = dictionary(dictFields, dictValues);
                    % sessionStr = string(sessionLength);
                    trialTypeDictKeys{j} = j;
                    trialTypeDictValues{j} = sessionDict{j};
                end
            fprintf("Mouse " + dictionaryKeys(i) + "\n")
            fprintf("Session " + j);
            trialTypeDict{dictionaryKeys(i)} = dictionary(trialTypeDictKeys{j},trialTypeDictValues{j});
            disp(trialTypeDict{dictionaryKeys(i)}(j));
            end
       
        % trialTypeDict{dictionaryKdeys(i)} = tempArray; 
        
    end

end

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

function avgDict = calculateAverageTTC(dictParam, key)

    
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

            fprintf("%d  ",data);
        end
        fprintf("]\n");
    end
end