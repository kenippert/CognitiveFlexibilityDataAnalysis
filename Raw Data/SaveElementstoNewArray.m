% Create a cell array with arrays of different lengths
arrayCell = { [1, 2, 3, 4], [5, 6], [7, 8, 9] };

% Initialize an empty cell array to store the last elements
lastElements = cell(1, numel(arrayCell));

% Loop through each array to extract and store the last element
for i = 1:numel(arrayCell)
    currentArray = arrayCell{i};
     if ~isempty(currentArray)
        lastElements{i} = currentArray(end);
    else
        lastElements{i} = NaN; % Set to NaN if the array is empty
    end

end

% Convert the cell array of last elements to a numeric array if needed
lastElementsNumeric = cell2mat(lastElements);

% Display the last elements
disp("Last Elements:");
disp(lastElementsNumeric);
averageLastElement = mean(lastElementsNumeric);
disp("Average of the last elements")
disp(averageLastElement);

%remove last element from each array and store it in a new array
for i = 1:numel(arrayCell)
    currentArray = arrayCell{i};

    %check 
    if ~isempty(currentArray)
        currentArray(end) = [];
        lastElements{i} = currentArray();
    end
    arrayCell{i} = currentArray;

end

disp("Updated arrays: no last elements");
disp(arrayCell); 

% average the elements of the array
averages = zeros(1, numel(arrayCell));

% % Loop through each array in the cell array
elements= cell(1, numel(arrayCell));

for i = 1:numel(arrayCell)
    currentArray = arrayCell{i};
     if ~isempty(currentArray)
        elements{i} = currentArray();
    else
        elements{i} = NaN; % Set to NaN if the array is empty
    end
averages = mean(elements);


end
disp("Average across each element in the array");
disp(averages);


