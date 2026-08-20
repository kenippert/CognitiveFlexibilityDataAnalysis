%% Initialization and file selection
clc
clear

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
%% Run preprocessing to generate phase, side, light, and sound data
for XY = 1:length(data)
    x = data{1,XY}; %iterates through each animal's data - sessions are iterated within the MouseGetBayes function
    [outpt{XY},sz{XY},sessions{XY}] = MouseGetBayes(x); %generates nested cell array: array of subjects.array of individual sessions 
end
%% Run likelihood and analysis functions

for XZ = 1:length(data)
    [Sessionlength{XZ}, SPlike{XZ}, SPalike{XZ}, LIlike{XZ}, SOlike{XZ}, Phases{XZ}] = getSigm_shuffled(outpt,sz,XZ,sessions); 
    [normSP{XZ},normSPa{XZ}, normLI{XZ},normSO{XZ},propSP{XZ},propSPa{XZ}, propLI{XZ},propSO{XZ}, propNoStrat{XZ}] = MouseAnaBayes(XZ,Sessionlength, SPlike, SPalike, LIlike, SOlike, Phases,sessions);
end

% %% Graphing raw data
% %import matlab report generator powerpoint functionality
% 
for XZZ = 1:length(data) 
    MousePltBayes(normSP,normSPa, normLI,normSO,Phases,XZZ, outpt, sessions, ppt);
    % MousePltPie(XZZ,sessions, propSP, propSPa, propLI, propSO, propNoStrat);
end
