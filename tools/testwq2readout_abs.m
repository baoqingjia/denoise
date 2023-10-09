clc;clear; close all;
% fidname{1}='D:\NMRdata\400.3.2mm.20221116\2014\fid';
% fidname{2}='D:\NMRdata\400.3.2mm.20221116\2015\fid';
% fidname{3}='D:\NMRdata\400.3.2mm.20221116\2016\fid';
% fidname{4}='D:\NMRdata\400.3.2mm.20221116\2017\fid'
% fidname{5}='D:\NMRdata\400.3.2mm.20221116\2018\fid';
% fidname{6}='D:\NMRdata\400.3.2mm.20221116\2019\fid';
% fidname{7}='D:\NMRdata\400.3.2mm.20221116\2020\fid';
% fidname{8}='D:\NMRdata\400.3.2mm.20221116\2021\fid';
% fidname{9}='D:\NMRdata\400.3.2mm.20221116\2022\fid';
% fidname{10}='D:\NMRdata\400.3.2mm.20221116\2023\fid';
% fidname{11}='D:\NMRdata\400.3.2mm.20221116\2024\fid';
% fidname{12}='D:\NMRdata\400.3.2mm.20221116\2025\fid'
% fidname{13}='D:\NMRdata\400.3.2mm.20221116\2026\fid';
% fidname{14}='D:\NMRdata\400.3.2mm.20221116\2027\fid';
% fidname{15}='D:\NMRdata\400.3.2mm.20221116\2028\fid';
% fidname{16}='D:\NMRdata\400.3.2mm.20221116\2029\fid';

fidname{1}='D:\topspin\400.3.2mm.20221116\2020\fid';
fidname{2}='D:\topspin\400.3.2mm.20221116\2021\fid';
fidname{3}='D:\topspin\400.3.2mm.20221116\2022\fid';
fidname{4}='D:\topspin\400.3.2mm.20221116\2023\fid';
fidname{5}='D:\topspin\400.3.2mm.20221116\2024\fid';
fidname{6}='D:\topspin\400.3.2mm.20221116\2025\fid';
fidname{7}='D:\topspin\400.3.2mm.20221116\2026\fid';
fidname{8}='D:\topspin\400.3.2mm.20221116\2027\fid';
fidname{9}='D:\topspin\400.3.2mm.20221116\2028\fid';
fidname{10}='D:\topspin\400.3.2mm.20221116\2029\fid';
fidname{11}='D:\topspin\400.3.2mm.20221116\2030\fid';
fidname{12}='D:\topspin\400.3.2mm.20221116\2031\fid';
fidname{13}='D:\topspin\400.3.2mm.20221116\2032\fid';
fidname{14}='D:\topspin\400.3.2mm.20221116\2033\fid';
fidname{15}='D:\topspin\400.3.2mm.20221116\2034\fid';
fidname{16}='D:\topspin\400.3.2mm.20221116\2035\fid';


% fidname{1}='I:\topspindata\topspindata\13C-poorSN\3040\fid';
% fidname{2}='I:\topspindata\topspindata\13C-poorSN\3041\fid';
% fidname{3}='I:\topspindata\topspindata\13C-poorSN\3042\fid';
% fidname{4}='I:\topspindata\topspindata\13C-poorSN\3043\fid'
% fidname{5}='I:\topspindata\topspindata\13C-poorSN\3044\fid';
% fidname{6}='I:\topspindata\topspindata\13C-poorSN\3045\fid';
% fidname{7}='I:\topspindata\topspindata\13C-poorSN\3046\fid';
% fidname{8}='I:\topspindata\topspindata\13C-poorSN\3047\fid';
%  fidname{9}='I:\topspindata\topspindata\13C-poorSN\3048\fid';
%  fidname{10}='I:\topspindata\topspindata\13C-poorSN\3049\fid';
%  fidname{11}='I:\topspindata\topspindata\13C-poorSN\3050\fid';
%  fidname{12}='I:\topspindata\topspindata\13C-poorSN\3051\fid';
%  fidname{13}='I:\topspindata\topspindata\13C-poorSN\3052\fid';
%  fidname{14}='I:\topspindata\topspindata\13C-poorSN\3053\fid';
%  fidname{15}='I:\topspindata\topspindata\13C-poorSN\3054\fid';
%  fidname{16}='I:\topspindata\topspindata\13C-poorSN\3055\fid';


