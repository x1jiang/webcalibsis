function [rcxvalues,rcyvalues,pointsperbin] = reliabilitycurve_c(predictions,labels)
% calculates the points of the reliablility curve and returns their x-values and y-values

ordered = sortrows([predictions,labels]);
predictions = ordered(:,1);
labels = ordered(:,2);

l = length(predictions);
bins =zeros(l,1);

for i =1:9
    bins( (i-1)*ceil(l/10)+1: (i)*ceil(l/10)) = i;
end
bins(9*ceil(l/10)+1:end) =10;

[predictions_means,labels_means] = deal(zeros([10,1]));
num_bin = [];

for bin = 1:10
    % prediction mean
    predictions_in_bin = predictions(bins==bin);
    num_bin(end+1)=length(predictions_in_bin);
    predictions_means(bin) = mean(predictions_in_bin);
    % fraction of positives
    labels_in_bin = labels(bins==bin);
    labels_means(bin) = mean(labels_in_bin);
end

rcxvalues = predictions_means;
rcyvalues = labels_means;
pointsperbin = num_bin;