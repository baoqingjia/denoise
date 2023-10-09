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
end
Original=sumfid;          %16张谱叠加 8192*1
figure;plot(Original);legend('Original');

NMR_signalreal=Original;
NMR_signalreal=NMR_signalreal/max(abs(Original));
NMR_signal2Dreal=repmat(NMR_signalreal,[1,length(NMR_signalreal)]);
NMR_denoisedreal = wavDenoise(NMR_signal2Dreal,4.5);

NMR_denoised=real((NMR_denoisedreal(:,1)));
figure;plot(NMR_denoised);legend('WT');








