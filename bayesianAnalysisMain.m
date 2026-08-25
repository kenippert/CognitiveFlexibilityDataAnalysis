%% Initialization and file selection
clc
clear

% Open a file selection UI
[filename, filepath] = uigetfile('*.mat', 'Select a MATLAB file');

% Check if the user selected a file (filename is not 0)
if filename ~= 0
    % Construct the full path to the selected file
    fullFileName = fullfile(filepath, filename);
    
    % Display the selected file
    disp(['Selected file: ', fullFileName]);
    
    % Load the .mat file into the workspace
    data = load(fullFileName);
    data = data.data_structure;
else
    disp('No file was selected.');
end

%% Run preprocessing to generate phase, side, light, and sound data
for XY = 1:length(data)
    x = data{1,XY}; %iterates through each animal's data - sessions are iterated within the MouseGetBayes function
    [outpt{XY},sz{XY},sessions{XY}] = MouseGetBayes(x); %generates nested cell array: array of subjects.array of individual sessions
end

%% Remove sessions MouseGetBayes skipped (empty outpt entries) BEFORE analysis
% A session MouseGetBayes couldn't process (wrong dimensions, all-NaN, or an
% error) comes back as outpt{XY}{k} = []. If that lands in the first slot it
% breaks the Var1 identification in MouseGetSigm. Strip empties here so no
% downstream function (MouseGetSigm, getSigmShuffled, ...) ever sees a blank.
for XY = 1:length(data)
    keep = ~cellfun(@isempty, outpt{XY});   % skipped sessions are []
    if ~all(keep)
        firstKeep = find(keep, 1, 'first');
        if isempty(firstKeep)
            subjLabel = sprintf('(index %d)', XY);
        else
            subjLabel = sprintf('%d', outpt{XY}{1,firstKeep}{1,6});
        end
        fprintf('Subject %s: removing %d empty session(s) from outpt before analysis\n', ...
                subjLabel, nnz(~keep));
    end
    outpt{XY}    = outpt{XY}(keep);
    sz{XY}       = sz{XY}(keep);
    sessions{XY} = nnz(keep);
end

%% Run likelihood and analysis functions - REAL (non-shuffled) data
for XZ = 1:length(data)
    [Sessionlength{XZ}, SPlike{XZ}, LIlike{XZ}, SOlike{XZ}, Phases{XZ}, trialsperphase{XZ}] = MouseGetSigm(outpt,sz,XZ,sessions);

    % ---- Drop blank sessions (skipped by MouseGetBayes/MouseGetSigm) ----
    % Skipped sessions come back as [] in the MouseGetSigm outputs. Remove
    % them from EVERY parallel per-session array so indexing stays aligned,
    % then update the session count used as the loop bound downstream.
    valid = ~cellfun(@isempty, SPlike{XZ});   % blank sessions have [] here

    if ~all(valid)
        firstValid = find(valid, 1, 'first');
        if isempty(firstValid)
            subjLabel = sprintf('(index %d)', XZ);
        else
            subjLabel = sprintf('%d', outpt{XZ}{1,firstValid}{1,6});
        end
        fprintf('Subject %s: dropping %d blank session(s) of %d\n', ...
                subjLabel, nnz(~valid), numel(valid));
    end

    Sessionlength{XZ}  = Sessionlength{XZ}(valid);
    SPlike{XZ}         = SPlike{XZ}(valid);
    LIlike{XZ}         = LIlike{XZ}(valid);
    SOlike{XZ}         = SOlike{XZ}(valid);
    Phases{XZ}         = Phases{XZ}(valid);
    trialsperphase{XZ} = trialsperphase{XZ}(valid);
    outpt{XZ}          = outpt{XZ}(valid);
    sz{XZ}             = sz{XZ}(valid);
    sessions{XZ}       = nnz(valid);

    % ---- If nothing valid remains, skip this subject entirely ----
    if sessions{XZ} == 0
        warning('Subject index %d has no valid sessions; skipping.', XZ);
        continue
    end

    [normSP{XZ}, normLI{XZ}, normSO{XZ}, propSP{XZ}, propLI{XZ}, propSO{XZ}, propNoStrat{XZ}] = MouseAnaBayes(XZ,Sessionlength, SPlike,LIlike, SOlike, Phases, sessions);
end

