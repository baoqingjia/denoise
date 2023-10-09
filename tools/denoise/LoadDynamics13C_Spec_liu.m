close all; clear;clc
% 
FidPath='E:\PV share\DMI\lxj_mouse_NSPECT_test.h31\12\';
FidPath='E:\PV share\DMI\lxj_mouse_T3_1208.hj1\8\';
FidPath='E:\PV share\DMI\lxj_mouse_T1_1207.hi1\';
FidPath='E:\PV share\DMI\lxj_mouse_T3_1208.hj1\';
% FidPath='E:\PV share\DMI\lxj_mouse_B16T1_1225.hA1\';
FidPath='E:\Qingjia_work\NewMatlabCode\matlabcode\CSI_simulate\CSI_simulate\PHIP_Dynamic_image\lxj_13C_coil_ref_power_230301.iF2\lxj_13C_coil_ref_power_230301.iF2\';

datalist=textread([FidPath 'datalist.txt'],'%u');

MoreAverage=1;   %%根据需要累加几次数据
Baselinbe=0;

fid=[];
for nexp=1:length(datalist)
    
ParaPath=[FidPath num2str(datalist(nexp)) filesep];
swHz = ReadPVParam(ParaPath, 'SW_h');
PVM_NRepetitions = ReadPVParam(ParaPath, 'PVM_NRepetitions');
fidpoints = ReadPVParam(ParaPath, 'PVM_SpecMatrix');
rawObj = RawDataObject(ParaPath);
RawData=squeeze(rawObj.data{1});
RawData=RawData(:,:)';

fid=cat(1,fid,RawData);
end

