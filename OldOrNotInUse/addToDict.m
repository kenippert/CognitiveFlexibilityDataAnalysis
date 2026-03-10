function averageWithoutElement = addToDict(avgToAdd, averageWithoutElement, mouseID)
    tempArray = {};
    % first check if avgDict is initialized otherwise will error
    if isConfigured(averageWithoutElement)
        % then check if specific part of avgDict is initialized
        if isKey(averageWithoutElement, mouseID)
            tempArray = averageWithoutElement{mouseID};
        end
    end
    % adding mean of sessionDict's session to Calculate to
    % the end of temporary array so the index will be the same
    tempArray{length(tempArray) + 1} = avgToAdd;

    % add new tempArray back to its spot in avgDict
    averageWithoutElement{mouseID} = tempArray;
end