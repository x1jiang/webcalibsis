A = importdata('output.txt');
Z = A(:,1);
Z = Z(randperm(length(Z)));

fid = fopen('output3.txt','w');
for i =1:length(Z)
    fprintf(fid,'%.3f \t %.3f \t %d\n',A(i,1),Z(i),A(i,2));
end
fclose(fid);