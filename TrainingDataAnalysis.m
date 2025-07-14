%Training data analysis
clear;
clc;

% Open a file selection UI
[filename, filepath] = uigetfile('*.mat', 'Select a MATLAB file');

% Check if the user selected a file (filename is not 0)
if filename ~= 0
    % Construct the full path to the selected file
    fullFileName = fullfile(filepath, filename);
    
    % Display the selected file
    disp(['Selected file: ', fullFileName]);
    
    % Load the .mat file into the workspace
    data = load(fullFileName);
    data = data.data_structure;
else
    disp('No file was selected.');
end
%% Run engagement analysis
for mouse = 1:length(data)
    x = data{1,mouse}; %iterates through each animal's data - sessions are iterated within the MouseGetBayes function
    [trialsEngaged{mouse},trialsOmitted{mouse},percentOmitted{mouse},sessions{mouse}, level{mouse}] = taskEngagement(x); %generates nested cell array: array of subjects.array of individual sessions 
end

for mouse = 1:length(data)
    x = data{1,mouse};
    [binnedOmissions{mouse}] = binnedOmits(x);
end