SizeTD1=size(fid,1);
PVM_NRepetitions=size(fid,1)/MoreAverage;
FidMoreAverage=reshape(fid,[MoreAverage,SizeTD1/MoreAverage,size(fid,2)]);
FidMoreAverage=squeeze(sum(FidMoreAverage,1));
fid=FidMoreAverage;
% figure;plot(real(fid(:,:)'));
%% 获取移点点数
DECIM = ReadPVParam(ParaPath, 'DECIM');
DSPFVS = ReadPVParam(ParaPath, 'DSPFVS');
DIGMOD = ReadPVParam(ParaPath, 'DIGMOD');
GRPDLY = ReadPVParam(ParaPath, 'GRPDLY');
PVM_FrqWork = ReadPVParam(ParaPath, 'SFO1');
NrPointsToShift = DetermineBrukerDigitalFilter(DECIM, DSPFVS, DIGMOD,GRPDLY);
ShiftNum =  round( NrPointsToShift );
ShiftResidual= NrPointsToShift-ShiftNum;

%% 加窗
lb =50;
fidSize=size(fid,2);
points = 0:1:(fidSize-1);
t=exp(-points.*(pi*lb/swHz));
tWindow=repmat(t,[PVM_NRepetitions,1]);
WindowFidData=fid.*t;
figure;plot(real(WindowFidData(:,:)'));title('addwin FID');


%% 移点
TempFidData=WindowFidData(:,1:ShiftNum);
WindowFidData=[WindowFidData(:, ShiftNum+1:end) TempFidData];
% [WindowFidData,Spec] = DelayInterpolation(WindowFidData,NrPointsToShift);
% WindowFidData(:,(fidpoints-ShiftNum+1):end)=0;
figure;plot(real(WindowFidData(:,:)'));

%% 填零
ftSize =1024;
fidAddWin = [WindowFidData zeros(size(fid,1),ftSize-fidSize)];
FidData=fidAddWin;
% figure;plot(real(FidData(:,:)'));

%% 傅里叶变换
DataBeforePhase1 = ifftshift((ifft(FidData(:,:),[],2)),2);
SumFid=sum(FidData,1);
figure;plot(abs(ifftshift((ifft(SumFid,[],2)),2)))

RankSet=3;
[U,S,V] = svd((DataBeforePhase1(Baselinbe+1:end,:)),'econ');
svector=diag(S);
svector(RankSet+1:end)=0;
Sdenoise=diag(svector);
DenoisedSpecImag=U*Sdenoise*V';
% DataBeforePhase1=cat(1,mean(DataBeforePhase1(1:Baselinbe,:),1), DenoisedSpecImag);
DataBeforePhase1=cat(1,DataBeforePhase1(1:Baselinbe,:), DenoisedSpecImag);

figure;plot(sum(abs(DataBeforePhase1(:,:)),1));
% [U,S,V] = svd((DataBeforePhase1(1:end,:)),'econ');
% svector=diag(S);
% svector(RankSet+1:end)=0;
% Sdenoise=diag(svector);
% DenoisedSpecImag=U*Sdenoise*V';
% DataBeforePhase1=DenoisedSpecImag;
% figure;plot(real(DataBeforePhase1(:,:)'));

sigma=10000;
SpecAll=DataBeforePhase1';
z=abs(SpecAll);
z=z/max(z(:))*256;
[NA, y_est] = BM3D(1, z, sigma);
figure;subplot(1,2,1);imagesc(abs(z))
subplot(1,2,2);imagesc(abs(y_est))
figure;subplot(1,2,1);plot(abs(sum(y_est,2)));subplot(1,2,2);plot((abs(sum(SpecAll,2))))

figure;plot(y_est(561,:));hold on;;plot(y_est(325,:));
figure;plot(z(561,:));hold on;;plot(z(325,:));

%% 相位校正
% DataBeforePhase1=DataBeforePhase1(1,:);
DataSize = size(DataBeforePhase1,2);

PHC0= -154.113;   %FidPath='E:\PV share\DMI\lxj_mouse_T3_1208.hj1\';
PHC1= 0;
% PHC0= -140;   %FidPath='E:\PV share\DMI\lxj_mouse_B16T1_1225.hA1\';
% PHC1= 0;
PHC0= 50;   %FidPath='E:\PV share\DMI\lxj_ICH_rat_control_230110.im1\';
PHC1= -30;
PHC0=PHC0*(pi/180.0);
PHC1=PHC1*(pi/180.0)+ShiftResidual*360*(pi/180.0);
disp(PHC0);
disp(PHC1);
a_num = ((0:DataSize-1))/(DataSize);
PhaseVector=exp(-1i*(PHC0+PHC1*a_num));
PhaseMap=repmat(PhaseVector,[size(DataBeforePhase1,1),1]);
PhaseDataAfterphc = DataBeforePhase1.*PhaseMap  ;
TrucTime=size(PhaseDataAfterphc,1);
figure;plot(real(PhaseDataAfterphc'));title('after phasw correcton');

% PhaseDataAfterphcShow=PhaseDataAfterphc(:,600:1300);
PhaseDataAfterphc=flip(PhaseDataAfterphc,2);
figure;plot(real(PhaseDataAfterphc'));

TimeScle=linspace(0,SizeTD1,PVM_NRepetitions);
FreqScale=linspace(-swHz/2,swHz/2,size(PhaseDataAfterphc,2));
PppmScale=FreqScale/PVM_FrqWork+3.282000000000000;
PppmScale=sort(PppmScale,'descend');
figure;stackedplot(real(PhaseDataAfterphc(1:end,:)'));
figure;stackedplot(real(PhaseDataAfterphc(1:end,:)')); title('singal with 1 time');
figure;stackedplot(real(PhaseDataAfterphc(1:end,:)'),1,5); title('singal with 5 times'); %时间曲线图
figure;plot(PppmScale,((sum(abs(PhaseDataAfterphc(1:end,:))))));title('singal with all times');set(gca,'xdir','reverse');

figure;plot(real(PhaseDataAfterphc(1,:)'));
PhaseDataAfterphc1=PhaseDataAfterphc;
% set(gca,'ylim',[0 1600]);
%% Dynamic change process
figure;plot((sum(real(PhaseDataAfterphc(1:end,:)))));
PeakCenter=[435,483,605];%FidPath='E:\PV share\DMI\lxj_mouse_T3_1208.hj1\';
% PeakCenter=[435,482,605];%FidPath='E:\PV share\DMI\lxj_mouse_B16T1_1225.hA1\';
PeakCenter=[445,485,556];%FidPath='E:\PV share\DMI\lxj_ICH_rat_control_230110.im1\';
RealData=real(PhaseDataAfterphc);
waterCenter=PeakCenter(1);
WaterPeakIndex=waterCenter-2:waterCenter+2;
WaterPeakDynamic=mean(RealData(:,WaterPeakIndex),2);
figure;plot(WaterPeakDynamic(1:TrucTime))
GlucoseCenter=PeakCenter(2);
GlucosePeakIndex=GlucoseCenter-2:GlucoseCenter+2;
GlucosePeakDynamic=mean(RealData(:,GlucosePeakIndex),2);
figure;plot(GlucosePeakDynamic(1:TrucTime))
lacCenter=PeakCenter(3);
LacPeakIndexReal=lacCenter-2:lacCenter+2;
LacPeakDynamic=mean(RealData(:,LacPeakIndexReal),2);
figure;plot(LacPeakDynamic(1:TrucTime))

figure;plot(TimeScle,WaterPeakDynamic(1:TrucTime)/max(WaterPeakDynamic(1:TrucTime)),'r'); hold on;
plot(TimeScle,GlucosePeakDynamic(1:TrucTime)/max(GlucosePeakDynamic(1:TrucTime)),'b'); 
plot(TimeScle,LacPeakDynamic(1:TrucTime)/max(LacPeakDynamic(1:TrucTime)),'k');hold off;

Lac_Glc=LacPeakDynamic./GlucosePeakDynamic;
% Lac_Glx= LacPeakDynamic./GlxPeakDynamic;
figure;plot(TimeScle(5:end),Lac_Glc(5:end));
% figure;plot(Lac_Glx(10:end));

disp(PHC0);
disp(PHC1);


%%
