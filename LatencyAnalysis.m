
function postErrorDict = LatencyAnalysis(dictParam, key, key2)
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
                k=2;
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
                    avgLatencyCorrectCD = mean(latencyArrayCorrectResponseCD,"omitmissing");
                    avgLatencyIncorrectCD = mean(latencyArrayIncorrectResponseCD,"omitmissing");

                    avgLatencyCorrectID1 = mean(latencyArrayCorrectResponseID1,"omitmissing");
                    avgLatencyIncorrectID1 = mean(latencyArrayIncorrectResponseID1,"omitmissing"); 

                    avgLatencyCorrectED1 = mean(latencyArrayCorrectResponseED1,"omitmissing");
                    avgLatencyIncorrectED1 = mean(latencyArrayIncorrectResponseED1,"omitmissing");

                    totalLatencyCorrect = [avgLatencyCorrectCD,avgLatencyCorrectID1, avgLatencyCorrectED1];
                    totalLatencyIncorrect = [avgLatencyIncorrectCD,avgLatencyIncorrectID1, avgLatencyIncorrectED1];

                    averageLatencyCorrect = mean(totalLatencyCorrect,"omitmissing");
                    averageLatencyIncorrect = mean(totalLatencyIncorrect,"omitmissing");


                    % Store the results in the post_error_slowing
                    % dictionary
                    %if any final values are NaN latency for a stage or
                    %correct/incorrect condition, it means they got NONE
                    %correct or none incorret 
                    
                    dictFields = ["LatencyCorrectResp","LatencyIncResp","CorrectLatencyCD", "IncorrectLatencyCD","CorrectLatencyID1", "IncorrectLatencyID1", ...
                        "CorrectLatencyED1","IncorrectLatencyED1"];
                    dictValues = [averageLatencyCorrect, averageLatencyIncorrect, avgLatencyCorrectCD, avgLatencyIncorrectCD, avgLatencyCorrectID1, avgLatencyIncorrectID1, avgLatencyCorrectED1, avgLatencyIncorrectED1]; 

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