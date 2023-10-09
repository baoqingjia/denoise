clc;clear; close all;

fidname{1}='E:\Qingjia_work\NewMatlabCode\matlabcode\CSI_simulate\CSI_simulate\PHIP_Dynamic_image\500.4mm.20220818\2002\fid';
fidname{2}='E:\Qingjia_work\NewMatlabCode\matlabcode\CSI_simulate\CSI_simulate\PHIP_Dynamic_image\500.4mm.20220818\2004\fid';
 fidname{3}='E:\Qingjia_work\NewMatlabCode\matlabcode\CSI_simulate\CSI_simulate\PHIP_Dynamic_image\500.4mm.20220818\2005\fid';
 fidname{4}='E:\Qingjia_work\NewMatlabCode\matlabcode\CSI_simulate\CSI_simulate\PHIP_Dynamic_image\500.4mm.20220818\2006\fid';
fidname{5}='E:\Qingjia_work\NewMatlabCode\matlabcode\CSI_simulate\CSI_simulate\PHIP_Dynamic_image\500.4mm.20220818\2007\fid';
fidname{6}='E:\Qingjia_work\NewMatlabCode\matlabcode\CSI_simulate\CSI_simulate\PHIP_Dynamic_image\500.4mm.20220818\2008\fid';
fidname{7}='E:\Qingjia_work\NewMatlabCode\matlabcode\CSI_simulate\CSI_simulate\PHIP_Dynamic_image\500.4mm.20220818\2009\fid';
fidname{8}='E:\Qingjia_work\NewMatlabCode\matlabcode\CSI_simulate\CSI_simulate\PHIP_Dynamic_image\500.4mm.20220818\2010\fid';


% fidname{1}='E:\Qingjia_work\work\WIPM_Work\HumanBaby\400.3.2mm.20221116\2013\fid';
% fidname{2}='E:\Qingjia_work\work\WIPM_Work\HumanBaby\400.3.2mm.20221116\2014\fid';
%  fidname{3}='E:\Qingjia_work\work\WIPM_Work\HumanBaby\400.3.2mm.20221116\2015\fid';
%  fidname{4}='E:\Qingjia_work\work\WIPM_Work\HumanBaby\400.3.2mm.20221116\2016\fid';
% fidname{5}='E:\Qingjia_work\work\WIPM_Work\HumanBaby\400.3.2mm.20221116\2017\fid';
% fidname{6}='E:\Qingjia_work\work\WIPM_Work\HumanBaby\400.3.2mm.20221116\2018\fid';
% fidname{7}='E:\Qingjia_work\work\WIPM_Work\HumanBaby\400.3.2mm.20221116\2019\fid';
% fidname{8}='E:\Qingjia_work\work\WIPM_Work\HumanBaby\400.3.2mm.20221116\2020\fid';

% fidname{1}='E:\Qingjia_work\NewMatlabCode\matlabcode\CSI_simulate\CSI_simulate\PHIP_Dynamic_image\27Al-poorSN\3600\fid';


% FidAll=zeros(1536,8);
sumFid=0;
for i=1:size(fidname,2)
    fid0=fopen(fidname{i},'r','ieee-le');
    [H,Length]=fread(fid0,'int32','ieee-le');
    fid00=transpose(reshape(H,2,Length/2));
    fid000=fid00(:,1)+1i*((fid00(:,2)));
%     fid01=fid000;
%     OneEchoPoint=570;
%     GuessTotalPoiint=OneEchoPoint*30;
%     fid01=fid01(1:GuessTotalPoiint);
    sumFid=sumFid+fid000;
    FidAll(:,i)=fid000;
end

fid01=sumFid;
figure;plot(abs(fftshift(fft(fid01))))
    
%     fid01(find(abs(fid01)==0))=[];
    %fid01(all(fid01==0,2),:)=[];
%     fid1=fftshift(fft(fid01));
    
%     ProfileSpec=fftshift(fft(fid01)); +
%     FidBack=ifft(fftshift(ProfileSpec));
%     figure;plot(abs(FidBack))

% %     noiseFid = AverageFid;
%     Fid_noise_sup = NASR(fid01,'FID').';
 
%     fid01=Fid_noise_sup;
    

%     fid01Guess=cat(1,fid01,zeros(GuessTotalPoiint-length(fid01),1));
%     fidReshape=reshape(fid01Guess,[OneEchoPoint, GuessTotalPoiint/OneEchoPoint]);
%     figure;plot(abs(fidReshape))
    
