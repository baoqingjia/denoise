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

fidname{1}='E:\topspindata\data\400.3.2mm.20221116\3103\fid';
fidname{2}='E:\topspindata\data\400.3.2mm.20221116\3104\fid';
fidname{3}='E:\topspindata\data\400.3.2mm.20221116\3105\fid';
fidname{4}='E:\topspindata\data\400.3.2mm.20221116\3106\fid';
fidname{5}='E:\topspindata\data\400.3.2mm.20221116\3107\fid';
fidname{6}='E:\topspindata\data\400.3.2mm.20221116\3108\fid';
fidname{7}='E:\topspindata\data\400.3.2mm.20221116\3109\fid';
fidname{8}='E:\topspindata\data\400.3.2mm.20221116\3110\fid';
fidname{9}='E:\topspindata\data\400.3.2mm.20221116\3111\fid';
fidname{10}='E:\topspindata\data\400.3.2mm.20221116\3112\fid';
fidname{11}='E:\topspindata\data\400.3.2mm.20221116\3113\fid';
fidname{12}='E:\topspindata\data\400.3.2mm.20221116\3114\fid';
fidname{13}='E:\topspindata\data\400.3.2mm.20221116\3115\fid';
fidname{14}='E:\topspindata\data\400.3.2mm.20221116\3116\fid';
fidname{15}='E:\topspindata\data\400.3.2mm.20221116\3117\fid';
fidname{16}='E:\topspindata\data\400.3.2mm.20221116\3118\fid';


% 
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

 Tempfid01=zeros([8192,1]);                %创建一个8192*1的零矩阵
 Tempfid01(1:length(fid01{i}))=fid01{i};   %将fid01中的数据复制到Tempfid01中，剩下位置都填充0
 fid01{i}=Tempfid01;

sumfid= sumfid+fid01{i};
spe{i}=(fftshift(fft(fid01{i})));
%figure;plot(abs(spe{i}))
end
% fid02=sumfid;
%  figure;plot(abs(fftshift(fft(fid02))))
 SpecAll=[];                               %创建空矩阵
 for i=1:size(spe,2)                       %遍历变量spe中的每一个元素，将它们按列拼接，然后赋值给SpecAll
 SpecAll=cat(2,SpecAll,spe{i});
 end
 
 imgNoiseVol=permute(SpecAll(:,1:16),[1,3,2]);                  %取SpecAll前16列，将结果垂直排列成一个矩阵，对这个矩阵进行维度转换，加个第二维和第三维进行交换，得到128*16*1的三维数组
 RealimgNoiseVol=real(imgNoiseVol)/max(abs(imgNoiseVol(:)));    %取数组绝对值的最大值，然后用除法将所有元素归一化为[-1,1]的范围
 RealimgNoiseVol=repmat(RealimgNoiseVol,[1,128,1]);             %将数组扩展为128*128*16的三维数组，其中第二维和第三维大小与imgnosievol相同
 RealimgWaveletMultiframe = waveletMultiFrame(RealimgNoiseVol, 'k', 4, 'p',5, 'maxLevel', 5, 'weightMode', 4, 'basis', 'dualTree');  %小波去噪
 
 ImgimgNoiseVol=imag(imgNoiseVol)/max(abs(imgNoiseVol(:)));     %虚部，同上
 ImgimgNoiseVol=repmat(ImgimgNoiseVol,[1,128,1]);               
 ImgimgWaveletMultiframe = waveletMultiFrame(ImgimgNoiseVol, 'k', 4, 'p', 5, 'maxLevel', 5, 'weightMode',4, 'basis', 'dualTree');
 
 RealimgWaveletMultiframe=flip(RealimgWaveletMultiframe,1);     %将矩阵中每一行的顺序翻转
 ImgimgWaveletMultiframe=flip(ImgimgWaveletMultiframe,1);       %同上
 
 Phase = RealimgWaveletMultiframe +1i*ImgimgWaveletMultiframe;  %组合成一个复数矩阵
 
 FileStr={'1r' '1i'};                                           %第一个矩阵，将phase矩阵沿第二个维度求和取绝对值
 DataCell={abs(sum(Phase,2)),sum(ImgimgWaveletMultiframe,2)};   %第二个矩阵，将ImgimgWaveletMultiframe沿第二个维度求和
 WritePath=['E:\topspindata\data\400.3.2mm.20221116\3133\pdata\1\'];
%WritePath=['D:\NMRdata\400.3.2mm.20221116\9999\pdata\1\'];

 for i=1:size(FileStr,2)                                        %写入文件
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
figure;plot(abs(sum(Phase,2)), 'color', [0, 0, 1]);box off;axis off; 
zx=(abs(sum(Phase,2)))';
zx=zx(2391:5801);
figure;plot(zx, 'color', [0, 0, 1]);box off;axis off; 

SpecAll=flip(SpecAll,1);
figure;plot((sum(abs(SpecAll),2)), 'color', [1, 0, 0]);box off;axis off; 
zy=((sum(abs(SpecAll),2)))';
zy=zy(2391:5801);
figure;plot(zy, 'color', [1, 0, 0]);box off;axis off; 


%WDMS+WT
data=real(Phase) ;
dataCell = cell(1, 128);  % 创建一个单元格数组用于存储每一列数据
for col = 1:128
    columnData = data(:, col);
    dataCell{col} = columnData;
end
wname = 'db4';
denoisedMatrix = zeros(8192, 128);  % 存储去噪后的矩阵
for col = 1:128
    % 获取当前列的数据
    columnData = data(:, col);
    % 进行小波变换及去噪操作
    [c,l] = wavedec(columnData, 4, wname);
    thr = median(abs(c)) / 0.03;
    c_t = wthresh(c, 's', thr);
    denoisedData = waverec(c_t, l, wname);
    denoisedMatrix(:, col) = denoisedData;  % 将去噪后的数据存储到 denoisedMatrix 中
end
figure;plot(abs(sum(denoisedMatrix,2)), 'color', [0.5, 0, 0.5]);box off;axis off; 
zz=(abs(sum(denoisedMatrix,2)))';
zz=zz(2391:5801);
figure;plot(zz, 'color', [0.5, 0, 0.5]);box off;axis off; 
