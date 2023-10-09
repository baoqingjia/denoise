clc; clear; close all;
% sw=10000;% unit Hz
sw_range=[7200,8400,9000,10000,11000,12000];
% sw=10000;% unit Hz
np=4*1024;
Maxnoiselevel=1; % 0~0.05 due to noise
Maxpointdistorion=0;% 0~10 due to baseline distortion  interger
Maxdistorionlever=0;% due to baseline distortion
MaxdelayControl=0;% [0 ~ 4]due to 1st phase
EdgeNoise=500; %unit Hz 0:20 & sw-20:sw is noise no peak

fidname{1}='D:\topspin\data\400.3.2mm.20221116\3104\fid';
Max=10e8;
sumFid=0;
for i=1:size(fidname,2)
    fid0=fopen(fidname{i},'r','ieee-le');
    [H,Length]=fread(fid0,'int32','ieee-le');
    fid00=transpose(reshape(H,2,Length/2));
    fid000=fid00(:,1)+1i*((fid00(:,2)));
    fid01=fid000;
    OneEchoPoint=212;
    GuessTotalPoiint=OneEchoPoint*18;
    fid01=fid01(70:GuessTotalPoiint);
    sumFid=sumFid+fid01;
end
fid01=sumFid;
    figure;plot(abs(fftshift(fft(fid01))))
    Windows=hamming(OneEchoPoint);
    fid01Guess=cat(1,fid01,zeros(GuessTotalPoiint-length(fid01),1));
    fidReshape=reshape(fid01Guess,[OneEchoPoint, GuessTotalPoiint/OneEchoPoint]);
   % figure;plot(abs(fidReshape))
  for  i=1:size(fidReshape,2)
     fidReshape(:,i)=fidReshape(:,i)%.*Windows;  
  %   figure;plot(real(fidReshape(:,i)));
  end
 ZeroFill=512;
    AllFidZeroFill=zeros(ZeroFill,size(fidReshape,2));
    AllFidZeroFill((ZeroFill-OneEchoPoint)/2+1:(ZeroFill-OneEchoPoint)/2+OneEchoPoint,:)=fidReshape;
    AllFidZeroFill((ZeroFill-OneEchoPoint)/2+1:(ZeroFill-OneEchoPoint)/2+OneEchoPoint,:)=fidReshape;
   
    SpecAll=fftshift(fft((AllFidZeroFill),[],1),1);
    figure;plot(abs(SpecAll(:,1)))
idealFid=(abs(sum(abs(SpecAll),2)));
%filePath = 'D:\topspin\data1\400.3.2mm.20221116\3104\pdata\1\';
%fileName = '1r';
%fid = fopen(fullfile(filePath, fileName), 'r', 'ieee-le');
%idealFid= fread(fid, 'int32', 'ieee-le');

IdealSpecdata=idealFid';
figure;plot(abs(IdealSpecdata));
%IdealSpecdata=IdealSpecdata(3600-62:4500+61);
%IdealSpecdata=IdealSpecdata(1976-62:3900+61);
figure;plot(real(IdealSpecdata));

IdealFidData = ifft(ifftshift(IdealSpecdata));

Specdata1=fftshift(fft(IdealFidData));

noiseLevel=[   0.15 0.1 0.05 ];

FreqScale=linspace(-125000,125000,length(IdealSpecdata)); %作为x轴输入数据


