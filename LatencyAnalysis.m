function [postErrorCell, sessionCell] = LatencyAnalysis(dictParam, key, key2)
    postErrorCell = cell(numel(dictParam), 1);  % Pre-allocate cell array for each subject

    dictionaryKeys = keys(dictParam);

    for i = 1:numel(dictionaryKeys)
        mouseID = dictParam(dictionaryKeys(i));
        Sessions = numel(mouseID);

        sessionCell = cell(1, Sessions);  % Pre-allocate cell array for each session
        
        for j = 1:Sessions
            latencyArrayCorrectResponseCD = [];
            latencyArrayIncorrectResponseCD = [];

            latencyArrayCorrectResponseID1 = [];
            latencyArrayIncorrectResponseID1 = [];

            latencyArrayCorrectResponseED1 = [];
            latencyArrayIncorrectResponseED1 = [];

            session = mouseID{j};
            % Trial by trial performance
            field = session{j}{key};
            % Latency on each trial
            field2 = session{j}{key2};
            
            sessionLength = numel(field);

            for k = 2:sessionLength
                % TRIAL BY TRIAL LATENCY FOLLOWING CORRECT AND INCORRECT RESPONSES ON COMPOUND DISCRIMINATION
                if field(k-1) == 1 
                    latencyArrayCorrectResponseCD(end+1) = field2(k);

                elseif field(k-1) == 2 
                    latencyArrayIncorrectResponseCD(end+1) = field2(k);

                % LATENCY AND POST ERROR LATENCY ON ID1
                elseif field(k-1) == 3
                    latencyArrayCorrectResponseID1(end+1) = field2(k);

                elseif field(k-1) == 4
                    latencyArrayIncorrectResponseID1(end+1) = field2(k);

                % LATENCY AND POST ERROR LATENCY ON ED1
                elseif field(k-1) == 5
                    latencyArrayCorrectResponseED1(end+1) = field2(k);

                elseif field(k-1) == 6 
                    latencyArrayIncorrectResponseED1(end+1) = field2(k);
                end                
            end

            % Calculate the average latency following correct and incorrect responses
            sessionLatencyCorrectCD = mean(latencyArrayCorrectResponseCD, "omitmissing");
            sessionLatencyIncorrectCD = mean(latencyArrayIncorrectResponseCD, "omitmissing");

            sessionLatencyCorrectID1 = mean(latencyArrayCorrectResponseID1, "omitmissing");
            sessionLatencyIncorrectID1 = mean(latencyArrayIncorrectResponseID1, "omitmissing"); 

            sessionLatencyCorrectED1 = mean(latencyArrayCorrectResponseED1, "omitmissing");
            sessionLatencyIncorrectED1 = mean(latencyArrayIncorrectResponseED1, "omitmissing");

            sessionLatencyArraysCorrect = [sessionLatencyCorrectCD, sessionLatencyCorrectID1, sessionLatencyCorrectED1];
            sessionLatencyArraysIncorrect = [sessionLatencyIncorrectCD, sessionLatencyIncorrectID1, sessionLatencyIncorrectED1];

            sessionLatencyCorrect = mean(sessionLatencyArraysCorrect, "omitmissing");
            sessionLatencyIncorrect = mean(sessionLatencyArraysIncorrect, "omitmissing");

            % Store the results in the post_error_slowing cell array
            cellFields = {"CorrectLatency", "CDCorrectLatency", "ID1CorrectLatency", "ED1CorrectLatency", ...
                          "IncorrectLatency", "IncorrectLatencyCD", "IncorrectLatencyID1", "IncorrectLatencyED1"};
            cellValues = {sessionLatencyCorrect, sessionLatencyCorrectCD, sessionLatencyCorrectID1, ...
                          sessionLatencyCorrectED1, sessionLatencyIncorrect, sessionLatencyIncorrectCD, ...
                          sessionLatencyIncorrectID1, sessionLatencyIncorrectED1};

            sessionCell{j} = cell(2, numel(cellFields));  % Create a 2-row cell array for field names and values
            sessionCell{j}(1, :) = cellFields;
            sessionCell{j}(2, :) = cellValues;
    fprintf("Latency calculated %s\n", dictionaryKeys(i,1));
        end

        % Store session-wise data in postErrorCell for each mouse
        postErrorCell{i} = sessionCell;  % Assign session cell array to postErrorCell for the current mouse
        
    end
end
