function graphicalreport(filename,IPfolder)

close all;
clc;
createFolders(IPfolder);
global htest;
htest = false;
% import data
fsize =6;
[predictions labels htmlTemplate om_flag]=loadModelFromFile(filename);
if om_flag
    [cutoff,auc,fmeasure,caliberror,aucsd,sens,aucci,spec,pvalue_ctest,pvalue_htest,type1error]=evaluateOneModel(predictions,labels,IPfolder,true);    
    writeOneModelFile(cutoff,auc,fmeasure,caliberror,aucsd,sens,aucci,spec,pvalue_ctest,pvalue_htest,type1error,IPfolder,htmlTemplate);
     exit;
else
    p=0;
    for i=1:length(predictions)
        [A(i).cutoff,A(i).auc,A(i).fmeasure,A(i).caliberror,A(i).aucsd,A(i).sens,A(i).aucci,A(i).spec,A(i).pvalue_ctest,A(i).pvalue_htest,A(i).type1error,A(i).rocxvalues,A(i).rocyvalues,A(i).idx,A(i).rcxvalues,A(i).rcyvalues,A(i).pointsperbin]=evaluateOneModel(predictions(i).p,labels,IPfolder,false);  
    end
    if length(A) ==2
        std_aucA_minus_aucB = computeAUCvar(predictions,labels);
        z_value = (A(1).auc - A(2).auc)/std_aucA_minus_aucB;
        p = 2* (1 -normcdf(z_value));
    end
    plot_roc_multiModel(A,IPfolder,fsize);
    plot_rc_multiModel(A,IPfolder,fsize); 
    writeMultiModelFile(A,IPfolder,htmlTemplate,p);   
     exit;
end

end

function writeOneModelFile(cutoff,auc,fmeasure,caliberror,aucsd,sens,aucci,spec,pvalue_ctest,pvalue_htest,type1error,IPfolder,htmlTemplate)
    htmlInstance = sprintf(htmlTemplate,'Your Report','image/rocplot.png','image/rcplot.png',cutoff,auc,fmeasure,caliberror,aucsd,sens,aucci(1),aucci(2),spec,pvalue_ctest,pvalue_htest,type1error);
    outputFile =strcat(IPfolder,'/index.html');
    fid = fopen(outputFile,'w');
    fprintf(fid,htmlInstance);
    fclose(fid);

    webdir = sprintf('%s//%s//%s',pwd,IPfolder,'index.html');
    web(webdir);
    close all;

end

function writeMultiModelFile(A,IPfolder,htmlTemplate,p)
    headerInstance = sprintf(htmlTemplate.header,'Your Report','image/rocplot.png','image/rcplot.png');
    if length(A) ==2
        twoModelOption = sprintf(htmlTemplate.twoModelOption,p);
        headerInstance = strcat(headerInstance,twoModelOption);
    end
    
    tables = '';
    for i = 1:length(A)
        temp = sprintf(htmlTemplate.tables,i,A(i).cutoff,A(i).auc,A(i).fmeasure,A(i).caliberror,A(i).aucsd,A(i).sens,A(i).aucci(1),A(i).aucci(2),A(i).spec,A(i).type1error,A(i).pvalue_ctest,A(i).pvalue_htest);
        tables = strcat(tables,temp);
    end
    footerInstance = sprintf(htmlTemplate.footer);
    
    htmlPage = sprintf('%s \n %s \n %s',headerInstance,tables,footerInstance);
    
%     htmlInstance = sprintf(htmlTemplate,'Your Report','image/rocplot.png','image/rcplot.png',A.auc,B.auc,A.caliberror,B.caliberror,A.aucsd,B.aucsd,A.aucci(1),A.aucci(2),B.aucci(1),B.aucci(2),A.pvalue,B.pvalue,std_aucA_minus_aucB);
    outputFile =strcat(IPfolder,'/index.html');
    fid = fopen(outputFile,'w');
    fprintf(fid,htmlPage);
    fclose(fid);

    webdir = sprintf('%s//%s//%s',pwd,IPfolder,'index.html');
    web(webdir);
    close all;
end

