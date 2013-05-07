function auc = areaunderroccurve(predictions,labels)
% calculation of the area under a ROC curve

normals = predictions(labels==0);
abnormals = predictions(labels==1);

nsort = sort(normals);
asort = sort(abnormals);

auc = 0;
for i = 1 : size(nsort,1)
    auc = auc + sum(asort > nsort(i)) + 0.5 * sum(asort == nsort(i));
end
 
auc = auc / (size(nsort,1) * size(asort,1));

  
    
    
    
