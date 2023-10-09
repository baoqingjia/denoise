clc; clear; close all;
% sw=10000;% unit Hz
sw_range=[7200,8400,9000,10000,11000,12000];
% sw=10000;% unit Hz
np=4*1024;
Maxnoiselevel=0.1; % 0~0.05 due to noise
Maxpointdistorion=0;% 0~10 due to baseline distortion  interger
Maxdistorionlever=0;% due to baseline distortion
MaxdelayControl=0;% [0 ~ 4]due to 1st phase
EdgeNoise=100; %unit Hz 0:20 & sw-20:sw is noise no peak

for k=1:2000

    sw=sw_range(1);
    swPeakRegion=sw-2*EdgeNoise;
    t=0:1/sw:(np-1)/sw;
    delltime=1/sw;
    FreqScale=linspace(-sw/2,sw/2,length(t));%ori
    noiselevel=Maxnoiselevel*rand(1,1); % 0~0.05 due to noise
    pointdistorion=round(Maxpointdistorion*rand(1,1));% 0~10 due to baseline distortion  interger
    distorionlever=Maxdistorionlever*rand(1,1);% due to baseline distortion
    
    delayControl=MaxdelayControl*rand(1,1);% [0 ~ 4]due to 1st phase
    zeroPhaseControl=0; % [180 180 ]due to 0st phase
%     zeroPhaseControl=0; % [180 180 ]due to 0st phase
    
    PeakNum=4;%ori
%     PeakNum=5+randperm(30,1);

    freq= swPeakRegion*(rand(1,PeakNum)-0.5); %-1500+2500*rand(1,PeakNum);%freq=-2000+4000*rand(1,PeakNum);
%   amp=3*rand(1,PeakNum);
    amp=8*rand(1,PeakNum);%谱峰有正有负,少部分为负,ori3
%     T2=0.05+0.3*rand(1,PeakNum);% T2=0.1+0.9*rand(1,PeakNum);#ori
    T2=2+0.5*rand(1,PeakNum);% T2=0.1+0.9*rand(1,PeakNum);
    delay=delayControl*delltime; % for the first order phase
    zerophase=zeroPhaseControl/180*pi;
    
    fid=zeros(1,length(t));
    realt=t+delay;
    idealfid=zeros(1,length(t));
    for i=1:length(freq)
        fid=fid+amp(i)*exp(-1i*2*pi*freq(i)*t).*exp(-t/T2(i))*exp(1i*(zerophase+2*pi*freq(i)*delay));
        idealfid=idealfid+amp(i)*exp(-1i*2*pi*freq(i)*t).*exp(-t/T2(i));
    end
    
    % add noise and baseline distortion
    idealfid=idealfid+0*noiselevel*max(abs(idealfid))*(rand(1,length(t))-0.5)/10000;
    NoiseSpec=1;
    fidNoise=zeros(NoiseSpec,length(fid));
    for iNoiseSpec=1:NoiseSpec
        fidNoise(iNoiseSpec,:)=fid+noiselevel*max(abs(fid))*((rand(1,length(t))-0.5)+1i*(rand(1,length(t))-0.5));
    end

    SpecNoise=fftshift(fft(fidNoise,[],2));%去尾部的疑问数据
%     figure;stackedplot(real(SpecNoise(1:20:end,:)'),1,1);  
    SpecNoise=SpecNoise-mean(SpecNoise(:,1:20),2);
    ImagShowNum=1;
    figure('Name','all Spec');
    ha = tight_subplot(1,ImagShowNum,0.001);
    for iSilce=1:ImagShowNum
        axes(ha(iSilce)); %#ok<LAXES>
        plot((real((SpecNoise(iSilce,:))))); ylim([-1000,max(real(SpecNoise(:)))])
    end
    
    
    figure;subplot(1,2,1);plot(t,real(idealfid));
    subplot(1,2,2);plot(t,real(fid));

    Spec=fftshift(fft(fid));%去尾部的疑问数据
%     Spec2=fftshift(fft(fid));
    idealSpec=fftshift(fft(idealfid));
    idealSpec=idealSpec;
    
    
    figure;plot(FreqScale,real(Spec),'r',FreqScale,real(idealSpec),'b');
    figure;subplot(1,2,1);plot(FreqScale,real(Spec)); ylim([-10,max(real(idealSpec(:)))])
    subplot(1,2,2);plot(FreqScale,real(idealSpec));  ylim([-10,max(real(idealSpec(:)))])




end