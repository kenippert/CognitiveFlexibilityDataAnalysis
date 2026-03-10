function allSubjectValues = SessionDataExcel(dictParam, key, key2, key3, key4, key5, key6, key7, key8)
% SessionData
% Writes per-session data for each mouse into an Excel file.
% One sheet per mouse, one row per session.

allSubjectValues = {};
excelFile = fullfile(pwd,'EthanolNaiveHomecageEtOH.xlsx');

% gets the dictionary keys for the dictionary
% i.e. returns [136,137,138,...]
sortedKeys = containers.Map(dictParam.keys,dictParam.values);
dictionaryKeys = keys(sortedKeys);
display(dictionaryKeys);
%initialize summary data arrays for later
summaryMouseNames = {};
summaryAttentionalSets = {};
summaryTrials     = {};
summaryNoInit     = {};
summaryCorr       = {};
summaryInc        = {};
summaryTTC        = {};

maxTTC = 0;

%% iterate through mice (i.e. subject 137,138,...)
for i = 1:numel(dictionaryKeys)

    % ----- Mouse info -----
    sessions = dictParam{dictionaryKeys{1,i}};
    % Convert mouse ID to safe Excel sheet name
    sheetName = "Mouse" + dictionaryKeys{1,i};
    sheetName = replace(sheetName," ","_");
    sheetName = regexprep(sheetName,'[:*?/\\[\]]','');
    % ----- Excel header -----
    numSessions = numel(sessions);
    columnHeaders = {'Session','Date','SubjectID','Attentional Sets', ...
        'Trial','No Initiations', 'Correct Responses','Correct (L)', 'Correct (R)'...
        'Incorrect Responses','Incorrect (L)', 'Incorrect (R)', 'Trials to Criterion'};
    ExcelRows = cell(numel(columnHeaders), numSessions+1);
    ExcelRows(:,1) = columnHeaders;

    % Initialize cell arrays for per session outputs
    dateArray = {};
    subjectID = {};
    ssAttentionalSet = {};
    ssTrials = {};
    ssNoInit = {};
    ssCorrTrials = {};
    ssIncTrials = {};
    ssTrialsToCriterion = {};
    %Initialize arrays for across session outputs
    % Accumulators for per-mouse averaging
    attentionalSets_all = [];
    trials_all  = [];
    noInit_all  = [];
    corr_all    = [];
    inc_all     = [];
    ttc_all     = {};

    %% ----- Loop through sessions -----
    for j = 1:numSessions
        session = sessions{j};
        dateVal  = session{key};
        subjID   = session{key2};
        attSets = session{key3};
        trials = session{key4};
        noInit = session{key5};
        corrTrials = session{key6};
        incTrials = session{key7};
        trialsToCriterion = session{key8};
     
        % Store for per session output variable
       
        dateArray{j} = dateVal;
        subjectID{j} = subjID;
        ssAttentionalSet{j} = attSets;
        ssTrials{j} = trials;
        ssNoInit{j} = noInit;
        ssCorrTrials{j} = corrTrials;
        ssIncTrials{j} = incTrials;
        ssTrialsToCriterion{j} = trialsToCriterion;
        
        %store for across session outputs
        % ----- Accumulate for summary -----
        attentionalSets_all(end +1) = attSets;
        trials_all(end+1) = trials;
        noInit_all(end+1) = noInit;
        
        corr_all(end+1,:) = corrTrials(:)';
        inc_all(end+1,:)  = incTrials(:)';
        
        if numel(trialsToCriterion) < 3
            validTTC = NaN;    % entire session contributes NaN
        else
            validTTC = trialsToCriterion(2:end-2);
        end
        
        ttc_all{end+1} = validTTC(:)';
        maxTTC = max(maxTTC, numel(validTTC));


        % ----- Excel row -----
        ExcelRows{1,j+1} = j;           % Session number
        ExcelRows{2,j+1} = dateVal;     % Date
        ExcelRows{3,j+1} = subjID;      % Subject ID
        ExcelRows{4,j+1} = attSets;     % Session data (cell-safe)
        ExcelRows{5,j+1} = trials;     % Session data (cell-safe)
        ExcelRows{6,j+1} = noInit;     % Session data (cell-safe)
        ExcelRows{7,j+1} = corrTrials(1);     % Session data (cell-safe)
        ExcelRows{8,j+1} = corrTrials(2);
        ExcelRows{9,j+1} = corrTrials(3);
        ExcelRows{10,j+1} = incTrials(1);     % Session data (cell-safe)
        ExcelRows{11,j+1} = incTrials(2);
        ExcelRows{12,j+1} = incTrials(3);
        lengthTTC = numel(trialsToCriterion) - 2;
        for k = 2:lengthTTC
            ExcelRows{13+k,j+1} = trialsToCriterion(k);     % Session data (cell-safe)
        end
    end
    % ----- Compute per-mouse means for summary -----
    summaryMouseNames{i} = sheetName;
    summaryAttentionalSets{i} = mean(attentionalSets_all, 'omitnan');
    summaryTrials{i} = mean(trials_all, 'omitnan');
    summaryNoInit{i} = mean(noInit_all, 'omitnan');
    
    summaryCorr{i} = mean(corr_all, 1, 'omitnan');
    summaryInc{i}  = mean(inc_all, 1, 'omitnan');
    
    % Trials to Criterion (variable length)
    ttcMat = nan(numel(ttc_all), maxTTC);
    for s = 1:numel(ttc_all)
        len = numel(ttc_all{s});
        ttcMat(s,1:len) = ttc_all{s};
    end
    summaryTTC{i} = mean(ttcMat, 1, 'omitnan');

    % Write sheet for this mouse
    %write cell function does not preserve the shape inside a cell. 
    %It was flattening my doubles.
    writecell(ExcelRows, excelFile, 'Sheet', sheetName);

    % Match your original nested-cell output structure
    allSubjectValues{1,i} = [dateArray; subjectID; ssAttentionalSet; ssTrials; ssNoInit; ...
        ssCorrTrials; ssIncTrials; ssTrialsToCriterion];

