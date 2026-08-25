function bayesGetExcel(propSP, propLI, propSO, propNoStrat, outpt, filename)
% bayesExcel  Write per-session strategy proportions to an Excel workbook.
%   One sheet per mouse; columns = sessions (headed by the session DATE);
%   rows = strategies in the order spatial, sound, light, no_strategy.
%
%   bayesExcel(propSP, propLI, propSO, propNoStrat, outpt, filename)
%
%   propSP/propLI/propSO/propNoStrat : 1 x nMice cells; each {XZ} holds the
%                          per-session proportions for that mouse (cell or row).
%   outpt                : per-mouse sessions; column 7 of each session carries
%                          the datenum, used for the column headers and to read
%                          the subject number (column 6) for the sheet name.
%   filename             : output .xlsx path (default 'StrategyProportions.xlsx').

    if nargin < 6 || isempty(filename)
        filename = 'StrategyProportions.xlsx';
    end

    % Start from a clean workbook so stale sheets from a prior run don't linger
    if isfile(filename)
        delete(filename);
    end

    rowNames = {'spatial'; 'sound'; 'light'; 'no_strategy'};
    usedSheets = {};   % track sheet names to keep them unique

    for XZ = 1:numel(outpt)
        % Skip mice with no valid sessions (dropped/skipped upstream)
        if isempty(outpt{XZ}) || XZ > numel(propSP) || isempty(propSP{XZ})
            continue
        end

        % Pull each strategy across sessions as a 1 x nSess row
        sp = toRow(propSP{XZ});
        so = toRow(propSO{XZ});
        li = toRow(propLI{XZ});
        ns = toRow(propNoStrat{XZ});

        % Keep everything to a common length (guards against any mismatch)
        nSess = min([numel(sp), numel(so), numel(li), numel(ns), numel(outpt{XZ})]);
        if nSess == 0
            continue
        end
        sp = sp(1:nSess); so = so(1:nSess); li = li(1:nSess); ns = ns(1:nSess);

        % Rows in requested order: spatial, sound, light, no_strategy
        M = [sp; so; li; ns];           % 4 x nSess

        % Column headers = session dates, back-converted from the datenum in
        % column 7 of each session (trial 1 carries the whole-session date).
        dateStrs = cell(1, nSess);
        for j = 1:nSess
            dn = outpt{XZ}{j}{1,7};
            dateStrs{j} = datestr(dn, 'mm/dd/yy');
        end

        % Assemble the full sheet block: header row + strategy rows
        C = [ [{'strategy'}, dateStrs]; ...
              [rowNames, num2cell(M)] ];

        % Sheet name from subject number; make unique if a number repeats
        % (reused subject numbers across cohorts each get their own sheet)
        subj = round(outpt{XZ}{1,1}{1,6});
        baseName = sprintf('Subject_%d', subj);
        sheetName = baseName;
        k = 2;
        while any(strcmp(sheetName, usedSheets))
            sheetName = sprintf('%s_%d', baseName, k);
            k = k + 1;
        end
        usedSheets{end+1} = sheetName; %#ok<AGROW>

        writecell(C, filename, 'Sheet', sheetName);
    end

    fprintf('Wrote %d mouse sheet(s) to %s\n', numel(usedSheets), filename);
end

% ---- helper: coerce a per-mouse proportion entry to a numeric row vector ----
function v = toRow(c)
    if iscell(c)
        c = cell2mat(c);
    end
    v = reshape(c, 1, []);
end