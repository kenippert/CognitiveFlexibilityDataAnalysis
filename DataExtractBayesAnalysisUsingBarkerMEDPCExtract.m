%This file takes allOut from the Barker medpc extract and creates a table containing
%cell arrays of data for Bayes analysis.
%
%Animal identity = subject number + group, then further split by date: within a
%subject+group bucket, a gap of MORE than maxWithinAnimalGapMonths between
%consecutive sessions starts a new cohort. Sessions with no group are never merged
%into a known-group animal.
%
%A full disposition audit records what happened to EVERY allOut entry (kept vs
%skipped), tagged with date, so you can see when/where sessions were left out.
%
%NOTE: requires MATLAB R2016b+ (local functions in scripts).

% =========================== CONFIG ===========================
% Fields used to disambiguate reused subject numbers, tried in order.
identityFields = {'Group','Experiment'};

% MedPC often defaults an un-entered Group/Experiment to 0. If true, 0 is
% treated as "not entered" (-> UNKNOWN + flagged) rather than a real group.
treatZeroGroupAsMissing = true;

% Within one subject+group, a gap of MORE than this many calendar months
% between consecutive sessions is treated as a different cohort (new animal).
maxWithinAnimalGapMonths = 8;

% Date window to audit for missing/dropped sessions (e.g., around Jan 2025).
% Every allOut entry whose StartDate falls in this window is listed with its
% disposition (kept vs skipped + reason). Widen as needed.
auditWindowStart = datetime(2024,12,1);
auditWindowEnd   = datetime(2025,2,28);
% ==============================================================

data_structure = {};
% Maps canonical animal key (char) -> index into data_structure
animal_index_map = containers.Map('KeyType','char','ValueType','int32');
% Parallel metadata per data_structure entry, for reporting
animalMeta = struct('subject',{},'group',{},'groupPresent',{},'key',{});

% Record of sessions that get dropped, and why
skippedSessions = struct('index', {}, 'subject', {}, 'reason', {});
% Lightweight per-session log (valid sessions only), used to compute review flags
sessionLog = struct('index',{},'subject',{},'dateNum',{}, ...
                    'present',{},'group',{},'canon',{},'srcField',{});
% Full disposition audit: what happened to every allOut entry, with date
auditLog = struct('index',{},'subject',{},'date',{},'disposition',{},'detail',{});

