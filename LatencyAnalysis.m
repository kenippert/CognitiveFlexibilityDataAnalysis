
function [postErrorDict, sessionDict] = LatencyAnalysis(dictParam, key, key2)
    postErrorDict = dictionary();

    dictionaryKeys = keys(dictParam);

    for i = 1:numel(dictionaryKeys)
        mouseID = dictParam{dictionaryKeys(i)};
        Sessions = numel(mouseID);
        % numberOfSessions = Sessions();
            %go inside a session
            sessionDict = dictionary();
            
            for j = 1:Sessions
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
                sessionDict = dictionary();
                for k = 2:sessionLength

                    %TRIAL BY TRIAL LATENCY FOLLOWING CORRECT AND
                    %INCORRECT RESPONSES ON COMPOUND DISCRIMINATION
                    if field(k-1) == 1 
                        latencyArrayCorrectResponseCD(end+1) = field2(k);

                    elseif field(k-1) == 2 
                         latencyArrayIncorrectResponseCD(end+1) = field2(k);

                    %LATENCY AND POST ERROR LATENCY ON ID1
                    elseif field(k-1) == 3
                        latencyArrayCorrectResponseID1(end+1) = field2(k);

                    elseif field(k-1) == 4
                        latencyArrayIncorrectResponseID1(end+1) = field2(k);

                    %LATENCY AND POST ERROR LATENCY ON ED1
                    elseif field(k-1) == 5
                        latencyArrayCorrectResponseED1(end+1) = field2(k);

                    elseif field(k-1) == 6 
                        latencyArrayIncorrectResponseED1(end+1) = field2(k);
                  
                    end                
                    
                    % Calculate the average latency following correct and incorrect responses
                    sessionLatencyCorrectCD = mean(latencyArrayCorrectResponseCD,"omitmissing");
                    sessionLatencyIncorrectCD = mean(latencyArrayIncorrectResponseCD,"omitmissing");

                    sessionLatencyCorrectID1 = mean(latencyArrayCorrectResponseID1,"omitmissing");
                    sessionLatencyIncorrectID1 = mean(latencyArrayIncorrectResponseID1,"omitmissing"); 

                    sessionLatencyCorrectED1 = mean(latencyArrayCorrectResponseED1,"omitmissing");
                    sessionLatencyIncorrectED1 = mean(latencyArrayIncorrectResponseED1,"omitmissing");

                    sessionLatencyArraysCorrect = [sessionLatencyCorrectCD,sessionLatencyCorrectID1, sessionLatencyCorrectED1];
                    sessionLatencyArraysIncorrect = [sessionLatencyIncorrectCD,sessionLatencyIncorrectID1, sessionLatencyIncorrectED1];

                    sessionLatencyCorrect = mean(sessionLatencyArraysCorrect,"omitmissing");
                    sessionLatencyIncorrect = mean(sessionLatencyArraysIncorrect,"omitmissing");


                    % Store the results in the post_error_slowing
                    % dictionary
                    %if any final values are NaN latency for a stage or
                    %correct/incorrect condition, it means they got NONE
                    %correct or none incorret 
                    
                    dictFields = ["CorrectLatency","CDCorrect Latency", "ID1CorrectLatency","ED1CorrectLatency","IncLatency", ...
                        "IncorrectLatencyCD","IncorrectLatencyID1", "IncorrectLatencyED1"];
                    dictValues = [sessionLatencyCorrect, sessionLatencyCorrectCD,  sessionLatencyCorrectID1, sessionLatencyCorrectED1, sessionLatencyIncorrect, ...
                        sessionLatencyIncorrectCD,sessionLatencyIncorrectID1, sessionLatencyIncorrectED1]; 

                    sessionDict{j} = dictionary(dictFields, dictValues);
                    postErrorDictKeys{j} = j;
                    postErrorDictValues{j} = sessionDict{j};


                end
            fprintf("Mouse " + dictionaryKeys(i) + "\n")
            fprintf("Session " + j);
            postErrorDict{dictionaryKeys(i)} = dictionary(postErrorDictKeys{j},sessionDict{j});
            disp(postErrorDict{dictionaryKeys(i)}(j));
            
            end        
    end

end