%     ProfileSpecAll=fftshift(fft((fid01),[],1),1);
%     fidReshape=fidReshape-repmat(mean(fidReshape(end-250:end,:),1),[size(fidReshape,1) 1]);
% %      figure;plot(abs(ProfileSpecAll))
% %     figure;plot(abs(sum(ProfileSpecAll,2)))
%     figure;subplot(1,2,1);plot(abs(sum(abs(ProfileSpecAll),2)));subplot(1,2,2);plot((abs(ProfileSpecAll)))
%     
%     ZeroFill=1024;
%     AllFidZeroFill=zeros(ZeroFill,size(fidReshape,2));
%     AllFidZeroFill((ZeroFill-OneEchoPoint)/2+1:(ZeroFill-OneEchoPoint)/2+OneEchoPoint,:)=fidReshape;
%     SpecAll=fftshift(fft((AllFidZeroFill),[],1),1);
    
    
%     SumSpecAllComplex=sum(SpecAll,2);
%     figure;plot(abs(SumSpecAllComplex))
    fidZero=zeros(8192,1);
    fidZero(1:2048)=fid01;
   
    AdsSumSpecAllComplex=abs(fftshift(fft(fidZero)));
    AdsSumSpecAllComplex=AdsSumSpecAllComplex/max(AdsSumSpecAllComplex);
    AdsSumSpecAllComplex=repmat(AdsSumSpecAllComplex,[1,length(AdsSumSpecAllComplex)]);
    
    res = wavDenoise(AdsSumSpecAllComplex,0.08); 
    figure;subplot(1,2,1);plot(AdsSumSpecAllComplex(:,1));subplot(1,2,2);plot(res(:,1));

    FidAllZero=zeros(8192,8);
    FidAllZero(1:2048,:)=FidAll;
    SpecAll=fftshift(fft((FidAllZero),[],1),1);
    imgNoiseVol=permute(SpecAll(:,1:8),[1,3,2]);
    imgNoiseVol=abs(imgNoiseVol)/max(abs(imgNoiseVol(:)));
    imgNoiseVol=repmat(imgNoiseVol,[1,16,1]);
    imgWaveletMultiframe = waveletMultiFrame(imgNoiseVol, 'k', 6, 'p', 4, 'maxLevel', 3, 'weightMode', 4, 'basis', 'dualTree');
    
    figure;
    subplot(1,2,1);plot((abs(sum(imgWaveletMultiframe,2))));subplot(1,2,2);plot((abs(sum(abs(SpecAll),2))))
    figure;
    subplot(1,2,1);plot((abs(sum(imgWaveletMultiframe,2)))/8);subplot(1,2,2);plot(res)
    
    SpecMulti=(abs(sum(imgWaveletMultiframe,2)))/8;
    SpecMulti=SpecMulti/max(SpecMulti);
    res=res/max(res);
    figure;plot(SpecMulti-mean(SpecMulti(10:20)),'k');hold on;plot(res-mean(res(10:20)),'r');
    
    
    
%     SumSpecAllComplexDenoise = cadzow(abs(SumSpecAllComplex), 50, 50);
%      figure;subplot(1,2,1);plot(abs(SumSpecAllComplex));subplot(1,2,2); plot(abs(SumSpecAllComplexDenoise))

%      figure;plot(abs(SpecAll(:,1)))
    
%     y = doubledual_S1D(abs(sum(SpecAll,2))/max(abs(sum(SpecAll,2))),0.05);            % denoise the noisy image using Double-Density Dual-Tree DWT
%     figure;
%     subplot(1,2,1);plot(abs(sum(SpecAll,2))/max(abs(sum(SpecAll,2))));
%     subplot(1,2,2);plot(abs(y));
    
%     AverageFidDenoise=cadzow(sum(fidReshape,2),60,100);
%     AverageSpec=fftshift(fft(sum(fidReshape,2), [], 1));
%     AverageSpecDenoise = fftshift(fft(AverageFidDenoise, [], 1));
%     figure;subplot(1,2,1);plot(abs(AverageSpec))
%     subplot(1,2,2);plot(abs(AverageSpecDenoise))
    
%     figure;plot(real(AllFidZeroFill))

    
%     ImagShowNum=18
%     figure('Name','all Spec');
%     ha = tight_subplot(1,ImagShowNum,0.001);
%     for iSilce=1:ImagShowNum
%         axes(ha(iSilce)); %#ok<LAXES>
%         plot((abs((SpecAll(:,iSilce)))));ylim([0,max(abs(SpecAll(:)))]);axis off;
%     end
%     
%     RankSet=4;
%     [U,S,V] = svd((SpecAll(1:end,:)),'econ');
%     svector=diag(S);
%     svector(RankSet+1:end)=0;
%     Sdenoise=diag(svector);
%     DenoisedSpecImag=U*Sdenoise*V';
%     figure;subplot(1,2,1);plot(abs(sum(DenoisedSpecImag,2)));subplot(1,2,2);plot((abs(sum(SpecAll,2))))
    
    
%     DenoiseSpec2Fid=fftshift(ifft(fftshift(DenoisedSpecImag,1),[],1),1);
%     DenoiseSpec2Fid=reshape(DenoiseSpec2Fid,[],1);
%     Fid_noise_sup = NASR(DenoiseSpec2Fid,'FID').';
    % %     noiseFid = AverageFid;


    
    
    
