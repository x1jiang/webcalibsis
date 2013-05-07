function [rcxvalues,rcyvalues,pointsperbin] = reliabilitycurve_h(predictions,labels)
% calculates the points of the reliablility curve and returns their x-values and y-values


bins = max(ceil(predictions*10),1);
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