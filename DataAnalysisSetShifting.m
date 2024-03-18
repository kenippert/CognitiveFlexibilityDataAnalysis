load("BaselineDataDREADDsACCxCFC2.mat");

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

TBTP = trialType(data_dictionary,"TrialByTrialPerformance","LeftTrials", "RightTrials", "LightStimuli", "SoundStimuli");


function  trialTypeDict = trialType(dictParam, key, key2, key3, key4, key5)
    trialTypeDict = dictionary();
    dictionaryKeys = keys(dictParam);

    for i = 1:size(dictionaryKeys)
        mouseID = dictParam{dictionaryKeys(i)};
        Sessions = size(mouseID);
        numberOfSessions = Sessions(2);
            %go inside a session
            sessionDict = dictionary();
            
            for j = 1:numberOfSessions
                CorrectSoundCD = 0; IncSoundCD = 0;CorrectLightCD = 0;IncLightCD = 0;
                CorrectSoundID1 = 0; IncSoundID1 = 0; CorrectLightID1 = 0;IncLightID1 = 0;
                CorrectSoundED1 = 0; IncSoundED1 = 0;CorrectLightED1 = 0;IncLightED1 = 0;
                CorrectSoundID2 = 0;IncSoundID2 = 0; CorrectLightID2 = 0; IncLightID2 = 0;
                CorrectSoundED2 = 0;IncSoundED2 = 0;CorrectLightED2 = 0;IncLightED2 = 0;

                session = mouseID{j};
                %Trial by trial performance
                field = session{key};
                %Left stimuli trials
                field2 = session{key2};
                %Right stimuli trials
                field3 = session{key3};
                %Light Stimuli trials
                field4 = session{key4};
                %Right stimuli trials
                field5 = session{key5};
                
                fieldDimensions = size(field);

                sessionLength = fieldDimensions(2);
                    % disp(k);
                for k = 1:sessionLength
                    % if mod(field(k),2) == 0 && (field2(k) == 2 || field3(k) == 2)
                    %     IncLight = IncLight + 1;
                    % elseif mod(field(k),2) ~= 0 && (field2(k) == 2 || field3(k) == 2)
                    %     CorrectLight = CorrectLight + 1;
                    % elseif mod(field(k),2) == 0 && (field2(k) == 1 || field3(k) == 1)
                    %     IncSound = IncSound + 1;
                    % elseif mod(field(k),2) ~= 0 && (field2(k) == 1 || field3(k) == 1)
                    %     CorrectSound = CorrectSound + 1;
                    % end
                    
                    %TRIAL BY TRIAL PERFORMANCE BY TYPE OF SHIFT/ATTENTIONAL SET
                    %Compound discrimination light versus sound trials
                    if field(k) == 1 && (field2(k) == 2 || field3(k) == 2)
                        CorrectLightCD = CorrectLightCD + 1;
                    elseif field(k) == 2 && (field2(k) == 2 || field3(k) == 2)
                        IncLightCD = IncLightCD + 1;
                    elseif field(k) == 1 && (field2(k) == 1 || field3(k) == 1)
                        CorrectSoundCD = CorrectSoundCD + 1;
                    elseif field(k) == 2 && (field2(k) == 1 || field3(k) == 1)
                        IncSoundCD = IncSoundCD + 1;
                        
                    %ID1 light versus sound trials
                    elseif field(k) == 3 && (field2(k) == 2 || field3(k) == 2)
                        CorrectLightID1 = CorrectLightID1 + 1;
                    elseif field(k) == 4 && (field2(k) == 2 || field3(k) == 2)
                        IncLightID1 = IncLightID1 + 1;
                    elseif field(k) == 3 && (field2(k) == 1 || field3(k) == 1)
                        CorrectSoundID1 = CorrectSoundID1 + 1;
                    elseif field(k) == 4 && (field2(k) == 1 || field3(k) == 1)
                        IncSoundID1 = IncSoundID1 + 1;

                     %ED1 light versus sound trials
                    elseif field(k) == 5 && (field2(k) == 2 || field3(k) == 2)
                        CorrectLightED1 = CorrectLightED1 + 1;
                    elseif field(k) == 6 && (field2(k) == 2 || field3(k) == 2)
                        IncLightED1 = IncLightED1 + 1;
                    elseif field(k) == 5 && (field2(k) == 1 || field3(k) == 1)
                        CorrectSoundED1 = CorrectSoundED1 + 1;
                    elseif field(k) == 6 && (field2(k) == 1 || field3(k) == 1)
                        IncSoundED1 = IncSoundED1 + 1;  

                    %ID2 light versus sound trials
                    elseif field(k) == 7 && (field2(k) == 2 || field3(k) == 2)
                        CorrectLightID2 = CorrectLightID2 + 1;
                    elseif field(k) == 8 && (field2(k) == 2 || field3(k) == 2)
                        IncLightID2 = IncLightID2 + 1;
                    elseif field(k) == 7 && (field2(k) == 1 || field3(k) == 1)
                        CorrectSoundID2 = CorrectSoundID2 + 1;
                    elseif field(k) == 8 && (field2(k) == 1 || field3(k) == 1)
                        IncSoundID2 = IncSoundID2 + 1;

                    %ED2 light versus sound trials
                    elseif field(k) == 9 && (field2(k) == 2 || field3(k) == 2)
                        CorrectLightED2 = CorrectLightED2 + 1;
                    elseif field(k) == 10 && (field2(k) == 2 || field3(k) == 2)
                        IncLightED2 = IncLightED2 + 1;
                    elseif field(k) == 9 && (field2(k) == 1 || field3(k) == 1)
                        CorrectSoundED2 = CorrectSoundED2 + 1;
                    elseif field(k) == 10 && (field2(k) == 1 || field3(k) == 1)
                        IncSoundED2 = IncSoundED2 + 1;  
                    end

                    CorrectLight = CorrectLightCD + CorrectLightID1 + CorrectLightED2 + CorrectLightID2 + CorrectLightED1;
                    IncLight = IncLightED2 + IncLightID2 + IncLightED1 + IncLightID1 + IncLightCD; 
                    CorrectSound = CorrectSoundED2 + CorrectSoundID2 + CorrectSoundED1 + CorrectSoundID1 + CorrectSoundCD;
                    IncSound = IncSoundED2 + IncSoundID2 + IncSoundED1 + IncSoundID1 + IncSoundCD;


                    %%TRIAL BY TRIAL PERFORMANCE BASED ON STIMULUS
                    %if the trial had a stimuli and the response was
                    %correct (odd numbers)
                    redCorrect = 0;
                    yellowCorrect =0;
                    greenCorrect = 0;
                    blueCorrect = 0;
                    whiteCorrect = 0;
                    purpleCorrect = 0;

                    redInc = 0;
                    yellowInc = 0;
                    greenInc = 0;
                    blueInc = 0;
                    whiteInc = 0;
                    purpleInc = 0;

                    %if trial performance is non NaN & an odd number AND it
                    %is a left or right trial light trial (O or J =2) and
                    %it has the unique light stimuli identifier
                    %(1,2,3,4,5,6)
                    if (~isnan(field(k)) && mod(field(k),2) ~= 0) && (field2(k) ==2 || field3(k) ==2) && field4(k) ==1
                        redCorrect = redCorrect + 1;
                    elseif field4(k) == 2
                        yellowCorrect = yellowCorrect +1;
                    elseif field4(k) == 3
                        greenCorrect = greenCorrect +1;
                    elseif field4(k) == 4
                        blueCorrect = blueCorrect + 1;
                    elseif field4(k) == 5
                        whiteCorrect = whiteCorrect + 1;
                    elseif field4(k) == 6
                        purpleCorrect = purpleCorrect + 1;
                    end
                    %Check for incorrect light responses
                    if (~isnan(field(k)) && mod(field(k),2) == 0) && (field2(k) ==2 || field3(k) ==2) && field4(k) ==1
                        redInc = redInc + 1;
                    elseif field4(k) == 2
                        yellowInc = yellowInc +1;
                    elseif field4(k) == 3
                        greenInc = greenInc +1;
                    elseif field4(k) == 4
                        blueInc = blueInc+ 1;
                    elseif field4(k) == 5
                        whiteInc = whiteInc + 1;
                    elseif field4(k) == 6
                        purpleInc = purpleInc + 1;
                    end
                    %initialize variables for number of correct and
                    %incorrect responses on each sound stimuli, number in
                    %variable name refers to the frequency in kHz
                    twoCorrect = 0;
                    fiveCorrect =0;
                    twelveCorrect = 0;
                    nineCorrect = 0;
                    fifteenCorrect = 0;
                    twentyCorrect = 0;

                    twoInc = 0;
                    fiveInc = 0;
                    twelveInc = 0;
                    nineInc = 0;
                    fifteenInc = 0;
                    twentyInc = 0;

                    %if trial performance is non NaN & an odd number AND it
                    %is a left or right trial SOUND trial (O or I =1) and
                    %it has the unique sound stimuli identifier
                    %(1,2,3,4,5,6)
                    if (~isnan(field(k)) && mod(field(k),2) ~= 0) && (field2(k) ==1 || field3(k) ==1) && field5(k) ==1
                        twoCorrect = twoCorrect + 1;
                    elseif field5(k) == 2
                        fiveCorrect = fiveCorrect +1;
                    elseif field5(k) == 3
                        twelveCorrect = twelveCorrect +1;
                    elseif field5(k) == 4
                        nineCorrect = nineCorrect + 1;
                    elseif field5(k) == 5
                        fifteenCorrect = fifteenCorrect + 1;
                    elseif field5(k) == 6
                        twentyCorrect = twentyCorrect + 1;
                    end
                    %Check for incorrect sound responses
                    if (~isnan(field(k)) && mod(field(k),2) == 0) && (field2(k) ==1 || field3(k) ==1) && field5(k) ==1
                        twoInc = twoInc + 1;
                    elseif field5(k) == 2
                        fiveInc = fiveInc +1;
                    elseif field5(k) == 3
                        twelveInc = twelveInc +1;
                    elseif field5(k) == 4
                        nineInc = nineInc+ 1;
                    elseif field5(k) == 5
                        fifteenInc = fifteenInc + 1;
                    elseif field5(k) == 6
                        twentyInc = twentyInc + 1;
                    end                 

                    dictFields = ["CorrectLightCD","IncLightCD", "CorrectSoundCD", "IncSoundCD" ... 
                        "CorrectLightID1","IncLightID1", "CorrectSoundID1", "IncSoundID1" ...
                        "CorrectLightED1","IncLightED1", "CorrectSoundED1", "IncSoundED1" ...
                        "CorrectLightID2","IncLightID2", "CorrectSoundID2", "IncSoundID2" ...
                        "CorrectLightED2","IncLightED2", "CorrectSoundED2", "IncSoundED2" ...
                        "Total Correct Light", "Total Incorrect Light" , "Total Correct Sound", "Total Incorrect Sound", ...
                        "RedCorrect", "RedIncorrect", "YellowCorrect", "YellowIncorrect", "GreenCorrect", "GreenIncorrect", "BlueCorrect", ...
                        "BlueIncorrect", "WhiteCorrect", "WhiteIncorrect", "PurpleCorrect","PurpleIncorrect" ...
                        "2kHzCorrect","2kHzInc", "5kHzCorrect","5kHzInc", "12kHzCorrect","12kHzInc" ...
                        "9kHz Correct","9kHzInc", "15kHzCorrect","15kHzInc","20kHzCorrect", "20kHzInc"];
                    
                    dictValues = [CorrectLightCD, IncLightCD, CorrectSoundCD, IncSoundCD ...
                        CorrectLightID1, IncLightID1, CorrectSoundID1, IncSoundID1 ...
                        CorrectLightED1, IncLightED1, CorrectSoundED1, IncSoundED1 ...
                        CorrectLightID2, IncLightID2, CorrectSoundID2, IncSoundID2 ...
                        CorrectLightED2, IncLightED2, CorrectSoundED2, IncSoundED2 ...
                        CorrectLight, IncLight, CorrectSound, IncSound, ...
                        redCorrect, redInc, yellowCorrect, yellowInc, greenCorrect, greenInc ...
                        blueCorrect, blueInc, whiteCorrect, whiteInc, purpleCorrect, purpleInc ...
                        twoCorrect, twoInc, fiveCorrect, fiveInc, twelveCorrect, twelveInc ...
                        nineCorrect, nineInc, fifteenCorrect, fifteenInc, twentyCorrect, twentyInc];

                    sessionDict{j} = dictionary(dictFields, dictValues);
                    trialTypeDictKeys{j} = j;
                    trialTypeDictValues{j} = sessionDict{j};
                    

                end
            fprintf("Mouse " + dictionaryKeys(i) + "\n")
            fprintf("Session " + j);
            trialTypeDict{dictionaryKeys(i)} = dictionary(trialTypeDictKeys{j},trialTypeDictValues{j});
            disp(trialTypeDict{dictionaryKeys(i)}(j));
            
            end        
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