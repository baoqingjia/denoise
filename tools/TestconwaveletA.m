clc;clear; close all;
% fidname{1}='I:\topspindata\topspindata\27Al-poorSN\3040\fid';
% fidname{2}='I:\topspindata\topspindata\27Al-poorSN\3041\fid';
% fidname{3}='I:\topspindata\topspindata\27Al-poorSN\3042\fid';
% fidname{4}='I:\topspindata\topspindata\27Al-poorSN\3043\fid'
% fidname{5}='I:\topspindata\topspindata\27Al-poorSN\3044\fid';
% fidname{6}='I:\topspindata\topspindata\27Al-poorSN\3045\fid';
% fidname{7}='I:\topspindata\topspindata\27Al-poorSN\3046\fid';
% fidname{8}='I:\topspindata\topspindata\27Al-poorSN\3047\fid';
%  fidname{9}='I:\topspindata\topspindata\27Al-poorSN\3048\fid';
%  fidname{10}='I:\topspindata\topspindata\27Al-poorSN\3049\fid';
%  fidname{11}='I:\topspindata\topspindata\27Al-poorSN\3050\fid';
%  fidname{12}='I:\topspindata\topspindata\27Al-poorSN\3051\fid';
%  fidname{13}='I:\topspindata\topspindata\27Al-poorSN\3052\fid';
%  fidname{14}='I:\topspindata\topspindata\27Al-poorSN\3053\fid';
%  fidname{15}='I:\topspindata\topspindata\27Al-poorSN\3054\fid';
%  fidname{16}='I:\topspindata\topspindata\27Al-poorSN\3055\fid';
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

% fidname{1}='I:\topspindata\topspindata\MIL53\999\fid';
% fidname{2}='I:\topspindata\topspindata\MIL53\998\fid';
% fidname{3}='I:\topspindata\topspindata\MIL53\997\fid';
% fidname{4}='I:\topspindata\topspindata\MIL53\996\fid';
% fidname{5}='I:\topspindata\topspindata\MIL53\995\fid';
% fidname{6}='I:\topspindata\topspindata\MIL53\994\fid';
% fidname{7}='I:\topspindata\topspindata\MIL53\993\fid';
% fidname{8}='I:\topspindata\topspindata\MIL53\992\fid';
fidname{9}='E:\topspindata\data\MIL53\991\fid';
fidname{10}='E:\topspindata\data\MIL53\990\fid';
fidname{11}='E:\topspindata\data\MIL53\989\fid';
fidname{12}='E:\topspindata\data\MIL53\988\fid';
fidname{13}='E:\topspindata\data\MIL53\987\fid';
fidname{14}='E:\topspindata\data\MIL53\986\fid';
fidname{15}='E:\topspindata\data\MIL53\985\fid';
fidname{16}='E:\topspindata\data\MIL53\984\fid';
% fidname{17}='I:\topspindata\topspindata\MIL53\983\fid';
% fidname{18}='I:\topspindata\topspindata\MIL53\982\fid';
% fidname{19}='I:\topspindata\topspindata\MIL53\981\fid';
% fidname{20}='I:\topspindata\topspindata\MIL53\980\fid';
% fidname{21}='I:\topspindata\topspindata\MIL53\979\fid';
% fidname{22}='I:\topspindata\topspindata\MIL53\978\fid';
% fidname{23}='I:\topspindata\topspindata\MIL53\977\fid';
% fidname{24}='I:\topspindata\topspindata\MIL53\976\fid';
% fidname{25}='I:\topspindata\topspindata\MIL53\975\fid';
% fidname{26}='I:\topspindata\topspindata\MIL53\974\fid';
% fidname{27}='I:\topspindata\topspindata\MIL53\973\fid';
% fidname{28}='I:\topspindata\topspindata\MIL53\972\fid';
% fidname{29}='I:\topspindata\topspindata\MIL53\971\fid';
% fidname{30}='I:\topspindata\topspindata\MIL53\970\fid';
% fidname{31}='I:\topspindata\topspindata\MIL53\969\fid';
% fidname{32}='I:\topspindata\topspindata\MIL53\968\fid';


