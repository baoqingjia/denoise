% function [outputArg1,outputArg2] = LoadBrukerFID()
%LOADBRUKERFID 此处显示有关此函数的摘要
%   此处显示详细说明
function LoadBrukerFID_bao_2()
clc;close all;

dataPath = 'In situ data/4';
dataPath='E:\Qingjia_work\NewMatlabCode\matlabcode\CSI_simulate\CSI_simulate\PHIP_Dynamic_image\4\';

%% 读取FID
fidPath = [dataPath '/fid'];
if(~exist(fidPath))
   fidPath = [dataPath '/ser']; 
end
swHz = ReadTopspinParam(fidPath, 'SW_h');
fidpoints = ReadTopspinParam(fidPath, 'TD');
if(exist([dataPath '/acqu2s']))
SizeTD1 = ReadTopspinParam2D(fidPath, 'TD');
else
    SizeTD1=1;
end
% SizeTD1 = 1202;
ByteOrder = 2;
[fid, SizeTD2, SizeTD1] = GetFIdFromBidary(fidPath, fidpoints, SizeTD1, ByteOrder);
figure(1);
plot(real(fid(1,:)));
% fid=fid(200:end,:);
% SizeTD1=size(fid,1);

MoreAverage=1;
Baselinbe=0;
if(SizeTD1>MoreAverage)
    RoundAverage=floor(SizeTD1/MoreAverage);
    fid=fid(1:RoundAverage*MoreAverage,:);
    FidMoreAverage=reshape(fid,[MoreAverage,RoundAverage,size(fid,2)]);
    FidMoreAverage=squeeze(sum(FidMoreAverage,1));
    fid=FidMoreAverage;
    SizeTD1=RoundAverage;
end

title('raw FID');


specPath = [dataPath '/pdata/1/1r'];  %% 处理参数记录在procs中
swppm = ReadTopspinParam(specPath, 'SW');
offsetppm = ReadTopspinParam(specPath, 'OFFSET');
lockppm = ReadTopspinParam(specPath, 'LOCKPPM');
swppmHalf=swppm/2;
IdealWater=offsetppm-swppmHalf;
Diff=-(IdealWater-lockppm);

%% 获取移点点数
DECIM = ReadTopspinParam(fidPath, 'DECIM');
DSPFVS = ReadTopspinParam(fidPath, 'DSPFVS');
DIGMOD = ReadTopspinParam(fidPath, 'DIGMOD');
GRPDLY = ReadTopspinParam(fidPath, 'GRPDLY');
NrPointsToShift = DetermineBrukerDigitalFilter(DECIM, DSPFVS, DIGMOD,GRPDLY);
ShiftNum = 0 * round( NrPointsToShift );

%% 加窗
lb = ReadTopspinParam(specPath, 'LB');
% lb = 0;
fidSize=fidpoints/2;
points = 0:1:(fidSize-1);
t=exp(-points.*(pi*lb/swHz));
if(SizeTD1>1)
    t=repmat(t,[SizeTD1,1]);
end
WindowFidData=fid.*t;
figure(2);
plot(real(WindowFidData(1,:)));
title('addwin FID');



%% 填零
ftSize = 0;%ReadTopspinParam(specPath, 'SI');
if(SizeTD1>1)
    fidAddWin = cat(2,WindowFidData, zeros([SizeTD1,ftSize-fidSize]));
else
fidAddWin = [WindowFidData zeros(1,ftSize-fidSize)];
end

%% 移点
TempFidData=fidAddWin(:,1:ShiftNum);
FidData=[fidAddWin(:, ShiftNum+1:end) TempFidData];

%% 傅里叶变换
if(SizeTD1>1)
    DataBeforePhase1 =  ifftshift((ifft(FidData(:,:),[],2)),2);
else
    DataBeforePhase1 = ifftshift((ifft(FidData(1,:))));
end
figure(3);
plot(real(DataBeforePhase1(1,:)));

figure(3);
plot(sum(abs(DataBeforePhase1(:,:))));


%% 相位校正
DataSize = length(DataBeforePhase1);
PHC0= ReadTopspinParam(specPath, 'PHC0');
PHC1= ReadTopspinParam(specPath, 'PHC1');
PHC0=PHC0*(pi/180.0);
PHC1=PHC1*(pi/180.0)+NrPointsToShift*360*(pi/180.0);
% pivot = (offsetppm-Diff)*(DataSize/swppm);
% PHC0=1.8*Diff*100*PHC1+PHC0;
% PHC0 = -0.087*PHC1 + PHC0;

a_num = ((0:DataSize-1))/(DataSize);
if(SizeTD1>1)
    PhaseVector=exp(-1i*(PHC0+PHC1*a_num));
    PhaseVector=repmat(PhaseVector,[SizeTD1,1]);
    PhaseDataAfterphc = DataBeforePhase1 .* PhaseVector;
else
    PhaseDataAfterphc = DataBeforePhase1 .* exp(-1i*(PHC0+PHC1*a_num));
end

PhaseDataAfterphc=PhaseDataAfterphc(:,100:end-100);
PhaseDataRef=real(PhaseDataAfterphc);

