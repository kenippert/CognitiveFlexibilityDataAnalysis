clc
clear
% Open a file selection UI
%This data cleaning file produces output for the bayesian analysis. MATLAB
%data files originating from the JSONDataExtractforBayesianAnalysis file
%should be used. 
[filename, filepath] = uigetfile('*.mat', 'Select a MATLAB file');

% Check if the user selected a file (filename is not 0)
if filename ~= 0
    % Construct the full path to the selected file
    fullFileName = fullfile(filepath, filename);
    
    % Display the selected file
    disp(['Selected file: ', fullFileName]);
    
    % Load the .mat file into the workspace
    file = load(fullFileName);
    data = file.data_structure;
else
    disp('No file was selected.');
end
data_extracted = data{1,1}.concatenatedDataCellArray{1};
%data_extracted(i,1) = date number
%data_extracted(i,2) = subject ID
%data_extracted(i,3) = H array, correct or incorrect. Odd = correct;
%even=incorrect
%data_extracted(i,4) = light stimulus ID
%data_extracted(i,5) = sound stimulus ID
%data_extracted(i,6) = trial type (1=sound; 2=light)
%remove NaN values from the data
data_extracted = rmmissing(data_extracted);

length_of_session = length(data_extracted);
%initiate phase, sideChoice, corrLight, corrSound, and stimSelected arrays
phase = zeros(length_of_session,1);

sideChoice = zeros(length_of_session, 1);
reinforcedSide = zeros(length_of_session,1);

congruentTrial = zeros(length_of_session,1);

lightPresented = zeros(length_of_session,1);
soundPresented = zeros(length_of_session,1);

lightChoice = zeros(length_of_session,1);
soundChoice = zeros(length_of_session,1);

