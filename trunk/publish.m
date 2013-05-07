function publish(filename,folder)

global filename;

options_doc_nocode.format = 'html';
fol = strcat('//',folder);
options_doc_nocode.outputDir = strcat(pwd,fol);
options_doc_nocode.showCode = false;

file = publish('graphicalreport.m',options_doc_nocode);
web(file)
%exit

end
