function [testStat,pvalue] = hosmer_lemeshow_H(predictions,labels)
% Hosmer Lemeshow goodness-of-fit H-test

ordered = sortrows([predictions,labels]);
testStat = 0;
for i = 1 : 10
    group = ordered(find(ordered(:,1)>(i-1)*0.1 & ordered(:,1)<=i*0.1),:);
    n = size(group,1);
    if n>0
        observed = sum(group(:,2));
        expected = mean(group(:,1));
        testStat = testStat + ((observed - n * expected)^2 / (n * expected * (1 - expected)));
    end
end

pvalue = 1 - chi2cdf(testStat,8);