%     figure;subplot(1,2,1);plot(abs(sum(SpecAll,2)));subplot(1,2,2);plot((abs(sum(SpecAll(:,1:1),2))))
%     figure;plot(abs(sum(SpecAll,2))/max(abs(sum(SpecAll,2))),'r');hold on;
%     plot(abs(sum(SpecAll(:,1:1),2))/max(abs(sum(SpecAll(:,1:1),2))),'k');hold off;
    
    
    
%     ImagShowNum=18
%     figure('Name','all Spec');
%     ha = tight_subplot(2,ImagShowNum,0.001);
%     for iSilce=1:ImagShowNum
%         axes(ha(iSilce)); %#ok<LAXES>
%         plot((abs((SpecAll(:,iSilce)))));ylim([0,max(abs(SpecAll(:)))])
%         axes(ha(iSilce+ImagShowNum)); %#ok<LAXES>
%         plot((abs((DenoisedSpecImag(:,iSilce)))));ylim([0,max(abs(SpecAll(:)))])
%     end
%     
%     figure;plot(abs(DenoisedSpecImag(211,:)));hold on; plot(abs(SpecAll(211,:)),'r-*');hold on;
    
    
%     RankSet=3;
%     [U,S,V] = svd((AllFidZeroFill(1:end,:)),'econ');
%     svector=diag(S);
%     svector(RankSet+1:end)=0;
%     Sdenoise=diag(svector);
%     DenoisedSpecFid=U*Sdenoise*V';
%     DenoiseSpecAll=fftshift(fft(fftshift(DenoisedSpecFid),[],1));
%     figure;subplot(1,2,1);plot(abs(sum(DenoiseSpecAll,2)));subplot(1,2,2);plot((abs(sum(SpecAll,2))))
    
%     figure;stackedplot(abs(DenoiseSpecAll(1:1:end,:)),1,8);
%     figure;stackedplot(abs(SpecAll(1:1:end,:)),1,8);
%     figure;stackedplot(abs((DenoisedSpecImag(1:1:end,:))),1,8);
    
    
%     figure('Name','all Spec');
%     ha = tight_subplot(2,ImagShowNum,0.001);
%     for iSilce=1:ImagShowNum
%         axes(ha(iSilce)); %#ok<LAXES>
%         plot((abs((SpecAll(:,iSilce)))));;ylim([0,max(abs(SpecAll(:)))])
%         axes(ha(iSilce+ImagShowNum)); %#ok<LAXES>
%         plot((abs((DenoiseSpecAll(:,iSilce)))));;ylim([0,max(abs(SpecAll(:)))])
%     end
%     
%     figure;plot(abs(DenoiseSpecAll(512,:)));hold on; plot(abs(SpecAll(512,:)),'r-*');hold on;
    
    
    
    %%
    
    
    
    
%  [yOut] = cadzow(AllFidZeroFill(246:741,1), 15,100);
%  figure;plot(abs(fftshift(fft(yOut))))

 
% sigma=20;
% z=abs(SpecAll);
% z=z/max(z(:))*256;
% [NA, y_est] = BM3D(1, z, sigma);
% figure;subplot(1,2,1);imagesc(abs(z))
% subplot(1,2,2);imagesc(abs(y_est))
% figure;subplot(1,2,1);plot(abs(sum(y_est,2)));subplot(1,2,2);plot((abs(sum(SpecAll,2))))
% 
% figure('Name','all Spec');
% ha = tight_subplot(2,ImagShowNum,0.001);
% for iSilce=1:ImagShowNum
%     axes(ha(iSilce)); %#ok<LAXES>
%     plot((abs((SpecAll(:,iSilce)))));;ylim([0,max(abs(SpecAll(:)))])
%     axes(ha(iSilce+ImagShowNum)); %#ok<LAXES>
%     plot((abs((y_est(:,iSilce)))));;ylim([0,max(abs(y_est(:)))])
% end
% 
%  figure;plot(sum(abs(y_est(474:559,:)),1));hold on; plot(sum(abs(SpecAll(474:559,:)),1),'r-*');hold off;
 
 
 
 imgNoiseVol=permute(SpecAll(:,1:15),[1,3,2]);
 imgNoiseVol=abs(imgNoiseVol)/max(abs(imgNoiseVol(:)));
 imgNoiseVol=repmat(imgNoiseVol,[1,16,1]);
 imgWaveletMultiframe = waveletMultiFrame(imgNoiseVol, 'k', 6, 'p', 4, 'maxLevel', 3, 'weightMode', 4, 'basis', 'dualTree');
 


 figure;
 subplot(1,2,1);plot((abs(sum(imgWaveletMultiframe,2))));subplot(1,2,2);plot((abs(sum(abs(SpecAll),2))))
 
 imgWaveletMultiframeSum=(abs(sum(imgWaveletMultiframe,2)));
    imgWaveletMultiframeSumDenoise = cadzow(abs(imgWaveletMultiframeSum), 80, 100);
     figure;subplot(1,2,1);plot(abs(imgWaveletMultiframeSum));subplot(1,2,2); plot(abs(imgWaveletMultiframeSumDenoise))
