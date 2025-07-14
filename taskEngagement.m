%%% Training data analysis
%Average no initiations across training stages (2,3,4) and no initiations
%binned across single sessions
function [trialsEngaged, trialsOmitted,percentOmitted,sessions,level] = taskEngagement(x)
sessions = height(x.dateTable);
trialsEngaged = cell(3,sessions);
trialsOmitted = cell(3,sessions);
percentOmitted = cell(3,sessions);

for k = 1:sessions
    trialData = x.trialByTrialData{k};
    sessionLength = length(trialData);
    level = x.level{k};
    subject = x.subjectTable{k};
    engagedCount = 0;
    omittedCount = 0;
    for i = 1:sessionLength
         if trialData(i,1) == 0
            omittedCount = omittedCount + 1;
         elseif trialData (i,1) ~= 0 
            engagedCount = engagedCount + 1;
         end 
    end
    percentOmitted{1,k} = (omittedCount/(omittedCount + engagedCount))*100;
    percentOmitted{2,k} = [x.level{k}];
    percentOmitted{3,k} = subject;
    trialsOmitted{1,k} = omittedCount;
    trialsOmitted{2,k} = [x.level{k}];
    trialsOmitted{3,k} = subject;
    trialsEngaged{1,k} = engagedCount;
    trialsEngaged{2,k} = [x.level{k}];
    trialsEngaged{3,k} = subject;
    level(k) = x.level(k);
end
end
