close all; clear ;clc

FileDir='D:\to_install\Topspin\data\';
% FilePath='E:\Qingjia_work\NewMatlabCode\matlabcode\2DHyperSeH2O\RealData\2\';
% FilePath='D:\Qingjia_work\NewMatlabCode\matlabcode\2DHyperSeH2O\RealData\2_testReco'
ScanNum=3;

sw2=2556;% unit Hz
TR=30e-3;
Nf2=256;

fidPath=[FileDir filesep num2str(ScanNum(1)) filesep];
sw1 = ReadTopspinParam(fidPath, 'SW_h');
Nf1 = ReadTopspinParam(fidPath, 'TD');
sw2 = ReadTopspin2DParam(fidPath, 'SW_h');
Nf2 = ReadTopspin2DParam(fidPath, 'TD');

AcquPoint=[Nf1/2 Nf2];% unit Hz
Ta1=AcquPoint(1)/sw1;
Ta2=AcquPoint(2)/sw2;

%% 获取移点点数
DECIM = ReadTopspinParam(fidPath, 'DECIM');
DSPFVS = ReadTopspinParam(fidPath, 'DSPFVS');
DIGMOD = ReadTopspinParam(fidPath, 'DIGMOD');
GRPDLY = ReadTopspinParam(fidPath, 'GRPDLY');
NrPointsToShift = DetermineBrukerDigitalFilter(DECIM, DSPFVS, DIGMOD,GRPDLY);
ShiftNum =  round( NrPointsToShift );
ShiftResidual= NrPointsToShift-ShiftNum;
%%
rawdataAll=zeros([AcquPoint(1) 256 length(ScanNum)]);
for iScan=1:length(ScanNum)
    FilePath=[FileDir filesep num2str(ScanNum(iScan))];
    filename= fullfile(FilePath, 'ser');
    [fp, msg]=fopen(filename,'r','l');
    if fp==-1  %如果打开文件不成功
        msgbox(msg);  % 显示错误提示信息
        return;  %退出程序
    end
    clear msg filename pathname fname;
    dat=fread(fp,inf,'int32');
    size(dat)
    fidBruker=complex(dat(1:2:end-1), dat(2:2:end))';
    size(fidBruker)
    
    rawdata=reshape(fidBruker,[AcquPoint(1) AcquPoint(2)]);
    rawdataAll(:,:,iScan)=rawdata;
    % Nf2=size(rawdata,1)/Nf1;
    fclose(fp);
end

%%  window function
% lb = ReadTopspinParam(specPath, 'LB');
% fidSize=length(fid);
% points = 0:1:(fidSize-1);
% t=exp(-points.*(pi*lb/swHz));
% WindowFidData=fid.*t;
%figure(2);
%plot(real(WindowFidData(1,:)));
%title('addwin FID');
rawdataAllCos=rawdataAll(:,1:2:end);
rawdataAllSin=rawdataAll(:,2:2:end);
WindowFidDataCos=SinBell2D(rawdataAllCos,-Ta2,-Ta2,sw2); % Window function for Brukerser state-tppi data(F2)
WindowFidDataSin=SinBell2D(rawdataAllSin,-Ta2,-Ta2,sw2); % Window function for Brukerser state-tppi data(F2)
WindowFidData=0*rawdataAll;
WindowFidData(:,1:2:end)=WindowFidDataCos;
WindowFidData(:,2:2:end)=WindowFidDataSin;
WindowFidData=SinBell1D(WindowFidData, -Ta1, -Ta1,sw1,0); % Window function for Brukerser(F1)
WindowFidDataNoFilling=WindowFidData;
% WindowFidData=rawdataAll;
%% zerofilling 
pDataDir = [fidPath '/pdata/1'];
specPath = [pDataDir '/1r'];  %% 处理参数记录在procs中
ftSize = ReadTopspinParam(specPath, 'SI');
ftSize2D = ReadTopspin2DParam(specPath, 'SI');

fidAddWin=zeros(ftSize,ftSize2D*2);
fidAddWin(1:AcquPoint(1),1:AcquPoint(2)) = WindowFidData;
WindowFidData=fidAddWin;