PhaseDataAfterphc=(PhaseDataAfterphc);
PhaseDataAfterphc=PhaseDataAfterphc-mean(PhaseDataAfterphc(:));

FIDback=(fft(PhaseDataAfterphc));
figure;plot(real(FIDback))
figure;subplot(1,2,1);plot(real(PhaseDataAfterphc));
subplot(1,2,2);plot(real(((ifft(FIDback(1,:))))))

%%
im=FIDback;%real(PhaseDataAfterphc);
FT = 1;
N = length(FIDback);

L =100;
%L = target_rank+1;

% T is the prediction matrix before filtering.
T = conj(hankel(im(1:N-L),im(N-L:N).'));

data=FIDback';
data=data/max(abs(data(:)));

%generate transform operator

% XFM = Wavelet('Daubechies',8,4);	% Wavelet
% XFM = TIDCT(8,4);			% DCT
XFM = 1;				% Identity transform 	
TVWeight = 0.01; 	% Weight for TV penalty
xfmWeight = 0.1;	% Weight for Transform L1 penalty
Itnlim = 20;		% Number of iterations
% initialize Parameters for reconstruction
param = init;
param.FT = FT;
param.XFM = XFM;
param.TV = TVOP;
param.data = data;
param.TVWeight =TVWeight;     % TV penalty 
param.xfmWeight = xfmWeight;  % L1 wavelet penalty
param.Itnlim = Itnlim;

im_dc = FT'*(data);	% init with zf-w/dc (zero-fill with density compensation)
figure(100), imshow(abs(im_dc),[]);drawnow;

res = XFM*im_dc;



% do iterations
tic
for n=1:8
	res = fnlCg(res,param);
	im_res = XFM'*res;
	figure(100), imshow(abs(im_res),[]), drawnow
end
toc

% yOut = conj([im_res(:,1); im_res(size(im_res,1),2:size(im_res,2)).']);
figure;subplot(1,2,1);plot(real(PhaseDataAfterphc));
% subplot(1,2,2);plot(real((((yOut(:)')))))
subplot(1,2,2);plot(real(((fft(im_res(:,1)')))))

%%    %% fista solution 
	Y      = T/max(abs(T(:)));
	D      = 1;
    function c = calc_F(X)
        c = (0.5*normF2(Y - D*X) + lambda*norm1(X))/size(X, 2);
    end
	lambda = 0.2;
	opts.pos = true;
	opts.lambda = lambda;
    opts.backtracking = false;
	X_fista = fista_lasso(Y, D, [], opts);
yOut = conj([X_fista(:,1); X_fista(size(X_fista,1),2:size(X_fista,2)).']);
figure;subplot(1,2,1);plot(real(PhaseDataAfterphc));
% subplot(1,2,2);plot(real((((yOut(:)')))))
subplot(1,2,2);plot(real(((fft(yOut(:,1)')))))
    
%%
[yOut] = cadzow(FIDback, 50, 100);
WindowFidDataNew=yOut';
figure;subplot(1,2,1);plot(real(PhaseDataAfterphc));
subplot(1,2,2);plot(real(((fft(WindowFidDataNew(1,:))))))

    %% rALOHA    
%     diter=2;
%     Nimg=25;
%     dname='barbara';
%     Nfir=11;
% tolE=tolE_set(diter);
%     mask=ones(size(FIDback));
%     param=struct('iname',dname,'mask',mask,'dimg',dimg,...
%         'mu',1e0,'beta',1e0,'tau',tau,...
%         'tolE',tolE,'tolE_stop',1e-4,...
%         'muiter',50,'Nimg',Nimg,'Nfir',Nfir,'d',d,'Nc',1,...
%         'maxval',255,'opt_inc','inc');
%     
%     [recon,reconE,t_pro] = aloha_sl(param);
%     error = img - recon;
%     psnr_aloha = 10*log10(1/mean((error(:)).^2));
%     display(['PSNR (ALOHA) : ' num2str(psnr_aloha,4)])

    %%
RankSet=3;
[U,S,V] = svd((PhaseDataAfterphc(Baselinbe+1:end,:)),'econ');
svector=diag(S);
svector(RankSet+1:end)=0;
Sdenoise=diag(svector);
DenoisedSpecImag=U*Sdenoise*V';
% DataBeforePhase1=cat(1,mean(DataBeforePhase1(1:Baselinbe,:),1), DenoisedSpecImag);
PhaseDataAfterphc=cat(1,PhaseDataAfterphc(1:Baselinbe,:), DenoisedSpecImag);

if(SizeTD1==1)
    figure(4);
    plot(real(PhaseDataAfterphc(1,:)));
else
    figure(4);
    plot(sum(real(PhaseDataAfterphc(:,:))));
end
% figure(5);
% plot(imag(PhaseDataAfterphc));


figure;imagesc(abs(real(PhaseDataAfterphc(1:1:end,:))'));
figure;stackedplot(real(PhaseDataAfterphc(1:10:end,:)'),1,1);

figure;plot(real(PhaseDataRef(end,:)),'r');hold on;
plot(real(PhaseDataAfterphc(end,:)),'b');hold off;

figure;plot(real(PhaseDataAfterphc(:,3716)))
disp('over')
% end
end
