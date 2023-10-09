clc; clear; close all;
% sw=10000;% unit Hz
sw_range=[30000,8400,9000,10000,11000,12000];
% sw=10000;% unit Hz
np=2000; %4*1024;
Maxnoiselevel=10; % 0~0.05 due to noise
Maxpointdistorion=0;% 0~10 due to baseline distortion  interger
Maxdistorionlever=0;% due to baseline distortion
MaxdelayControl=0;% [0 ~ 4]due to 1st phase
EdgeNoise=3000; %unit Hz 0:20 & sw-20:sw is noise no peak

SpecNoisef=[];
Specidealf=[];

for k=1:5000

    sw=sw_range(1);
    swPeakRegion=sw-2*EdgeNoise;
    t=0:1/sw:(np-1)/sw;
    delltime=1/sw;
    FreqScale=linspace(-sw/2,sw/2,length(t));%ori
    noiselevel=Maxnoiselevel*rand(1,1); % 0~0.05 due to noise
    
%     PeakNum=30;%ori
    PeakNum=30+randperm(20,1);

    freq= swPeakRegion*(rand(1,PeakNum)-0.5); %-1500+2500*rand(1,PeakNum);%freq=-2000+4000*rand(1,PeakNum);
%     amp=3*rand(1,PeakNum);
    amp=8*rand(1,PeakNum);%谱峰有正有负,少部分为负,ori3
%     T2=0.05+0.3*rand(1,PeakNum);% T2=0.1+0.9*rand(1,PeakNum);#ori
    T2=100+200*rand(1,PeakNum);% T2=0.1+0.9*rand(1,PeakNum);

    
    IdealGaussianSpec=zeros(1,length(t));
    for i=1:PeakNum
        IdealGaussianSpec=IdealGaussianSpec+amp(i)*exp(-((FreqScale-freq(i))/T2(i)).^2);
    end
    
    % add noise and baseline distortion
    NoiseSpec=2; %100;  
    NoiseGaussianSpec=zeros(NoiseSpec,length(IdealGaussianSpec));
    for iNoiseSpec=1:NoiseSpec
        NoiseGaussianSpec(iNoiseSpec,:)=IdealGaussianSpec+noiselevel*max(abs(IdealGaussianSpec))*(rand(1,length(t))-0.5)/PeakNum;
    end
%     disp('over')

%     figure;plot(NoiseGaussianSpec(2,:),'r-');hold on;plot(IdealGaussianSpec,'b-.');
%     IdealGaussianSpeck=repmat(IdealGaussianSpec,20,1);
    SpecNoisef=cat(1,SpecNoisef, NoiseGaussianSpec(1,:)/max(NoiseGaussianSpec(1,:)));
    Specidealf=cat(1,Specidealf, NoiseGaussianSpec(2,:)/max(NoiseGaussianSpec(2,:)));
%     Specidealf=cat(1,Specidealf, IdealGaussianSpeck);
end

save data\Spec_C\Spec_C_n2n_2qNew_train1.mat SpecNoisef
save data\Spec_C\Spec_C_n2n_2qNew_train2.mat Specidealf
% save data\GT_C_n2n_test.mat Specidealf

figure;plot(SpecNoisef(2,:),'r-');hold on;plot(Specidealf(2,:),'b-.');
figure;plot(A(2,:),'r-');hold on;plot(Specidealf(2,:),'b-.');hold on;plot(B(2,:),'g-');


