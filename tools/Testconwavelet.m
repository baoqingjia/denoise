clc;clear; close all;
% fidname{1}='I:\topspindata\topspindata\13C-poorSN\3040\fid';
% fidname{2}='I:\topspindata\topspindata\13C-poorSN\3041\fid';
% fidname{3}='I:\topspindata\topspindata\13C-poorSN\3042\fid';
% fidname{4}='I:\topspindata\topspindata\13C-poorSN\3043\fid'
% fidname{5}='I:\topspindata\topspindata\13C-poorSN\3044\fid';
% fidname{6}='I:\topspindata\topspindata\13C-poorSN\3045\fid';
% fidname{7}='I:\topspindata\topspindata\13C-poorSN\3046\fid';
% fidname{8}='I:\topspindata\topspindata\13C-poorSN\3047\fid';
% fidname{9}='I:\topspindata\topspindata\13C-poorSN\3048\fid';
% fidname{10}='I:\topspindata\topspindata\13C-poorSN\3049\fid';
% fidname{11}='I:\topspindata\topspindata\13C-poorSN\3050\fid';
% fidname{12}='I:\topspindata\topspindata\13C-poorSN\3051\fid';
% fidname{13}='I:\topspindata\topspindata\13C-poorSN\3052\fid';
% fidname{14}='I:\topspindata\topspindata\13C-poorSN\3053\fid';
% fidname{15}='I:\topspindata\topspindata\13C-poorSN\3054\fid';
% fidname{16}='I:\topspindata\topspindata\13C-poorSN\3055\fid';

fidname{1}='D:\topspin\data\400.3.2mm.20221116\2020\fid';
fidname{2}='D:\topspin\data\400.3.2mm.20221116\2021\fid';
fidname{3}='D:\topspin\data\400.3.2mm.20221116\2022\fid';
fidname{4}='D:\topspin\data\400.3.2mm.20221116\2023\fid';
fidname{5}='D:\topspin\data\400.3.2mm.20221116\2024\fid';
fidname{6}='D:\topspin\data\400.3.2mm.20221116\2025\fid';
fidname{7}='D:\topspin\data\400.3.2mm.20221116\2026\fid';
fidname{8}='D:\topspin\data\400.3.2mm.20221116\2027\fid';
fidname{9}='D:\topspin\data\400.3.2mm.20221116\2028\fid';
 fidname{10}='D:\topspin\data\400.3.2mm.20221116\2029\fid';
 fidname{11}='D:\topspin\data\400.3.2mm.20221116\2030\fid';
 fidname{12}='D:\topspin\data\400.3.2mm.20221116\2031\fid';
 fidname{13}='D:\topspin\data\400.3.2mm.20221116\2032\fid';
 fidname{14}='D:\topspin\data\400.3.2mm.20221116\2033\fid';
 fidname{15}='D:\topspin\data\400.3.2mm.20221116\2034\fid';
 fidname{16}='D:\topspin\data\400.3.2mm.20221116\2035\fid';
 %fidname{17}='D:\topspin\data\400.3.2mm.20221116\2036\fid';
%fidname{18}='D:\topspin\data\400.3.2mm.20221116\2037\fid';
%fidname{19}='D:\topspin\data\400.3.2mm.20221116\2038\fid';
%fidname{20}='D:\topspin\data\400.3.2mm.20221116\2039\fid'
%fidname{21}='D:\topspin\data\400.3.2mm.20221116\2040\fid';
%fidname{22}='D:\topspin\data\400.3.2mm.20221116\2041\fid';
%fidname{23}='D:\topspin\data\400.3.2mm.20221116\2042\fid';
%fidname{24}='D:\topspin\data\400.3.2mm.20221116\2043\fid';
%fidname{25}='D:\topspin\data\400.3.2mm.20221116\2044\fid';
%fidname{26}='D:\topspin\data\400.3.2mm.20221116\2045\fid';
%fidname{27}='D:\topspin\data\400.3.2mm.20221116\2046\fid';
%fidname{28}='D:\topspin\data\400.3.2mm.20221116\2047\fid';
%fidname{29}='D:\topspin\data\400.3.2mm.20221116\2048\fid';
%fidname{30}='D:\topspin\data\400.3.2mm.20221116\2049\fid';
%fidname{31}='D:\topspin\data\400.3.2mm.20221116\2050\fid';
%fidname{32}='D:\topspin\data\400.3.2mm.20221116\2051\fid';