NrPointsToShift = DetermineBrukerDigitalFilter(DECIM, DSPFVS, DIGMOD,GRPDLY);
NrPointsToShift = round(NrPointsToShift);
FidData=0*WindowFidData;
%     NrPointsToShift = 33;
for i = 1:AcquPoint(2)
    TempFidData=WindowFidData(1:NrPointsToShift,i);
    FidData(:,i)=[WindowFidData(NrPointsToShift+1:end,i)' TempFidData']';
end

%% 
Spec1D=fftshift(fft(FidData,[],1),1);
Spec1DCos=Spec1D(:,1:2:end);
Spec1DSin=Spec1D(:,2:2:end);

ComSpec1D=(real(Spec1DCos) + 1i*real(Spec1DSin));
ComSpec1DImag=(imag(Spec1DCos) + 1i*imag(Spec1DSin));
figure;plot(real(ComSpec1D(:,20)))

figure;plot(real(ComSpec1D))

Spec2D=(fft(ComSpec1D,[],2));
Spec2DImag=(fft(ComSpec1DImag,[],2));

Fidback=ifft(Spec2D,[],2);
Fidback=ifft(Fidback,[],1);
fidAddWin=zeros(ftSize,ftSize2D);
fidAddWin(1:size(Fidback,1)/2,1:size(Fidback,2)) = Fidback(1:size(Fidback,1)/2,1:size(Fidback,2));
fidAddWin(size(Fidback,1)/2+1+(ftSize-size(Fidback,1)):end,1:size(Fidback,2)) = Fidback(size(Fidback,1)/2+1:end,1:size(Fidback,2));
Spec2Dxx0=fft(fidAddWin,[],2);
Spec2Dxx0=fft(Spec2Dxx0,[],1);


