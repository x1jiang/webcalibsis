function [testStat,pvalue] = hosmer_lemeshow(predictions,labels)
% Hosmer Lemeshow goodness-of-fit test

ordered = sortrows([predictions,labels]);
testStat = 0;
for i = 1 : 10
    group = ordered(((i-1) * size(ordered,1) / 10 + 1) : (i * size(ordered,1) / 10),:);
    n = size(group,1);
    observed = sum(group(:,2));
    expected = mean(group(:,1));
    testStat = testStat + ((observed - n * expected)^2 / (n * expected * (1 - expected)));
end

pvalue = 1 - chi2cdf(testStat,8);



