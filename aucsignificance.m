function pvalue = aucsignificance(auc,aucsd)
% calculates if the auc is significantly greater than 0.5 using the z-test

stdauc = (auc-0.5)/aucsd; % standardized AUC
pvalue = 1-0.5*erfc(-stdauc/sqrt(2)); % p-value