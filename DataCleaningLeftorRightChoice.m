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

data_extracted = data{1,1}.concatenatedDataCellArray{1};
length_of_session = length(data_extracted);
%array for trial by trial side choice data. sideChoice = 1, left port;
%sideChoice = 2, right port


%array for trial by trial stimulus choice data. stimSelected = 1, attending to sound;
%stimSelected= 2, attending to light;

data_extracted = data{1,1}.concatenatedDataCellArray{1};
length_of_session = length(data_extracted);
sideChoice = zeros(length_of_session, 1); % Pre-allocate sideChoice array
stimSelected = zeros(length_of_session, 1);
for i = 1:length_of_session
    % Check if trial is a sound trial
    if isnan(data_extracted(i,3))
        sideChoice(i) = 0; %replace 0 with empty [] 
        stimSelected(i) = 0; %NaNs need to be removed
    elseif  data_extracted(i,6) == 1
        % Determine sideChoice based on conditions on sound trials, sideChoice of 1 is
        % LEFT; sideChoice of 2 is RIGHT
        if mod(data_extracted(i,5), 2) ~= 0 && mod(data_extracted(i,3), 2) ~= 0
            sideChoice(i) = 1; % Left
        elseif mod(data_extracted(i,5), 2) ~= 0 && mod(data_extracted(i,3), 2) == 0
            sideChoice(i) = 2; % Right
        elseif mod(data_extracted(i,5), 2) == 0 && mod(data_extracted(i,3), 2) ~= 0
            sideChoice(i) = 2; % Right
        elseif mod(data_extracted(i,5), 2) == 0 && mod(data_extracted(i,3), 2) == 0
            sideChoice(i) = 1; % Left
        end

        %determine the stimulus that was selected on sound trials

        %On a sound trial, if the response was correct, then the stimulus
        %selected was SOUND
        if mod(data_extracted(i,3),2) ~= 0
            stimSelected(i) = 1;

        %on a sound trial, if the response was incorrect AND the trial
        %was congruent (both stimuli associated with the same reward
        %port) then the stimSelected was SPATIAL and this was a random
        %error/error
        elseif mod(data_extracted(i,3),2) == 0 && (mod(data_extracted(i,5),2) ~= 0 && mod(data_extracted(i,4),2) ~= 0 || ... 
                (mod(data_extracted(i,5),2) == 0 && mod(data_extracted(i,4),2) == 0))
            stimSelected(i) = 3; 

        %on a sound trial, if the response was incorrect and the trial was
        %incongruent (stimuli indacted opposing reward ports) then the
        %stimulus selected was LIGHT
        elseif mod(data_extracted(i,3),2) == 0 && (mod(data_extracted(i,5),2) ~= 0 && mod(data_extracted(i,4),2) == 0 || ... 
                (mod(data_extracted(i,5),2) == 0 && mod(data_extracted(i,4),2) ~= 0))
            stimSelected(i) = 2; 
        end

    elseif  data_extracted(i,6) == 2
                % Determine sideChoice based on conditions on light trials, sideChoice of 1 is
        % LEFT; sideChoice of 2 is RIGHT; 0 was an ommitted trial based on
        % NaN values in the H array (column 3 in data_extracted)
        if mod(data_extracted(i,4), 2) ~= 0 && mod(data_extracted(i,3), 2) ~= 0
            sideChoice(i) = 1; % Left
        elseif mod(data_extracted(i,4), 2) ~= 0 && mod(data_extracted(i,3), 2) == 0
            sideChoice(i) = 2; % Right
        elseif mod(data_extracted(i,4), 2) == 0 && mod(data_extracted(i,3), 2) ~= 0
            sideChoice(i) = 2; % Right
        elseif mod(data_extracted(i,4), 2) == 0 && mod(data_extracted(i,3), 2) == 0
            sideChoice(i) = 1; % Left
        end

        %On a light trial, if the response was correct, then the stimulus
        %selected was light
        if mod(data_extracted(i,3),2) ~= 0
            stimSelected(i) = 2;

        %on a light trial, if the response was incorrect AND the trial
        %was congruent (both stimuli associated with the same reward
        %port) then the stimSelected was SPATIAL and this was a random
        %error/error
        elseif mod(data_extracted(i,3),2) == 0 && (mod(data_extracted(i,5),2) ~= 0 && mod(data_extracted(i,4),2) ~= 0 || ... 
                (mod(data_extracted(i,5),2) == 0 && mod(data_extracted(i,4),2) == 0))
            stimSelected(i) = 3; 

        %on a light trial, if the response was incorrect and the trial was
        %incongruent (stimuli indacted opposing reward ports) then the
        %stimulus selected was SOUND
        elseif mod(data_extracted(i,3),2) == 0 && (mod(data_extracted(i,5),2) ~= 0 && mod(data_extracted(i,4),2) == 0 || ... 
                (mod(data_extracted(i,5),2) == 0 && mod(data_extracted(i,4),2) ~= 0))
            stimSelected(i) = 1; 
        end
    end
end
dataSideChoice = [data_extracted, sideChoice, stimSelected];
output = {[data_extracted(:,1), data_extracted(:,2), sideChoice, stimSelected]};

