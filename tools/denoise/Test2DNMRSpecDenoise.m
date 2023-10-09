clc;close all; clear;

PeakNum=5;

sw1=2000;% unit Hz 
sw2=2000;% unit Hz 

AcquPoint=[512 512];% unit Hz 




%%
Freq1DScale=linspace(-sw1/2,sw1/2,AcquPoint(1));
Freq2DScale=linspace(-sw2/2,sw2/2,AcquPoint(2));

% Freq1D=[500,200,-300,416,-385,618,-587];% unit Hz 
% Freq2D=[-300,400,100,-416,-397,-610,587]; % unit Hz 
% PeakAmp=[1 0.5 2 1.8 0.9 1.3 1.5 0.87];
% T21D=[80 100 70 90 200 30 20 30]/1000;% unit s 
% T22D=[20 150 50 100 15 68 40 60 40]/1000;% unit s 

Freq1D=1500*rand(1,PeakNum)-750;%[500,200,-300,416,-385,618,-587];% unit Hz
Freq2D=1500*rand(1,PeakNum)-750;
PeakAmp=10*rand(1,PeakNum);%[1 0.5 2 1.8 0.9 1.3 1.5 0.87];
T21D=1*(rand(1,PeakNum)*25+15)/1000;%[80 100 70 90 200 10 20 30]/4000;% unit s
T22D=1*(rand(1,PeakNum)*25+15)/1000;%[20 150 50 100 15 20 40 60 40]/4000;% unit s



t11D=0:1/(sw1):1/(sw1)*(AcquPoint(1)-1);

fid1D=zeros([1 length(t11D)]);
for iPeak=1:length(Freq1D)
    fid1D=fid1D+PeakAmp(iPeak)*exp(1i*2*pi*Freq1D(iPeak)*t11D).*exp(-t11D/T21D(iPeak));
end

figure;plot(real(fid1D))

figure;plot(Freq1DScale',real(fftshift(fft(fid1D',[],1),1)))

fid2DOnePeak=zeros([2,length(Freq1D),AcquPoint]);
fid2D=zeros([2,AcquPoint]);
for iAcq2=1:AcquPoint(2)
    t12D=(iAcq2-1)/sw2;
    for iPeak=1:length(Freq1D)
        for iState=1:2
%         PeakOne=PeakAmp(iPeak)*exp(1i*2*pi*Freq2D(iPeak)*t12D).*exp(-t12D/T22D(iPeak));
        if(iState==1)
             PeakOne=PeakAmp(iPeak)*cos(2*pi*Freq2D(iPeak)*t12D).*exp(-t12D/T22D(iPeak)).*(1+randn(1)*0. + 0*i*(1+randn(1)*0.1));
        else
             PeakOne=PeakAmp(iPeak)*sin(2*pi*Freq2D(iPeak)*t12D).*exp(-t12D/T22D(iPeak)).*((1+randn(1)*0.) + 0*i*(1+randn(1)*0.1));
        end
        fid2DOnePeak(iState,iPeak,:,iAcq2)=PeakOne*exp(1i*2*pi*Freq1D(iPeak)*t11D).*exp(-t11D/T21D(iPeak));
%         fid2DOnePeak(iState,iPeak,:,iAcq2)= fid2DOnePeak(iState,iPeak,:,iAcq2)-mean(fid2DOnePeak(iState,iPeak,:,iAcq2));
        end
    end
%      fid2D(iState,:,iAcq2)=squeeze(sum(fid2DOnePeak(iState,:,:,iAcq2),2));
end
% fid2DOnePeak=fid2DOnePeak-mean(fid2DOnePeak(:));
fid2D=squeeze(sum(fid2DOnePeak,2));
for iAcq2=1:AcquPoint(2)
     for iState=1:2
      fid2DT1Noise(iState,:,iAcq2)= fid2D(iState,:,iAcq2);%*(1+0*0.5*(randn(1)-0.5))*exp(1i*0.5*(randn(1)-0.5));%(1+ 0.2*randn(1) + i*(1+0.2*randn(1)));
     end
end

noiseLevel=3;
fid2DT1Noise=fid2DT1Noise+noiseLevel*(randn(size(fid2D))+1i*randn(size(fid2D)));
% figure;mesh(squeeze(abs(fid2D(1,:,:))))
 [Spec2D ComFid] = Recio2DSpec_State(fid2D);
 [Spec2DNoise ComFidNoise] = Recio2DSpec_State(fid2DT1Noise);

  
%%
 pfgnmrdata.filename='E:\Qingjia_work\NewMatlabCode\matlabcode\CSI_simulate\CSI_simulate\PHIP_Dynamic_image';
 pfgnmrdata.np=size(fid2DT1Noise,2);
 pfgnmrdata.wp=10;
 pfgnmrdata.sp=0;
 pfgnmrdata.dosyconstant=0;
 pfgnmrdata.Gzlvl=zeros(1,512);
 pfgnmrdata.ngrad=512;
 pfgnmrdata.Ppmscale=linspace(0,10,pfgnmrdata.np);
 pfgnmrdata.SPECTRA=squeeze(fid2DT1Noise(1,:,:))';%real(SpecNoise)';
 
 [mcrdata]=mcr_mn(pfgnmrdata,10,[0 10],[0 0 0 0 0 0]);
fid2DT1NoiseDenoise=0*fid2DT1Noise;
fid2DT1NoiseDenoise(1,:,:)=mcrdata.DECAYS*mcrdata.COMPONENTS;

 pfgnmrdata.filename='E:\Qingjia_work\NewMatlabCode\matlabcode\CSI_simulate\CSI_simulate\PHIP_Dynamic_image';
 pfgnmrdata.np=size(fid2DT1Noise,2);
 pfgnmrdata.wp=10;
 pfgnmrdata.sp=0;
 pfgnmrdata.dosyconstant=0;
 pfgnmrdata.Gzlvl=zeros(1,512);
 pfgnmrdata.ngrad=512;
 pfgnmrdata.Ppmscale=linspace(0,10,pfgnmrdata.np);
 pfgnmrdata.SPECTRA=squeeze(fid2DT1Noise(2,:,:))';%real(SpecNoise)';
 
 [mcrdata2]=mcr_mn(pfgnmrdata,10,[0 10],[0 0 0 0 0 0]);

fid2DT1NoiseDenoise(2,:,:)=mcrdata2.DECAYS*mcrdata2.COMPONENTS;
  [Spec2DNoiseDenoise ComFidNoise] = Recio2DSpec_State(fid2DT1NoiseDenoise);
 
  
% figure;mesh(squeeze(abs(Spec2D)))
[XX,YY] = meshgrid(Freq1DScale,Freq2DScale);
figure;subplot(1,3,1);contour(squeeze(real(Spec2D)),7);subplot(1,3,2);contour(squeeze(real(Spec2DNoise)),40);subplot(1,3,3);contour(squeeze(real(Spec2DNoiseDenoise)),40);



figure;subplot(1,3,1);mesh(squeeze(real(Spec2D)));subplot(1,3,2);mesh(squeeze(real(Spec2DNoise)));subplot(1,3,3);mesh(squeeze(real(Spec2DNoiseDenoise)));
