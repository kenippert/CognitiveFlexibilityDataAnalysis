%Latency and post-error slowing analysis code
clear
clc
load("C:\Users\katyn\Desktop\Lab Work\Cognitive Flexibility\DREADDsACC x CognitiveFlex Cohort 2\Baseline Sessions Raw Data DREADD mice\BaselineDataDREADDACCxCFC2.mat");

post_error_slowing = postErrorSlowing(data_dictionary,"TrialByTrialPerformance","Latency");

function postErrorDict = postErrorSlowing(dictParam, key, key2)
    postErrorDict = dictionary();
    dictionaryKeys = keys(dictParam);

    for i = 1:numel(dictionaryKeys)
        mouseID = dictParam{dictionaryKeys(i)};
        Sessions = numel(mouseID);
        numberOfSessions = Sessions(2);
            %go inside a session
            sessionDict = dictionary();
            
            for j = 1:numberOfSessions
                latencyArrayCorrectResponseCD = [];
                latencyArrayIncorrectResponseCD = [];

                latencyArrayCorrectResponseID1 = [];
                latencyArrayIncorrectResponseID1 = [];

                latencyArrayCorrectResponseED1 = [];
                latencyArrayIncorrectResponseED1 = [];

                session = mouseID{j};
                %Trial by trial performance
                field = session{key};
                %Latency on each trial
                field2 = session{key2};
                
                fieldDimensions = size(field);

                sessionLength = numel(field);
                    % disp(k);
                for k = 2:sessionLength

                    %TRIAL BY TRIAL LATENCY FOLLOWING CORRECT AND
                    %INCORRECT RESPONSES ON COMPOUND DISCRIMINATION
                    if field(k-1) == 1
                        latencyArrayCorrectResponseCD(end+1) = field2(k);

                    elseif field(k-1) == 2 
                         latencyArrayIncorrectResponseCD(end+1) = field2(k);

                        
                    %LATENCY AND POST ERROR SLOWING ON ID1
                    elseif field(k-1) == 3
                        latencyArrayCorrectResponseID1(end+1) = field2(k);

                    elseif field(k-1) == 4
                        latencyArrayIncorrectResponseID1(end+1) = field2(k);

                    %LATENCY AND POST ERROR SLOWING ON ED1
                    elseif field(k-1) == 5
                        latencyArrayCorrectResponseED1(end+1) = field2(k);

                    elseif field(k-1) == 6 
                        latencyArrayIncorrectResponseED1(end+1) = field2(k);
                    
                    end                
                    
                    % Calculate the average latency for correct and incorrect responses
                    avgLatencyCorrectCD = mean(latencyArrayCorrectResponseCD);
                    avgLatencyIncorrectCD = mean(latencyArrayIncorrectResponseCD);

                    avgLatencyCorrectID1 = mean(latencyArrayCorrectResponseID1);
                    avgLatencyIncorrectID1 = mean(latencyArrayIncorrectResponseID1); 

                    avgLatencyCorrectED1 = mean(latencyArrayCorrectResponseED1);
                    avgLatencyIncorrectED1 = mean(latencyArrayIncorrectResponseED1);
                    % Store the results in the trialTypeDict

                    dictFields = ["CorrectLatencyCD", "IncorrectLatencyCD","CorrectLatencyID1", "IncorrectLatencyID1", ...
                        "CorrectLatencyED1","IncorrectLatencyED1"];
                    dictValues = [avgLatencyCorrectCD; avgLatencyIncorrectCD, avgLatencyCorrectID1, avgLatencyIncorrectID1, avgLatencyCorrectED1, avgLatencyIncorrectED1]; 

                    sessionDict{j} = dictionary(dictFields, dictValues);
                    postErrorDictKeys{j} = j;
                    postErrorDictValues{j} = sessionDict{j};


                end
            fprintf("Mouse " + dictionaryKeys(i) + "\n")
            fprintf("Session " + j);
            postErrorDict{dictionaryKeys(i)} = dictionary(postErrorDictKeys{j},postErrorDictValues{j});
            disp(postErrorDict{dictionaryKeys(i)}(j));
            
            end        
    end

end