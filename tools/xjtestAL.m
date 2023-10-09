clc;clear; close all;
fidname{1}='E:\topspindata\data1\MIL53\976\pdata\1\1r';
fidname{2}='E:\topspindata\data1\MIL53\977\pdata\1\1r';
fidname{3}='E:\topspindata\data1\MIL53\978\pdata\1\1r';
fidname{4}='E:\topspindata\data1\MIL53\979\pdata\1\1r';
fidname{5}='E:\topspindata\data1\MIL53\980\pdata\1\1r';
fidname{6}='E:\topspindata\data1\MIL53\981\pdata\1\1r';
fidname{7}='E:\topspindata\data1\MIL53\982\pdata\1\1r';
fidname{8}='E:\topspindata\data1\MIL53\983\pdata\1\1r';
fidname{9}='E:\topspindata\data1\MIL53\984\pdata\1\1r';
fidname{10}='E:\topspindata\data1\MIL53\985\pdata\1\1r';
fidname{11}='E:\topspindata\data1\MIL53\986\pdata\1\1r';
fidname{12}='E:\topspindata\data1\MIL53\987\pdata\1\1r';
fidname{13}='E:\topspindata\data1\MIL53\988\pdata\1\1r';
fidname{14}='E:\topspindata\data1\MIL53\989\pdata\1\1r';
fidname{15}='E:\topspindata\data1\MIL53\990\pdata\1\1r';
fidname{16}='E:\topspindata\data1\MIL53\991\pdata\1\1r';

sumfid=0;
sumspe=0;
Max=10e8;
for i=1:size(fidname,2)
fid0{i}=fopen(fidname{i},'r','ieee-le');
fid01{i}=fread(fid0{i},'int32','ieee-le');
sumfid= sumfid+fid01{i};
%figure;plot(abs(spe{i}))
end
 fid02=sumfid;
 figure;plot((fid02));
 SpecAll=[];                               %创建空矩阵
 for i=1:size(fid01,2)                     %遍历变量spe中的每一个元素，将它们按列拼接，然后赋值给SpecAll
 SpecAll=cat(2,SpecAll,fid01{i});
 end
 %  figure;plot(SpecAll)
 imgNoiseVol=permute(SpecAll(:,1:16),[1,3,2]);                  %取SpecAll前16列，将结果垂直排列成一个矩阵，对这个矩阵进行维度转换，加个第二维和第三维进行交换，得到128*16*1的三维数组
 RealimgNoiseVol=real(imgNoiseVol)/max((imgNoiseVol(:)));    %取数组绝对值的最大值，然后用除法将所有元素归一化为[-1,1]的范围
 RealimgNoiseVol=repmat(RealimgNoiseVol,[1,256,1]);             %将数组扩展为128*128*16的三维数组，其中第二维和第三维大小与imgnosievol相同
 RealimgWaveletMultiframe = waveletMultiFrame(RealimgNoiseVol, 'k', 5, 'p',8,'windowsize',1, 'maxLevel', 5, 'weightMode', 4, 'basis', 'dualTree');  %小波去噪
 
