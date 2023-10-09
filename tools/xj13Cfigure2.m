clc;clear; close all;
fidname{1}='E:\topspindata\data1\400.3.2mm.20221116\2020\pdata\1\1r';
fidname{2}='E:\topspindata\data1\400.3.2mm.20221116\2021\pdata\1\1r';
fidname{3}='E:\topspindata\data1\400.3.2mm.20221116\2022\pdata\1\1r';
fidname{4}='E:\topspindata\data1\400.3.2mm.20221116\2023\pdata\1\1r';
fidname{5}='E:\topspindata\data1\400.3.2mm.20221116\2024\pdata\1\1r';
fidname{6}='E:\topspindata\data1\400.3.2mm.20221116\2025\pdata\1\1r';
fidname{7}='E:\topspindata\data1\400.3.2mm.20221116\2026\pdata\1\1r';
fidname{8}='E:\topspindata\data1\400.3.2mm.20221116\2027\pdata\1\1r';
fidname{9}='E:\topspindata\data1\400.3.2mm.20221116\2028\pdata\1\1r';
fidname{10}='E:\topspindata\data1\400.3.2mm.20221116\2029\pdata\1\1r';
fidname{11}='E:\topspindata\data1\400.3.2mm.20221116\2030\pdata\1\1r';
fidname{12}='E:\topspindata\data1\400.3.2mm.20221116\2031\pdata\1\1r';
fidname{13}='E:\topspindata\data1\400.3.2mm.20221116\2032\pdata\1\1r';
fidname{14}='E:\topspindata\data1\400.3.2mm.20221116\2033\pdata\1\1r';
fidname{15}='E:\topspindata\data1\400.3.2mm.20221116\2034\pdata\1\1r';
fidname{16}='E:\topspindata\data1\400.3.2mm.20221116\2035\pdata\1\1r';

sumfid=0;
Max=10e8;
for i=1:size(fidname,2)
fid0{i}=fopen(fidname{i},'r','ieee-le');
fid01{i}=fread(fid0{i},'int32','ieee-le');
sumfid= sumfid+fid01{i};
end
 fid02=sumfid;
 SpecAll=[];                               %创建空矩阵
 for i=1:size(fid01,2)                     %遍历变量spe中的每一个元素，将它们按列拼接，然后赋值给SpecAll
 SpecAll=cat(2,SpecAll,fid01{i});
 end
 %  figure;plot(SpecAll)
 imgNoiseVol=permute(SpecAll(:,1:16),[1,3,2]);                  %取SpecAll前16列，将结果垂直排列成一个矩阵，对这个矩阵进行维度转换，加个第二维和第三维进行交换，得到128*16*1的三维数组
 RealimgNoiseVol=real(imgNoiseVol)/max(abs(imgNoiseVol(:)));    %取数组绝对值的最大值，然后用除法将所有元素归一化为[-1,1]的范围
 RealimgNoiseVol=repmat(RealimgNoiseVol,[1,128,1]);             %将数组扩展为128*128*16的三维数组，其中第二维和第三维大小与imgnosievol相同
 RealimgWaveletMultiframe = waveletMultiFrame(RealimgNoiseVol, 'k', 5, 'p',8,'windowsize',1, 'maxLevel', 5, 'weightMode', 4, 'basis', 'dualTree');  %小波去噪

 FileStr={'1r' };                                           %第一个矩阵，将phase矩阵沿第二个维度求和取绝对值
 DataCell0={(sum(RealimgWaveletMultiframe,2))};   %第二个矩阵，将ImgimgWaveletMultiframe沿第二个维度求和
 WritePath=['E:\topspindata\data1\400.3.2mm.20221116\99991\pdata\1\'];
%WritePath=['D:\NMRdata\400.3.2mm.20221116\9999\pdata\1\'];

 for i=1:size(FileStr,2)                                        %写入文件
     fileID = fopen([WritePath FileStr{i}],'w','l');
   fwrite(fileID,round(round(DataCell0{i}*10e12)/max(max(round(DataCell0{i}*10e12)))*Max),'int32');
    fclose(fileID);
 end
 
%figure;subplot(1,2,1);plot(abs(sum(RealimgWaveletMultiframe,2)));subplot(1,2,2);plot((sum(abs(SpecAll),2)));
figure;plot((sum(RealimgWaveletMultiframe,2)), 'color', [1, 0, 0]);box off;axis off; 
figure;plot((sum((SpecAll),2)), 'color', [0, 0, 0]);box off;axis off; 
Original=sum((SpecAll),2);
WDMSdata=(sum(RealimgWaveletMultiframe,2));



WritePathorigin= ['E:\topspindata\data1\400.3.2mm.20221116\77771\pdata\1\'];
DataCell5=Original;
     
fileID2 = fopen([WritePathorigin '1r'],'w','l');
fwrite(fileID,round(round(DataCell5*10e12)/max(max(round(DataCell5*10e12)))*Max),'int32');
fclose(fileID);

%WDMS+WT2去噪
wname = 'db4';
WDMS=real((sum(RealimgWaveletMultiframe,2)));
[c,l] =wavedec(WDMS',4,'db4');
thr = median(abs(c))/0.06;
c_t = wthresh(c,'s',thr);
NMR_denoised = waverec(c_t,l,wname);  
    
figure;plot((real(NMR_denoised)), 'color', [0.5, 0, 0.5]);box off;axis off;  
DataCell2=(real(NMR_denoised));
   
WritePathplus= ['E:\topspindata\data1\400.3.2mm.20221116\55551\pdata\1\'];
fileID = fopen([WritePathplus '1r'],'w','l');
fwrite(fileID,round(round(DataCell2*10e12)/max(max(round(DataCell2*10e12)))*Max),'int32');
fclose(fileID);
   
WDMS_WT2=(real(NMR_denoised));

%理想谱
filePath2 = 'E:\topspindata\data1\400.3.2mm.20221116\2015\pdata\999\';
fileName2 = '1r';
fid2 = fopen(fullfile(filePath2, fileName2), 'r', 'ieee-le');
data2 = fread(fid2, 'int32', 'ieee-le');
fclose(fid2);
%figure;plot(data2, 'color', [0, 1, 0]);box off;axis off; 
figure;plot(data2);

%SSIM
    RawNoiseSpec=Original;
    MultiFrameDenoiseSpec1=WDMSdata; 
    MultiFrameDenoiseSpec2=WDMS_WT2'; 
    figure;plot(Original);
    figure;plot(WDMSdata);
    figure;plot(WDMS_WT2');
    
 disp('ssim Compare')
     SignalRegion=1:8192;
 
    ssimRaw=ssim(RawNoiseSpec(SignalRegion)/max(RawNoiseSpec),real(data2(SignalRegion))/max(real(data2)));
    
    ssimWDMS=ssim(MultiFrameDenoiseSpec1(SignalRegion)/max(MultiFrameDenoiseSpec1),real(data2(SignalRegion))/max(real(data2)));
    ssimMultiFrame2=ssim(MultiFrameDenoiseSpec2(SignalRegion)/max(MultiFrameDenoiseSpec2),real(data2(SignalRegion))/max(real(data2)));
    
    
    disp(['Original ssim=', num2str(ssimRaw)]);
    disp(['WDMS denoise ssim=', num2str(ssimWDMS)]);
    disp(['WDMS+WT2 denoise ssim=', num2str(ssimMultiFrame2)]);



