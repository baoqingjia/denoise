clc;
clear all;
close all;
% fidname{1,1}='E:\Qingjia_work\NewMatlabCode\matlabcode\CSI_simulate\CSI_simulate\PHIP_Dynamic_image\800.7mm.20220517\1215\fid';
fidname{1,1}='E:\topspindata\500.4mm.20220818\2002\fid';
for m=1:1
    
    fid0=fopen(fidname{m},'r','ieee-le');
    [H,Length]=fread(fid0,'int32','ieee-le');
    fid00=transpose(reshape(H,2,Length/2));     %对 H 进行转置和重塑操作，使得 fid00 为一个大小为 (Length/2) × 2 的矩阵。其中，每一行包含两个数，分别表示实部和虚部
    fid000=fid00(:,1)+1i*((fid00(:,2)));        %实部+虚部  
    fid01=fid000;                               
    OneEchoPoint=570;                           %模拟回波中采样点数量       
    GuessTotalPoiint=OneEchoPoint*20;           
    fid01=fid01(1:GuessTotalPoiint);            %从fid01数组中截取前GuessTotalPoiint个采样点内
    figure;plot(abs(fftshift(fft(fid01))))
    
%     fid01(find(abs(fid01)==0))=[];
    %fid01(all(fid01==0,2),:)=[];
%     fid1=fftshift(fft(fid01));
    
%     ProfileSpec=fftshift(fft(fid01));
%     FidBack=ifft(fftshift(ProfileSpec));
%     figure;plot(abs(FidBack))

% %     noiseFid = AverageFid;
%     Fid_noise_sup = NASR(fid01,'FID').';
 
%     fid01=Fid_noise_sup;
    

    fid01Guess=cat(1,fid01,zeros(GuessTotalPoiint-length(fid01),1));
    fidReshape=reshape(fid01Guess,[OneEchoPoint, GuessTotalPoiint/OneEchoPoint]);
    figure;plot(abs(fidReshape))
    
    ProfileSpecAll=fftshift(fft((fidReshape),[],1),1);
    fidReshape=fidReshape-repmat(mean(fidReshape(end-250:end,:),1),[size(fidReshape,1) 1]);
     figure;plot(abs(ProfileSpecAll))
    figure;plot(abs(sum(ProfileSpecAll,2)))
    figure;subplot(1,2,1);plot(abs(sum(abs(ProfileSpecAll),2)));subplot(1,2,2);plot((abs(ProfileSpecAll)))
    
    ZeroFill=1024;
    AllFidZeroFill=zeros(ZeroFill,size(fidReshape,2));
    AllFidZeroFill((ZeroFill-OneEchoPoint)/2+1:(ZeroFill-OneEchoPoint)/2+OneEchoPoint,:)=fidReshape;
    SpecAll=fftshift(fft((AllFidZeroFill),[],1),1);
    
    
    

     figure;plot(abs(SpecAll(:,1)))
     a=abs(sum(abs(SpecAll(:,1:10)),2));
%      a=flipud(a);
     b=abs(SpecAll(:,1));
     a=a-mean(a(10:20));
     b=b-mean(b(10:20));
     a=a/max(a);
     b=b/max(b);
        figure;plot(a,'k');hold on; plot(b,'r')
    
%     y = doubledual_S1D(abs(sum(SpecAll,2))/max(abs(sum(SpecAll,2))),0.05);            % denoise the noisy image using Double-Density Dual-Tree DWT
%     figure;
%     subplot(1,2,1);plot(abs(sum(SpecAll,2))/max(abs(sum(SpecAll,2))));
%     subplot(1,2,2);plot(abs(y));
    
%     AverageFidDenoise=cadzow(sum(fidReshape,2),60,100);
%     AverageSpec=fftshift(fft(sum(fidReshape,2), [], 1));
%     AverageSpecDenoise = fftshift(fft(AverageFidDenoise, [], 1));
%     figure;subplot(1,2,1);plot(abs(AverageSpec))
%     subplot(1,2,2);plot(abs(AverageSpecDenoise))
    
    figure;plot(real(AllFidZeroFill))

    
    ImagShowNum=18
    figure('Name','all Spec');
    ha = tight_subplot(1,ImagShowNum,0.001);
    for iSilce=1:ImagShowNum
        axes(ha(iSilce)); %#ok<LAXES>
        plot((abs((SpecAll(:,iSilce)))));ylim([0,max(abs(SpecAll(:)))]); axis off;
    end
    
    RankSet=4;
    [U,S,V] = svd((SpecAll(1:end,:)),'econ');
    svector=diag(S);
    svector(RankSet+1:end)=0;
    Sdenoise=diag(svector);
    DenoisedSpecImag=U*Sdenoise*V';
    figure;subplot(1,2,1);plot(abs(sum(DenoisedSpecImag,2)));subplot(1,2,2);plot((abs(sum(SpecAll,2))))
    
    
