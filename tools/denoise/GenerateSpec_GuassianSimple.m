clc; clear; close all;
% sw=10000;% unit Hz
sw_range=[30000,8400,9000,10000,11000,12000];
% sw=10000;% unit Hz
np=4*1024;
Maxnoiselevel=16; % 0~0.05 due to noise
Maxpointdistorion=0;% 0~10 due to baseline distortion  interger
Maxdistorionlever=0;% due to baseline distortion
MaxdelayControl=0;% [0 ~ 4]due to 1st phase
EdgeNoise=3000; %unit Hz 0:20 & sw-20:sw is noise no peak

for k=1:2000

    sw=sw_range(1);
    swPeakRegion=sw-2*EdgeNoise;
    t=0:1/sw:(np-1)/sw;
    delltime=1/sw;
    FreqScale=linspace(-sw/2,sw/2,length(t));%ori
    noiselevel=Maxnoiselevel; % 0~0.05 due to noise
  
    
    
%     PeakNum=30;%ori
    PeakNum=30+randperm(20,1);
    freq= swPeakRegion*(rand(1,PeakNum)-0.5); %-1500+2500*rand(1,PeakNum);%freq=-2000+4000*rand(1,PeakNum);
%     amp=3*rand(1,PeakNum);
    amp=8*rand(1,PeakNum);%谱峰有正有负,少部分为负,ori3
%     T2=0.05+0.3*rand(1,PeakNum);% T2=0.1+0.9*rand(1,PeakNum);#ori
    T2=200+400*rand(1,PeakNum);% T2=0.1+0.9*rand(1,PeakNum);
    
    IdealGaussianSpec=zeros(1,length(t));
    for i=1:PeakNum
        IdealGaussianSpec=IdealGaussianSpec+amp(i)*exp(-((FreqScale-freq(i))/T2(i)).^2);
    end
    
    % add noise and baseline distortion
    NoiseSpec=40;
    NoiseGaussianSpec=zeros(NoiseSpec,length(IdealGaussianSpec));
    for iNoiseSpec=1:NoiseSpec
        NoiseGaussianSpec(iNoiseSpec,:)=IdealGaussianSpec+noiselevel*max(abs(IdealGaussianSpec))*(rand(1,length(t))-0.5)/PeakNum;
    end
    
    
    figure;plot(sum(NoiseGaussianSpec,1))
    
    ReapteNum=40;
    for i=1:ReapteNum
        AverIndex=randperm(NoiseSpec,20);
        PortionFidSum(i,:)=sum(NoiseGaussianSpec(AverIndex,:),1);
        %disp(AverIndex);
    end
    lb = 20;
    fidSize=size(PortionFidSum,2);
    points = 0:1:(fidSize-1);
    t=exp(-points.*(pi*lb/sw));
    t=repmat(t,[ReapteNum,1]);
    PortionFidSum=PortionFidSum.*t;
    
    fftFID =PortionFidSum ;
    tempSpec = real(fftFID)/max(abs(real(fftFID(:))));
    RSD=std(tempSpec,1)./abs(mean(tempSpec,1));
    
        %     RSD=RSD/max(RSD(:));
    Alfa=0.2;
    Beta=120;
    Sigma=0.1;
    WeightedCurve=Alfa+(1-Alfa)./(1+exp(Beta*(RSD-Sigma)));
%         WeightedCurve=  whittf(WeightedCurve', 1600);
%         WeightedCurve=WeightedCurve';
    


    WeightAverageSpec=sum(NoiseGaussianSpec,1).*WeightedCurve;
    WeightAverageSpec=WeightAverageSpec-mean(WeightAverageSpec(1:20));
    figure;subplot(1,2,1);plot(real(sum(NoiseGaussianSpec,1)));subplot(1,2,2);plot(real(WeightAverageSpec))

  disp('over')


end