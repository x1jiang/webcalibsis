function [testStat,pvalue] = hosmer_lemeshow_ctest(predictions,labels)
% Hosmer Lemeshow goodness-of-fit C-test

ordered = sortrows([predictions,labels]);
testStat = 0;
g = 0;
for i = 1 : 10
    group = ordered(find(ordered(:,1)>(i-1)*0.1 & ordered(:,1)<=i*0.1),:);
    n = size(group,1);
    if n>0
        observed = sum(group(:,2));
        expected = mean(group(:,1));
        testStat = testStat + ((observed - n * expected)^2 / (n * expected * (1 - expected)));
        g = g+1;
    end
end

pvalue = 1 - chi2cdf(testStat,g-2);