%     DenoiseSpec2Fid=fftshift(ifft(fftshift(DenoisedSpecImag,1),[],1),1);
%     DenoiseSpec2Fid=reshape(DenoiseSpec2Fid,[],1);
%     Fid_noise_sup = NASR(DenoiseSpec2Fid,'FID').';
    % %     noiseFid = AverageFid;


    
    
    
%     figure;subplot(1,2,1);plot(abs(sum(SpecAll,2)));subplot(1,2,2);plot((abs(sum(SpecAll(:,1:1),2))))
%     figure;plot(abs(sum(SpecAll,2))/max(abs(sum(SpecAll,2))),'r');hold on;
%     plot(abs(sum(SpecAll(:,1:1),2))/max(abs(sum(SpecAll(:,1:1),2))),'k');hold off;
    
    
    
    ImagShowNum=18
    figure('Name','all Spec');
    ha = tight_subplot(2,ImagShowNum,0.001);
    for iSilce=1:ImagShowNum
        axes(ha(iSilce)); %#ok<LAXES>
        plot((abs((SpecAll(:,iSilce)))));ylim([0,max(abs(SpecAll(:)))])
        axes(ha(iSilce+ImagShowNum)); %#ok<LAXES>
        plot((abs((DenoisedSpecImag(:,iSilce)))));ylim([0,max(abs(SpecAll(:)))])
    end
    
    figure;plot(abs(DenoisedSpecImag(211,:)));hold on; plot(abs(SpecAll(211,:)),'r-*');hold on;
    
    
    RankSet=3;
    [U,S,V] = svd((AllFidZeroFill(1:end,:)),'econ');
    svector=diag(S);
    svector(RankSet+1:end)=0;
    Sdenoise=diag(svector);
    DenoisedSpecFid=U*Sdenoise*V';
    DenoiseSpecAll=fftshift(fft(fftshift(DenoisedSpecFid),[],1));
    figure;subplot(1,2,1);plot(abs(sum(DenoiseSpecAll,2)));subplot(1,2,2);plot((abs(sum(SpecAll,2))))
    
%     figure;stackedplot(abs(DenoiseSpecAll(1:1:end,:)),1,8);
%     figure;stackedplot(abs(SpecAll(1:1:end,:)),1,8);
%     figure;stackedplot(abs((DenoisedSpecImag(1:1:end,:))),1,8);
    
    
    figure('Name','all Spec');
    ha = tight_subplot(2,ImagShowNum,0.001);
    for iSilce=1:ImagShowNum
        axes(ha(iSilce)); %#ok<LAXES>
        plot((abs((SpecAll(:,iSilce)))));;ylim([0,max(abs(SpecAll(:)))])
        axes(ha(iSilce+ImagShowNum)); %#ok<LAXES>
        plot((abs((DenoiseSpecAll(:,iSilce)))));;ylim([0,max(abs(SpecAll(:)))])
    end
    
    figure;plot(abs(DenoiseSpecAll(512,:)));hold on; plot(abs(SpecAll(512,:)),'r-*');hold on;
    
    
    
    %%
%  [yOut] = cadzow(AllFidZeroFill(246:741,1), 15,100);
%  figure;plot(abs(fftshift(fft(yOut))))
%  
 
sigma=20;
z=abs(SpecAll);
z=z/max(z(:))*256;
[NA, y_est] = BM3D(1, z, sigma);
figure;subplot(1,2,1);imagesc(abs(z))
subplot(1,2,2);imagesc(abs(y_est))
figure;subplot(1,2,1);plot(abs(sum(y_est,2)));subplot(1,2,2);plot((abs(sum(SpecAll,2))))

figure('Name','all Spec');
ha = tight_subplot(2,ImagShowNum,0.001);
for iSilce=1:ImagShowNum
    axes(ha(iSilce)); %#ok<LAXES>
    plot((abs((SpecAll(:,iSilce)))));;ylim([0,max(abs(SpecAll(:)))])
    axes(ha(iSilce+ImagShowNum)); %#ok<LAXES>
    plot((abs((y_est(:,iSilce)))));;ylim([0,max(abs(y_est(:)))])
end

 figure;plot(sum(abs(y_est(474:559,:)),1));hold on; plot(sum(abs(SpecAll(474:559,:)),1),'r-*');hold off;
 
 
 
 imgNoiseVol=permute(SpecAll(:,1:15),[1,3,2]);
 imgNoiseVol=abs(imgNoiseVol)/max(abs(imgNoiseVol(:)));
 imgNoiseVol=repmat(imgNoiseVol,[1,16,1]);
 imgWaveletMultiframe = waveletMultiFrame(imgNoiseVol, 'k', 6, 'p', 4, 'maxLevel', 3, 'weightMode', 4, 'basis', 'dualTree');
 
 
 

 figure;subplot(1,3,1);plot(abs(sum(y_est,2)));
 subplot(1,3,2);plot((abs(sum(imgWaveletMultiframe,2))));subplot(1,3,3);plot((abs(sum(abs(SpecAll),2))))
  %% to reco with shuffling
  