% ImgimgNoiseVol=imag(imgNoiseVol)/max(abs(imgNoiseVol(:)));     %虚部，同上
% ImgimgNoiseVol=repmat(ImgimgNoiseVol,[1,128,1]);               
% ImgimgWaveletMultiframe = waveletMultiFrame(ImgimgNoiseVol, 'k', 4, 'p', 5, 'maxLevel', 5, 'weightMode',4, 'basis', 'dualTree');
% RealimgWaveletMultiframe=flip(RealimgWaveletMultiframe,1);     %将矩阵中每一行的顺序翻转
% ImgimgWaveletMultiframe=flip(ImgimgWaveletMultiframe,1);       %同上 
% Phase = RealimgWaveletMultiframe +1i*ImgimgWaveletMultiframe;  %组合成一个复数矩阵
 
 FileStr={'1r' };                                           %第一个矩阵，将phase矩阵沿第二个维度求和取绝对值
 DataCell0={(sum(RealimgWaveletMultiframe,2))};   %第二个矩阵，将ImgimgWaveletMultiframe沿第二个维度求和
 WritePath=['E:\topspindata\data1\MIL53\99991\pdata\1\'];
%WritePath=['D:\NMRdata\400.3.2mm.20221116\9999\pdata\1\'];

 for i=1:size(FileStr,2)                                        %写入文件
     fileID = fopen([WritePath FileStr{i}],'w','l');
   fwrite(fileID,round(round(DataCell0{i}*10e12)/max(max(round(DataCell0{i}*10e12)))*Max),'int32');
% %    fwrite(fileID,DataCell{i},'int32');
    fclose(fileID);
 end
 
figure;
subplot(1,2,1);plot((sum(RealimgWaveletMultiframe,2)));subplot(1,2,2);plot((sum((SpecAll),2)));
figure;plot((sum(RealimgWaveletMultiframe,2)), 'color', [0.5, 0, 0.5]);box off;axis off; 
figure;plot((sum((SpecAll),2)), 'color', [0, 0, 0]);box off;axis off; 
Original=(sum((SpecAll),2));


%WDMS+WT去噪
NMR_signalreal=(sum(RealimgWaveletMultiframe,2));
NMR_signal2Dreal=repmat(NMR_signalreal,[1,length(NMR_signalreal)]);
NMR_denoisedreal = wavDenoise(NMR_signal2Dreal,4.5);
NMR_denoised2 =NMR_denoisedreal;

figure;plot((real(NMR_denoised2(:,2))));legend('WDMS+WT'); 
DataCell1=((real(NMR_denoised2(:,2))));
   
WritePathplus= ['E:\topspindata\data1\MIL53\5555\pdata\1\'];
fileID = fopen([WritePathplus '1r'],'w','l');
fwrite(fileID,round(round(DataCell1*10e12)/max(max(round(DataCell1*10e12)))*Max),'int32');
fclose(fileID);
  
%WT去噪
NMR_signalreal=(Original);
NMR_signalreal=NMR_signalreal/max(NMR_signalreal);
NMR_signal2Dreal=repmat(NMR_signalreal,[1,length(NMR_signalreal)]);
NMR_denoisedreal = wavDenoise(NMR_signal2Dreal,4.5);

NMR_signal=Original;
NMR_denoised=NMR_denoisedreal;

figure;
subplot(1,2,1); plot(Original);legend('Original'); subplot(1,2,2); plot(real(NMR_denoised(:,1)));legend('Denoised');
figure;plot((NMR_signal));legend('Original');
figure;plot(real(NMR_denoised(:,1)));legend('WT');
%  FileStr={'1r' '1i'};
DataCell={real(NMR_denoised(:,1)),Original};
WritePath=['E:\topspindata\data1\MIL53\88881\pdata\1\'];
WritePathorigin= ['E:\topspindata\data1\MIL53\77771\pdata\1\'];
DataCell{1}=(DataCell{1});
DataCell{2}=(DataCell{2});

fileID = fopen([WritePath '1r'],'w','l');
fwrite(fileID,round(round(DataCell{1}*10e12)/max(max(round(DataCell{1}*10e12)))*Max),'int32');
fclose(fileID);
      
fileID2 = fopen([WritePathorigin '1r'],'w','l');
fwrite(fileID,round(round(DataCell{2}*10e12)/max(max(round(DataCell{2}*10e12)))*Max),'int32');
fclose(fileID);
  
      
%WDMS+WT2去噪
wname = 'db4';
WDMS=real((sum(RealimgWaveletMultiframe,2)));
[c,l] =wavedec(WDMS',4,'db4');% wavedec((real(fftshift(fft(fidNoiseSum)))),4,'db4');
thr = median(abs(c))/0.0018;
c_t = wthresh(c,'s',thr);
NMR_denoised3 = waverec(c_t,l,wname);  
    
figure;plot(real(NMR_denoised3), 'color', [0, 0, 1]);box off;axis off; 
DataCell2=(real(NMR_denoised3));
   
WritePathplus= ['E:\topspindata\data1\MIL53\55551\pdata\1\'];
fileID = fopen([WritePathplus '1r'],'w','l');
fwrite(fileID,round(round(DataCell2*10e12)/max(max(round(DataCell2*10e12)))*Max),'int32');
fclose(fileID);
   

%WT2去噪
[c,l] =wavedec(Original,4,'db4');
thr = median(abs(c))/0.0018;
c_t = wthresh(c,'s',thr);
NMR_denoisedWavelet = waverec(c_t,l,wname);
figure;plot(real(NMR_denoisedWavelet), 'color', [1, 0, 0]);box off;axis off; 
DataCell3=real(NMR_denoisedWavelet);
   
WritePathplus= ['E:\topspindata\data1\MIL53\55552\pdata\1\'];
fileID = fopen([WritePathplus '1r'],'w','l');
fwrite(fileID,round(round(DataCell3*10e12)/max(max(round(DataCell3*10e12)))*Max),'int32');
fclose(fileID);


%理想谱
filePath2 = 'E:\topspindata\data1\MIL53\2010\pdata\1\';
fileName2 = '1r';
fid2 = fopen(fullfile(filePath2, fileName2), 'r', 'ieee-le');
data2 = fread(fid2, 'int32', 'ieee-le');
fclose(fid2);
figure;plot(data2);
 %% ssim Compare
    %RawNoiseSpec=real(fftshift(fft(fidNoiseSum)));
    MultiFrameDenoiseSpec=((real(NMR_denoised2(:,2))));
    WaveDenoise=(real(NMR_denoised(:,1)));
    %SpecDenoiseCzdzow=real(SpecDenoiseCzdzow);
    MultiFrameDenoiseSpec1=(sum(RealimgWaveletMultiframe,2)); 
 
 
 disp('ssim Compare')
     SignalRegion=1:8192;
 
    %ssimRaw=ssim(RawNoiseSpec(SignalRegion)/max(RawNoiseSpec),real(Original(SignalRegion))/max(real(Original)));
    ssimMultiFrame=ssim(MultiFrameDenoiseSpec(SignalRegion)/max(MultiFrameDenoiseSpec),real(Original(SignalRegion))/max(real(Original)));
    ssimWaveDenoise=ssim(WaveDenoise(SignalRegion)/max(WaveDenoise),real(Original(SignalRegion))/max(real(Original)));
    %ssimCzdow=ssim(SpecDenoiseCzdzow(SignalRegion)'/max(SpecDenoiseCzdzow),real(IdealSpecdata(SignalRegion))/max(real(IdealSpecdata)));
    ssimMultiFrame1=ssim(MultiFrameDenoiseSpec1(SignalRegion)/max(MultiFrameDenoiseSpec1),real(Original(SignalRegion))/max(real(Original)));
    
    
    figure;plot(MultiFrameDenoiseSpec/max(MultiFrameDenoiseSpec),'r');hold on; plot(real(Original)/max(real(Original)),'g'); 
      plot(WaveDenoise/max(WaveDenoise),'k');
    %disp(['Original ssim=', num2str(ssimRaw)]);
    disp(['WDMS+WT denoise ssim=', num2str(ssimMultiFrame)]);
    disp(['WT ssim=', num2str(ssimWaveDenoise)]);
    %disp(['Czdow denoise ssim=', num2str(ssimCzdow)]);
    disp(['WDMS denoise ssim=', num2str(ssimMultiFrame1)]);
    
x = linspace(-1918.85,1918.85 , 8192);
figure;
plot(x, zeros(size(x)), 'visible', 'off');
axis([-1918.85 1918.85   -0.1 0.1]);
set(gca, 'YColor', 'none');


