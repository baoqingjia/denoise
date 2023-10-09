clc;clear; close all;
% 指定文件路径和文件名
filePath = 'D:\topspin\data1\400.3.2mm.20221116\2020\pdata\1\';
fileName = '1r';

% 读取文件
fid = fopen(fullfile(filePath, fileName), 'r', 'ieee-le');
data = fread(fid, 'int32', 'ieee-le');
fclose(fid);

% 显示数据

% 指定文件路径和文件名
filePath2 = 'D:\topspin\data1\MIL53\2010\pdata\1\';
fileName2 = '1r';

% 读取文件
fid2 = fopen(fullfile(filePath2, fileName2), 'r', 'ieee-le');
data2 = fread(fid2, 'int32', 'ieee-le');
fclose(fid2);

figure;plot(data2);

snr_value = snr(data2,data);
disp(['SNR value: ', num2str(snr_value), ' dB']);




% 指定文件路径和文件名
filePath1 = 'D:\topspin\data\MIL53\976\';
fileName1 = 'fid';

% 读取文件
fid1 = fopen(fullfile(filePath1, fileName1), 'r', 'ieee-le');
data1 = fread(fid1, 'int32', 'ieee-le');
fclose(fid1);

% 调整数据格式
realData = data1(1:2:end);
imaginaryData = data1(2:2:end);
complexData = realData + 1i * imaginaryData;

% 显示数据
figure;plot(abs(complexData));
figure;plot(data1);
figure;plot(data2)

figure;
subplot(1,2,1);plot(data);subplot(1,2,2);plot(abs(complexData));


fidname='D:\topspin\data1\400.3.2mm.20221116\20201\fid';
sumfid=0;
Max=10e8;

fid0=fopen(fidname,'r','ieee-le');
[H,Length]=fread(fid0,'int32','ieee-le');
fid00=transpose(reshape(H,2,Length/2));
fid000=fid00(:,1)+1i*((fid00(:,2)));
fid01=fid000;

% Tempfid01=zeros([8192,1]);                %创建一个8192*1的零矩阵
% Tempfid01(1:length(fid01))=fid01;   %将fid01中的数据复制到Tempfid01中，剩下位置都填充0
% fid01=Tempfid01;

sumfid= sumfid+fid01;
spe=fftshift(fft(fid01));
figure;plot(abs(spe))

 fid02=sumfid;
  figure;plot(abs(fftshift(fft(fid02))))

figure;
subplot(1,2,1);plot(data);subplot(1,2,2);plot(abs(fftshift(fft(fid02))));
