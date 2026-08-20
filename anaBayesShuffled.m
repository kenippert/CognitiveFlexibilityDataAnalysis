%MOUSEANABAYES_SHUFFLED  Shuffled-data counterpart to MouseAnaBayes.
%Normalizes per-trial strategy likelihoods into posterior "belief"
%traces, run separately for every bootstrap draw of the shuffled data.
%
%Only sessions that were actually shuffled by MouseGetSigm_shuffled
%(i.e. have non-empty entries in SPlike_sh{XZ}) are processed; all
%others are skipped and left empty so indexing stays aligned with the
%real-data outputs from MouseAnaBayes.
%
%Inputs mirror MouseAnaBayes, but SPlike_sh/SPalike_sh/LIlike_sh/SOlike_sh
%are indexed {subject}{session}{bootstrap} instead of {subject}{session},
%and "bootstraps" gives the number of shuffles run per session.
%
%Outputs mirror MouseAnaBayes but with an added bootstrap dimension:
%normSP_sh{session}{bootstrap} and propSP_sh{session}(bootstrap), etc.
function [normSP_sh, normLI_sh, normSO_sh, propSP_sh, propLI_sh, propSO_sh, propNoStrat_sh] = anaBayesShuffled(XZ, Sessionlength, SPlike_sh, LIlike_sh, SOlike_sh, Phases, sessions, bootstraps)

    normSP_sh  = cell(1,sessions{XZ});
    % normSPa_sh = cell(1,sessions{XZ});
    normLI_sh  = cell(1,sessions{XZ});
    normSO_sh  = cell(1,sessions{XZ});

    propSP_sh      = cell(1,sessions{XZ});
    % propSPa_sh     = cell(1,sessions{XZ});
    propLI_sh      = cell(1,sessions{XZ});
    propSO_sh      = cell(1,sessions{XZ});
    propNoStrat_sh = cell(1,sessions{XZ});

    for m = 1:sessions{XZ}
        if isempty(SPlike_sh{1,XZ}{1,m}) %session wasn't shuffled - leave empty
            continue
        end

        SL         = Sessionlength{1,XZ}{1,m};
        phasestart = Phases{1,XZ}{1,m};

        normSP_sh{m}  = cell(1,bootstraps);
        % normSPa_sh{m} = cell(1,bootstraps);
        normLI_sh{m}  = cell(1,bootstraps);
        normSO_sh{m}  = cell(1,bootstraps);

        propSP_sh{m}      = zeros(1,bootstraps);
        % propSPa_sh{m}     = zeros(1,bootstraps);
        propLI_sh{m}      = zeros(1,bootstraps);
        propSO_sh{m}      = zeros(1,bootstraps);
        propNoStrat_sh{m} = zeros(1,bootstraps);

        for l = 1:bootstraps
            SigmSP  = SPlike_sh{1,XZ}{1,m}{l};
            % SigmSPa = SPalike_sh{1,XZ}{1,m}{l};
            SigmLI  = LIlike_sh{1,XZ}{1,m}{l};
            SigmSO  = SOlike_sh{1,XZ}{1,m}{l};

            [noSP, noLI, noSO] = computeStrategyPosteriors(SigmSP, SigmLI, SigmSO, SL, phasestart);

            normSP_sh{m}{l}  = noSP;
            % normSPa_sh{m}{l} = noSPa;
            normLI_sh{m}{l}  = noLI;
            normSO_sh{m}{l}  = noSO;

            propSP_sh{m}(l)      = sum(noSP  > 0.6) ./ SL;
            % propSPa_sh{m}(l)     = sum(noSPa > 0.6) ./ SL;
            propLI_sh{m}(l)      = sum(noLI  > 0.6) ./ SL;
            propSO_sh{m}(l)      = sum(noSO  > 0.6) ./ SL;
            propNoStrat_sh{m}(l) = 1 - (propSP_sh{m}(l) + propLI_sh{m}(l) + propSO_sh{m}(l));
        end
    end
end