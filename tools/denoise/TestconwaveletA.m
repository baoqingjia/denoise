clc;clear; close all;
fidname{1}='E:\Qingjia_work\27Al-poorSN\3040\fid';
fidname{2}='E:\Qingjia_work\27Al-poorSN\3041\fid';
fidname{3}='E:\Qingjia_work\27Al-poorSN\3042\fid';
fidname{4}='E:\Qingjia_work\27Al-poorSN\3043\fid'
fidname{5}='E:\Qingjia_work\27Al-poorSN\3044\fid';
fidname{6}='E:\Qingjia_work\27Al-poorSN\3045\fid';
fidname{7}='E:\Qingjia_work\27Al-poorSN\3046\fid';
fidname{8}='E:\Qingjia_work\27Al-poorSN\3047\fid';
 fidname{9}='E:\Qingjia_work\27Al-poorSN\3048\fid';
 fidname{10}='E:\Qingjia_work\27Al-poorSN\3049\fid';
 fidname{11}='E:\Qingjia_work\27Al-poorSN\3050\fid';
 fidname{12}='E:\Qingjia_work\27Al-poorSN\3051\fid';
 fidname{13}='E:\Qingjia_work\27Al-poorSN\3052\fid';
 fidname{14}='E:\Qingjia_work\27Al-poorSN\3053\fid';
 fidname{15}='E:\Qingjia_work\27Al-poorSN\3054\fid';
 fidname{16}='E:\Qingjia_work\27Al-poorSN\3055\fid';
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
%  Tempfid01=Tempfid01-mean(Tempfid01(1:end));
 fid01{i}=Tempfid01;
sumfid= sumfid+fid01{i};
spe{i}=fftshift(fft(fid01{i}));
% figure;plot(abs(spe{i}))
sumspe=sumspe+spe{i};
end

figure;
for i=1:size(fidname,2)
    plot(abs(spe{i}));hold on;
end

% sumfid=sumfid-mean(sumfid(end-64:end));
figure;plot(abs(fftshift(fft(sumfid))))
NMR_signal=abs(sumspe);
NMR_signal=NMR_signal/max(NMR_signal);
NMR_signal2D=repmat(NMR_signal,[1,length(NMR_signal)]);
NMR_denoised = wavDenoise(NMR_signal2D,0.3);

% % Define wavelet function
% wname = 'db4';
% 
% % Perform wavelet decomposition
% [c,l] = wavedec(NMR_signal,4,'db4');
% 
% % Threshold the coefficients
% thr = median(abs(c))/0.3;
% c_t = wthresh(c,'h',thr);
% 
% % Reconstruct the signal
% NMR_denoised = waverec(c_t,l,wname);
% 
% % Plot original and denoised signals
% % figure;
% % plot(NMR_signal);
% % hold on;
% % plot(NMR_denoised,'LineWidth',1);
% % legend('Original','Denoised');
% 
% AA=denoise_spectrum(real(spe{i}),'db4');
figure;
subplot(1,2,1); plot(abs(NMR_signal));legend('Original'); subplot(1,2,2); plot(abs(NMR_denoised(:,1)));legend('Denoised');
%  FileStr={'1r' '1i'};
 DataCell={sum(abs(NMR_denoised),2),sum(abs(NMR_signal),2)};
 WritePath=['E:\Qingjia_work\27Al-poorSN\8888\pdata\1\'];
 WritePathorigin=['E:\Qingjia_work\27Al-poorSN\7777\pdata\1\'];
DataCell{1}=flipud(DataCell{1});
DataCell{2}=flipud(DataCell{2});
%  for i=1:size(FileStr,2)
     fileID = fopen([WritePath '1r'],'w','l');
   fwrite(fileID,round(round(DataCell{1}*10e12)/max(max(round(DataCell{1}*10e12)))*Max),'int32');
% %    fwrite(fileID,DataCell{i},'int32');
    fclose(fileID);
%  end
   fileID2 = fopen([WritePathorigin '1r'],'w','l');
   fwrite(fileID,round(round(DataCell{2}*10e12)/max(max(round(DataCell{2}*10e12)))*Max),'int32');
   fclose(fileID);