%% Run likelihood and analysis functions - SHUFFLED data (for comparison against the real analysis above)
binsz = 2;
bootstraps = 100;
for XZ = 1:length(data)
    if sessions{XZ} == 0 || isempty(outpt{XZ})   % subject had no valid sessions
        continue
    end
    [SPlike_sh{XZ}, SOlike_sh{XZ}, LIlike_sh{XZ}] = getSigmShuffled(outpt, XZ, Phases, trialsperphase, sz, binsz, bootstraps);
    [normSP_sh{XZ}, normLI_sh{XZ}, normSO_sh{XZ}, propSP_sh{XZ}, propLI_sh{XZ}, propSO_sh{XZ}, propNoStrat_sh{XZ}] = anaBayesShuffled(XZ, Sessionlength, SPlike_sh, LIlike_sh, SOlike_sh, Phases, sessions, bootstraps);
end

%% BAYES EXCEL FUNCTION. RAW PROPORTION DATA IS EXPORTED TO EXCEL ALONG WITH THE DATE AND THE NUMBER OF PHASES COMPLETED IN THAT SESSION. 
% Define the prompt and dialog title
prompt = {'Enter the Excel filename (without extension):'};
dlgtitle = 'Filename Input';
dims = [1 50];
definput = {'my_excel_file'};

% Open the input dialog box
answer = inputdlg(prompt, dlgtitle, dims, definput);

% Check if the user clicked OK and append the extension
if ~isempty(answer)
    filename = [answer{1}, '.xlsx'];
    
    % Example: Save a blank table to create the file
    % t = table();
    % writetable(t, filename);
else
    disp('User canceled the operation.');
end

bayesGetExcel(propSP, propLI, propSO, propNoStrat, outpt, filename);

%% Graphing raw data (REAL data only, as before - see note at bottom on extending to shuffled)
%import matlab report generator powerpoint functionality
import mlreportgen.ppt.*
%Name of powerpoint containing Bayes posterior graphs for each session for
%each subject
filename = 'PosteriorPlotsAllShiftingSessions.pptx';
% filename2 = 'estingShuffled.pptx';

%Name of powerpoint containing summary proportion graphs for each subject
filename3 = 'proportionStrategyPlotsALlSession6of8Sigmoidal.pptx';

%create one powerpoint presentation object called ppt for Bayes graphs
% ppt = Presentation(filename);
% ppt2 = Presentation(filename2);
ppt3 = Presentation(filename3);
%open the powerpoint
% open(ppt);
% open(ppt2);

% for XZZ = 1:length(data)
%     MousePltBayes(normSP,normLI,normSO,Phases,XZZ, outpt, sessions, ppt);
%     MousePltBayesShuffled(normSP,normLI,normSO, normSP_sh,normLI_sh,normSO_sh,Phases,XZZ, outpt, sessions, ppt2)
% end
% close(ppt);
% close(ppt2);
% create one powerpoint presentation object called ppt2 for proportion
% graphs
open(ppt3);
titleSlide = add(ppt3, 'Title Slide');
titleText = "acrossSessionProportionPlotsNormandShuff";
replace(titleSlide, 'Title', titleText);
% 

for XZ = 1:length(data)
    if sessions{XZ} == 0 || isempty(outpt{XZ})   % subject had no valid sessions
        continue
    end
    import mlreportgen.ppt.*
    figure;
    mouse = [cell2mat(propSP{1,XZ});cell2mat(propLI{1,XZ});cell2mat(propSO{1,XZ})];
    mouseShuffled = [cell2mat(propSP_sh{1,XZ});cell2mat(propLI_sh{1,XZ});cell2mat(propSO_sh{1,XZ})];
    nostrat = [];
    nostratShuffled = [];
for i = 1:width(mouse)
        nostrat(i) = 1-(sum(mouse(:,i)));
end
for i = 1:width(mouseShuffled)
        nostratShuffled(i) = 1-(sum(mouseShuffled(:,i)));
