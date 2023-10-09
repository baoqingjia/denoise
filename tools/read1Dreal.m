clc;clear; close all;

Number=32;
ReadPath1=['D:\NMRdata\400.3.2mm.20221116\'];
ReadPath2=['\pdata\1\1r'];

for i=1:Number
starnumber=2013;
str1=num2str(starnumber+i);
filestr1=[ReadPath1 str1 ReadPath2];
fidname{i}=filestr1;
end

% fidname{1}='D:\NMRdata\400.3.2mm.20221116\2014\pdata\1\1r';
% fidname{2}='D:\NMRdata\400.3.2mm.20221116\2015\pdata\1\1r';
% fidname{3}='D:\NMRdata\400.3.2mm.20221116\2016\pdata\1\1r';
% fidname{4}='D:\NMRdata\400.3.2mm.20221116\2017\pdata\1\1r'
% fidname{5}='D:\NMRdata\400.3.2mm.20221116\2018\pdata\1\1r';
% fidname{6}='D:\NMRdata\400.3.2mm.20221116\2019\pdata\1\1r';
% fidname{7}='D:\NMRdata\400.3.2mm.20221116\2020\pdata\1\1r';
% fidname{8}='D:\NMRdata\400.3.2mm.20221116\2021\pdata\1\1r';
Max=10e8;
for i=1:size(fidname,2)
spereal{i}=fopen(fidname{i},'r','l');
spereal0{i}=fread(spereal{i},'int32','ieee-le');
end

 SpecAll=[];
 for i=1:size(spereal0,2)
 SpecAll=cat(2,SpecAll,spereal0{i});
 end
 
 imgNoiseVol=permute(SpecAll(:,1:Number),[1,3,2]);
 imgNoiseVol=imgNoiseVol/max(abs(imgNoiseVol(:)));
 imgNoiseVol=repmat(imgNoiseVol,[1,128,1]);
 imgWaveletMultiframe = waveletMultiFrame(imgNoiseVol, 'k', 6, 'p',5, 'maxLevel', 4, 'weightMode', 4, 'windowSize',4,'basis', 'dualTree');
 
 Realspec=imgWaveletMultiframe;
 
  FileStr={'1r'};
 %DataCell={sum(RealimgWaveletMultiframe,2),sum(ImgimgWaveletMultiframe,2)};
 WritePath=['D:\NMRdata\400.3.2mm.20221116\9999\pdata\1\'];

   fileID = fopen([WritePath FileStr{1}],'w','l');
   fwrite(fileID,round(round(Realspec*10e12)/max(max(round(Realspec*10e12)))*Max),'int32');
% %    fwrite(fileID,DataCell{i},'int32');
   fclose(fileID);

% 
  figure;
  subplot(1,2,1);plot(sum(Realspec,2));subplot(1,2,2);plot((sum(abs(SpecAll),2)));
 
 
 
 
 
 
%fname='1r';
%     SizeTD1=1;
%     SizeTD2=32*1024;
%     ByteOrder=2;
%     if (ByteOrder == 2)
%         id=fopen(fname, 'r', 'l');   %use little endian format if asked for
%     else
%         id=fopen(fname, 'r', 'b');   %use big endian format by default
%     end
%     
%     RealSpecData=zeros(1,SizeTD1*SizeTD2);
%     [RealSpecData, count] = fread(id, SizeTD1*SizeTD2, 'int');
%     L=length(RealSpecData);
%     
%     fname='1i';
%     if (ByteOrder == 2)
%         id=fopen(fname, 'r', 'l');   %use little endian format if asked for
%     else
%         id=fopen(fname, 'r', 'b');   %use big endian format by default
%     end 
%     ImagSpecData=zeros(1,SizeTD1*SizeTD2);
%     [ImagSpecData, count] = fread(id, SizeTD1*SizeTD2, 'int');