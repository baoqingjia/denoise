clc;clear; close all;
fidname{1}='E:\Qingjia_work\NewMatlabCode\matlabcode\CSI_simulate\CSI_simulate\PHIP_Dynamic_image\500.4mm.20220818\2002\fid';
fidname{2}='E:\Qingjia_work\NewMatlabCode\matlabcode\CSI_simulate\CSI_simulate\PHIP_Dynamic_image\500.4mm.20220818\2004\fid';
 fidname{3}='E:\Qingjia_work\NewMatlabCode\matlabcode\CSI_simulate\CSI_simulate\PHIP_Dynamic_image\500.4mm.20220818\2005\fid';
 fidname{4}='E:\Qingjia_work\NewMatlabCode\matlabcode\CSI_simulate\CSI_simulate\PHIP_Dynamic_image\500.4mm.20220818\2006\fid';
fidname{5}='E:\Qingjia_work\NewMatlabCode\matlabcode\CSI_simulate\CSI_simulate\PHIP_Dynamic_image\500.4mm.20220818\2007\fid';
fidname{6}='E:\Qingjia_work\NewMatlabCode\matlabcode\CSI_simulate\CSI_simulate\PHIP_Dynamic_image\500.4mm.20220818\2008\fid';
fidname{7}='E:\Qingjia_work\NewMatlabCode\matlabcode\CSI_simulate\CSI_simulate\PHIP_Dynamic_image\500.4mm.20220818\2009\fid';
fidname{8}='E:\Qingjia_work\NewMatlabCode\matlabcode\CSI_simulate\CSI_simulate\PHIP_Dynamic_image\500.4mm.20220818\2010\fid';

% fidname{9}='D:\NMRdata\400.3.2mm.20221116\2022\fid';
% fidname{10}='D:\NMRdata\400.3.2mm.20221116\2023\fid';
% fidname{11}='D:\NMRdata\400.3.2mm.20221116\2024\fid';
% fidname{12}='D:\NMRdata\400.3.2mm.20221116\2025\fid'
% fidname{13}='D:\NMRdata\400.3.2mm.20221116\2026\fid';
% fidname{14}='D:\NMRdata\400.3.2mm.20221116\2027\fid';
% fidname{15}='D:\NMRdata\400.3.2mm.20221116\2028\fid';
% fidname{16}='D:\NMRdata\400.3.2mm.20221116\2029\fid';

sumfid=0;
sumspe=0;
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
% figure;plot(abs(spe{i}))
sumspe=sumspe+spe{i};
end
NMR_signal=real(sumspe);
% Define wavelet function
wname = 'db4';

% Perform wavelet decomposition
[c,l] = wavedec(NMR_signal,4,'db4');

% Threshold the coefficients
thr = median(abs(c))/0.3745;
c_t = wthresh(c,'h',thr);

% Reconstruct the signal
NMR_denoised = waverec(c_t,l,wname);

% Plot original and denoised signals
% figure;
% plot(NMR_signal);
% hold on;
% plot(NMR_denoised,'LineWidth',1);
% legend('Original','Denoised');

% AA=denoise_spectrum(real(spe{i}),'db4');
figure;
subplot(1,2,1); plot(abs(NMR_signal));legend('Original'); subplot(1,2,2); plot(abs(NMR_denoised));legend('Denoised')


SpecAll=zeros([size(spe{1},1) size(spe,2)]);
for i=1:size(spe,2)
    SpecAll(:,i)=spe{i};
end

 imgNoiseVol=permute(SpecAll(:,1:8),[1,3,2]);
 imgNoiseVol=abs(imgNoiseVol)/max(abs(imgNoiseVol(:)));
 imgNoiseVol=repmat(imgNoiseVol,[1,16,1]);
 imgWaveletMultiframe = waveletMultiFrame(imgNoiseVol, 'k', 6, 'p', 4, 'maxLevel', 3, 'weightMode', 4, 'basis', 'dualTree');
 
 figure;
 subplot(1,2,1);plot((abs(sum(imgWaveletMultiframe,2))));subplot(1,2,2);plot((abs(sum(abs(SpecAll),2))))


