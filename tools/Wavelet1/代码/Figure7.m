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
Max=10e8;
for i=1:size(fidname,2)
fid0{i}=fopen(fidname{i},'r','ieee-le');
fid01{i}=fread(fid0{i},'int32','ieee-le');
sumfid= sumfid+fid01{i};
end
Original=sumfid;          %16张谱叠加 8192*1
figure;plot(Original);legend('Original');

 SpecAll=[];
 for i=1:size(fid01,2)
 SpecAll=cat(2,SpecAll,fid01{i});
 end

%WDMS
imgNoiseVol=permute(SpecAll(:,1:16),[1,3,2]);
RealimgNoiseVol=real(imgNoiseVol)/max(abs(imgNoiseVol(:)));
RealimgNoiseVol=repmat(RealimgNoiseVol,[1,256,1]);
RealimgWaveletMultiframe = waveletMultiFrame(RealimgNoiseVol, 'k', 5, 'p',8,'windowsize',1, 'maxLevel', 5, 'weightMode', 4, 'basis', 'dualTree');
%RealimgWaveletMultiframe=flip(RealimgWaveletMultiframe,1);

figure;plot((sum(RealimgWaveletMultiframe,2)), 'color', [0, 0, 1]);box off;axis off; 
figure;plot((sum((SpecAll),2)), 'color', [0, 0, 0]);box off;axis off; 
WDMSdata=((sum(RealimgWaveletMultiframe,2)));

%WT
NMR_signalreal=Original;
NMR_signalreal=NMR_signalreal/max(abs(Original));
NMR_signal2Dreal=repmat(NMR_signalreal,[1,length(NMR_signalreal)]);
NMR_denoisedreal = wavDenoise(NMR_signal2Dreal,15);

NMR_denoised=real((NMR_denoisedreal(:,1)));
figure;plot(NMR_denoised);legend('WT');
WTdata=real((NMR_denoisedreal(:,1)));

%WDMS+WT
NMR_signalreal=WDMSdata;
NMR_signalreal=NMR_signalreal/max(WDMSdata);
NMR_signal2Dreal=repmat(NMR_signalreal,[1,length(NMR_signalreal)]);
NMR_denoisedreal = wavDenoise(NMR_signal2Dreal,15);

NMR_denoised=real((NMR_denoisedreal(:,1)));
figure;plot(NMR_denoised);legend('WDMS+WT');
WDMS_WT=real((NMR_denoisedreal(:,1)));

%WT2
wname = 'db4';
[c,l] =wavedec(Original,4,'db4');
thr = median(abs(c))/0.0018;
c_t = wthresh(c,'s',thr);
NMR_denoisedWavelet = waverec(c_t,l,wname);
figure;plot(real(NMR_denoisedWavelet), 'color', [1, 0, 0]);box off;axis off; 
WT2data=(real(NMR_denoisedWavelet));

%WDMS+WT2
wname = 'db4';
[c,l] =wavedec(WDMSdata,4,'db4');
thr = median(abs(c))/0.0018;
c_t = wthresh(c,'s',thr);
NMR_denoisedWavelet = waverec(c_t,l,wname);
figure;plot(real(NMR_denoisedWavelet), 'color', [0.5, 0, 0.5]);box off;axis off; 
WDMS_WT2=(real(NMR_denoisedWavelet));

%理想谱
filePath2 = 'E:\topspindata\data1\MIL53\2010\pdata\1\';
fileName2 = '1r';
fid2 = fopen(fullfile(filePath2, fileName2), 'r', 'ieee-le');
data2 = fread(fid2, 'int32', 'ieee-le');
fclose(fid2);
figure;plot(data2, 'color', [0, 1, 0]);box off;axis off; 

%% ssim Compare
    RawNoiseSpec=Original;
    MultiFrameDenoiseSpec=WDMS_WT;
    WaveDenoise=WTdata;
    MultiFrameDenoiseSpec1=WDMSdata; 
    MultiFrameDenoiseSpec2=WDMS_WT2;
    WaveDenoise2=WT2data;
 
 
 disp('ssim Compare')
     SignalRegion=1:8192;
 
    ssimRaw=ssim(RawNoiseSpec(SignalRegion)/max(RawNoiseSpec),real(data2(SignalRegion))/max(real(data2)));
    ssimMultiFrame=ssim(MultiFrameDenoiseSpec(SignalRegion)/max(MultiFrameDenoiseSpec),real(data2(SignalRegion))/max(real(data2)));
    ssimWaveDenoise=ssim(WaveDenoise(SignalRegion)/max(WaveDenoise),real(data2(SignalRegion))/max(real(data2)));
    ssimWDMS=ssim(MultiFrameDenoiseSpec1(SignalRegion)/max(MultiFrameDenoiseSpec1),real(data2(SignalRegion))/max(real(data2)));
    ssimMultiFrame2=ssim(MultiFrameDenoiseSpec2(SignalRegion)/max(MultiFrameDenoiseSpec2),real(data2(SignalRegion))/max(real(data2)));
    ssimWaveDenoise2=ssim(WaveDenoise2(SignalRegion)/max(WaveDenoise2),real(data2(SignalRegion))/max(real(data2)));
    
    
    
    %figure;plot(MultiFrameDenoiseSpec/max(MultiFrameDenoiseSpec),'r');hold on; plot(real(Original)/max(real(Original)),'g'); plot(WaveDenoise/max(WaveDenoise),'k');
    disp(['Original ssim=', num2str(ssimRaw)]);
    disp(['WDMS+WT denoise ssim=', num2str(ssimMultiFrame)]);
    disp(['WT ssim=', num2str(ssimWaveDenoise)]);
    disp(['WDMS denoise ssim=', num2str(ssimWDMS)]);
    disp(['WDMS+WT2 denoise ssim=', num2str(ssimMultiFrame2)]);
    disp(['WT2 ssim=', num2str(ssimWaveDenoise2)]);
