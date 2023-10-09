clc;clear; close all;
fidname{1}='E:\topspindata\data1\400.3.2mm.20221116\2020\pdata\1\1r';
fidname{2}='E:\topspindata\data1\400.3.2mm.20221116\2021\pdata\1\1r';
fidname{3}='E:\topspindata\data1\400.3.2mm.20221116\2022\pdata\1\1r';
fidname{4}='E:\topspindata\data1\400.3.2mm.20221116\2023\pdata\1\1r';
%fidname{5}='E:\topspindata\data1\400.3.2mm.20221116\2024\pdata\1\1r';
%fidname{6}='E:\topspindata\data1\400.3.2mm.20221116\2025\pdata\1\1r';
%fidname{7}='E:\topspindata\data1\400.3.2mm.20221116\2026\pdata\1\1r';
%fidname{8}='E:\topspindata\data1\400.3.2mm.20221116\2027\pdata\1\1r';
%fidname{9}='E:\topspindata\data1\400.3.2mm.20221116\2028\pdata\1\1r';
%fidname{10}='E:\topspindata\data1\400.3.2mm.20221116\2029\pdata\1\1r';
%fidname{11}='E:\topspindata\data1\400.3.2mm.20221116\2030\pdata\1\1r';
%fidname{12}='E:\topspindata\data1\400.3.2mm.20221116\2031\pdata\1\1r';
%fidname{13}='E:\topspindata\data1\400.3.2mm.20221116\2032\pdata\1\1r';
%fidname{14}='E:\topspindata\data1\400.3.2mm.20221116\2033\pdata\1\1r';
%fidname{15}='E:\topspindata\data1\400.3.2mm.20221116\2034\pdata\1\1r';
%fidname{16}='E:\topspindata\data1\400.3.2mm.20221116\2035\pdata\1\1r';

sumfid=0;
Max=10e8;
for i=1:size(fidname,2)
fid0{i}=fopen(fidname{i},'r','ieee-le');
fid01{i}=fread(fid0{i},'int32','ieee-le');
% Tempfid01=zeros([8192,1]);                %创建一个8192*1的零矩阵
% Tempfid01(1:length(fid01{i}))=fid01{i};   %将fid01中的数据复制到Tempfid01中，剩下位置都填充0
% fid01{i}=Tempfid01;
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
 imgNoiseVol=permute(SpecAll(:,1:4),[1,3,2]);                  %取SpecAll前16列，将结果垂直排列成一个矩阵，对这个矩阵进行维度转换，加个第二维和第三维进行交换，得到128*16*1的三维数组
 RealimgNoiseVol=real(imgNoiseVol)/max(abs(imgNoiseVol(:)));    %取数组绝对值的最大值，然后用除法将所有元素归一化为[-1,1]的范围
 RealimgNoiseVol=repmat(RealimgNoiseVol,[1,128,1]);             %将数组扩展为128*128*16的三维数组，其中第二维和第三维大小与imgnosievol相同
 RealimgWaveletMultiframe = waveletMultiFrame(RealimgNoiseVol, 'k', 5, 'p',8,'windowsize',1, 'maxLevel', 5, 'weightMode', 4, 'basis', 'dualTree');  %小波去噪
 
