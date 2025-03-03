clear;
clc;
% Open file dialog to select a .mat file
[file, path] = uigetfile('*.mat', 'Select a MAT File');

% Check if a file was selected
if isequal(file, 0)
    disp('No file selected');
else
    % Load the selected .mat file
    filepath = fullfile(path, file);
    disp(['Loading file: ', filepath]);
    load(filepath);  % Loads the .mat file into workspace
end

numberSetShifts = SessionData(data_dictionary,"AttentionalSetsCompleted", "Date","subjectID");


numberTrials = SessionData(data_dictionary,"Trials", "Date", "subjectID");


numberNoInitiations = SessionData(data_dictionary,"NoInitiations", "Date", "subjectID");


correctResponsesByRP = SessionData(data_dictionary,"CorrectResponses", "Date", "subjectID");

incorrectResponsesByRP = SessionData(data_dictionary,"IncorrectResponses", "Date", "subjectID");

trialsToCriterion = SessionData(data_dictionary,"TrialsToCriterion", "Date", "subjectID");

% latency = LatencyAnalysis(data_dictionary,"TrialByTrialPerformance","Latency");
% fprintf("Latency\n---------------\n");

% TBTP = DetailedResponseClassifier(data_dictionary,"TrialByTrialPerformance","LeftTrials", "RightTrials", "LightStimuli", "SoundStimuli");
