
function std_aucA_minus_aucB = computeAUCvar(predictions,labels)
% get the A statitics
A.D = predictions(1).p(find(labels == 1));
A.H = predictions(1).p(find(labels == 0));

A.VD = zeros(1,length(A.D));  A.VH = zeros(1,length(A.H));

for i = 1:length(A.D)
   A.VD(i) = length(find(A.H<A.D(i)))/length(A.H); 
end

for i = 1:length(A.H)
    A.VH(i) = 1-length(find(A.D<A.H(i)))/length(A.D);    
end

% get the B statitics
B.D = predictions(2).p(find(labels == 1));
B.H = predictions(2).p(find(labels == 0));

B.VD = zeros(1,length(B.D));  B.VH = zeros(1,length(B.H));

for i = 1:length(B.D)
   B.VD(i) = length(find(B.H<B.D(i)))/length(B.H); 
end

for i = 1:length(B.H)
    B.VH(i) = 1-length(find(B.D<B.H(i)))/length(B.D);    
end

nh = length(A.VH);
nd = length(A.VD);

% ph = nh / (nh+nd);
% pd = nd / (nh+nd);

var_auc_A = var(A.VH)/nh + var(A.VD)/nd;
std_auc_A = sqrt(var_auc_A);
var_auc_B = var(B.VH)/nh + var(B.VD)/nd;
std_auc_B = sqrt(var_auc_B);

temp =0;
for i = 1:nh
    temp = temp + A.VH(i)*B.VH(i);
end
cov_VHA_VHB = (temp/(nh-1) - mean(A.VH)*mean(B.VH));

temp =0;
for i = 1:nd
    temp = temp + A.VD(i)*B.VD(i);
end
cov_VDA_VDB = (temp/(nd-1) - mean(A.VD)*mean(B.VD));

cov_aucA_aucB = cov_VHA_VHB/nh + cov_VDA_VDB/nd;

var_aucA_minus_aucB = var_auc_A + var_auc_B - 2*cov_aucA_aucB;
std_aucA_minus_aucB = sqrt(max(0,var_aucA_minus_aucB));
end
