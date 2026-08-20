%COMPUTESTRATEGYPOSTERIORS  Core Bayesian normalization step shared by
%MouseAnaBayes (real data) and MouseAnaBayes_shuffled (shuffled data).
%
%Given the four sigmoidal likelihood traces for a single session (spatial
%perseveration, spatial alternation, light, sound), computes the
%normalized posterior ("no*") for each strategy at each trial.
%
%Inputs:
%   SigmSP, SigmSPa, SigmLI, SigmSO - sigmoid likelihood vectors (SL x 1)
%   SL                              - session length (number of trials)
%   phasestart                      - trial indices where a new phase begins
%
%Outputs:
%   noSP, noSPa, noLI, noSO - normalized posterior ("belief") that the
%                             animal is using that strategy, at each trial
function [noSP, noLI, noSO] = computeStrategyPosteriors(SigmSP, SigmLI, SigmSO, SL, phasestart)

    posteriorSP  = zeros(SL,1); posteriorSP(phasestart)  = 0.5;
    noSP         = zeros(SL,1); noSP(phasestart)         = 0.33;
    % 
    % posteriorSPa = zeros(SL,1); posteriorSPa(phasestart) = 0.5;
    % noSPa        = zeros(SL,1); noSPa(phasestart)        = 0.25;

    posteriorLI  = zeros(SL,1); posteriorLI(phasestart)  = 0.5;
    noLI         = zeros(SL,1); noLI(phasestart)         = 0.33;

    posteriorSO  = zeros(SL,1); posteriorSO(phasestart)  = 0.5;
    noSO         = zeros(SL,1); noSO(phasestart)         = 0.33;

    for k = 1:SL
        if k == 1
            continue
        end

        atPhaseStart = ismember(k, phasestart);

        if atPhaseStart && noSP(k-1) < 0.6 && noLI(k-1) < 0.6 && noSO(k-1) < 0.6
            % No strategy had a dominant posterior heading into the new
            % phase - nothing carries over, so skip (posteriors stay 0).
            continue
        end

        if atPhaseStart && noSP(k-1) > 0.6
            % Spatial perseveration was dominant - carry it forward,
            % reset the others to neutral.
            posteriorSP(k)  = SigmSP(k) * noSP(k-1);
            % posteriorSPa(k) = 0.5;
            posteriorLI(k)  = 0.5;
            posteriorSO(k)  = 0.5;
        % elseif atPhaseStart && noSPa(k-1) > 0.6
        %     posteriorSP(k)  = 0.5;
        %     posteriorSPa(k) = SigmSPa(k) * noSPa(k-1);
        %     posteriorLI(k)  = 0.5;
        %     posteriorSO(k)  = 0.5;
        elseif atPhaseStart && noLI(k-1) > 0.6
            posteriorSP(k)  = 0.5;
            % posteriorSPa(k) = 0.5;
            posteriorLI(k)  = SigmLI(k) * noLI(k-1);
            posteriorSO(k)  = 0.5;
        elseif atPhaseStart && noSO(k-1) > 0.6
            posteriorSP(k)  = 0.5;
            % posteriorSPa(k) = 0.5;
            posteriorLI(k)  = 0.5;
            posteriorSO(k)  = SigmSO(k) * noSO(k-1);
        else
            posteriorSP(k)  = SigmSP(k)  * noSP(k-1);
            % posteriorSPa(k) = SigmSPa(k) * noSPa(k-1);
            posteriorLI(k)  = SigmLI(k)  * noLI(k-1);
            posteriorSO(k)  = SigmSO(k)  * noSO(k-1);
        end

        total    = posteriorSP(k) + posteriorLI(k) + posteriorSO(k);
        noSP(k)  = posteriorSP(k)  / total;
        % noSPa(k) = posteriorSPa(k) / total;
        noLI(k)  = posteriorLI(k)  / total;
        noSO(k)  = posteriorSO(k)  / total;
    end
end