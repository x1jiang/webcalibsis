function [testStat,pvalue] = hosmer_lemeshow_C(predictions,labels)
% Hosmer Lemeshow goodness-of-fit C-test

ordered = sortrows([predictions,labels]);
N = size(ordered,1);
rest = mod(N,10);
testStat = 0;
for i = 1 : 10
    if (i <= rest)
        group = ordered((i-1) * ceil(N / 10) + 1 : i * ceil(N / 10),:);
    else
        group = ordered(rest + (i-1) * fix(N / 10) + 1 : rest + i * fix(N / 10),:);
    end
    n = size(group,1);
    observed = sum(group(:,2));
    expected = mean(group(:,1));
    if (n*expected~=observed)
        testStat = testStat + ((observed - n * expected)^2 / (n * expected * (1 - expected)));
    end
end

pvalue = 1 - chi2cdf(testStat,8);



