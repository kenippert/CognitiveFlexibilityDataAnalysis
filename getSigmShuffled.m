%MOUSEGETSIGM_SHUFFLED  Shuffled-data counterpart to MouseGetSigm.
%
%Runs the same sigmoidal likelihood calculation as MouseGetSigm, but on
%trial-shuffled versions of the choice data, repeated for "bootstraps"
%iterations per session. This gives a null distribution of likelihood
%traces to compare the real MouseGetSigm output against.
%
%Session length, phase boundaries, and trial-per-phase counts are the
%same regardless of shuffling, so they are taken as inputs (from the
%real-data MouseGetSigm call) rather than recomputed here.
%
%Inputs:
%   outpt           - subject/session choice data (same as MouseGetSigm)
%   XZ              - subject number
%   Phases          - phase-start trial indices, from MouseGetSigm
%   trialsperphase  - trial counts per phase, from MouseGetSigm
%   sz              - session lengths
%   binsz           - bin size used to chunk trials before shuffling
%   bootstraps      - number of shuffle iterations to run per session
%
%Outputs (each is a 1 x nSessions cell array; only the entries in
%sessions_to_shuffle are populated, the rest are left empty []):
%   SPlike_sh{session}{bootstrap}  - spatial perseveration likelihoods
%   SPalike_sh{session}{bootstrap} - spatial alternation likelihoods
%   SOlike_sh{session}{bootstrap}  - sound likelihoods
%   LIlike_sh{session}{bootstrap}  - light likelihoods
function [SPlike_sh, SOlike_sh, LIlike_sh] = getSigmShuffled(outpt, XZ, Phases, trialsperphase, sz, binsz, bootstraps)

    sessions_to_shuffle = [1 2]; %specific sessions to run shuffle on (could generate random sessions here, probably would be better)
    nSessions = length(sz{1,XZ});

    SPlike_sh  = cell(1,nSessions);
    % SPalike_sh = cell(1,nSessions);
    SOlike_sh  = cell(1,nSessions);
    LIlike_sh  = cell(1,nSessions);

    for j = 1:length(sessions_to_shuffle)
        s = sessions_to_shuffle(j); %actual session index within this subject's data
        disp('DEBUG:')
        disp(['XZ = ', num2str(XZ)])
        disp(['size(sz) = ', mat2str(size(sz))])
        disp(['s = ', num2str(s)])
        SL = sz{1,XZ}{1,s};
        phase = Phases{1,XZ}{1,s}(:,:);

        % if SL < 3 %don't shuffle sessions with less than three phases completed
        %     break
        % end

        shSPlike_session  = cell(1,bootstraps);
        % shSPalike_session = cell(1,bootstraps);
        shSOlike_session  = cell(1,bootstraps);
        shLIlike_session  = cell(1,bootstraps);

        for l = 1:bootstraps %move up to 100 for full shuffling procedure

            session = cell2table(outpt{1,XZ}{1,s}); %use cell2table for normal data, array2table for ground truth data
            spatial = categorical(session.Var2);
            light   = categorical(session.Var3);
            sound   = categorical(session.Var4);
            stim    = [spatial, sound, light]; %categorical variable

            b = length(phase);
            trials = {};
            chunks = {};

            for i = 1:(b-1)
                idx = trialsperphase{1,XZ}{s}(i+1); %number of trials
                chunks{i} = round(idx/binsz); %number of bins is number of trials divided by bin size
                tstidx = (phase(i)) : (phase(i+1));
                trials{i} = tstidx;
            end
            % disp('----- SL DEBUG -----')
            % disp(SL)
            % disp(class(SL))
            % disp(size(SL))
            % 
            % disp('----- PHASE DEBUG -----')
            % disp(phase)
            % disp(class(phase))
            % disp(size(phase))
            % disp(phase(end))
            finalphase = phase(end) : SL;
            trials = [trials, finalphase];

            f = numel(finalphase);
            fchunk = round(f/binsz);
            chunks = [chunks, fchunk];

            shuffle = {};

            for k = 1:b %run within each phase separately
                sti = stim(trials{1,k},:);
                ma  = discretize(trials{1,k}, chunks{1,k}); %assign data to bins
                rng('shuffle');
                shu  = randperm(chunks{1,k}); %shuffle those bins
                data = NaN(1,3);
                data = categorical(data);
                for r = 1:length(shu)
                    realdata = sti((ma == shu(r)),:); %pulling real data from the bin identities
                    data = [data; realdata];
                end
                shuffle{k} = data;
            end

            shuf = vertcat(shuffle{:});

            shufspatial = shuf(:,1);
            shufsound   = shuf(:,2);
            shuflight   = shuf(:,3);

            %% Spatial perseveration strategy
            spatialcons = ones(SL,1); %initializes matrix for the consecutive for loop below
            %This produces a logical where 1 indicates 2 consecutive choices
            for p = 3:(SL - 1)
                spatialcons(p) = [logical(shufspatial(p) == shufspatial(p+1))];
            end

            %calculate the number of consecutive choices along a single dimension -
            %this goes into sigmoidal to influence "strength of evidence"
            spcons = spatialcons.'; %some function below requires this to be in column, rather than row format
            isp    = cumsum([true diff(spcons)~=0]);                            % index the sections
            cssp   = arrayfun(@(a) cumsum(spcons(isp==a)), 1:isp(end), 'un', 0); % cumsum each section
            Sp     = cat(2,cssp{:});                                            % concatenate the cells

            %Run sigmoidal function for likelihood values, adjusting on the basis of
            %how many consecutive choices have been made
            SigmSP = 0.5+((1./(1+exp(-1.75*(Sp-3))))./2); %6/8 criterion
            % SigmSP = 0.5+((1./(1+exp(-1.5*(Sp-3.5))))./2); %7/9 criterion
       
            SigmSP = SigmSP.';

            for k = 2:SL
                if ismember(k,phase) %skip iteration of for loop at each of these trials where a new phase begins
                    SigmSP(k) = 0.5;
                    continue
                end

                % sess_1_spatialcons index values where this = 0 and in Sigm, replace those
                % indexed values with 1-prev value as likelihood when a
                % response pattern is not detected - scales with consistency of
                % behavior
                spsig       = [0;SigmSP(1:end-1)];
                invsp       = 1-spsig; % inverse likelihood, shifted down by one cell
                rst         = spatialcons == 0; % indexes trials where consecutive streak ends
                SigmSP(rst) = invsp(rst); % on trials where non-consistent choices are made, replace likelihood with the inverse of the previous likelihood
            end

            % %% Spatial alternation strategy
            % spatialalt = ones(SL,1);
            % for p = 3:(SL-1)
            %     spatialalt(p) = [logical(shufspatial(p) ~= shufspatial(p+1))];
            % end
            % %This alternating strategy is currently calculated by asking for
            % %runs of trials where the animal is explicitly NOT choosing the
            % %same side consecutively
            % 
            % spalt = spatialalt.'; %some function below requires this to be in column, rather than row format
            % ispa  = cumsum([true diff(spalt)~=0]);
            % csspa = arrayfun(@(a) cumsum(spalt(ispa==a)), 1:ispa(end), 'un', 0);
            % Spa   = cat(2,csspa{:});
            % 
            % % SigmSPa = 0.5+((1./(1+exp(-1.75*(Spa-3))))./2); %6/8
            % %% criterion
            % SigmSPa = 0.5+((1./(1+exp(-1.5*(Spa-3.5))))./2); %7/9 criterion
            % SigmSPa = SigmSPa.';
            % 
            % spasig        = [0;SigmSPa(1:end-1)];
            % invspa        = 1-spasig; % inverse likelihood, shifted down by one cell
            % rspa          = spatialalt == 0; % indexes trials where consecutive streak ends
            % SigmSPa(rspa) = invspa(rspa);

            %% Sound strategy
            soundcons = ones(SL,1); %initializes matrix for the consecutive for loop below
            for p = 3:(SL - 1)
                soundcons(p) = [logical(shufsound(p) == shufsound(p+1))];
            end

            socons = soundcons.';
            ish    = cumsum([true diff(socons)~=0]);
            cssh   = arrayfun(@(a) cumsum(socons(ish==a)), 1:ish(end), 'un', 0);
            So     = cat(2,cssh{:});

            SigmSO = 0.5+((1./(1+exp(-1.75*(So-3))))./2); %6/8 criterion
            % SigmSO = 0.5+((1./(1+exp(-1.5*(So-3.5))))./2); %7/9 criterion
            SigmSO = SigmSO.';

            for k = 2:SL
                if ismember(k,phase) %skip iteration of for loop at each of these trials where a new phase begins
                    SigmSO(k) = 0.5;
                    continue
                end
                shsig       = [0;SigmSO(1:end-1)];
                invsh       = 1-shsig; % inverse likelihood, shifted down by one cell
                rsh         = soundcons == 0; % indexes trials where consecutive streak ends
                SigmSO(rsh) = invsh(rsh); % on trials where non-consistent choices are made, replace likelihood with the inverse of the previous likelihood
            end

            %% Light strategy
            lightcons = ones(SL,1); %initializes matrix for the consecutive for loop below
            for p = 3:(SL - 1)
                lightcons(p) = [logical(shuflight(p) == shuflight(p+1))];
            end

            licons = lightcons.';
            ili    = cumsum([true diff(licons)~=0]);
            csli   = arrayfun(@(a) cumsum(licons(ili==a)), 1:ili(end), 'un', 0);
            Li     = cat(2,csli{:});

            SigmLi = 0.5+((1./(1+exp(-1.75*(Li-3))))./2); %6/8 criterion
            % SigmLi = 0.5+((1./(1+exp(-1.5*(Li-3.5))))./2); %7/9 criterion

            SigmLi = SigmLi.';
            for k = 2:SL
                if ismember(k,phase) %skip iteration of for loop at each of these trials where a new phase begins
                    SigmLi(k) = 0.5;
                    continue
                end
                cosig       = [0;SigmLi(1:end-1)];
                invco       = 1-cosig; % inverse likelihood, shifted down by one cell
                rco         = lightcons == 0; % indexes trials where consecutive streak ends
                SigmLi(rco) = invco(rco); % on trials where non-consistent choices are made,
            end

            if numel(phase) > 2
                SigmLi(1:phase(3)) = 0; %Setting equal to zero for the first two phases since color is not an option
            else
                SigmLi(1:end) = 0;
            end

            shSPlike_session{l}  = SigmSP;
            % shSPalike_session{l} = SigmSPa;
            shSOlike_session{l}  = SigmSO;
            shLIlike_session{l}  = SigmLi;
        end

        SPlike_sh{s}  = shSPlike_session;
        % SPalike_sh{s} = shSPalike_session;
        SOlike_sh{s}  = shSOlike_session;
        LIlike_sh{s}  = shLIlike_session;
    end
end