RR=real(Spec2D);
RI=imag(Spec2D);
IR=real(Spec2DImag);
II=imag(Spec2DImag);
figure;contour(abs(Spec2D'),10)
figure;contour(abs(Spec2Dxx0'),10)
% Spec2D=fftshift(Spec2D,2);

% TestRead=[fidPath   'pdata\2\2rr'];
% fileID = fopen(TestRead,'r','l');
% Testdata=fread(fileID,inf,'int32');
% Testdata=reshape(Testdata,[2048,1024]); 
Max=10000;
% fclose(fileID);

FileStr={'2rr' '2ri' '2ir' '2ii'};
DataCell={RR,RI,IR, II};
WritePath=[fidPath  'pdata\1\'];
for i=1:size(FileStr,2)
    fileID = fopen([WritePath FileStr{i}],'w','l');
    fwrite(fileID,round(DataCell{i})/max(max(round(DataCell{i})))*Max,'int32');
    fclose(fileID);
end

%% now phase correction 
% figure;contour(RR,10)
figure;mesh(RR)
figure;subplot(1,2,1);plot(real(sum(RR,1)));
subplot(1,2,2);plot(squeeze(real(sum(RR,2))))

Spec2D=Spec2D';
L=size(Spec2D,1);
a_num=-((1:L)-0)/(L);

% testSpec=squeeze((sum(Spec2D,2)));
%  testSpecPhase = testSpec.* exp(1i*pi/180*(38+0*a_num)); 
%  figure;plot(real(testSpec),'r');hold on;
%  plot(real(testSpecPhase),'b');hold off;


for i=1:size(Spec2D,2)
 Spec2DPhaseCorr(:,i) = Spec2D(:,i) .* exp(sqrt(-1)*pi/180*(0-00*a_num))'; 
end

figure;subplot(1,2,1);plot(real(sum(Spec2D,2)));
subplot(1,2,2);plot(squeeze(real(sum(Spec2DPhaseCorr,2))))

L2=size(Spec2D,2);
a_num2=-((1:L2)-0)/(L2);
for i=1:size(Spec2D,1)
 Spec2DPhaseCorr(i,:) = Spec2DPhaseCorr(i,:) .* exp(sqrt(-1)*pi/180*(57+0*180*a_num2)); 
end

figure;contour(abs(Spec2DPhaseCorr),10)
figure;mesh(real(Spec2DPhaseCorr))
figure;subplot(1,2,1);plot(real(sum(Spec2DPhaseCorr,1)));
subplot(1,2,2);plot(squeeze(real(sum(Spec2DPhaseCorr,2))))
disp('over')

%% Now try to simulation undersample
ScanNum=10;
FilePath=[FileDir filesep num2str(ScanNum(1))];
pDataDir = [FilePath '/pdata/1'];
specPath = [pDataDir '/1r'];  %% 处理参数记录在procs中
SampleIndex=load([FilePath filesep 'nuslist']);
SampleIndex=round(SampleIndex/2)+1;
MaskSample=zeros(size(ComSpec1D));
% MaskSample(:,1:128)=1;
R = 16;
ProbDe=5;
AcquPointTest=[AcquPoint(1) AcquPoint(2)/2];

% GenMaskTemp;
% MaskSample(:,SampleIndex+1,iScan)=1;
mask2D=MaskSample(:,:,1);

for iCos=1:2
    if(iCos==1)
        ComSpec1DRaw=ComSpec1D;
        ComSpec1D=ComSpec1D.*mask2D;
    else
        ComSpec1D=ComSpec1DImag.*mask2D;
    end
    
    
    mask1D=mask2D(2,:);
    %%  to reco per point by point
    ComSpec1DNus=ComSpec1D;
    x_sum0=zeros(size(ComSpec1D));
    x_RecoRank=zeros(size(ComSpec1D));
    ph=1;
    N = 50; % (100)
    NN = 3; %hardThreshold (20) 12 if lb=1 - 14
    lambda = 0.0001; % SoftThreshold (0.009) 0.007 - 0.01
    nIter = 200; % number of iterations
    
    options.lambda = 3000;
    for nf1=1:AcquPoint(1)
        x = ComSpec1DNus(nf1,:,:);%reshape(ComSpec1DNus(54,:),[],1);
        SIG_u =ComSpec1DNus(nf1,:,:);
%         maxsig = abs(max(abs(x)));
%         x=x/maxsig;
%         SIG_u=SIG_u/maxsig;
        for n=1:nIter
%             xRealImag=zeros(size(mask2D(nf1,:)));
%             SIG_uRealImag=zeros(size(mask2D(nf1,:)));
            
            X = im2row(x.*conj(ph),[1,N]);
            [U,S,V] = svd(X,'econ');
            S = SoftThresh(S,S(1,1)*lambda);
            X(:,:) = U(:,1:NN)*S(1:NN,1:NN)*V(:,1:NN)';
            %x = row2im(X,[size(x,1),1,1],[N,1]).*ph;
            x = row2im(X,[1,size(x,2),size(x,3)],[1,N]).*ph;
   
            x = (x.*(1-mask2D(nf1,:,:)) + SIG_u.*mask2D(nf1,:,:));
 
            %     figure(1000);subplot(1,2,1);plot(real(SIG_u(120,:,1)));
            %     subplot(1,2,2);plot(real(x(120,:,1)));
%             if(mod(n,200)==0)
%                 %         figure (1), plot(1:AcquPoint(1),real(fft(x(:,:,1).*conj(ph),[],2)),'k',1:AcquPoint(1),real(fft(SIG_u(:,:,2).*conj(ph),[],1)),'r'); drawnow;
%                 figure (1), plot(1:AcquPoint(2)/2,real((x(:,:,1).*conj(ph))),'k*',1:AcquPoint(2)/2,real((SIG_u(:,:,1).*conj(ph))),'ro'); drawnow;
%             end
        end
%         x=x*maxsig;
        x_sum0(nf1,:,:)=x;

        
        Idx=find(mask1D(:)==1);
        f_s=SIG_u(Idx);
        f_lr = low_rank(transpose(f_s), Idx, length(mask1D), options); % reconstructed FID
%         f_lr=f_lr*maxsig;
        x_RecoRank(nf1,:,:)=f_lr;
        
%         figure (1), plot(1:AcquPoint(2)/2,real((x(:,:,1).*conj(ph))),'k*',.....
%             1:AcquPoint(2)/2,real(ComSpec1DRaw(nf1,:,:)),'ro'); drawnow;
%         figure (2), plot(1:AcquPoint(2)/2,real((f_lr(:,:,1).*conj(ph))),'k*',.....
%             1:AcquPoint(2)/2,real(ComSpec1DRaw(nf1,:,:)),'ro'); drawnow;

%         figure (1), plot(1:AcquPoint(2)/2,real(fft(x(:,:,1).*conj(ph))),'-k*',.....
%             1:AcquPoint(2)/2,real(fft(ComSpec1DRaw(nf1,:,:))),'-ro'); drawnow;
%         figure (2), plot(1:AcquPoint(2)/2,real(fft(f_lr(:,:,1).*conj(ph))),'-k*',.....
%             1:AcquPoint(2)/2,real(fft(ComSpec1DRaw(nf1,:,:))),'-ro'); drawnow;

        disp(['nf1=',num2str(nf1)]);
    end
    if(iCos==1)
    RealFinalRecoSpec=fft(x_sum0,[],2);
%     FinalRecoFid(:,1:2:end)=RealFinalRecoFid;
    else
    ImagFinalRecoSpec=fft(x_sum0,[],2);
%   FinalRecoFid(:,2:2:end)=ImagFinalRecoFid;
    end
    
    Spec2Dxx0=fft(x_sum0,[],2);  
    Fidback=ifft(Spec2Dxx0,[],2);
    Fidback=ifft(Fidback,[],1);
    fidAddWin=zeros(ftSize,ftSize2D);
    fidAddWin(1:size(Fidback,1)/2,1:size(Fidback,2)) = Fidback(1:size(Fidback,1)/2,1:size(Fidback,2));
    fidAddWin(size(Fidback,1)/2+1+(ftSize-size(Fidback,1)):end,1:size(Fidback,2)) = Fidback(size(Fidback,1)/2+1:end,1:size(Fidback,2));
    Spec2Dxx0=fft(fidAddWin,[],2);
    Spec2Dxx0=fft(Spec2Dxx0,[],1);
    figure;contour(squeeze(abs(Spec2Dxx0(:,:,1)')))
    figure;mesh(squeeze(real(Spec2Dxx0(:,:,1)')))
    
   
    Spec2Dxx0Rank=fft(x_RecoRank,[],2);
    FidbackRank=ifft(Spec2Dxx0Rank,[],2);
    FidbackRank=ifft(FidbackRank,[],1);
    fidAddWinRank=zeros(ftSize,ftSize2D);
    fidAddWinRank(1:size(FidbackRank,1)/2,1:size(FidbackRank,2)) = FidbackRank(1:size(FidbackRank,1)/2,1:size(FidbackRank,2));
    fidAddWinRank(size(FidbackRank,1)/2+1+(ftSize-size(FidbackRank,1)):end,1:size(FidbackRank,2)) = FidbackRank(size(FidbackRank,1)/2+1:end,1:size(FidbackRank,2));
    Spec2Dxx0Rank=fft(fidAddWinRank,[],2);
    Spec2Dxx0Rank=fft(Spec2Dxx0Rank,[],1);
    figure;contour(squeeze(abs(Spec2Dxx0Rank(:,:,1)')))
    figure;mesh(squeeze(real(Spec2Dxx0Rank(:,:,1)')))
    
    
    FilePath=[FileDir filesep num2str(TryIndex)];
    WritePath=[FilePath  'pdata\3\'];
    if(iCos==1 )
        Spec2Dxx0Real=real(Spec2Dxx0);
        fileID = fopen([WritePath '2rr'],'w','l');
        fwrite(fileID,round(Spec2Dxx0Real)/max(max(round(Spec2Dxx0Real)))*10000,'int32');
        fclose(fileID);
        Spec2Dxx0Imag=imag(Spec2Dxx0);
        fileID = fopen([WritePath '2ri'],'w','l');
        fwrite(fileID,round(Spec2Dxx0Imag)/max(max(round(Spec2Dxx0Imag)))*10000,'int32');
        fclose(fileID);
    end
    if(iCos==2 )
        Spec2Dxx0Real=real(Spec2Dxx0);
        fileID = fopen([WritePath '2ir'],'w','l');
        fwrite(fileID,round(Spec2Dxx0Real)/max(max(round(Spec2Dxx0Real)))*10000,'int32');
        fclose(fileID);
        Spec2Dxx0Imag=imag(Spec2Dxx0);
        fileID = fopen([WritePath '2ii'],'w','l');
        fwrite(fileID,round(Spec2Dxx0Imag)/max(max(round(Spec2Dxx0Imag)))*10000,'int32');
        fclose(fileID);
    end
end