function createFolders(IPfolder)
cdir = pwd;
if(~isdir(IPfolder))
    mkdir(IPfolder);
end
cd(IPfolder);
if(~isdir('image'))
    mkdir('image');
end
cd(cdir);
end

function [predictions labels htmlTemplate om_flag]=loadModelFromFile(filename)
data = importdata(filename);
om_flag = true;
if (size(data,2)==2)
    predictions = data(:,1);
    labels = data(:,2);
    htmlTemplate = fileread('templates\htmlTemplate.htm');
else
    l = size(data,2);
    for i =1:l-1
        predictions(i).p = data(:,i);
    end
    labels = data(:,end);
    htmlTemplate.header = fileread('templates\header.template');
    htmlTemplate.tables = fileread('templates\tables.template');
    htmlTemplate.footer = fileread('templates\footer.template');
    htmlTemplate.twoModelOption = fileread('templates\twoModelOption.template');
    om_flag = false;
end
end

function [cutoff,auc,fmeasure,caliberror,aucsd,sens,aucci,spec,pvalue_ctest,pvalue_htest,type1error,rocxvalues,rocyvalues,idx,rcxvalues,rcyvalues,pointsperbin]=evaluateOneModel(predictions,labels,IPfolder,plot_flag)
% ROC
global htest;
[rocxvalues,rocyvalues] = roccurve(predictions,labels);
fsize = 6;

% AUC
auc = areaunderroccurve(predictions,labels);

% standard deviation of the AUC
nh = length(predictions(labels==0));
nd = length(predictions(labels==1));
aucsd = aucstandarddeviation(auc,nd,nh);

% confidence interval of the AUC
aucci = aucconfidenceinterval(auc,aucsd,0.05);

% significance of the AUC
aucsign = aucsignificance(auc,aucsd);

% cut-off point
[idx,cutoff,cotable] = roccutoff(rocxvalues,rocyvalues,predictions,labels);
if plot_flag
    plot_roc(rocxvalues,rocyvalues,idx,IPfolder,fsize);
end
cs = sum(cotable); % columns sum
rs = sum(cotable,2); % rows sums
N = sum(cotable(:)); % numbers of elements
d = diag(cotable); % true positives and true negatives

% sensitivity and specificity
SS = d./cs';
sens = SS(1);
spec = SS(2);

% false proportion
fp = 1-SS;

% type-1 error
type1error = fp(1);