%fidname{33}='D:\topspin\data\400.3.2mm.20221116\2052\fid';
%fidname{34}='D:\topspin\data\400.3.2mm.20221116\2053\fid';
%fidname{35}='D:\topspin\data\400.3.2mm.20221116\2054\fid';
%fidname{36}='D:\topspin\data\400.3.2mm.20221116\2055\fid'
%fidname{37}='D:\topspin\data\400.3.2mm.20221116\2056\fid';
%fidname{38}='D:\topspin\data\400.3.2mm.20221116\2057\fid';
%fidname{39}='D:\topspin\data\400.3.2mm.20221116\2058\fid';
%fidname{40}='D:\topspin\data\400.3.2mm.20221116\2059\fid';
%fidname{41}='D:\topspin\data\400.3.2mm.20221116\2060\fid';
%fidname{42}='D:\topspin\data\400.3.2mm.20221116\2061\fid';
%fidname{43}='D:\topspin\data\400.3.2mm.20221116\2062\fid';
%fidname{44}='D:\topspin\data\400.3.2mm.20221116\2063\fid';
%fidname{45}='D:\topspin\data\400.3.2mm.20221116\2064\fid';
%fidname{46}='D:\topspin\data\400.3.2mm.20221116\2065\fid';
%fidname{47}='D:\topspin\data\400.3.2mm.20221116\2066\fid';
%fidname{48}='D:\topspin\data\400.3.2mm.20221116\2067\fid';
% fidname{49}='D:\topspin\data\400.3.2mm.20221116\2068\fid';
%fidname{50}='D:\topspin\data\400.3.2mm.20221116\2069\fid';
%fidname{51}='D:\topspin\data\400.3.2mm.20221116\2070\fid';
%fidname{52}='D:\topspin\data\400.3.2mm.20221116\2071\fid'
%fidname{53}='D:\topspin\data\400.3.2mm.20221116\2072\fid';
%fidname{54}='D:\topspin\data\400.3.2mm.20221116\2073\fid';
%fidname{55}='D:\topspin\data\400.3.2mm.20221116\2074\fid';
%fidname{56}='D:\topspin\data\400.3.2mm.20221116\2075\fid';
%fidname{57}='D:\topspin\data\400.3.2mm.20221116\2076\fid';
%fidname{58}='D:\topspin\data\400.3.2mm.20221116\2077\fid';
%fidname{59}='D:\topspin\data\400.3.2mm.20221116\2078\fid';
%fidname{60}='D:\topspin\data\400.3.2mm.20221116\2079\fid';
%fidname{61}='D:\topspin\data\400.3.2mm.20221116\2080\fid';
%fidname{62}='D:\topspin\data\400.3.2mm.20221116\2081\fid';
%fidname{63}='D:\topspin\data\400.3.2mm.20221116\2082\fid';
%fidname{64}='D:\topspin\data\400.3.2mm.20221116\2083\fid';

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
 fid01{i}=Tempfid01;
sumfid= sumfid+fid01{i};
spe{i}=fftshift(fft(fid01{i}));
% figure;plot(abs(spe{i}))
sumspe=sumspe+spe{i};
end
% NMR_signal=abs(sumspe);
% NMR_signal=NMR_signal/max(NMR_signal);
% NMR_signal2D=repmat(NMR_signal,[1,length(NMR_signal)]);
% NMR_denoised = wavDenoise(NMR_signal2D,0.40);


NMR_signalreal=real(sumspe);
NMR_signalreal=NMR_signalreal/max(abs(sumspe));
NMR_signal2Dreal=repmat(NMR_signalreal,[1,length(NMR_signalreal)]);
NMR_denoisedreal = wavDenoise(NMR_signal2Dreal,0.42);


NMR_signalimag=imag(sumspe);
NMR_signalimag=NMR_signalimag/max(abs(sumspe));
NMR_signal2Dimag=repmat(NMR_signalimag,[1,length(NMR_signalimag)]);
NMR_denoisedimag = wavDenoise(NMR_signal2Dimag,0.42);

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
%figure;plot(abs(NMR_signal));legend('Original');
%figure;plot(abs(NMR_denoised(:,1)));legend('Denoised');
%  FileStr={'1r' '1i'};
 DataCell={sum(abs(NMR_denoised),2),sum(abs(NMR_signal),2)};
 WritePath=['D:\topspin\data\400.3.2mm.20221116\8888\pdata\1\'];
 WritePathorigin= ['D:\topspin\data\400.3.2mm.20221116\7777\pdata\1\'];
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
   
snr_value = snr((abs(NMR_denoised(:,1))),(abs(NMR_signal)));
disp(['SNR value: ', num2str(snr_value), ' dB']);