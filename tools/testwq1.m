clc;clear; close all;
fidname{1}='D:\topspin\400.3.2mm.20221116\2014\fid';
fidname{2}='D:\topspin\400.3.2mm.20221116\2015\fid';
fidname{3}='D:\topspin\400.3.2mm.20221116\2016\fid';
fidname{4}='D:\topspin\400.3.2mm.20221116\2017\fid';
sumfid=0;
for i=1:size(fidname,2)                              %循环语句，i从1到fidname的列数即元素个数
fid0{i}=fopen(fidname{i},'r','ieee-le');             %打开指定文件，只读，little-endian字节序
[H,Length]=fread(fid0{i},'int32','ieee-le');         %读取数据，数据类型为32位整数，存储到H中，Length表示读取的数据数量
fid00{i}=transpose(reshape(H,2,Length/2));           %将一维的数据H按照列数为2，行数为Length/2进行重新排列，再进行转置操作。将结果保存到fid00的第i个元素中。         
fid000{i}=fid00{i}(:,1)+1i*((fid00{i}(:,2)));        %将fid00的第i个元素中的数据分离出来，第一列作为实部，第二列乘上虚数单位1i作为虚部，组成复数，并存储到fid000的第i个元素中。
fid01{i}=fid000{i};                                  %将fid000的第i个元素中的复数数据复制到fid01的第i个元素中。
sumfid= sumfid+fid01{i};                             %将fid01的第i个元素中的复数数据加到sumfid变量中，实现累加操作。

figure;plot(abs(fftshift(fft(fid01{i}))))            %对fid01中第i个元素进行fft变换，并将结果绘制成图形。fft函数计算FFT，fftshift将结果进行位移，abs函数计算FFT结果模值。
end
fid02=sumfid;                                        
 figure;plot(abs(fftshift(fft(fid02))))              
 SpecAll=cat(2,fid01{1},fid01{2},fid01{3},fid01{4}); %将fid01中的所有元素拼接成一个复合矩阵SpecAll。cat函数拼接多个矩阵，dim=2表示按列拼接，即将fid01中每个元素拼接成一个大的2xN矩阵。
 
 imgNoiseVol=permute(SpecAll(:,1:4),[1,3,2]);        %将SpecAll的前4个列拷贝到imgNoiseVol变量中，并通过permute函数将它们的维度转换为[数据点数, 1, 4]
 Realimg=real(imgNoiseVol);                          %计算imgNoiseVol的实部
 Realimg=abs(Realimg)/max(abs(Realimg(:)));          %对Realimg进行归一化，使得最大幅值等于1
 Realimg=repmat(Realimg,[1,16,1]);                   %使用repmat函数将Realimg在第二个维度上重复16次，即将其从[数据点数, 1, 4]扩展到[数据点数, 16, 4]
 RealimgWaveletMultiframe = waveletMultiFrame(Realimg, 'k', 6, 'p', 4, 'maxLevel', 3, 'weightMode', 4, 'basis', 'dualTree');
 %将Realimg用进行滤波和去噪。
 %'k', 6：选择Daubechies小波族中k=6的小波作为基函数。'p', 4：选择4个过采样点。'maxLevel', 3：指定最大分解级别为3。'weightMode', 4：选择使用基于最大似然估计的软阈值方法进行去噪。'basis', 'dualTree'：选择双树小波作为基。

 Imgimg=imag(imgNoiseVol);                           %同上，针对虚部图像
 Imgimg=Imgimg/max(abs(Imgimg(:)));
 Imgimg=repmat(Imgimg,[1,16,1]);
 ImgimgWaveletMultiframe = waveletMultiFrame(Realimg, 'k', 6, 'p', 4, 'maxLevel', 3, 'weightMode', 4, 'basis', 'dualTree');
% imgNoiseVol=abs(imgNoiseVol)/max(abs(imgNoiseVol(:)));
%  imgNoiseVol=repmat(imgNoiseVol,[1,16,1]);
%  imgWaveletMultiframe = waveletMultiFrame(imgNoiseVol, 'k', 6, 'p', 4, 'maxLevel', 3, 'weightMode', 4, 'basis', 'dualTree');
%Waveletfid=sum(imgWaveletMultiframe,2);
 Originalfid=sum(SpecAll,2);                                          %将SpecAll沿第二个维度求和，得到一个列向量。目的是将原始数据用一个单独的列向量表示，便于进一步处理。
 denoisefid=RealimgWaveletMultiframe+1i*ImgimgWaveletMultiframe;      %构造经小波多帧去噪后的复信号denoisefid。
 figure;   
subplot(1,2,1);plot((abs(sum(RealimgWaveletMultiframe,2))));subplot(1,2,2);plot((abs(sum(abs(SpecAll),2)))) 
%在一个 1x2 的网格中的第一个位置创建子图，然后绘制RealimgWaveletMultiframe的幅值。
%在同样的网格中的第二个位置创建子图，然后绘制原始数据SpecAll的幅值的总和的幅值。

figure;
subplot(1,2,1);plot(abs(fftshift(fft(sum(denoisefid,2)))));     %绘制denoisefid沿第二个维度求和、做傅里叶变换并移位后的幅值谱
subplot(1,2,2);plot(abs(fftshift(fft(Originalfid))));           %绘制Originalfid的傅里叶变换并移位后的幅值谱