NumSpec=size(AllFidZeroFill,2);
T1Small=0.1;
T2Big=10;
ScanIndex=0:1:(NumSpec-1);

T1Region=linspace(T1Small,T2Big,200);
T1RandomCurve=zeros(NumSpec,200);
OneSpecTime=1;
for i=1:length(T1Region)
    WaterDecayFactor=exp(-OneSpecTime*ScanIndex/T1Region(i));
    T1RandomCurve(:,i)=WaterDecayFactor;
end

[U, ~, ~] = svd(T1RandomCurve, 'econ');
K = 2; % subspace size
Phi = U(:,1:K);

Z = Phi*Phi'*T1RandomCurve;
figure;plot(Z)
err = norm(T1RandomCurve(:) - Z(:)) / norm(T1RandomCurve(:));
fprintf('Relative norm of error: %.6f\n', err);

figure;plot(Phi)
disp('over generate Phi')

Z = Phi*Phi'*(SpecAll');
figure;plot(abs(Z'))
figure;subplot(1,2,1);plot(abs(sum(Z,1)'));
subplot(1,2,2);plot(abs(sum(SpecAll,2)'))


    figure('Name','all Spec');
    ha = tight_subplot(2,ImagShowNum,0.001);
    for iSilce=1:ImagShowNum
        axes(ha(iSilce)); %#ok<LAXES>
        plot((abs((SpecAll(:,iSilce)))));;ylim([0,max(abs(SpecAll(:)))])
        axes(ha(iSilce+ImagShowNum)); %#ok<LAXES>
        plot((abs((Z(iSilce,:)))));;ylim([0,max(abs(SpecAll(:)))])
    end
    
        figure;plot(sum(abs(Z(:,474:559)),2));hold on; plot(sum(abs(SpecAll(474:559,:)),1),'r-*');hold on;


 %%
%  [yOut] = cadzow(fid01, 100,50);

    %%
E = xfm_FFT([size(AllFidZeroFill,1),1,1,size(AllFidZeroFill,2)],[],[]);
% y = E'*fftshift(PhaseDataAfterphc',1);            % Forward Transform
y =reshape((AllFidZeroFill),[],1);            % Forward Transform


out = reshape(E.iter(y,@pcg,1E-8,100),[E.Nd E.Nt]);
figure;plot(squeeze(abs(((out)))))

z4 = reshape(E.iter(y,@pcg,1E-6,100,[0 0 0 10]),[E.Nd E.Nt]);
z4 = squeeze(z4);
figure;plot(squeeze(abs(((z4)))))
figure;plot(sum(squeeze(abs(((z4)))),2))


z5 = reshape(svt(E, y, 1000, 'step', 5E-5, 'tol', 1E-3),[E.Nd  E.Nt]);
figure;plot(squeeze(abs(((z5)))))


z6 = iht_ms(E, y, 'rank',8, 'step', 1E-3, 'shrink', 0.1, 'tol', 1E-8);
z6 = reshape(z6.u*z6.v',[E.Nd E.Nt]);
figure;plot(squeeze(real(fftshift(fft(fftshift(z6,1),[],1),1))))
z6=squeeze(z6);
figure('Name','all Spec');
ha = tight_subplot(2,ImagShowNum,0.001);
for iSilce=1:ImagShowNum
    axes(ha(iSilce)); %#ok<LAXES>
    plot((abs((SpecAll(:,iSilce)))));ylim([0,3*10^6])
    axes(ha(iSilce+ImagShowNum)); %#ok<LAXES>
    plot((abs((z6(:,iSilce)))))
end
figure;plot(abs(sum(z6,2)))





FTSpecNoise=fftshift(fft(sum(fidNoise,1),[],2));%去尾部的疑问数据
figure;plot(flip(real(FTSpecNoise),2))
    
    %%
    
    AllFidZeroFillReshape=reshape(AllFidZeroFill,[],1);
    DenoisedSpecFidReshape=reshape(DenoisedSpecFid,[],1);
    AllSpecZeroFillReshape=fftshift(fft(AllFidZeroFillReshape));
    AllSpecDenoiseReshape=fftshift(fft(DenoisedSpecFidReshape));
    figure;subplot(1,2,1);plot(abs((AllSpecZeroFillReshape)));subplot(1,2,2);plot((abs((AllSpecDenoiseReshape))))
    
    
    
    
end



