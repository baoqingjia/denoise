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
% fidname{9}='I:\topspindata\topspindata\400.3.2mm.20221116\2022\fid';
% fidname{10}='I:\topspindata\topspindata\400.3.2mm.20221116\2023\fid';
% fidname{11}='I:\topspindata\topspindata\400.3.2mm.20221116\2024\fid';
% fidname{12}='I:\topspindata\topspindata\400.3.2mm.20221116\2025\fid'
% fidname{13}='I:\topspindata\topspindata\400.3.2mm.20221116\2026\fid';
% fidname{14}='I:\topspindata\topspindata\400.3.2mm.20221116\2027\fid';
% fidname{15}='I:\topspindata\topspindata\400.3.2mm.20221116\2028\fid';
% fidname{16}='I:\topspindata\topspindata\400.3.2mm.20221116\2029\fid';
% 
%  fidname{1}='D:\NMRdata\3055\3040\fid';
%  fidname{2}='D:\NMRdata\3055\3041\fid';
%  fidname{3}='D:\NMRdata\3055\3042\fid';
%  fidname{4}='D:\NMRdata\3055\3043\fid';
%  fidname{5}='D:\NMRdata\3055\3044\fid';
%  fidname{6}='D:\NMRdata\3055\3045\fid';
%  fidname{7}='D:\NMRdata\3055\3046\fid';
%  fidname{8}='D:\NMRdata\3055\3047\fid';
%  fidname{9}='D:\NMRdata\3055\3048\fid';
%  fidname{10}='D:\NMRdata\3055\3049\fid';
%  fidname{11}='D:\NMRdata\3055\3050\fid';
%  fidname{12}='D:\NMRdata\3055\3051\fid';
%  fidname{13}='D:\NMRdata\3055\3052\fid';
%  fidname{14}='D:\NMRdata\3055\3053\fid';
%  fidname{15}='D:\NMRdata\3055\3054\fid';
%  fidname{16}='D:\NMRdata\3055\3055\fid';
 
 
  fidname{1}='D:\NMRdata\3605\984\fid';
 fidname{2}='D:\NMRdata\3605\985\fid';
 fidname{3}='D:\NMRdata\3605\986\fid';
 fidname{4}='D:\NMRdata\3605\987\fid';
 fidname{5}='D:\NMRdata\3605\988\fid';
 fidname{6}='D:\NMRdata\3605\989\fid';
 fidname{7}='D:\NMRdata\3605\990\fid';
 fidname{8}='D:\NMRdata\3605\991\fid';
 fidname{9}='D:\NMRdata\3605\992\fid';
 fidname{10}='D:\NMRdata\3605\993\fid';
 fidname{11}='D:\NMRdata\3605\994\fid';
 fidname{12}='D:\NMRdata\3605\995\fid';
 fidname{13}='D:\NMRdata\3605\996\fid';
 fidname{14}='D:\NMRdata\3605\997\fid';
 fidname{15}='D:\NMRdata\3605\998\fid';
 fidname{16}='D:\NMRdata\3605\999\fid';
 fidname{17}='D:\NMRdata\3605\968\fid';
 fidname{18}='D:\NMRdata\3605\969\fid';
 fidname{19}='D:\NMRdata\3605\970\fid';
 fidname{20}='D:\NMRdata\3605\971\fid';
 fidname{21}='D:\NMRdata\3605\972\fid';
 fidname{22}='D:\NMRdata\3605\973\fid';
 fidname{23}='D:\NMRdata\3605\974\fid';
 fidname{24}='D:\NMRdata\3605\975\fid';
 fidname{25}='D:\NMRdata\3605\976\fid';
 fidname{26}='D:\NMRdata\3605\977\fid';
 fidname{27}='D:\NMRdata\3605\978\fid';
 fidname{28}='D:\NMRdata\3605\979\fid';
 fidname{29}='D:\NMRdata\3605\980\fid';
 fidname{30}='D:\NMRdata\3605\981\fid';
 fidname{31}='D:\NMRdata\3605\982\fid';
 fidname{32}='D:\NMRdata\3605\983\fid';
 
sumfid=0;
Max=10e8;
for i=1:size(fidname,2)
fid0{i}=fopen(fidname{i},'r','ieee-le');
[H,Length]=fread(fid0{i},'int32','ieee-le');
fid00{i}=transpose(reshape(H,2,Length/2));
fid000{i}=fid00{i}(:,1)+1i*((fid00{i}(:,2)));
fid01{i}=fid000{i};