for i=1:length(allOut)
    name_of_subject = allOut{i}.Subject;
    display(allOut{i}.Subject)
    display(allOut{i}.MSN)

    % Best-effort date for auditing (independent of any later skip)
    bestDate = NaT;
    if isfield(allOut{i}, 'StartDate')
        try
            bestDate = datetime(allOut{i}.StartDate, 'InputFormat', 'MM/dd/yy');
        catch
            bestDate = NaT;
        end
    end

    % ---- Resolve subject number ----
    if ~isnumeric(name_of_subject)
        if ischar(name_of_subject) || isstring(name_of_subject)
            val = str2double(name_of_subject);
            if isnan(val)
                skippedSessions(end+1) = struct('index', i, ...
                    'subject', name_of_subject, ...
                    'reason', 'subject name not convertible to number');
                auditLog = pushAudit(auditLog, i, name_of_subject, bestDate, ...
                    'skipped', 'subject name not convertible to number');
                continue
            else
                name_of_subject = val;
            end
        else
            skippedSessions(end+1) = struct('index', i, ...
                'subject', NaN, ...
                'reason', 'subject name non-numeric, non-string');
            auditLog = pushAudit(auditLog, i, NaN, bestDate, ...
                'skipped', 'subject name non-numeric, non-string');
            continue
        end
    end

    % ===== Validate trial-by-trial array sizes; skip mismatched sessions =====
    if ~isfield(allOut{i}, 'H') || isempty(allOut{i}.H)
        skippedSessions(end+1) = struct('index', i, ...
            'subject', name_of_subject, 'reason', 'missing/empty H');
        auditLog = pushAudit(auditLog, i, name_of_subject, bestDate, 'skipped', 'missing/empty H');
        fprintf('Skipping session %d (subject %s): missing/empty H\n', ...
                i, num2str(name_of_subject));
        continue
    end
    length_of_array = numel(allOut{i}.H);

    sizesOK = true;
    reason = '';
    for fn = {'L','S'}
        f = fn{1};
        if ~isfield(allOut{i}, f) || numel(allOut{i}.(f)) < length_of_array
            sizesOK = false;
            reason = sprintf('%s shorter than H (%d)', f, length_of_array);
            break
        end
    end
    if sizesOK
        if isfield(allOut{i}, 'R') && numel(allOut{i}.R) > 1
            if numel(allOut{i}.R) ~= length_of_array
                sizesOK = false;
                reason = sprintf('R length %d ~= H length %d', ...
                                 numel(allOut{i}.R), length_of_array);
            end
        else
            if ~(isfield(allOut{i}, 'O') && isfield(allOut{i}, 'J') && ...
                 numel(allOut{i}.O) >= length_of_array && ...
                 numel(allOut{i}.J) >= length_of_array)
                sizesOK = false;
                reason = 'O/J missing or shorter than H';
            end
        end
    end
    if ~sizesOK
        skippedSessions(end+1) = struct('index', i, ...
            'subject', name_of_subject, 'reason', reason);
        auditLog = pushAudit(auditLog, i, name_of_subject, bestDate, 'skipped', reason);
        fprintf('Skipping session %d (subject %s): %s\n', ...
                i, num2str(name_of_subject), reason);
        continue
    end
    % ========================================================================

    % ---- Parse session date (guard against malformed StartDate) ----
    dateStr = allOut{i}.StartDate;
    try
        dateObj = datetime(dateStr, 'InputFormat', 'MM/dd/yy');
        dateNum = datenum(dateObj);
    catch
        skippedSessions(end+1) = struct('index', i, ...
            'subject', name_of_subject, ...
            'reason', sprintf('unparseable StartDate: %s', char(string(dateStr))));
        auditLog = pushAudit(auditLog, i, name_of_subject, bestDate, ...
            'skipped', sprintf('unparseable StartDate: %s', char(string(dateStr))));
        fprintf('Skipping session %d (subject %s): unparseable StartDate\n', ...
                i, num2str(name_of_subject));
        continue
    end

    % ---- Resolve group -> animal identity ----
    [grpDisp, grpPresent, grpCanon, grpSrc] = ...
        resolveGroup(allOut{i}, identityFields, treatZeroGroupAsMissing);
    animalKey = sprintf('S%s|G%s', num2str(name_of_subject), grpCanon);

    % ---- Register a new animal bucket if needed ----
    if ~isKey(animal_index_map, animalKey)
        dateTable = {};
        subjectTable = {};
        box = {};
        timer = {};
        trials = {};
        concatenatedData = {};
        data_structure{ end + 1 } = table(dateTable, subjectTable, box, timer, trials, concatenatedData);
        animal_index_map( animalKey ) = numel(data_structure);
        animalMeta(end+1) = struct('subject', name_of_subject, ...
            'group', grpDisp, 'groupPresent', grpPresent, 'key', animalKey);
    end

    % ---- Log this valid session (for review-flag computation) ----
    sessionLog(end+1) = struct('index', i, 'subject', name_of_subject, ...
        'dateNum', dateNum, 'present', grpPresent, 'group', grpDisp, ...
        'canon', grpCanon, 'srcField', grpSrc);

    % ---- Extract trial-by-trial data ----
    date = repmat(dateNum, length_of_array, 1);
    subject_fill_value = allOut{i}.Subject;
    subject = repmat(subject_fill_value, length_of_array, 1);
    trialByTrialPerformance = allOut{i}.H(1:length_of_array)';
    lightStimuli = allOut{i}.L(1:length_of_array)';
    soundStimuli = allOut{i}.S(1:length_of_array)';

    trialTypeID = NaN(length_of_array, 1); % Initialize R with NaN
    if isfield(allOut{i}, 'R') && numel(allOut{i}.R) > 1 
        trialTypeID = allOut{i}.R';
    else
        for j = 1:length_of_array
            if (allOut{i}.O(j) == 1) || (allOut{i}.J(j) == 1)
                trialTypeID(j) = 1;
            elseif (allOut{i}.O(j) == 2) || (allOut{i}.J(j) == 2)
                trialTypeID(j) = 2;
            else 
                trialTypeID(j) = NaN;
            end
        end
    end

    concatenatedData = horzcat(date,subject,trialByTrialPerformance,lightStimuli,soundStimuli,trialTypeID);

    % Add session-level information to table
    newRow = table({allOut{i}.StartDate}, allOut{i}.Subject, allOut{i}.Box, allOut{i}.T, allOut{i}.I, {concatenatedData}, ...
        'VariableNames', {'dateTable', 'subjectTable', 'box', 'timer', 'trials', 'concatenatedData'});

    % Append to the animal-specific table
    idx = animal_index_map(animalKey);
    data_structure{idx} = [data_structure{idx}; newRow];

    % ---- Record disposition: kept, and into which animal ----
    auditLog = pushAudit(auditLog, i, name_of_subject, bestDate, 'kept', animalKey);
