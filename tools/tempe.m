clc;clear; close all;
Number=2;
ReadPath1=['D:\NMRdata\400.3.2mm.20221116\'];
ReadPath2=['\pdata\1\1r'];


for i=1:Number
starnumber=2013;
str1=num2str(starnumber+i);
filestr1=[ReadPath1 str1 ReadPath2];
fidname{i}=filestr1;
end