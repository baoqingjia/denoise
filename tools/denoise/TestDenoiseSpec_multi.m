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

for k=1:1
    
    sw=sw_range(1);
    swPeakRegion=sw-2*EdgeNoise;
    t=0:1/sw:(np-1)/sw;
    delltime=1/sw;
    FreqScale=linspace(-sw/2,sw/2,length(t));%ori
    noiselevel=0.1*Maxnoiselevel; % 0~0.05 due to noise
    pointdistorion=round(Maxpointdistorion*rand(1,1));% 0~10 due to baseline distortion  interger
    distorionlever=Maxdistorionlever*rand(1,1);% due to baseline distortion
    
    delayControl=MaxdelayControl*rand(1,1);% [0 ~ 4]due to 1st phase
    zeroPhaseControl=0; % [180 180 ]due to 0st phase
    %     zeroPhaseControl=0; % [180 180 ]due to 0st phase
    
    PeakNum=32;%ori
    %     PeakNum=5+randperm(30,1);
    
    freq= swPeakRegion/2*(rand(1,PeakNum)-0.5); %-1500+2500*rand(1,PeakNum);%freq=-2000+4000*rand(1,PeakNum);
    %   amp=3*rand(1,PeakNum);
    amp=8*rand(1,PeakNum);%谱峰有正有负,少部分为负,ori3
    %     T2=0.05+0.3*rand(1,PeakNum);% T2=0.1+0.9*rand(1,PeakNum);#ori
    T2=0.01+0.01*rand(1,PeakNum);% T2=0.1+0.9*rand(1,PeakNum);
    delay=delayControl*delltime; % for the first order phase
    zerophase=zeroPhaseControl/180*pi;
    
    fid=zeros(1,length(t));
    realt=t+delay;
    idealfid=zeros(1,length(t));
    for i=1:length(freq)
        fid=fid+amp(i)*exp(-1i*2*pi*freq(i)*t).*exp(-t/T2(i));
        idealfid=idealfid+amp(i)*exp(-1i*2*pi*freq(i)*t).*exp(-t/T2(i));
    end
    
    % add noise and baseline distortion
    idealfid=idealfid+0*noiselevel*max(abs(idealfid))*(rand(1,length(t))-0.5)/10000;
    NoiseSpec=32;
    fidNoise=zeros(NoiseSpec,length(fid));
    for iNoiseSpec=1:NoiseSpec
        fidNoise(iNoiseSpec,:)=fid+noiselevel*max(abs(fid))*((rand(1,length(t))-0.5)+1i*(rand(1,length(t))-0.5));
    end
    
    SpecNoise=fftshift(fft(fidNoise,[],2));%去尾部的疑问数据
    %     figure;stackedplot(real(SpecNoise(1:20:end,:)'),1,1);
    SpecNoise=SpecNoise-mean(SpecNoise(:,1:20),2);
    ImagShowNum=5;
    figure('Name','all Spec');
    ha = tight_subplot(1,ImagShowNum,0.001);
    for iSilce=1:ImagShowNum
        axes(ha(iSilce)); %#ok<LAXES>
        plot((real((SpecNoise(iSilce,:))))); %ylim([-1000,max(real(SpecNoise(:)))])
    end
    
    
    figure;subplot(1,2,1);plot(t,real(idealfid));
    subplot(1,2,2);plot(t,real(fid));
    
    Spec=fftshift(fft(fid));%去尾部的疑问数据
    %     Spec2=fftshift(fft(fid));
    idealSpec = fftshift(fft(idealfid));
    idealSpec = idealSpec;
    
    figure;plot(FreqScale,real(Spec),'r',FreqScale,real(idealSpec),'b');
    figure;subplot(1,2,1);plot(FreqScale,real(SpecNoise)); %ylim([-10,max(real(idealSpec(:)))])
    subplot(1,2,2);plot(FreqScale,real(idealSpec)); % ylim([-10,max(real(idealSpec(:)))])
    
    figure;subplot(1,2,1);plot(real(sum(SpecNoise,1)));subplot(1,2,2);plot(real(idealSpec));
    
    
    fidNoiseSum=sum(fidNoise,1);
    [yOut] = cadzow(fidNoiseSum, 32, 32);
    SpecDenoiseCzdzow=fftshift(fft(yOut));
    
    figure;subplot(1,3,1);plot(FreqScale,real(fftshift(fft(fidNoiseSum)))); %ylim([-10,max(real(idealSpec(:)))])
    subplot(1,3,2);plot(FreqScale,real(SpecDenoiseCzdzow)); % ylim([-10,max(real(idealSpec(:)))])
    subplot(1,3,3);plot(FreqScale,real(idealSpec)); % ylim([-10,max(real(idealSpec(:)))])
    
    
    SpecNoiseT = SpecNoise';
    
    imgNoiseVol = permute(SpecNoiseT(:,1:32),[1,3,2]);
    imgNoiseVol = real(imgNoiseVol)/max(real(imgNoiseVol(:)));
    imgNoiseVol = repmat(imgNoiseVol,[1,32,1]);
    imgWaveletMultiframe = waveletMultiFrame(imgNoiseVol, 'k', 6, 'p', 8, 'maxLevel', 3, 'weightMode', 4, 'basis', 'dualTree');
    
    figure;subplot(1,3,1);plot((real(sum(imgWaveletMultiframe,2))));subplot(1,3,2);plot((real(sum((SpecNoise),1))));subplot(1,3,3);plot(real(idealSpec))
    
    figure;
    subplot(2,2,1);plot((real(sum(imgWaveletMultiframe,2)))/32);subplot(2,2,2);plot((real(sum((SpecNoise),1))));
    subplot(2,2,3);plot(real(idealSpec));subplot(2,2,4);plot(real(SpecDenoiseCzdzow));
    
    
    wname = 'db4';
    
    % Perform wavelet decomposition
    [c,l] = wavedec((real(fftshift(fft(fidNoiseSum)))),4,'db4');
    % Threshold the coefficients
    thr = median(abs(c))/0.1745;;
    c_t = wthresh(c,'h',thr);
    % Reconstruct the signal
    NMR_denoised = waverec(c_t,l,wname);
    
    % Plot original and denoised signals
    % figure;
    % plot(NMR_signal);
    % hold on;
    % plot(NMR_denoised,'LineWidth',1);
    % legend('Original','Denoised');
    
    % AA=denoise_spectrum(real(spe{i}),'db4');
    figure;
    subplot(1,2,1); plot(NMR_denoised);legend('Denoise'); subplot(1,2,2); plot(real(fftshift(fft(fidNoiseSum))));legend('Original')
    
    SpecSum=(real(fftshift(fft(fidNoiseSum))));
    SpecSum=SpecSum/max(SpecSum);
    im=    repmat(SpecSum',[1,size(SpecSum,2)]);
    res = wavDenoise(im,0.2);
    figure;
    subplot(1,2,1); plot(sum(res,2));legend('Original'); subplot(1,2,2); plot(real(fftshift(fft(fidNoiseSum))));legend('Denoised') 
    figure;plot(real(fftshift(fft(fidNoiseSum)))/max(real(fftshift(fft(fidNoiseSum)))))
    ;hold on    ; plot(sum(res,2)/max( (sum(res,2)))) 
    pfgnmrdata.filename='E:\Qingjia_work\NewMatlabCode\matlabcode\CSI_simulate\CSI_simulate\PHIP_Dynamic_image';
    pfgnmrdata.np=size(SpecNoise,2);
    pfgnmrdata.wp=10;
    pfgnmrdata.sp=0;
    pfgnmrdata.dosyconstant=0;
    pfgnmrdata.Gzlvl=zeros(1,32);
    pfgnmrdata.ngrad=32;
    pfgnmrdata.Ppmscale=linspace(0,10,pfgnmrdata.np);
    pfgnmrdata.SPECTRA=(fidNoise');%
    
    [mcrdata]=mcr_mn(pfgnmrdata,10,[0 10],[1 0 0 0 0 0]);
    %     mcrdata.DECAYS(find(abs(mcrdata.DECAYS))<abs(0.4*max(mcrdata.DECAYS(:))))=0;
    
%     for i=1:size(mcrdata.DECAYS,2)
%         if(max(abs(mcrdata.DECAYS(:,i)))<0.5*max(abs(mcrdata.DECAYS(:))))
%             mcrdata.DECAYS(:,i)=0;
%         end
%     end
    DenoiseData=mcrdata.DECAYS*mcrdata.COMPONENTS;
    
    
    SpecNoise_mcr=fftshift(fft(DenoiseData,[],2));%去尾部的疑问数据
    %     figure;stackedplot(real(SpecNoise(1:20:end,:)'),1,1);
    SpecNoise_mcr=SpecNoise_mcr-mean(SpecNoise_mcr(:,1:20),2);
    DenoiseDataSum=sum(SpecNoise_mcr,1);
    
    figure;
    subplot(1,2,1); plot(real(((DenoiseDataSum))));legend('Denoised'); subplot(1,2,2); plot(real(fftshift(fft(fidNoiseSum))));legend('Original')
    
    SpecNoiseT = real(SpecNoise_mcr');
    
    imgNoiseVol = permute(SpecNoiseT(:,1:32),[1,3,2]);
    imgNoiseVol = real(imgNoiseVol)/max(real(imgNoiseVol(:)));
    imgNoiseVol = repmat(imgNoiseVol,[1,32,1]);
    imgWaveletMultiframe1 = waveletMultiFrame(imgNoiseVol, 'k', 6, 'p', 4, 'maxLevel', 3, 'weightMode', 4, 'basis', 'dualTree');
    
    figure;subplot(1,3,1);plot((real(sum(imgWaveletMultiframe1,2))));subplot(1,3,2);plot((real(sum((SpecNoise),1))));subplot(1,3,3);plot(real(imgWaveletMultiframe))
    

    
    disp('over')
end