end
% ===== WRITE SUMMARY SHEET =====
numMice = numel(summaryMouseNames);

summaryLabels = {
    'Mean Attentional Sets'
    'Mean Trials'
    'Mean No Initiations'
    'Mean Correct (L)'
    'Mean Correct (R)'
    'Mean Correct (Total)'
    'Mean Incorrect (L)'
    'Mean Incorrect (R)'
    'Mean Incorrect (Total)'
};

for k = 1:maxTTC
    summaryLabels{end+1,1} = sprintf('Mean Trials to Criterion (%d)', k);
end

SummarySheet = cell(numel(summaryLabels)+1, numMice+1);

% Headers
SummarySheet(1,2:end) = summaryMouseNames;
SummarySheet(2:end,1) = summaryLabels;

% Fill data
for i = 1:numMice
    r = 2;

    SummarySheet{r,i+1} = summaryAttentionalSets{i}; r = r+1;
    SummarySheet{r,i+1} = summaryTrials{i}; r = r+1;
    SummarySheet{r,i+1} = summaryNoInit{i}; r = r+1;

    SummarySheet{r,i+1} = summaryCorr{i}(1); r = r+1;
    SummarySheet{r,i+1} = summaryCorr{i}(2); r = r+1;
    SummarySheet{r,i+1} = summaryCorr{i}(3); r = r+1;

    SummarySheet{r,i+1} = summaryInc{i}(1); r = r+1;
    SummarySheet{r,i+1} = summaryInc{i}(2); r = r+1;
    SummarySheet{r,i+1} = summaryInc{i}(3); r = r+1;

    for k = 1:maxTTC
        if k <= numel(summaryTTC{i})
            SummarySheet{r,i+1} = summaryTTC{i}(k);
        else
            SummarySheet{r,i+1} = NaN;
        end
        r = r+1;
    end

end

writecell(SummarySheet, excelFile, 'Sheet', 'Summary Data');
    
end