% fid01{i}=fid01{i}(1:512);

 Tempfid01=zeros([8192,1]);
 Tempfid01(1:length(fid01{i}))=fid01{i};
%  Tempfid01(1:256)=fid01{i}(1:256);
 fid01{i}=Tempfid01;
 Windows=hanning(length(fid01{1}));
sumfid= sumfid+fid01{i};
spe{i}=fftshift(fft(fid01{i}));
%figure;plot(abs(spe{i}))
end
% fid02=sumfid;
%  figure;plot(abs(fftshift(fft(fid02))))
%  SpecAll=[];
%  for i=1:size(spe,2)
%  SpecAll=cat(2,SpecAll,spe{i});
%  end

  fidAll=[];
  for i=1:size(fid01,2)
  fidAll=cat(2,fidAll,fid01{i});
  end

    SpecAll=[];
  for i=1:size(fid01,2)
  SpecAll=cat(2,SpecAll,spe{i});
  end

 imgNoiseVol=permute(SpecAll(:,1:32),[1,3,2]);
 RealimgNoiseVol=real(imgNoiseVol)/max(abs(imgNoiseVol(:)));
%  RealimgNoiseVol=real(imgNoiseVol);
 RealimgNoiseVol=repmat(RealimgNoiseVol,[1,32,1]);
 RealimgWaveletMultiframe = waveletMultiFrame(RealimgNoiseVol, 'k', 6, 'p',5, 'maxLevel', 4, 'weightMode', 4, 'basis', 'dualTree');
 
 ImgimgNoiseVol=imag(imgNoiseVol)/max(abs(imgNoiseVol(:)));
%  ImgimgNoiseVol=imag(imgNoiseVol);
 ImgimgNoiseVol=repmat(ImgimgNoiseVol,[1,32,1]);
 ImgimgWaveletMultiframe = waveletMultiFrame(ImgimgNoiseVol, 'k', 6, 'p', 5, 'maxLevel', 4, 'weightMode',4, 'basis', 'dualTree');
 
 Phase = RealimgWaveletMultiframe +1i*ImgimgWaveletMultiframe;
%  
%   imgNoiseVol=permute(SpecAll(:,1:16),[1,3,2]);
%  imgNoiseVol=abs(imgNoiseVol)/max(abs(imgNoiseVol(:)));
%  imgNoiseVol=repmat(imgNoiseVol,[1,64,1]);
%  imgWaveletMultiframe = waveletMultiFrame(imgNoiseVol, 'k', 6, 'p', 5, 'maxLevel', 5, 'weightMode', 4, 'basis', 'dualTree');
 
%   figure;
%  subplot(1,2,1);plot((abs(sum(imgWaveletMultiframe,2))));subplot(1,2,2);plot((abs(sum(abs(SpecAll),2))))
 


 
% FileStr={'1r' '1i'};
% DataCell={sum(RealimgWaveletMultiframe,2),sum(ImgimgWaveletMultiframe,2)};
% WritePath=['D:\NMRdata\400.3.2mm.20221116\9999\pdata\1\'];
% 
% for i=1:size(FileStr,2)
%     fileID = fopen([WritePath FileStr{i}],'w','l');
%    fwrite(fileID,round(round(DataCell{i}*10e12)/max(max(round(DataCell{i}*10e12)))*Max),'int32');
% %    fwrite(fileID,DataCell{i},'int32');
%     fclose(fileID);
% end
 
%  imgNoiseVol=abs(imgNoiseVol)/max(abs(imgNoiseVol(:)));
%  imgNoiseVol3D=repmat(imgNoiseVol,[1,16,1]);
%  imgWaveletMultiframe = waveletMultiFrame(imgNoiseVol3D, 'k',6, 'p', 5, 'maxLevel', 5, 'weightMode', 4, 'basis',  'dualTree');
%  figure;
%  subplot(1,3,1);plot(abs(sum(Phase,2)));subplot(1,3,2);plot((sum(abs(SpecAll),2)));subplot(1,3,3);plot((abs(sum(imgWaveletMultiframe,2))));
% speAll=fftshift(fft(sum(fidAll,2)));
% PhaseAll= fftshift(fft(sum(Phase,2)));
figure;
subplot(1,2,1);plot(abs(sum(Phase,2)));subplot(1,2,2);plot(abs(sum(SpecAll,2)));

% figure;
% subplot(1,2,1);plot(abs(PhaseAll));subplot(1,2,2);plot((abs(speAll)));