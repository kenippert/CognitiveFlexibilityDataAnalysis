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

% numberSetShifts = SessionAverages(data_dictionary,"AttentionalSetsCompleted");
% fprintf("AttentionalSetsCompleted\n---------------\n");
% printDictionaryData(numberSetShifts);
% 
% numberTrials = SessionAverages(data_dictionary,"Trials");
% fprintf("Number of Trials By Session\n---------------\n");
% printDictionaryData(numberTrials);
% 
% numberNoInitiations = SessionAverages(data_dictionary,"NoInitiations");
% fprintf("Number of No Initiations Per Session\n---------------\n");
% printDictionaryData(numberNoInitiations); 
% 
% correctResponsesByRP = AverageTTC(data_dictionary,"CorrectResponses");
% fprintf("Correct Responses\n---------------\nTotalCorrect " + "LeftCorrect " + "RightCorrect\n");
% printDictionaryData(correctResponsesByRP); 
% 
% incorrectResponsesByRP = AverageTTC(data_dictionary,"IncorrectResponses");
% fprintf("Incorrect Responses\n---------------\nTotalIncorrect " + "LeftIncorrect " + "RightIncorrect\n");
% printDictionaryData(incorrectResponsesByRP); 
% 
% trialsToCriterion = AverageTTC(data_dictionary,"TrialsToCriterion");
% fprintf("Trials To Criterion\n---------------\nCorrectCD " + "IncCD " + "CorrectID1 " + "IncID1 " + "CorrectED1 " + "IncED1");
% printDictionaryData(trialsToCriterion);

latency = LatencyAnalysis(data_dictionary,"TrialByTrialPerformance","Latency");
fprintf("Latency\n---------------\n");

TBTP = DetailedResponseClassifier(data_dictionary,"TrialByTrialPerformance","LeftTrials", "RightTrials", "LightStimuli", "SoundStimuli");