% LEFT IS CODED AS 0; AND RIGHT IS CODED TO BE 1
for i = 1:length_of_session
    H(i) = data_extracted(i,3);
    if H(i) == 1 || H(i) ==2 %CD
        phase(i) = 0;
    elseif H(i) == 3 || H(i) == 4 %ID1
        phase(i) = 1;
    elseif H(i) == 5 || H(i) == 6 %ED1
        phase(i) = 2;
    elseif H(i) == 7 || H(i) == 8 %ID2
        phase(i) = 3;
    elseif H(i) == 9 || H(i) == 10 %ED2
        phase(i) = 4; 
    elseif H(i) == 11 || H(i) == 12 %ID3
        phase(i) = 5; 
    elseif H(i) == 13 || H(i) == 14 %ED3
        phase(i) = 6; 
    elseif H(i) == 15 || H(i) == 16 %ED3
        phase(i) = 7;
    elseif H(i) == 17 || H(i) == 18
        phase(i) =8;
    end
    
    lightPresented(i) = data_extracted(i,4);
    soundPresented(i) = data_extracted(i,5);

    %determining congurent and incongruent trials
    if mod(data_extracted(i,4),2) ~=0 && mod(data_extracted(i,5),2) ~= 0
        congruentTrial(i) = 1; %congruent trials
    elseif mod(data_extracted(i,4),2) ==0 && mod(data_extracted(i,5),2) ==0
        congruentTrial(i) = 1;
    else
        congruentTrial(i) = 0; %Incongruent trials
    end 

    if  data_extracted(i,6) == 1
        % DETERMINE THE SIDE THE ANIMAL CHOSE; on sound trials, sideChoice of 1 is
        % LEFT; sideChoice of 2 is RIGHT
        if mod(data_extracted(i,5), 2) ~= 0 && mod(data_extracted(i,3), 2) ~= 0
            sideChoice(i) = 0; % Left
        elseif mod(data_extracted(i,5), 2) ~= 0 && mod(data_extracted(i,3), 2) == 0
            sideChoice(i) = 1; % Right
        elseif mod(data_extracted(i,5), 2) == 0 && mod(data_extracted(i,3), 2) ~= 0
            sideChoice(i) = 1; % Right
        elseif mod(data_extracted(i,5), 2) == 0 && mod(data_extracted(i,3), 2) == 0
            sideChoice(i) = 0; % Left
        end

        %DETERMINE WHICH SIDE WAS REINFORCED
        if mod(data_extracted(i,5),2) ~= 0 
            reinforcedSide(i) = 0;
        elseif mod(data_extracted(i,5),2) == 0
            reinforcedSide(i) = 1;
        end
        
        %DETERMINE WHICH STIMULUS THE ANIMAL CHOSE
        if mod(data_extracted(i,3),2) ~= 0 && congruentTrial(i) ==1
            soundChoice(i) = data_extracted(i,5); %Congruent sound trial and they got it right so soundChoice = soundPresented and lightChoice = lightPresented
            lightChoice(i) = data_extracted(i,4);
        elseif mod(data_extracted(i,3),2) == 0 && congruentTrial(i) == 1
            soundChoice(i) = 0; %Congruent sound trial but they got it wrong so lightChoice and soundChoice = none
            lightChoice(i) = 0; 
        elseif mod(data_extracted(i,3),2) == 0 && congruentTrial(i) == 0 %incongruent sound trial and they got it wrong, so soundChoice = none and lightChoice = light presented
            soundChoice(i) = 0;
            lightChoice(i) = data_extracted(i,4);
        elseif mod(data_extracted(i,3),2) ~= 0 && congruentTrial(i) == 0 %incongruent sound trial and they got it right, so soundChoice = soundPresented and lightChoice = none
            soundChoice(i) = data_extracted(i,5);
            lightChoice(i) = 0;
        end

    elseif  data_extracted(i,6) == 2
                % Determine sideChoice based on conditions on light trials, sideChoice of 1 is
        % LEFT; sideChoice of 2 is RIGHT; 0 was an ommitted trial based on
        % NaN values in the H array (column 3 in data_extracted)
        if mod(data_extracted(i,4), 2) ~= 0 && mod(data_extracted(i,3), 2) ~= 0
            sideChoice(i) = 0; % Left
        elseif mod(data_extracted(i,4), 2) ~= 0 && mod(data_extracted(i,3), 2) == 0
            sideChoice(i) = 1; % Right
        elseif mod(data_extracted(i,4), 2) == 0 && mod(data_extracted(i,3), 2) ~= 0
            sideChoice(i) = 1; % Right
        elseif mod(data_extracted(i,4), 2) == 0 && mod(data_extracted(i,3), 2) == 0
            sideChoice(i) = 0; % Left
        end

        %DETERMINE WHICH SIDE WAS REINFORCED
        if mod(data_extracted(i,4),2) ~= 0 
            reinforcedSide(i) = 0; %LEFT SIDE REINFORCED
        elseif mod(data_extracted(i,4),2) == 0
            reinforcedSide(i) = 1; %RIGHT SIDE REINFORCED
        end

        %DETERMINE WHICH STIMULUS/I WERE CHOSEN ON LIGHT TRIALS
        if mod(data_extracted(i,3),2) ~= 0 && congruentTrial(i) ==1
            soundChoice(i) = data_extracted(i,5); %Congruent light trial and they got it right so soundChoice = soundPresented and lightChoice = lightPresented
            lightChoice(i) = data_extracted(i,4);
        elseif mod(data_extracted(i,3),2) == 0 && congruentTrial(i) == 1
            soundChoice(i) = 0; %Congruent light trial but they got it wrong so soundChoice and lightChoice = none
            lightChoice(i) = 0; 
        elseif mod(data_extracted(i,3),2) == 0 && congruentTrial(i) == 0 %incongruent light trial and they got it wrong, so soundChoice = soundPresented and lightChoice = none
            soundChoice(i) = data_extracted(i,5);
            lightChoice(i) = 0;
        elseif mod(data_extracted(i,3),2) ~= 0 && congruentTrial(i) == 0 %incongruent light trial and they got it right, so soundChoice = none and lightChoice = lightPresented
            soundChoice(i) = 0;
            lightChoice(i) = data_extracted(i,4);
        end
    end
end
% dataSideChoice = [data_extracted, sideChoice, stimSelected];

%this output is only for one session right now
output = {[phase, reinforcedSide, lightPresented, soundPresented, sideChoice, lightChoice, soundChoice, congruentTrial]};