% 95% confidence interval for sensitivity and specificity
SScv = 1.96.*sqrt(SS.*fp./cs'); % critical value
% the confidence interval lower bound cannot be less than 0 and the
% upper bound can't be greater than 1
sensci = [max(0,SS(1)-SScv(1)),min(1,SS(1)+SScv(1))].*100;
specci = [max(0,SS(2)-SScv(2)),min(1,SS(2)+SScv(2))].*100;

% F-measure
PNp = d./rs; % positive and negative predictivity
fmeasure = harmmean([sens PNp(1)]);


% reliability curve
if (~htest)
    [rcxvalues,rcyvalues,pointsperbin] = reliabilitycurve_c(predictions,labels);
else
    [rcxvalues,rcyvalues,pointsperbin] = reliabilitycurve_h(predictions,labels);
end

if plot_flag
    plot_rc(rcxvalues,rcyvalues,pointsperbin,IPfolder,fsize);
end
% calibration error
caliberror = calibrationerror(predictions,labels);

% goodness-of-fit in terms of Hosmer-Lemeshow c-test
[CtestStat,pvalue_ctest] = hosmer_lemeshow_C(predictions,labels);

% goodness-of-fit in terms of Hosmer-Lemeshow h-test
[HtestStat,pvalue_htest] = hosmer_lemeshow_H(predictions,labels);

% if (testStat > chi2inv(0.95,8))
%     disp('-> model does not fulfill der Hosmer-Lemeshow C statistic!');
% end
end

function plot_roc(rocxvalues,rocyvalues,idx,IPfolder,fsize)
% plot ROC
roc = plot(rocxvalues,rocyvalues,'r.-','markersize',5);
hold on
randcl = plot([0,1],[0,1],'k');
hold off
title('ROC','fontsize',fsize)
xlabel('False Positive Rate (1-Specificity)','fontsize',fsize);
ylabel('True Positive Rate (Sensitivity)','fontsize',fsize);
axis square

hold on
co = plot(rocxvalues(idx),rocyvalues(idx),'bo','markersize',5);
hold on;
legend([roc,randcl,co],'ROC-Curve','Random Classifier','Cut-off Point','Location','SouthEast')
coplotFile = sprintf('%s\\%s\\%s',pwd,IPfolder,'image\rocplot.png');
hold on;

set(gca,'fontsize',fsize);
set(gcf,'PaperPosition',[0 0 22/6 16/6]);
saveas(co,coplotFile);
close;
end

function plot_roc_twoModel(A,B,IPfolder,fsize)
    % plot ROC
    rocA = plot(A.rocxvalues,A.rocyvalues,'r.-','markersize',5);
    hold on
    rocB = plot(B.rocxvalues,B.rocyvalues,'b.-','markersize',5);
    hold on;
    randcl = plot([0,1],[0,1],'k');
    hold off
    title('ROC','fontsize',fsize)
    xlabel('False Positive Rate (1-Specificity)','fontsize',fsize);
    ylabel('True Positive Rate (Sensitivity)','fontsize',fsize);
    axis square

    hold on
    coA = plot(A.rocxvalues(A.idx),A.rocyvalues(A.idx),'go','markersize',5);
    text(A.rocxvalues(A.idx)+0.02,A.rocyvalues(A.idx)-0.02,num2str(A.cutoff),'Color','g','fontsize',fsize);
    hold on;
    coB = plot(B.rocxvalues(B.idx),B.rocyvalues(B.idx),'go','markersize',5);
    text(B.rocxvalues(B.idx)+0.02,B.rocyvalues(B.idx)-0.02,num2str(B.cutoff),'Color','g','fontsize',fsize);
    hold on;
    
    legend([rocA,rocB,randcl],'ROC-Curve (A)','ROC-Curve (B)','Random Classifier','Location','SouthEast')
    coplotFile = sprintf('%s\\%s\\%s',pwd,IPfolder,'image\rocplot.png');
    hold on;

    set(gca,'fontsize',fsize);
    set(gcf,'PaperPosition',[0 0 22/6 16/6]);
    saveas(coB,coplotFile);
    close;
end


function plot_roc_multiModel(A,IPfolder,fsize)
    % plot ROC
    global htest;
    for i = 1:length(A)
        rocA(i) = plot(A(i).rocxvalues,A(i).rocyvalues,'.-','markersize',5,'color',[0 0 i]./length(A));
        hold on
%         rocB = plot(B.rocxvalues,B.rocyvalues,'b.-','markersize',5);
%         hold on;
        M{i} = sprintf('ROC Model(%i)',i);
    end
    randcl = plot([0,1],[0,1],'k');
    M{end+1} =  'Random Classifier';
    hold off
    title('ROC','fontsize',fsize)
    xlabel('False Positive Rate (1-Specificity)','fontsize',fsize);
    ylabel('True Positive Rate (Sensitivity)','fontsize',fsize);
    axis square

    hold on
    for i = 1:length(A)
        co = plot(A(i).rocxvalues(A(i).idx),A(i).rocyvalues(A(i).idx),'ro','markersize',5);
        text(A(i).rocxvalues(A(i).idx)+0.02,A(i).rocyvalues(A(i).idx)-0.02,num2str(A(i).cutoff),'Color','r','fontsize',fsize);        
        hold on;
    end
   
    legend([rocA,randcl],M,'Location','SouthEast')
    coplotFile = sprintf('%s\\%s\\%s',pwd,IPfolder,'image\rocplot.png');
    hold on;

    set(gca,'fontsize',fsize);
    set(gcf,'PaperPosition',[0 0 22/6 16/6]);
    saveas(co,coplotFile);
    close;
end

function plot_rc(rcxvalues,rcyvalues,pointsperbin,IPfolder,fsize)
% plot reliability curve
global htest;
rc = plot(rcxvalues,rcyvalues,'r.-','markersize',5);
hold on
xticks = get(gca,'XTickLabel');
optc = plot([0,str2num(xticks(end,:))],[0,str2num(xticks(end,:))],'k');
% optc = plot([0,1],[0,1],'k');
if (htest)
    for i=1:10
        text(rcxvalues(i)+0.02,rcyvalues(i)-0.02,num2str(pointsperbin(i)),'Color','Blue','fontsize',fsize);
    end
end
hold off
title('Reliability Diagram','FontSize',fsize);
xlabel('Mean Predicted Value','FontSize',fsize);
ylabel('Fraction of Positives','FontSize',fsize);
axis square
legend([rc,optc],'Calibration-Curve','Optimal','Location','SouthEast')
hold on;
set(gca,'fontsize',fsize);
set(gcf,'PaperPosition',[0 0 22/6 16/6]);
optcplotFile = sprintf('%s\\%s\\%s',pwd,IPfolder,'image\rcplot.png');
saveas(optc,optcplotFile);
end

function plot_rc_twoModel(A,B,IPfolder,fsize)
    % plot reliability curve
    rcA = plot(A.rcxvalues,A.rcyvalues,'r.-','markersize',5);
    hold on
    rcB = plot(B.rcxvalues,B.rcyvalues,'b.-','markersize',5);
    optc = plot([0,1],[0,1],'k');
    for i=1:10
        text(A.rcxvalues(i)+0.02,A.rcyvalues(i)-0.02,num2str(A.pointsperbin(i)),'Color','Red','fontsize',fsize);
        text(B.rcxvalues(i)+0.02,B.rcyvalues(i)-0.02,num2str(B.pointsperbin(i)),'Color','Blue','fontsize',fsize);
    end
    hold off
    title('Reliability Diagram','FontSize',fsize);
    xlabel('Mean Predicted Value','FontSize',fsize);
    ylabel('Fraction of Positives','FontSize',fsize);
    axis square
    legend([rcA,rcB,optc],'Calib. Curve (A)','Calib. Curve (B)','Optimal','Location','SouthEast')
    hold on;
    set(gca,'fontsize',fsize);
    set(gcf,'PaperPosition',[0 0 22/6 16/6]);
    optcplotFile = sprintf('%s\\%s\\%s',pwd,IPfolder,'image\rcplot.png');
    saveas(optc,optcplotFile);
end


function plot_rc_multiModel(A,IPfolder,fsize)
    % plot reliability curve
    global htest;
%     maxX = [];
    
    for i = 1:length(A)
        rcA(i) = plot(A(i).rcxvalues,A(i).rcyvalues,'r.-','markersize',5,'color',[0 0 i]./length(A));
        hold on
        M{i} = sprintf('Calib. Model(%i)',i);
    end
%     rcB = plot(B.rcxvalues,B.rcyvalues,'b.-','markersize',5);
    xticks = get(gca,'XTickLabel');
    optc = plot([0,str2num(xticks(end,:))],[0,str2num(xticks(end,:))],'k');
    M{end+1} = sprintf('Optimal');
    if (htest)
        for j =1:length(A)
            for i=1:10
                text(A(j).rcxvalues(i)+0.02,A(j).rcyvalues(i)-0.02,num2str(A(j).pointsperbin(i)),'color',[0 0 j]./length(A),'fontsize',fsize);
    %             text(B.rcxvalues(i)+0.02,B.rcyvalues(i)-0.02,num2str(B.pointsperbin(i)),'Color','Blue','fontsize',fsize);
            end
        end
    end
    hold off
    title('Reliability Diagram','FontSize',fsize);
    xlabel('Mean Predicted Value','FontSize',fsize);
    ylabel('Fraction of Positives','FontSize',fsize);
    axis square
    legend([rcA,optc],M,'Location','SouthEast')
    hold on;
    set(gca,'fontsize',fsize);
    set(gcf,'PaperPosition',[0 0 22/6 16/6]);
    optcplotFile = sprintf('%s\\%s\\%s',pwd,IPfolder,'image\rcplot.png');
    saveas(optc,optcplotFile);
end


