function trialTypeDict = ResponseClassifier(dictParam, key, key2, key3, key4, key5)
% ResponseClassifier - Classifies correct and incorrect responses per stimulus
% and writes results per mouse into an Excel workbook with a sheet for each mouse.

trialTypeDict = dictionary();
% Excel file to write
excelFile = fullfile(pwd,'EthanolNaiveVSHomecageEtOH.xlsx');

sortedKeys = containers.Map(dictParam.keys,dictParam.values);
dictionaryKeys = keys(sortedKeys);

summaryMouseNames = {};
summaryData = {};
for i = 1:numel(dictionaryKeys)
    mouseID = dictParam{dictionaryKeys{1,i}};
    mouseName = dictionaryKeys(i); % will be used for Excel sheet name
    sheetName = "Mouse" + dictionaryKeys{1,i}; %dont use char() for numbers
    sheetName = replace(sheetName," ","_");            % replace spaces
    sheetName = regexprep(sheetName,'[:*?/\\[\]]',''); % remove illegal Excel chars
   % sheetName = sheetName(1:min(strlength(sheetName),31)); % max 31 chars
    
    numberOfSessions = numel(mouseID);
    sessionDict = dictionary();
    
    % Excel rows initialization
    columnHeaders = {'Session', ...
        'CorrectLightCD','IncLightCD','CorrectSoundCD','IncSoundCD', ...
        'CorrectLightID1','IncLightID1','CorrectSoundID1','IncSoundID1', ...
        'CorrectLightED1','IncLightED1','CorrectSoundED1','IncSoundED1', ...
        'CorrectLightID2','IncLightID2','CorrectSoundID2','IncSoundID2', ...
        'CorrectLightED2','IncLightED2','CorrectSoundED2','IncSoundED2', ...
        'TotalCorrectLight','TotalIncorrectLight','TotalCorrectSound','TotalIncorrectSound', ...
        'RedCorrect','RedIncorrect','YellowCorrect','YellowIncorrect','GreenCorrect','GreenIncorrect', ...
        'BlueCorrect','BlueIncorrect','WhiteCorrect','WhiteIncorrect','PurpleCorrect','PurpleIncorrect', ...
        '2kHzCorrect','2kHzInc','5kHzCorrect','5kHzInc','12kHzCorrect','12kHzInc', ...
        '9kHzCorrect','9kHzInc','15kHzCorrect','15kHzInc','20kHzCorrect','20kHzInc'};
    
    ExcelRows = cell(numberOfSessions+1, numel(columnHeaders));
    ExcelRows(1,:) = columnHeaders;
    
    %initialize summary values array for summary accumulators
    summaryValues = []; 

    for j = 1:numberOfSessions
        % Initialize counters
        CorrectLightCD = 0; IncLightCD = 0; CorrectSoundCD = 0; IncSoundCD = 0;
        CorrectLightID1 = 0; IncLightID1 = 0; CorrectSoundID1 = 0; IncSoundID1 = 0;
        CorrectLightED1 = 0; IncLightED1 = 0; CorrectSoundED1 = 0; IncSoundED1 = 0;
        CorrectLightID2 = 0; IncLightID2 = 0; CorrectSoundID2 = 0; IncSoundID2 = 0;
        CorrectLightED2 = 0; IncLightED2 = 0; CorrectSoundED2 = 0; IncSoundED2 = 0;
        CorrectLight = 0; IncLight = 0; CorrectSound = 0; IncSound = 0;
        
        redCorrect = 0; yellowCorrect =0; greenCorrect = 0; blueCorrect = 0; whiteCorrect = 0; purpleCorrect = 0;
        redInc = 0; yellowInc = 0; greenInc = 0; blueInc = 0; whiteInc = 0; purpleInc = 0;
        
        twoCorrect = 0; fiveCorrect =0; twelveCorrect = 0; nineCorrect = 0; fifteenCorrect = 0; twentyCorrect = 0;
        twoInc = 0; fiveInc = 0; twelveInc = 0; nineInc = 0; fifteenInc = 0; twentyInc = 0;
        
        session = mouseID{j};
        
        % Trial-by-trial fields
        field  = session{key};
        field2 = session{key2};
        field3 = session{key3};
        field4 = session{key4};
        field5 = session{key5};
        
        sessionLength = numel(field);
        
        for k = 1:sessionLength
            % Correct / Incorrect Light / Sound
            if mod(field(k),2) == 0 && (field2(k) == 2 || field3(k) == 2)
                IncLight = IncLight + 1;
            elseif mod(field(k),2) ~= 0 && (field2(k) == 2 || field3(k) == 2)
                CorrectLight = CorrectLight + 1;
            elseif mod(field(k),2) == 0 && (field2(k) == 1 || field3(k) == 1)
                IncSound = IncSound + 1;
            elseif mod(field(k),2) ~= 0 && (field2(k) == 1 || field3(k) == 1)
                CorrectSound = CorrectSound + 1;
            end
            
            % Compound / ID / ED trial classification
            if field(k) == 1 && (field2(k) == 2 || field3(k) == 2)
                CorrectLightCD = CorrectLightCD + 1;
            elseif field(k) == 2 && (field2(k) == 2 || field3(k) == 2)
                IncLightCD = IncLightCD + 1;
            elseif field(k) == 1 && (field2(k) == 1 || field3(k) == 1)
                CorrectSoundCD = CorrectSoundCD + 1;
            elseif field(k) == 2 && (field2(k) == 1 || field3(k) == 1)
                IncSoundCD = IncSoundCD + 1;
            elseif field(k) == 3 && (field2(k) == 2 || field3(k) == 2)
                CorrectLightID1 = CorrectLightID1 + 1;
            elseif field(k) == 4 && (field2(k) == 2 || field3(k) == 2)
                IncLightID1 = IncLightID1 + 1;
            elseif field(k) == 3 && (field2(k) == 1 || field3(k) == 1)
                CorrectSoundID1 = CorrectSoundID1 + 1;
            elseif field(k) == 4 && (field2(k) == 1 || field3(k) == 1)
                IncSoundID1 = IncSoundID1 + 1;
            elseif field(k) == 5 && (field2(k) == 2 || field3(k) == 2)
                CorrectLightED1 = CorrectLightED1 + 1;
            elseif field(k) == 6 && (field2(k) == 2 || field3(k) == 2)
                IncLightED1 = IncLightED1 + 1;
            elseif field(k) == 5 && (field2(k) == 1 || field3(k) == 1)
                CorrectSoundED1 = CorrectSoundED1 + 1;
            elseif field(k) == 6 && (field2(k) == 1 || field3(k) == 1)
                IncSoundED1 = IncSoundED1 + 1;
            elseif field(k) == 7 && (field2(k) == 2 || field3(k) == 2)
                CorrectLightID2 = CorrectLightID2 + 1;
            elseif field(k) == 8 && (field2(k) == 2 || field3(k) == 2)
                IncLightID2 = IncLightID2 + 1;
            elseif field(k) == 7 && (field2(k) == 1 || field3(k) == 1)
                CorrectSoundID2 = CorrectSoundID2 + 1;
            elseif field(k) == 8 && (field2(k) == 1 || field3(k) == 1)
                IncSoundID2 = IncSoundID2 + 1;
            elseif field(k) == 9 && (field2(k) == 2 || field3(k) == 2)
                CorrectLightED2 = CorrectLightED2 + 1;
            elseif field(k) == 10 && (field2(k) == 2 || field3(k) == 2)
                IncLightED2 = IncLightED2 + 1;
            elseif field(k) == 9 && (field2(k) == 1 || field3(k) == 1)
                CorrectSoundED2 = CorrectSoundED2 + 1;
            elseif field(k) == 10 && (field2(k) == 1 || field3(k) == 1)
                IncSoundED2 = IncSoundED2 + 1;
            end
            
            % Total light/sound
            CorrectLight = CorrectLightCD + CorrectLightID1 + CorrectLightED1 + CorrectLightID2 + CorrectLightED2;
            IncLight = IncLightCD + IncLightID1 + IncLightED1 + IncLightID2 + IncLightED2;
            CorrectSound = CorrectSoundCD + CorrectSoundID1 + CorrectSoundED1 + CorrectSoundID2 + CorrectSoundED2;
            IncSound = IncSoundCD + IncSoundID1 + IncSoundED1 + IncSoundID2 + IncSoundED2;
            
            % Light stimuli by color
            if (~isnan(field(k)) && mod(field(k),2) ~= 0 && (field2(k) == 2 || field3(k) == 2))
                switch field4(k)
                    case 1, redCorrect = redCorrect + 1;
                    case 2, yellowCorrect = yellowCorrect +1;
                    case 3, greenCorrect = greenCorrect +1;
                    case 4, blueCorrect = blueCorrect + 1;
                    case 5, whiteCorrect = whiteCorrect + 1;
                    case 6, purpleCorrect = purpleCorrect + 1;
                end
            elseif (~isnan(field(k)) && mod(field(k),2) == 0 && (field2(k) == 2 || field3(k) == 2))
                switch field4(k)
                    case 1, redInc = redInc + 1;
                    case 2, yellowInc = yellowInc +1;
                    case 3, greenInc = greenInc +1;
                    case 4, blueInc = blueInc + 1;
                    case 5, whiteInc = whiteInc + 1;
                    case 6, purpleInc = purpleInc + 1;
                end
            end
            
            % Sound stimuli by frequency
            if (~isnan(field(k)) && mod(field(k),2) ~= 0 && (field2(k) == 1 || field3(k) == 1))
                switch field5(k)
                    case 1, twoCorrect = twoCorrect +1;
                    case 2, fiveCorrect = fiveCorrect +1;
                    case 3, twelveCorrect = twelveCorrect +1;
                    case 4, nineCorrect = nineCorrect +1;
                    case 5, fifteenCorrect = fifteenCorrect +1;
                    case 6, twentyCorrect = twentyCorrect +1;
                end
            elseif (~isnan(field(k)) && mod(field(k),2) == 0 && (field2(k) == 1 || field3(k) == 1))
                switch field5(k)
                    case 1, twoInc = twoInc +1;
                    case 2, fiveInc = fiveInc +1;
                    case 3, twelveInc = twelveInc +1;
                    case 4, nineInc = nineInc +1;
                    case 5, fifteenInc = fifteenInc +1;
                    case 6, twentyInc = twentyInc +1;
                end
            end
            
        end % session trials loop
        
        % Store in dictionary
        dictFields = columnHeaders(2:end); % omit 'Session' header
        dictValues = [CorrectLightCD,IncLightCD,CorrectSoundCD,IncSoundCD, ...
            CorrectLightID1,IncLightID1,CorrectSoundID1,IncSoundID1, ...
            CorrectLightED1,IncLightED1,CorrectSoundED1,IncSoundED1, ...
            CorrectLightID2,IncLightID2,CorrectSoundID2,IncSoundID2, ...
            CorrectLightED2,IncLightED2,CorrectSoundED2,IncSoundED2, ...
            CorrectLight,IncLight,CorrectSound,IncSound, ...
            redCorrect,redInc,yellowCorrect,yellowInc,greenCorrect,greenInc, ...
            blueCorrect,blueInc,whiteCorrect,whiteInc,purpleCorrect,purpleInc, ...
            twoCorrect,twoInc,fiveCorrect,fiveInc,twelveCorrect,twelveInc, ...
            nineCorrect,nineInc,fifteenCorrect,fifteenInc,twentyCorrect,twentyInc];

        summaryValues(j,:) = dictValues;
        sessionDict(j) = dictionary(dictFields, num2cell(dictValues));
        
        % Store Excel row
        ss = sprintf('Session %d',j);
        ExcelRows(j+1,:) = [ ss, num2cell(dictValues)];
        
    end % sessions
    % Write to Excel sheet for this mouse
    writecell(ExcelRows, excelFile, 'Sheet', sheetName);
    trialTypeDict(mouseName) = sessionDict;

    %convert values of zero to NaN so they don't skew the average(values
    %are zero for whichever stimulus modality was not the target
    summaryValues(summaryValues == 0) = NaN;

    summaryMean = mean(summaryValues,1,'omitnan');
    summaryMouseNames{end+1} = sheetName;
    summaryData{end + 1} = summaryMean;

end
% ===== WRITE SUMMARY SHEET =====
numMice = numel(summaryMouseNames);
numVars = numel(columnHeaders) - 1; % omit 'Session'

SummarySheet = cell(numVars+1, numMice+1);

% Headers
SummarySheet(1,2:end) = summaryMouseNames;
SummarySheet(2:end,1) = columnHeaders(2:end)';

% Fill data
for i = 1:numMice
    SummarySheet(2:end,i+1) = num2cell(summaryData{i}');
end

writecell(SummarySheet, excelFile, 'Sheet', 'Summary Data');

end
