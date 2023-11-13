load("TestingWeek1.mat");
trialPerformance = calculateAverageTrialPerf("TrialPerformance");
disp(trialPerformance);


function avgDict = calculateAverageTrialPerf(dictParam)
    key = 'TrialPerformance';
    avgDict = dictionary();
    % Get the dictionary keys for the dictionary
    dictionaryKeys = keys(dictParam);
    
    % Iterate through mouse sessions
    for i = 1:size(dictionaryKeys)
        fprintf('In key %d\n', dictionaryKeys(i));
        
        % Extract the session dictionary
        mouseArray = dictParam(dictionaryKeys(i));
        sessionDict = mouseArray(1);
        sessionDict = sessionDict{1};
        
        sessionArray = sessionDict(key);
        sessionArray = sessionArray{1};
        
        % Initialize arrays to store the means
        lastElementMean = NaN(length(sessionArray), 1);
        restOfElementsMean = NaN(length(sessionArray), 1);
        
        for j = 1:length(sessionArray)
            % Iterate through sessions for each mouse
            for k = 1:length(mouseArray)
                sessionDict = mouseArray(k);
                sessionDict = sessionDict{1};
                
                insideSession = sessionDict(key);
                insideSession = insideSession{1};
                
                if j <= length(insideSession)
                    fprintf('Adding %d to the average\n', insideSession(j));
                    averageArray(k) = insideSession(j);
                end
            end
            
            % Calculate the means
            lastElementMean(j) = mean(averageArray(1:k), 'omitnan');
            restOfElementsMean(j) = mean(averageArray(1:k-1), 'omitnan');
            fprintf('---------------\n');
        end
        
        % Store the means in the result dictionary
        avgDict(dictionaryKeys{i}) = [lastElementMean, restOfElementsMean];
    end
end