end

% ===== Split each subject+group bucket by date gaps (>N months = new cohort) =====
reviewFlags = struct('subject',{},'index',{},'issue',{});

new_data_structure = {};
new_animalMeta = struct('subject',{},'group',{},'groupPresent',{}, ...
                        'key',{},'dateStart',{},'dateEnd',{},'cohort',{});

for idx = 1:numel(data_structure)
    T = data_structure{idx};
    m = animalMeta(idx);
    if height(T) == 0
        continue
    end

    dts = datetime(T.dateTable, 'InputFormat', 'MM/dd/yy');
    [dts, order] = sort(dts);
    T = T(order, :);

    splitStarts = 1;
    for r = 2:height(T)
        if dts(r) > dts(r-1) + calmonths(maxWithinAnimalGapMonths)
            splitStarts(end+1) = r; 
        end
    end
    splitEnds = [splitStarts(2:end) - 1, height(T)];
    nCohorts = numel(splitStarts);

    for c = 1:nCohorts
        rows = splitStarts(c):splitEnds(c);
        keyStr = m.key;
        if nCohorts > 1
            keyStr = sprintf('%s|C%d', m.key, c);
        end
        new_data_structure{end+1} = T(rows, :); 
        new_animalMeta(end+1) = struct('subject', m.subject, 'group', m.group, ...
            'groupPresent', m.groupPresent, 'key', keyStr, ...
            'dateStart', dts(splitStarts(c)), 'dateEnd', dts(splitEnds(c)), ...
            'cohort', c);
    end

    if nCohorts > 1
        reviewFlags(end+1) = struct('subject', m.subject, 'index', NaN, ...
            'issue', sprintf(['subject+group "%s" split into %d cohorts by >%d-month ' ...
            'gap (verify these are truly different cohorts, not one long pause)'], ...
            m.key, nCohorts, maxWithinAnimalGapMonths)); 
    end
end

data_structure = new_data_structure;
animalMeta = new_animalMeta;
% animal_index_map is now stale (buckets were split); not used past this point.

% ===== Compute remaining review flags (mistakes worth a human look) =====
presentMask = logical([sessionLog.present]);
if any(presentMask)
    adoptionDate = min([sessionLog(presentMask).dateNum]);
else
    adoptionDate = Inf;
end

if ~isempty(sessionLog)
    subjectsAll = unique([sessionLog.subject]);
else
    subjectsAll = [];
end

for s = subjectsAll
    entries = sessionLog([sessionLog.subject] == s);
    pmask = logical([entries.present]);
    distinctCanons = unique({entries(pmask).canon});
    dispList = unique({entries(pmask).group});
    hasGrouped = ~isempty(distinctCanons);
    hasUngrouped = any(~[entries.present]);

    if numel(distinctCanons) >= 2
        reviewFlags(end+1) = struct('subject', s, 'index', NaN, ...
            'issue', sprintf('appears under %d groups: %s (verify real cohorts, not typos)', ...
            numel(distinctCanons), strjoin(dispList, ', ')));
    end

    if hasGrouped && hasUngrouped
        ung = entries(~[entries.present]);
        for e = ung
            reviewFlags(end+1) = struct('subject', s, 'index', e.index, ...
                'issue', 'subject has grouped sessions elsewhere but this one has no group (ambiguous)');
        end
    end

    srcs = unique({entries(pmask).srcField});
    srcs = srcs(~cellfun(@isempty, srcs));
    if numel(srcs) >= 2
        reviewFlags(end+1) = struct('subject', s, 'index', NaN, ...
            'issue', sprintf('identified via different fields across sessions: %s', strjoin(srcs, ', ')));
    end
end