NoiseSpec=32;
for k=1:length(noiseLevel)

  
    fidNoiseAll=zeros(NoiseSpec,length(IdealFidData));
    for iNoiseSpec=1:NoiseSpec
        fidNoiseAll(iNoiseSpec,:)=IdealFidData+noiseLevel(k)*max(abs(IdealFidData))*((rand(size(IdealFidData))-0.5)+1i*(rand(size(IdealFidData))-0.5));
    end
    
    
    SpecNoiseAll=fftshift(fft(fidNoiseAll,[],2));%去尾部的疑问数据
    
    figure;plot(FreqScale,real(sum(SpecNoiseAll,1)/NoiseSpec),'r',FreqScale,real(IdealSpecdata),'b');
    figure;subplot(1,2,1);plot(FreqScale,real(SpecNoiseAll)); %ylim([-10,max(real(idealSpec(:)))])
    subplot(1,2,2);plot(FreqScale,real(IdealSpecdata)); % ylim([-10,max(real(idealSpec(:)))])
    
    
    %cadzow去噪
    fidNoiseSum=sum(fidNoiseAll,1)/NoiseSpec;
    [yOut] = cadzow(fidNoiseSum, 15, 200);
    SpecDenoiseCzdzow=fftshift(fft(yOut));
    
    figure;
    subplot(1,3,1);plot(FreqScale,real(fftshift(fft(fidNoiseSum)))); %ylim([-10,max(real(idealSpec(:)))]) %带噪声谱
    subplot(1,3,2);plot(FreqScale,real(SpecDenoiseCzdzow)); % ylim([-10,max(real(idealSpec(:)))])         %cadzow去噪
    subplot(1,3,3);plot(FreqScale,real(IdealSpecdata)); % ylim([-10,max(real(idealSpec(:)))])             %理想初始谱
    
    %WDMS去噪
    SpecNoiseT = SpecNoiseAll';
    imgNoiseVol = permute(SpecNoiseT(:,1:32),[1,3,2]);
    imgNoiseVol = real(imgNoiseVol)/max(real(SpecNoiseT(:)));
    imgNoiseVol = repmat(imgNoiseVol,[1,64,1]);
    imgWaveletMultiframe = waveletMultiFrame(imgNoiseVol, 'k', 6, 'p', 5, 'windowSize',4,'maxLevel', 4, 'weightMode', 2, 'basis', 'dualTree','theta1');
    imgWaveletMultiframe=imgWaveletMultiframe*max(real(SpecNoiseT(:)))/32;
     figure;subplot(1,2,1);plot(sum(imgWaveletMultiframe,2));subplot(1,2,2);plot(real(fftshift(fft(fidNoiseSum))))
    
%     imgWaveletMultiframe = waveletMultiFrameBao(imgNoiseVol, 'k', 6, 'p', 8, 'maxLevel', 3, 'weightMode', 4, 'basis', 'dualTree');
%     imgWaveletMultiframe=imgWaveletMultiframe*max(real(SpecNoiseT(:)));

      
%     figure;
%     subplot(2,2,1);plot((real(sum(imgWaveletMultiframeBao,2)))/32);subplot(2,2,2);plot((real(fftshift(fft(fidNoiseSum)))));
%     subplot(2,2,3);plot(real(IdealSpecdata));subplot(2,2,4);plot(real(SpecDenoiseCzdzow));
    
