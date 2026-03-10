
function printDictionaryData(dict)
    % function that prints all data inside of a dictionary according
    % to whatever it has inside
    dictionaryKeys = keys(dict);
    
    for i = 1: length(dictionaryKeys)
        fprintf("In key %d\n", dictionaryKeys(i));
        mouseArray = dict{dictionaryKeys(i)};
        fprintf("[");
        for j = 1: length(mouseArray)
            data = mouseArray(j);
            data = data{1};

            fprintf("%d  ",data);
        end
        fprintf("]\n");
    end
end