for k = 1:numel(sessionLog)
    e = sessionLog(k);
    if ~e.present && e.dateNum >= adoptionDate
        reviewFlags(end+1) = struct('subject', e.subject, 'index', e.index, ...
            'issue', sprintf('no group, but dated on/after group tracking start (%s)', ...
            datestr(adoptionDate, 'mm/dd/yy')));
    end
end

% ===== Report skipped sessions =====
if isempty(skippedSessions)
    fprintf('\nNo sessions skipped.\n');
else
    fprintf('\n%d session(s) skipped:\n', numel(skippedSessions));
    disp(struct2table(skippedSessions));
end

% ===== Report review flags =====
if isempty(reviewFlags)
    fprintf('\nNo review flags.\n');
else
    fprintf('\n%d review flag(s) (kept in data, but check these):\n', numel(reviewFlags));
    disp(struct2table(reviewFlags));
end

% ===== Monthly disposition timeline (kept vs skipped per month) =====
fprintf('\nMonthly session disposition (kept vs skipped):\n');
if isempty(auditLog)
    fprintf('  (no sessions)\n');
else
    allDates = [auditLog.date];
    datedMask = ~isnat(allDates);
    if any(datedMask)
        mstart = dateshift(allDates(datedMask), 'start', 'month');
        dispo  = {auditLog(datedMask).disposition};
        uM = unique(mstart);
        for mm = uM
            sel = mstart == mm;
            keptN = sum(strcmp(dispo(sel), 'kept'));
            skipN = sum(sel) - keptN;
            fprintf('  %s: %d kept, %d skipped\n', datestr(mm, 'yyyy-mm'), keptN, skipN);
        end
    end
    nNaT = sum(~datedMask);
    if nNaT > 0
        fprintf('  (no parseable date): %d session(s)\n', nNaT);
    end
end

% ===== Windowed audit (what happened around the target dates) =====
fprintf('\nSession audit for %s to %s:\n', ...
    datestr(auditWindowStart, 'mm/dd/yy'), datestr(auditWindowEnd, 'mm/dd/yy'));
if isempty(auditLog)
    fprintf('  (no sessions)\n');
else
    allDates = [auditLog.date];
    inWin = ~isnat(allDates) & allDates >= auditWindowStart & allDates <= auditWindowEnd;
    if ~any(inWin)
        fprintf('  No sessions found in this window.\n');
        fprintf('  If you expected sessions here, they are likely missing from allOut\n');
        fprintf('  (dropped upstream in the medpc extract), not skipped by this script.\n');
    else
        win = auditLog(inWin);
        [~, ord] = sort([win.date]);
        win = win(ord);
        for w = win
            fprintf('  %s | idx %d | subject %s | %s (%s)\n', ...
                datestr(w.date, 'mm/dd/yy'), w.index, num2str(w.subject), ...
                w.disposition, w.detail);
        end
    end
end

save('BayesPreprocessedSampleSessions.mat', "data_structure", "animalMeta", ...
     "skippedSessions", "reviewFlags", "auditLog");

% ============================ local functions ============================
function A = pushAudit(A, idx, subj, dt, dispo, detail)
    % Append one disposition record to the audit log.
    A(end+1) = struct('index', idx, 'subject', subj, 'date', dt, ...
                      'disposition', dispo, 'detail', detail);
end

function [dispVal, present, canon, srcField] = resolveGroup(s, fieldOrder, treatZeroAsMissing)
    % Returns a display string, a presence flag, a canonical match key, and
    % which field the value came from. Tries fieldOrder in sequence.
    dispVal = '';
    present = false;
    canon = 'UNKNOWN';
    srcField = '';
    for k = 1:numel(fieldOrder)
        fname = fieldOrder{k};
        if ~isfield(s, fname), continue; end
        v = s.(fname);
        if isnumeric(v)
            if isscalar(v) && ~isnan(v)
                if treatZeroAsMissing && v == 0
                    continue;
                end
                dispVal = num2str(v); present = true; srcField = fname; break;
            end
        elseif ischar(v) || isstring(v)
            vs = strtrim(char(string(v)));
            if ~isempty(vs)
                dispVal = vs; present = true; srcField = fname; break;
            end
        end
    end
    if present
        canon = lower(regexprep(dispVal, '[^a-zA-Z0-9]', ''));
        if isempty(canon)
            canon = 'UNKNOWN'; present = false;
        end
    end
end