%     figure;
%     subplot(2,2,1);plot((real(sum(imgWaveletMultiframeBao,2)))/32);subplot(2,2,2);plot(real(sum(imgWaveletMultiframe,2))/32);
%     subplot(2,2,3);plot(real(IdealSpecdata));subplot(2,2,4);plot(real(SpecDenoiseCzdzow));

    %WDMS+WT去噪
    wname = 'db4';
    % Perform wavelet decomposition
    [c,l] =wavedec(real(sum(imgWaveletMultiframe,2))',4,'db4');% wavedec((real(fftshift(fft(fidNoiseSum)))),4,'db4');
    % Threshold the coefficients
    thr = median(abs(c))/0.05;
    c_t = wthresh(c,'s',thr);
    % Reconstruct the signal
    NMR_denoised = waverec(c_t,l,wname);    
   
    
 
%      [finalMultiDenoise, coeffin, coeffs] = WaveletDenoise1D_FromPython(3, real(sum(imgWaveletMultiframe,2))', 0, 'db4', 'mod', 0);
    % AA=denoise_spectrum(real(spe{i}),'db4');
    
    %WT去噪
    [c,l] =wavedec((real(fftshift(fft(fidNoiseSum)))),4,'db4');
    % Threshold the coefficients
    thr = median(abs(c))/.3;
    c_t = wthresh(c,'s',thr);
    % Reconstruct the signal
    NMR_denoisedWavelet = waverec(c_t,l,wname);
    
 figure;
subplot(1,2,1); plot(NMR_denoised);legend('Denoise'); subplot(1,2,2); plot(real(fftshift(fft(fidNoiseSum))));legend('Original')

figure;
subplot(2,3,1);plot((real(sum(imgWaveletMultiframe,2)))/32);
%box off;xlim([1, 2048]);set(gca, 'YTick', []);  set(gca, 'YColor', 'none');  ylabel(''); 
subplot(2,3,2);plot((real(fftshift(fft(fidNoiseSum)))));
subplot(2,3,3);plot(real(IdealSpecdata)); 
%subplot(2,3,4);plot(real(SpecDenoiseCzdzow));box off;axis off; 
subplot(2,3,4);plot(real(SpecDenoiseCzdzow));
subplot(2,3,5);plot(real(NMR_denoisedWavelet));
subplot(2,3,6); plot(real(NMR_denoised));


WMF=((real(sum(imgWaveletMultiframe,2)))/32)';
%WMF1=((real(sum(imgWaveletMultiframe,2)))/32);
%figure;
%subplot(1,2,1);plot(WMF1, 'g');box off;set(gca, 'Visible', 'off');
%subplot(1,2,2);plot(WMF, 'g');box off;set(gca, 'Visible', 'off');
    %%  SNR 
    RawNoiseSpec=real(fftshift(fft(fidNoiseSum)));
    MultiFrameDenoiseSpec=(NMR_denoised);
    WaveDenoise=real(NMR_denoisedWavelet);
    SpecDenoiseCzdzow=real(SpecDenoiseCzdzow);
    MultiFrameDenoiseSpec1=(WMF);
    
    disp('SNR Compare')
    SNRRaw=SNRCalculate(RawNoiseSpec);
    SNRMultiFrame=SNRCalculate(MultiFrameDenoiseSpec);
    SNRWaveDenoise=SNRCalculate(WaveDenoise);
    SNRCzdow=SNRCalculate(SpecDenoiseCzdzow');
    SNRMultiFrame1=SNRCalculate(MultiFrameDenoiseSpec1);
    
    disp(['Original SNR=', num2str(SNRRaw)]);
    disp(['MultiFrame denoise SNR=', num2str(SNRMultiFrame)]);
    disp(['WaveletDenoise SNR=', num2str(SNRWaveDenoise)]);
    disp(['Czdow denoise SNR=', num2str(SNRCzdow)]);
    disp(['MultiFrame1 denoise SNR=', num2str(SNRMultiFrame1)]);

 %% ssim Compare
     disp('ssim Compare')
     SignalRegion=1:512;
     
     
    ssimRaw=ssim(RawNoiseSpec(SignalRegion)/max(RawNoiseSpec),real(IdealSpecdata(SignalRegion))/max(real(IdealSpecdata)));
    ssimMultiFrame=ssim(MultiFrameDenoiseSpec(SignalRegion)/max(MultiFrameDenoiseSpec),real(IdealSpecdata(SignalRegion))/max(real(IdealSpecdata)));
    ssimWaveDenoise=ssim(WaveDenoise(SignalRegion)/max(WaveDenoise),real(IdealSpecdata(SignalRegion))/max(real(IdealSpecdata)));
    ssimCzdow=ssim(SpecDenoiseCzdzow(SignalRegion)'/max(SpecDenoiseCzdzow),real(IdealSpecdata(SignalRegion))/max(real(IdealSpecdata)));
    ssimMultiFrame1=ssim(MultiFrameDenoiseSpec1(SignalRegion)/max(MultiFrameDenoiseSpec1),real(IdealSpecdata(SignalRegion))/max(real(IdealSpecdata)));
    
    
    figure;plot(MultiFrameDenoiseSpec/max(MultiFrameDenoiseSpec),'r');hold on; plot(real(IdealSpecdata)/max(real(IdealSpecdata)),'g'); 
      plot(WaveDenoise/max(WaveDenoise),'k');
    disp(['Original ssim=', num2str(ssimRaw)]);
    disp(['MultiFrame denoise ssim=', num2str(ssimMultiFrame)]);
    disp(['WaveletDenoise ssim=', num2str(ssimWaveDenoise)]);
    disp(['Czdow denoise ssim=', num2str(ssimCzdow)]);
    disp(['MultiFrame1 denoise ssim=', num2str(ssimMultiFrame1)]);
    
    %% psnr
    disp('ssim Compare')
    psnrRaw=psnr(RawNoiseSpec/max(RawNoiseSpec),real(IdealSpecdata)/max(real(IdealSpecdata)));
    psnrMultiFrame=psnr(MultiFrameDenoiseSpec/max(MultiFrameDenoiseSpec),real(IdealSpecdata)/max(real(IdealSpecdata)));
    psnrWaveDenoise=psnr(WaveDenoise/max(WaveDenoise),real(IdealSpecdata)/max(real(IdealSpecdata)));
    psnrCzdow=psnr(SpecDenoiseCzdzow'/max(SpecDenoiseCzdzow),real(IdealSpecdata)/max(real(IdealSpecdata)));
    
    disp(['Original psnr=', num2str(psnrRaw)]);
    disp(['MultiFrame denoise psnr=', num2str(psnrMultiFrame)]);
    disp(['WaveletDenoise psnr=', num2str(psnrWaveDenoise)]);
    disp(['Czdow denoise ssim=', num2str(psnrCzdow)]);   
   
%     [final, coeffin, coeffs] = WaveletDenoise1D_FromPython(3, (real(fftshift(fft(fidNoiseSum)))), 0, 'db4', 'mod', 0);
%     
%   figure;subplot(2,2,1);plot((real(fftshift(fft(fidNoiseSum)))))
%     subplot(2,2,2);plot(NMR_denoisedWavelet)
%      subplot(2,2,3);plot(final)
%        subplot(2,2,4);plot(finalMultiDenoise)
    
    
    %      SpecSum=(real(fftshift(fft(fidNoiseSum))));
    %     SpecSum=SpecSum/max(SpecSum);
    %     im=    repmat(SpecSum',[1,size(SpecSum,2)]);
    %     res = wavDenoise(im,0.1);
    %     WaveDenoise2=sum(res,2)*max((real(fftshift(fft(fidNoiseSum)))))/size(SpecSum,2);
    %
    %     imgWaveletMultiframeSum=sum(imgWaveletMultiframe,2);
    %     imgWaveletMultiframeSum=imgWaveletMultiframeSum/max(imgWaveletMultiframeSum);
    %     im=    repmat(imgWaveletMultiframeSum,[1,size(imgWaveletMultiframeSum,1)]);
    %     res = wavDenoise(im,0.05);
    %     WaveDenoise3=sum(res,2)*max((real(fftshift(fft(fidNoiseSum)))))/size(SpecSum,2);
    
%     sigma=50;
%     z=real(SpecNoiseT);
%     z=z/max(z(:))*256;
%     [NA, y_est] = BM3D(1, z, sigma);
%     figure;subplot(1,2,1);imagesc(abs(z))
%     subplot(1,2,2);imagesc(abs(y_est))
%     figure;plot(sum(y_est,2))

%MCR去噪
 pfgnmrdata.filename='D:\R2020b\bin\PHIP_Dynamic_image';
 pfgnmrdata.np=size(SpecNoiseAll,2);
 pfgnmrdata.wp=10;
 pfgnmrdata.sp=0;
 pfgnmrdata.dosyconstant=0;
 pfgnmrdata.Gzlvl=zeros(1,size(SpecNoiseAll,1));
 pfgnmrdata.ngrad=size(SpecNoiseAll,1);
 pfgnmrdata.Ppmscale=linspace(0,10,pfgnmrdata.np);
 pfgnmrdata.SPECTRA=real(SpecNoiseAll');%real(SpecNoise)';
 [mcrdata]=mcr_mn(pfgnmrdata,4,[0 10],[0 0 0 0 0 1]);
SpecNoiseAllDenoiseMCR=mcrdata.DECAYS*mcrdata.COMPONENTS;
figure;subplot(1,2,1);plot(abs(mcrdata.DECAYS));subplot(1,2,2);plot(real(sum(SpecNoiseAllDenoiseMCR,1)));


wname = 'db4';
% Perform wavelet decomposition
[c,l] =wavedec(real(sum(real(SpecNoiseAllDenoiseMCR),1)),4,'db4');% wavedec((real(fftshift(fft(fidNoiseSum)))),4,'db4');
% Threshold the coefficients
thr = median(abs(c))/0.3;
c_t = wthresh(c,'s',thr);
% Reconstruct the signal
NMR_denoisedMCR_Wavlert = waverec(c_t,l,wname);

figure;subplot(1,3,1); plot(real(sum(SpecNoiseAll,1))');legend('Original')
subplot(1,3,2); plot(real(sum(SpecNoiseAllDenoiseMCR,1)));legend('MCR denoise')
subplot(1,3,3); plot(real(sum(NMR_denoisedMCR_Wavlert,1)));legend('MCR + wavelet denoise')

%     

    
 %%
%     %%
%     SpecSum=(real(fftshift(fft(fidNoiseSum))));
%     SpecSum=SpecSum/max(SpecSum);
%     im=    repmat(SpecSum',[1,size(SpecSum,2)]);
%     res = wavDenoise(im,0.2);
%     figure;
%     subplot(1,2,1); plot(sum(res,2));legend('Original'); subplot(1,2,2); plot(real(fftshift(fft(fidNoiseSum))));legend('Denoised') 
%     figure;plot(real(fftshift(fft(fidNoiseSum)))/max(real(fftshift(fft(fidNoiseSum)))))
%     ;hold on    ; plot(sum(res,2)/max( (sum(res,2)))) 
%     pfgnmrdata.filename='E:\Qingjia_work\NewMatlabCode\matlabcode\CSI_simulate\CSI_simulate\PHIP_Dynamic_image';
%     pfgnmrdata.np=size(SpecNoise,2);
%     pfgnmrdata.wp=10;
%     pfgnmrdata.sp=0;
%     pfgnmrdata.dosyconstant=0;
%     pfgnmrdata.Gzlvl=zeros(1,32);
%     pfgnmrdata.ngrad=32;
%     pfgnmrdata.Ppmscale=linspace(0,10,pfgnmrdata.np);
%     pfgnmrdata.SPECTRA=(fidNoise');%
%     
%     [mcrdata]=mcr_mn(pfgnmrdata,10,[0 10],[1 0 0 0 0 0]);
%     %     mcrdata.DECAYS(find(abs(mcrdata.DECAYS))<abs(0.4*max(mcrdata.DECAYS(:))))=0;
%     
% %     for i=1:size(mcrdata.DECAYS,2)
% %         if(max(abs(mcrdata.DECAYS(:,i)))<0.5*max(abs(mcrdata.DECAYS(:))))
% %             mcrdata.DECAYS(:,i)=0;
% %         end
% %     end
%     DenoiseData=mcrdata.DECAYS*mcrdata.COMPONENTS;
%     
%     
%     SpecNoise_mcr=fftshift(fft(DenoiseData,[],2));%去尾部的疑问数据
%     %     figure;stackedplot(real(SpecNoise(1:20:end,:)'),1,1);
%     SpecNoise_mcr=SpecNoise_mcr-mean(SpecNoise_mcr(:,1:20),2);
%     DenoiseDataSum=sum(SpecNoise_mcr,1);
%     
%     figure;
%     subplot(1,2,1); plot(real(((DenoiseDataSum))));legend('Denoised'); subplot(1,2,2); plot(real(fftshift(fft(fidNoiseSum))));legend('Original')
%     
%     SpecNoiseT = real(SpecNoise_mcr');
%     
%     imgNoiseVol = permute(SpecNoiseT(:,1:32),[1,3,2]);
%     imgNoiseVol = real(imgNoiseVol)/max(real(imgNoiseVol(:)));
%     imgNoiseVol = repmat(imgNoiseVol,[1,32,1]);
%     imgWaveletMultiframe1 = waveletMultiFrame(imgNoiseVol, 'k', 6, 'p', 4, 'maxLevel', 3, 'weightMode', 4, 'basis', 'dualTree');
%     
%     figure;subplot(1,3,1);plot((real(sum(imgWaveletMultiframe1,2))));subplot(1,3,2);plot((real(sum((SpecNoise),1))));subplot(1,3,3);plot(real(imgWaveletMultiframe))
%     
% 
%     
   disp('over')
end