function aucsd = aucstandarddeviation(auc,nd,nh)
% calculation of the standard deviation of AUC using the formula of Hanley
% and McNeil. (see Hanley and McNeil, "The meaning of the area under a 
% receiver operating characteristic (ROC) curve", Radiology, 1982, 143:29-36)

auc2 = auc^2;
q1 = auc/(2-auc);
q2 = 2*auc2/(1+auc);
aucsd = sqrt((auc*(1-auc)+(nd-1)*(q1-auc2)+(nh-1)*(q2-auc2))/(nd*nh));