fidname{1}='E:\topspindata\data\MIL53\983\fid';
fidname{2}='E:\topspindata\data\MIL53\982\fid';
fidname{3}='E:\topspindata\data\MIL53\981\fid';
fidname{4}='E:\topspindata\data\MIL53\980\fid';
fidname{5}='E:\topspindata\data\MIL53\979\fid';
fidname{6}='E:\topspindata\data\MIL53\978\fid';
fidname{7}='E:\topspindata\data\MIL53\977\fid';
fidname{8}='E:\topspindata\data\MIL53\976\fid';
% fidname{9}='I:\topspindata\topspindata\MIL53\975\fid';
% fidname{10}='I:\topspindata\topspindata\MIL53\974\fid';
% fidname{11}='I:\topspindata\topspindata\MIL53\973\fid';
% fidname{12}='I:\topspindata\topspindata\MIL53\972\fid';
% fidname{13}='I:\topspindata\topspindata\MIL53\971\fid';
% fidname{14}='I:\topspindata\topspindata\MIL53\970\fid';
% fidname{15}='I:\topspindata\topspindata\MIL53\969\fid';
% fidname{16}='I:\topspindata\topspindata\MIL53\968\fid';


sumfid=0;
sumspe=0;
Max=10e8;
% for i=1:size(fidname,2)
% fid0{i}=fopen(fidname{i},'r','ieee-le');
% [H,Length]=fread(fid0{i},'int32','ieee-le');
% fid00{i}=transpose(reshape(H,2,Length/2));
% fid000{i}=fid00{i}(:,1)+1i*((fid00{i}(:,2)));
% fid01{i}=fid000{i};
% 
%  Tempfid01=zeros([8192,1]);
%  Tempfid01(1:length(fid01{i}))=fid01{i};
%  fid01{i}=Tempfid01;
% sumfid= sumfid+fid01{i};
% spe{i}=fftshift(fft(fid01{i}));
% % figure;plot(abs(spe{i}))
% sumspe=sumspe+spe{i};
% end

for i=1:size(fidname,2)
fid0{i}=fopen(fidname{i},'r','ieee-le');
[H,Length]=fread(fid0{i},'int32','ieee-le');
fid00{i}=transpose(reshape(H,2,Length/2));
fid000{i}=fid00{i}(:,1)+1i*((fid00{i}(:,2)));
fid01{i}=fid000{i};

 Tempfid01=zeros([8192,1]);
Tempfid01(1:length(fid01{i}))=fid01{i};
Tempfidorigin=Tempfid01;
Sw1=4096;
nD2=length(Tempfid01);
t=exp(-[0:1/Sw1:(nD2-1)/Sw1]*pi*3);
Tempfid01=Tempfid01.*t.';

 fid01{i}=Tempfid01;
sumfid= sumfid+fid01{i};
spe{i}=fftshift(fft(fid01{i}));
% figure;plot(abs(spe{i}))
sumspe=sumspe+spe{i};
end

% figure; plot(abs(Tempfidorigin));
% figure; plot(abs(Tempfid01));


NMR_signal=abs(sumspe);
NMR_signal=NMR_signal/max(NMR_signal);
NMR_signal2D=repmat(NMR_signal,[1,length(NMR_signal)]);  %8192*1复制成8192*8192



NMR_signalreal=real(sumspe);
NMR_signalreal=NMR_signalreal/max(abs(sumspe));
NMR_signal2Dreal=repmat(NMR_signalreal,[1,length(NMR_signalreal)]);
NMR_denoisedreal = wavDenoise(NMR_signal2Dreal,4.5);


NMR_signalimag=imag(sumspe);
NMR_signalimag=NMR_signalimag/max(abs(sumspe));
NMR_signal2Dimag=repmat(NMR_signalimag,[1,length(NMR_signalimag)]);
NMR_denoisedimag = wavDenoise(NMR_signal2Dimag,4.5);

NMR_signal=abs(sumspe);
NMR_denoised=NMR_denoisedreal+1i*NMR_denoisedimag;

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
 WritePath=['E:\topspindata\data\MIL53\8888\pdata\1\'];
 WritePathorigin=['E:\topspindata\data\MIL53\7777\pdata\1\'];
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
figure;plot(abs(NMR_signal));legend('Original');
figure;plot(abs(NMR_denoised(:,1)));legend('WT');