sumfid=0;
Max=10e8;
for i=1:size(fidname,2)
fid0{i}=fopen(fidname{i},'r','ieee-le');
[H,Length]=fread(fid0{i},'int32','ieee-le');
fid00{i}=transpose(reshape(H,2,Length/2));
fid000{i}=fid00{i}(:,1)+1i*((fid00{i}(:,2)));
fid01{i}=fid000{i};

 Tempfid01=zeros([8192,1]);
 Tempfid01(1:length(fid01{i}))=fid01{i};
 fid01{i}=Tempfid01;

sumfid= sumfid+fid01{i};
spe{i}=fftshift(fft(fid01{i}));
%figure;plot(abs(spe{i}))
end
% fid02=sumfid;
%  figure;plot(abs(fftshift(fft(fid02))))
 SpecAll=[];
 for i=1:size(spe,2)
 SpecAll=cat(2,SpecAll,spe{i});
 end
 
 imgNoiseVol=permute(SpecAll(:,1:16),[1,3,2]);
 RealimgNoiseVol=real(imgNoiseVol)/max(abs(imgNoiseVol(:)));
 RealimgNoiseVol=repmat(RealimgNoiseVol,[1,128,1]);
 RealimgWaveletMultiframe = waveletMultiFrame(RealimgNoiseVol, 'k', 5, 'p',5, 'maxLevel', 5, 'weightMode', 4, 'basis', 'dualTree');
 
 ImgimgNoiseVol=imag(imgNoiseVol)/max(abs(imgNoiseVol(:)));
 ImgimgNoiseVol=repmat(ImgimgNoiseVol,[1,128,1]);
 ImgimgWaveletMultiframe = waveletMultiFrame(ImgimgNoiseVol, 'k', 5, 'p', 5, 'maxLevel', 5, 'weightMode',4, 'basis', 'dualTree');
%  imgNoiseVol=permute(SpecAll(:,1:8),[1,3,2]);
%  RealimgNoiseVol=abs(imgNoiseVol)/max(abs(imgNoiseVol(:)));
%  RealimgNoiseVol=repmat(RealimgNoiseVol,[1,128,1]);
%  RealimgWaveletMultiframe = waveletMultiFrame(RealimgNoiseVol, 'k', 5, 'p',10, 'maxLevel', 5, 'weightMode', 4, 'basis', 'dualTree');
 RealimgWaveletMultiframe=flip(RealimgWaveletMultiframe,1);
 ImgimgWaveletMultiframe=flip(ImgimgWaveletMultiframe,1);
 
 Phase = RealimgWaveletMultiframe +1i*ImgimgWaveletMultiframe;

%  Phase = RealimgWaveletMultiframe
 
 FileStr={'1r' '1i'};
 DataCell={sum(abs(Phase),2),sum(ImgimgWaveletMultiframe,2)};
 WritePath=['I:\topspindata\topspindata\13C-poorSN\6666\pdata\1\'];
%WritePath=['D:\NMRdata\400.3.2mm.20221116\9999\pdata\1\'];

 for i=1:size(FileStr,2)
     fileID = fopen([WritePath FileStr{i}],'w','l');
   fwrite(fileID,round(round(DataCell{i}*10e12)/max(max(round(DataCell{i}*10e12)))*Max),'int32');
% %    fwrite(fileID,DataCell{i},'int32');
    fclose(fileID);
 end
 
%  imgNoiseVol=abs(imgNoiseVol)/max(abs(imgNoiseVol(:)));
%  imgNoiseVol3D=repmat(imgNoiseVol,[1,16,1]);
%  imgWaveletMultiframe = waveletMultiFrame(imgNoiseVol3D, 'k',6, 'p', 5, 'maxLevel', 5, 'weightMode', 4, 'basis',  'dualTree');
%  figure;
%  subplot(1,3,1);plot(abs(sum(Phase,2)));subplot(1,3,2);plot((sum(abs(SpecAll),2)));subplot(1,3,3);plot((abs(sum(imgWaveletMultiframe,2))));
figure;
subplot(1,2,1);plot(abs(sum(Phase,2)));subplot(1,2,2);plot((sum(abs(SpecAll),2)));