end
    final = [mouse;nostrat];                        % 5 × nSessions (real)
    finalShuffled = [mouseShuffled;nostratShuffled];% 5 × nBoot (shuffled)

    % collapse shuffled to ONE averaged column, then append to the real sessions
    shuffledAvg = mean(finalShuffled, 2);           % 5 × 1
    combined = [final, shuffledAvg];                % 5 × (nSessions+1)

    bar(combined.','stacked');                      % one bar per session + one shuffled bar

    % x-axis labels: Session 1..n, then Shuffled avg
    nSess = width(mouse);
    xt = [arrayfun(@(s) sprintf('Session %d', s), 1:nSess, 'UniformOutput', false), {'Shuffled avg'}];
    set(gca, 'XTickLabel', xt);

    meanCoreStrategies = 100*mean(mouse,2);
    meanNoStrategy = 100*mean(nostrat,2);
    meanStrategiesShuffled = 100*mean(mouseShuffled,2);
    meanNoStrategyShuffled = 100*mean(nostratShuffled,2);

    % 5 segments -> 5 legend entries, each showing real + shuffled mean
    lg_entries = {
        sprintf('spatial: real %.2f%% / shuf %.2f%%',     meanCoreStrategies(1), meanStrategiesShuffled(1));
        sprintf('light: real %.2f%% / shuf %.2f%%',       meanCoreStrategies(2), meanStrategiesShuffled(2));
        sprintf('sound: real %.2f%% / shuf %.2f%%',       meanCoreStrategies(3), meanStrategiesShuffled(3));
        sprintf('no strategy: real %.2f%% / shuf %.2f%%', meanNoStrategy,        meanNoStrategyShuffled)};
    lgd = legend(lg_entries, 'Location','bestoutside');
    title(lgd, 'Average strategy usage across sessions');
    ylabel('proportion');
    xlabel('condition');
    ylim([0 1]);
    title(['Subject',sprintf('%d', outpt{1,XZ}{1,1}{1,6})]);
% set(gca, 'YScale', 'log'); %Set log scale for y-axis to minimize the visual overwhelm of the no strategy proportion

%this piece of code saves the current figure (which is gcf of the proportion graph for all a subjects sessions) as a
%.png with the file name "subject x strategy proportions.png"
    imgFileName = sprintf('Subject_%d_StrategyProportions.png', outpt{1,XZ}{1,1}{1,6});
    saveas(gcf, imgFileName);
    close(gcf); % Close the figure after saving
% this adds a 'title and content' type slide to the powerpoint and
% titles it "subject x title y" and then adds the image saved above as a
% picture onto the slide
    slide = add(ppt3,'Title and Content');
    slideTitleText = ['Subject',sprintf('%d',outpt{1,XZ}{1,1}{1,6})];
    replace(slide,'Title', slideTitleText);
    img = Picture(imgFileName);
    add(slide,img);
end
close(ppt3);
% % 
% % NOTE: to compare real vs. shuffled visually, the same plotting pattern
% % above can be repeated using normSP_sh{XZ}{m}{l} / propSP_sh{XZ}{m}(l)
% (etc.) in place of normSP{XZ}{m} / propSP{XZ}{m} - just add a loop over
% bootstraps l = 1:bootstraps, e.g. to plot the real proportion against
% the shuffled-bootstrap distribution for each session.
% % 
% % Bayesian slopes
% for XY = 1:length(data) %calculates slopes for each strategy over the final 6 trials in each phase
%     [slopesLI{XY}, slopesSO{XY}, slopesSP{XY}, slopesSPa{XY}, reinforced_stim{XY},rein{XY}] = MouseGetSlopes(XY,sessions, outpt,Phases,normLI,normSO,normSP,normSPa);
% end
% 
% figure;
% hold on
% ax = [1 2 3 4 5 6 7]; %allows superposition of all phases together, should work to isolate phases with light vs sound reward, or EDs
% for XX = 1:length(data)
%     for i = 1:sessions{1,XX}
%         for k = 1:length(rein{1,XX}{1,i})
%             if length(rein{1,XX}{1,i}) == 1
%                 continue
%             end
%             if rein{1,XX}{1,i}{k,1} == 2
%                 plot(k,slopesLI{1,XX}{1,i}(k),"r."); %colors slopes red only in trials where light was reinforced
%                 plot(k, slopesSO{1,XX}{1,i}(k),"k.");
%                 a(k) = slopesLI{1,XX}{1,i}(k); %calculate mean slope for reinforced dimension in each phase
%             else
%                 plot(k, slopesLI{1,XX}{1,i}(k),"k.");
%                 plot(k, slopesSO{1,XX}{1,i}(k),"r.");
%                 a(k) = slopesSO{1,XX}{1,i}(k);
%                 colors slopes red only in trials where sound was reinforced
%             end
%             plot(k, slopesSP{1,XX}{1,i}(k),'k.') %coloring spatial strategies alike
%             plot(k, slopesSPa{1,XX}{1,i}(k),'k.')
%         end
%         b{i} = a;
%     end
%     c{XX} = b;
% end
% xlabel('Phase');
% ylabel('b-value slope');
% xticklabels({'CD','ID1','ED1','ID2','ED2','ID3','ED3'});