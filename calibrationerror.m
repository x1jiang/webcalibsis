function b = calibrationerror(predictions,labels)
% calculates the calibration error in terms of the Brier score, with is the
% mean squared distances between predictions and labels

n = length(predictions);
b = sum((labels - predictions).^2)/n;