% ImgimgNoiseVol=imag(imgNoiseVol)/max(abs(imgNoiseVol(:)));     %虚部，同上
% ImgimgNoiseVol=repmat(ImgimgNoiseVol,[1,128,1]);               
% ImgimgWaveletMultiframe = waveletMultiFrame(ImgimgNoiseVol, 'k', 4, 'p', 5, 'maxLevel', 5, 'weightMode',4, 'basis', 'dualTree');
% RealimgWaveletMultiframe=flip(RealimgWaveletMultiframe,1);     %将矩阵中每一行的顺序翻转
% ImgimgWaveletMultiframe=flip(ImgimgWaveletMultiframe,1);       %同上 
% Phase = RealimgWaveletMultiframe +1i*ImgimgWaveletMultiframe;  %组合成一个复数矩阵
 
 FileStr={'1r' };                                           %第一个矩阵，将phase矩阵沿第二个维度求和取绝对值
 DataCell0={(sum(RealimgWaveletMultiframe,2))};   %第二个矩阵，将ImgimgWaveletMultiframe沿第二个维度求和
 WritePath=['E:\topspindata\data1\400.3.2mm.20221116\99991\pdata\1\'];
%WritePath=['D:\NMRdata\400.3.2mm.20221116\9999\pdata\1\'];

 for i=1:size(FileStr,2)                                        %写入文件
     fileID = fopen([WritePath FileStr{i}],'w','l');
   fwrite(fileID,round(round(DataCell0{i}*10e12)/max(max(round(DataCell0{i}*10e12)))*Max),'int32');
% %    fwrite(fileID,DataCell{i},'int32');
    fclose(fileID);
 end
 
figure;
subplot(1,2,1);plot(abs(sum(RealimgWaveletMultiframe,2)));subplot(1,2,2);plot((sum(abs(SpecAll),2)));
figure;plot((sum(RealimgWaveletMultiframe,2)), 'color', [1, 0, 0]);box off;axis off; 
figure;plot((sum((SpecAll),2)), 'color', [0, 0, 0]);box off;axis off; 
Original=(sum(abs(SpecAll),2));


%WDMS+WT去噪
NMR_signalreal=abs(sum(RealimgWaveletMultiframe,2));
NMR_signal2Dreal=repmat(NMR_signalreal,[1,length(NMR_signalreal)]);
NMR_denoisedreal = wavDenoise(NMR_signal2Dreal,0.14);
NMR_denoised2 =NMR_denoisedreal;
   
figure;plot(abs(NMR_denoised2(:,1)));legend('WDMS+WT');    
DataCell1=(sum(abs(NMR_denoised2),2));
   
WritePathplus= ['E:\topspindata\data1\400.3.2mm.20221116\5555\pdata\1\'];
fileID = fopen([WritePathplus '1r'],'w','l');
fwrite(fileID,round(round(DataCell1*10e12)/max(max(round(DataCell1*10e12)))*Max),'int32');
fclose(fileID);
  
%WT去噪
NMR_signalreal=(sum(abs(SpecAll),2));
NMR_signalreal=NMR_signalreal/max(abs(sum(abs(SpecAll),2)));
NMR_signal2Dreal=repmat(NMR_signalreal,[1,length(NMR_signalreal)]);
NMR_denoisedreal = wavDenoise(NMR_signal2Dreal,0.14);

NMR_signal=abs(sum(abs(SpecAll),2));
NMR_denoised=NMR_denoisedreal;

figure;
subplot(1,2,1); plot(abs(NMR_signal));legend('Original'); subplot(1,2,2); plot(abs(NMR_denoised(:,1)));legend('Denoised');
figure;plot(abs(NMR_signal));legend('Original');
figure;plot(abs(NMR_denoised(:,1)));legend('WT');
%  FileStr={'1r' '1i'};
DataCell={sum(abs(NMR_denoised),2),sum(abs(NMR_signal),2)};
WritePath=['E:\topspindata\data1\400.3.2mm.20221116\88881\pdata\1\'];
WritePathorigin= ['E:\topspindata\data1\400.3.2mm.20221116\77771\pdata\1\'];
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
thr = median(abs(c))/0.075;
c_t = wthresh(c,'s',thr);
NMR_denoised = waverec(c_t,l,wname);  
    
figure;plot((real(NMR_denoised)), 'color', [0.5, 0, 0.5]);box off;axis off;  
DataCell2=(real(NMR_denoised));
   
WritePathplus= ['E:\topspindata\data1\400.3.2mm.20221116\55551\pdata\1\'];
fileID = fopen([WritePathplus '1r'],'w','l');
fwrite(fileID,round(round(DataCell2*10e12)/max(max(round(DataCell2*10e12)))*Max),'int32');
fclose(fileID);
   

%WT2去噪
[c,l] =wavedec(Original,4,'db4');
thr = median(abs(c))/0.026225;
c_t = wthresh(c,'s',thr);
NMR_denoisedWavelet = waverec(c_t,l,wname);
figure;plot(real(NMR_denoisedWavelet), 'color', [0, 0, 1]);box off;axis off; 
DataCell3=real(NMR_denoisedWavelet);
   
WritePathplus= ['E:\topspindata\data1\400.3.2mm.20221116\55552\pdata\1\'];
fileID = fopen([WritePathplus '1r'],'w','l');
fwrite(fileID,round(round(DataCell3*10e12)/max(max(round(DataCell3*10e12)))*Max),'int32');
fclose(fileID);