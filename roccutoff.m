function [idx,cutoff,cotable] = roccutoff(rocxvalues,rocyvalues,predictions,labels)
% determines the best cut-off point, which is the closest point to (0,1)

% calculate all distances using the Pitagora's theorem
dists = realsqrt(rocxvalues.^2+(1-rocyvalues).^2); 
[c,idx] = min(dists); % find the least distance

% get cut-off point
x = [predictions,labels];
s = sortrows(x,1);

% ignore ties
unipreds = unique(s(:,1));
ubar = mean(x(x(:,2)==1),1); % diseased mean value
hbar = mean(x(x(:,2)==0),1); % healthy mean value
if hbar<ubar
    unipreds = flipud(unipreds);
end
cutoff = unipreds(idx);

% table at cut-off point
if hbar < ubar
    TP = length(x(x(:,2)==1 & x(:,1)>cutoff));
    FP = length(x(x(:,2)==0 & x(:,1)>cutoff));
    FN = length(x(x(:,2)==1 & x(:,1)<=cutoff));
    TN = length(x(x(:,2)==0 & x(:,1)<=cutoff));
else
    TP = length(x(x(:,2)==1 & x(:,1)<cutoff));
    FP = length(x(x(:,2)==0 & x(:,1)<cutoff));
    FN = length(x(x(:,2)==1 & x(:,1)>=cutoff));
    TN = length(x(x(:,2)==0 & x(:,1)>=cutoff));
end
cotable=[TP FP; FN TN];