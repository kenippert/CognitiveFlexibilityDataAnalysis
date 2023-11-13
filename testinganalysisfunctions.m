% %testing groupcounts
% X = [1 2 3 1 2 3 1 2 1];
% Y = [ 3 2 1 3 2 1 1 2 1 NaN];
% numbers = groupcounts(X.');
% numbersY = groupcounts(Y.');
% Create a cell array with arrays of different lengths
arrayCell = { [1, 2, 3, 4], [5, 6], [7, 8, 9] };

for i = 1:numel(arrayCell)
    currentArray = arrayCell{i};

    %check 
    if ~isempty(currentArray)
        currentArray(end) = [];
        lastElements{i} = currentArray();
    end
    arrayCell{i} = currentArray;

end
disp("Array with last elements removed");
disp(arrayCell);
