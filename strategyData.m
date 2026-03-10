function strategyData(outpt, XZZ, propLI, propNoStrat, propSO, propSP, propSPa,sessions)

strategyExcelFile = fullfile(pwd,'CIEFSSCFProlongedWithdrawalStrategies.xlsx');
subject = outpt{1,XZZ}{1,1}{1,6};
sheetName = sprintf("Subject%d", subject);
sheetName = replace(sheetName," ","_");
sheetName = regexprep(sheetName,'[:*?/\\[\]]','');
% ----- Excel header -----
columnHeaders = {'Session','propLi','propNoStrat','propSO','propSP','propSPa'};
ExcelRows = cell(numel(sessions{XZZ}) + 1, numel(columnHeaders));
ExcelRows(1,:) = columnHeaders;

for n = 1:sessions{XZZ}
    ExcelRows{n+1, 1} = n;
    ExcelRows{n+1, 2} = propLI{XZZ}{n};
    ExcelRows{n+1, 3} = propNoStrat{XZZ}{n};
    ExcelRows{n+1, 4} = propSO{XZZ}{n};
    ExcelRows{n+1, 5} = propSP{XZZ}{n};
    ExcelRows{n+1, 6} = propSPa{XZZ}{n};
end
writecell(ExcelRows, strategyExcelFile, 'Sheet', sheetName);

%% Summary data sheet for strategy proportions
%% Summary data sheet for strategy proportions

% ---- Compute per-subject means ----
summaryMouseName = sheetName;

summaryValues = [
    mean(cell2mat(propLI{XZZ}))
    mean(cell2mat(propNoStrat{XZZ}))
    mean(cell2mat(propSO{XZZ}))
    mean(cell2mat(propSP{XZZ}))
    mean(cell2mat(propSPa{XZZ}))
];

summaryLabels = {
    'PropLi'
    'PropNoStrat'
    'PropSO'
    'PropSP'
    'PropSPa'
};

summaryFile = strategyExcelFile;
summarySheetName = 'Summary Data';

% ---- Check if summary sheet already exists ----
[~, sheets] = xlsfinfo(summaryFile);

if any(strcmp(sheets, summarySheetName))
    % Read existing summary
    existing = readcell(summaryFile, 'Sheet', summarySheetName);

    % Append new subject column
    nextCol = size(existing, 2) + 1;
    existing{1, nextCol} = summaryMouseName;
    existing(2:end, nextCol) = num2cell(summaryValues);

    summarySheet = existing;
else
    % Create new summary sheet
    summarySheet = cell(numel(summaryLabels) + 1, 2);
    summarySheet(1,1) = {'Metric'};
    summarySheet(1,2) = {summaryMouseName};
    summarySheet(2:end,1) = summaryLabels;
    summarySheet(2:end,2) = num2cell(summaryValues);
end

writecell(summarySheet, summaryFile, 'Sheet', summarySheetName);
% pause(0.2);
% %% ---- Sort Excel sheets numerically & align Summary Data ----
% 
% excelFile = strategyExcelFile;
% 
% % Start Excel
% Excel = actxserver('Excel.Application');
% Excel.DisplayAlerts = false;
% WB = Excel.Workbooks.Open(excelFile,0,false);
% 
% % ---- Collect subject sheets ----
% sheetNames = {};
% subjectNums = [];
% 
% for i = 1:WB.Sheets.Count
%     name = WB.Sheets.Item(i).Name;
%     if startsWith(name, 'Subject')
%         sheetNames{end+1} = name;
%         subjectNums(end+1) = sscanf(name, 'Subject%d');
%     end
% end
% 
% % ---- Sort subjects numerically ----
% [~, idx] = sort(subjectNums);
% sortedSheets = sheetNames(idx);
% 
% % ---- Move sheets in correct order ----
% for i = 1:numel(sortedSheets)
%     WB.Sheets.Item(sortedSheets{i}).Move([], WB.Sheets.Item(i));
% end
% 
% % ---- Fix Summary Data column order ----
% summarySheet = WB.Sheets.Item('Summary Data');
% usedRange = summarySheet.UsedRange.Value;
% if ~iscell(usedRange)
%     usedRange = {usedRange};
% end
% 
% headers = usedRange(1, 2:end);
% summaryData = usedRange(2:end, 2:end);
% 
% % Extract subject numbers from headers
% if ~iscell(headers)
%     headers = {headers};
% end
% summaryNums = cellfun(@(x) sscanf(x,'Subject%d'), headers);
% 
% [~, colIdx] = sort(summaryNums);
% 
% % Rebuild summary sheet
% newSheet = cell(size(usedRange));
% newSheet(:,1) = usedRange(:,1);                 % Metric column
% newSheet(1,2:end) = headers(colIdx);
% newSheet(2:end,2:end) = summaryData(:,colIdx);
% 
% summarySheet.Cells.Clear;
% summarySheet.Range('A1').Resize(size(newSheet,1),size(newSheet,2)).Value = newSheet;
% 
% % ---- Save & close ----
% WB.Save;
% WB.Close;
% Excel.Quit;
% delete(Excel);

end 