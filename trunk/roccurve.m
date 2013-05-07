function [rocxvalues,rocyvalues] = roccurve(predictions,labels)
% calculates the points of the ROC and returns their x-values and y-values 

x = [predictions,labels];
s = sortrows(x,1);

% ignore ties
unipreds = unique(s(:,1));
n = length(unipreds); % count unique values

a = zeros(n,2); % array preallocation
ubar = mean(x(x(:,2)==1),1); % diseased mean value
hbar = mean(x(x(:,2)==0),1); % healthy mean value
for t = 1 : n
    if hbar < ubar
        TP = length(x(x(:,2)==1 & x(:,1)>unipreds(t)));
        FP = length(x(x(:,2)==0 & x(:,1)>unipreds(t)));
        FN = length(x(x(:,2)==1 & x(:,1)<=unipreds(t)));
        TN = length(x(x(:,2)==0 & x(:,1)<=unipreds(t)));
    else
        TP = length(x(x(:,2)==1 & x(:,1)<unipreds(t)));
        FP = length(x(x(:,2)==0 & x(:,1)<unipreds(t)));
        FN = length(x(x(:,2)==1 & x(:,1)>=unipreds(t)));
        TN = length(x(x(:,2)==0 & x(:,1)>=unipreds(t)));
    end
    a(t,:) = [TP/(TP+FN),TN/(TN+FP)]; % Sensitivity and Specificity
end

if hbar < ubar
    rocxvalues = flipud([1; 1-a(:,2); 0]); 
    rocyvalues = flipud([1; a(:,1); 0]);
else
    rocxvalues = [0; 1-a(:,2); 1];
    rocyvalues = [0; a(:,1); 1];
end