function aucci = aucconfidenceinterval(auc,aucsd,alpha)
% calculates the confidence interval of the AUC

cv = sqrt(2)*erfcinv(alpha);
aucci = auc+[-1 1].*(cv*aucsd);
if aucci(2)>1
    aucci(2)=1;
end