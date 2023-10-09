clc;clear; close all;

Number=4;
ReadPath1=['D:\NMRdata\400.3.2mm.20221116\'];
ReadPath2=['\pdata\1\1r'];

for i=1:Number
starnumber=2013;
str1=num2str(starnumber+i);
filestr1=[ReadPath1 str1 ReadPath2];
fidname{i}=filestr1;
end

fidname{1}='D:\NMRdata\400.3.2mm.20221116\3104\fid';
fidname{2}='D:\NMRdata\400.3.2mm.20221116\3105\fid';
fidname{3}='D:\NMRdata\400.3.2mm.20221116\3106\fid';
fidname{4}='D:\NMRdata\400.3.2mm.20221116\3107\fid';
fidname{5}='D:\NMRdata\400.3.2mm.20221116\3108\fid';
fidname{6}='D:\NMRdata\400.3.2mm.20221116\3109\fid';
fidname{7}='D:\NMRdata\400.3.2mm.20221116\3110\fid';
fidname{8}='D:\NMRdata\400.3.2mm.20221116\3111\fid';
Max=10e8;
for i=1:size(fidname,2)
    fid0=fopen(fidname{i},'r','ieee-le');
    [H,Length]=fread(fid0,'int32','ieee-le');
    fid00=transpose(reshape(H,2,Length/2));
    fid000=fid00(:,1)+1i*((fid00(:,2)));
    fid01{i}=fid000;
   speabs0{i}=abs(fftshift(fft(fid01{i})));
  %  figure;plot(abs(fftshift(fft(fid01{i}))));
end

 SpecAll=[];
 for i=1:size(speabs0,2)
 SpecAll=cat(2,SpecAll,speabs0{i});
 end
 
 imgNoiseVol=permute(SpecAll(:,1:Number),[1,3,2]);
 imgNoiseVol=imgNoiseVol/max(abs(imgNoiseVol(:)));
 imgNoiseVol=repmat(imgNoiseVol,[1,128,1]);
 imgWaveletMultiframe = waveletMultiFrame(imgNoiseVol, 'k', 4, 'p',5, 'maxLevel', 3, 'weightMode', 4,'r', 500, 'windowSize',2,'basis', 'dualTree');
 
 Realspec=imgWaveletMultiframe;
 
  FileStr={'1r'};
 %DataCell={sum(RealimgWaveletMultiframe,2),sum(ImgimgWaveletMultiframe,2)};
 WritePath=['D:\NMRdata\400.3.2mm.20221116\6666\pdata\1\'];

   fileID = fopen([WritePath FileStr{1}],'w','l');
   fwrite(fileID,round(round(Realspec*10e12)/max(max(round(Realspec*10e12)))*Max),'int32');
% %    fwrite(fileID,DataCell{i},'int32');
   fclose(fileID);

   FileStr={'1r'};
 %DataCell={sum(RealimgWaveletMultiframe,2),sum(ImgimgWaveletMultiframe,2)};
 WritePath1=['D:\NMRdata\400.3.2mm.20221116\5555\pdata\1\'];

   fileID1 = fopen([WritePath1 FileStr{1}],'w','l');
   fwrite(fileID1,round(round(SpecAll*10e12)/max(max(round(SpecAll*10e12)))*Max),'int32');
% %    fwrite(fileID,DataCell{i},'int32');
   fclose(fileID1);
   
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