% MOUSEPLTBAYESSHUFFLED
%
% Plots real Bayesian posterior traces together with the shuffled
% bootstrap distribution for each session.
%
% Inputs:
%   normSP       - real spatial strategy posterior
%   normSPa      - real spatial alternation posterior
%   normLI      - real light strategy posterior
%   normSO      - real sound strategy posterior
%
%   normSP_sh   - shuffled spatial posterior
%   normSPa_sh  - shuffled spatial alternation posterior
%   normLI_sh   - shuffled light posterior
%   normSO_sh   - shuffled sound posterior
%
%   Phases      - phase-start trial numbers
%   XZZ         - subject index
%   outpt       - original subject/session data
%   sessions    - number of sessions for each subject
%   ppt         - PowerPoint presentation object
%
% Shuffled data are indexed:
%   normSP_sh{subject}{session}{bootstrap}

function MousePltBayesShuffled(normSP, normLI, normSO, ...
    normSP_sh,  normLI_sh, normSO_sh, ...
    Phases, XZZ, outpt, sessions, ppt2)

    % Import PowerPoint functionality
    import mlreportgen.ppt.*

    % Add title slide for subject
    titleSlide = add(ppt2, 'Title Slide');

    dynamicText = Text(sprintf('Subject %d - Shuffled Analysis', ...
        outpt{1,XZZ}{1,1}{1,6}));

    titleText = Paragraph();
    append(titleText, dynamicText);
    replace(titleSlide, 'Title', titleText);


    % Loop through sessions
    for n = 1:sessions{XZZ}

        % -------------------------------------------------------------
        % Check whether this session actually has shuffled data
        % -------------------------------------------------------------
        if isempty(normSP_sh{1,XZZ}{1,n})
            disp(sprintf(['Subject %d Session %d was not shuffled. ', ...
                'Skipping shuffled plot.'], ...
                outpt{1,XZZ}{1,n}{1,6}, n));
            continue
        end

        figure;
        hold on;


        % -------------------------------------------------------------
        % Plot shuffled bootstrap traces
        % -------------------------------------------------------------

        nBoot = length(normSP_sh{1,XZZ}{1,n});

        for l = 1:nBoot

            % Spatial
            if ~isempty(normSP_sh{1,XZZ}{1,n}{l})
                plot(normSP_sh{1,XZZ}{1,n}{l}, ...
                    'Color',[0.75 0.75 0.75], ...
                    'LineWidth',0.5, ...
                    'HandleVisibility','off');
            end


            % Light
            if ~isempty(normLI_sh{1,XZZ}{1,n}{l})
                plot(normLI_sh{1,XZZ}{1,n}{l}, ...
                    'Color',[0.75 0.75 0.75], ...
                    'LineWidth',0.5, ...
                    'HandleVisibility','off');
            end

            % Sound
            if ~isempty(normSO_sh{1,XZZ}{1,n}{l})
                plot(normSO_sh{1,XZZ}{1,n}{l}, ...
                    'Color',[0.75 0.75 0.75], ...
                    'LineWidth',0.5, ...
                    'HandleVisibility','off');
            end

        end


        % -------------------------------------------------------------
        % Plot real data on top of shuffled distribution
        % -------------------------------------------------------------

        plot(normSP{1,XZZ}{1,n}, ...
            'LineWidth',2, ...
            'DisplayName','spatial strategy');



        plot(normLI{1,XZZ}{1,n}, ...
            'LineWidth',2, ...
            'DisplayName','light strategy');

        plot(normSO{1,XZZ}{1,n}, ...
            'LineWidth',2, ...
            'DisplayName','sound strategy');


        % -------------------------------------------------------------
        % Strategy threshold
        % -------------------------------------------------------------

        yline(0.6,'--', ...
            'DisplayName','strategy threshold');


        % -------------------------------------------------------------
        % Phase markers
        % -------------------------------------------------------------

        labels = {'CD','ID1','ED1','ID2','ED2','ID3','ED3','ID4'};

        A = numel(Phases{1,XZZ}{1,n});

        xline(Phases{1,XZZ}{1,n},'-',labels(1:A));


        % -------------------------------------------------------------
        % Labels / title
        % -------------------------------------------------------------

        ylabel('b-value');
        xlabel('trial');

        legend('location','northeastoutside');

        title(['Subject ', ...
            sprintf('%d',outpt{1,XZZ}{1,n}{1,6}), ...
            ' Session ',sprintf('%d',n), ...
            ' - Real vs Shuffled']);


        % -------------------------------------------------------------
        % Save figure
        % -------------------------------------------------------------

        imgFileName = sprintf( ...
            'Subject_%d_Session_%d_RealVsShuffled.png', ...
            outpt{1,XZZ}{1,n}{1,6}, n);

        saveas(gcf,imgFileName);

        close(gcf);


        % -------------------------------------------------------------
        % Add figure to PowerPoint
        % -------------------------------------------------------------

        slide = add(ppt2,'Title and Content');

        slideTitleText = ['Subject ', ...
            sprintf('%d',outpt{1,XZZ}{1,n}{1,6}), ...
            ' Session ',sprintf('%d',n), ...
            ' - Real vs Shuffled'];

        replace(slide,'Title',slideTitleText);

        img = Picture(imgFileName);
        add(slide,img);

    end
end