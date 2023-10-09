clc;clear; close all;
fidname{1}='D:\NMRdata\400.3.2mm.20221116\2014\fid';
fidname{2}='D:\NMRdata\400.3.2mm.20221116\2015\fid';
fidname{3}='D:\NMRdata\400.3.2mm.20221116\2016\fid';
fidname{4}='D:\NMRdata\400.3.2mm.20221116\2017\fid'
fidname{5}='D:\NMRdata\400.3.2mm.20221116\2018\fid';
fidname{6}='D:\NMRdata\400.3.2mm.20221116\2019\fid';
fidname{7}='D:\NMRdata\400.3.2mm.20221116\2020\fid';
fidname{8}='D:\NMRdata\400.3.2mm.20221116\2021\fid';
% fidname{9}='I:\topspindata\topspindata\400.3.2mm.20221116\2022\fid';
% fidname{10}='I:\topspindata\topspindata\400.3.2mm.20221116\2023\fid';
% fidname{11}='I:\topspindata\topspindata\400.3.2mm.20221116\2024\fid';
% fidname{12}='I:\topspindata\topspindata\400.3.2mm.20221116\2025\fid'
% fidname{13}='I:\topspindata\topspindata\400.3.2mm.20221116\2026\fid';
% fidname{14}='I:\topspindata\topspindata\400.3.2mm.20221116\2027\fid';
% fidname{15}='I:\topspindata\topspindata\400.3.2mm.20221116\2028\fid';
% fidname{16}='I:\topspindata\topspindata\400.3.2mm.20221116\2029\fid'
sumfid=0;
for i=1:size(fidname,2)
fid0{i}=fopen(fidname{i},'r','ieee-le');
[H,Length]=fread(fid0{i},'int32','ieee-le');
fid00{i}=transpose(reshape(H,2,Length/2));
fid000{i}=fid00{i}(:,1)+1i*((fid00{i}(:,2)));
fid01{i}=fid000{i};
sumfid= sumfid+fid01{i};
spe{i}=fftshift(fft(fid01{i}));
%figure;plot(abs(spe{i}))
end
fid02=sumfid;
 figure;plot(abs(fftshift(fft(fid02))))
 SpecAll=[];
 for i=1:size(spe,2)
 SpecAll=cat(2,SpecAll,spe{i});
 end
 
 imgNoiseVol=permute(SpecAll(:,1:8),[1,3,2]);
 RealimgNoiseVol=real(imgNoiseVol)/max(abs(imgNoiseVol(:)));
 RealimgNoiseVol=repmat(RealimgNoiseVol,[1,16,1]);
 RealimgWaveletMultiframe = waveletMultiFrame(RealimgNoiseVol, 'k', 6, 'p', 4, 'maxLevel', 3, 'weightMode', 4, 'basis', 'dualTree');
 
 ImgimgNoiseVol=imag(imgNoiseVol)/max(abs(imgNoiseVol(:)));
 ImgimgNoiseVol=repmat(ImgimgNoiseVol,[1,16,1]);
 ImgimgWaveletMultiframe = waveletMultiFrame(ImgimgNoiseVol, 'k', 6, 'p', 4, 'maxLevel', 3, 'weightMode', 4, 'basis', 'dualTree');
 
 Phase = RealimgWaveletMultiframe +1i*ImgimgWaveletMultiframe;
 
 
 imgNoiseVol=abs(imgNoiseVol)/max(abs(imgNoiseVol(:)));
 imgNoiseVol=repmat(imgNoiseVol,[1,16,1]);
 imgWaveletMultiframe = waveletMultiFrame(imgNoiseVol, 'k', 6, 'p', 4, 'maxLevel', 3, 'weightMode', 4, 'basis', 'dualTree');
 figure;
 subplot(1,3,1);plot(abs(sum(Phase,2)));subplot(1,3,2);plot((sum(abs(SpecAll),2)));subplot(1,3,3);plot((abs(sum(imgWaveletMultiframe,2))));