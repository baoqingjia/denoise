function [outputArg1,outputArg2] = LoadBrukerFID()
%LOADBRUKERFID 此处显示有关此函数的摘要
%   此处显示详细说明

clc;close all;clear all;

dataPath = 'RatPlasmaNoesy/1101';
pDataDir = [dataPath '/pdata/1'];

%% 读取FID
fidPath = [dataPath '/fid'];
swHz = ReadTopspinParam(fidPath, 'SW_h');
fidpoints = ReadTopspinParam(fidPath, 'TD');
SizeTD1 = 1;
ByteOrder = 2;
[fid, SizeTD2, SizeTD1] = GetFIdFromBidary(fidPath, fidpoints, SizeTD1, ByteOrder);
figure(1);
plot(real(fid(1,:)));
title('raw FID');

specPath = [pDataDir '/1r'];  %% 处理参数记录在procs中
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
ShiftNum =  round( NrPointsToShift );
ShiftResidual= NrPointsToShift-ShiftNum;

%% 加窗
lb = ReadTopspinParam(specPath, 'LB');
fidSize=length(fid);
points = 0:1:(fidSize-1);
t=exp(-points.*(pi*lb/swHz));
WindowFidData=fid.*t;
figure(2);
plot(real(WindowFidData(1,:)));
title('addwin FID');

%% 填零
ftSize = ReadTopspinParam(specPath, 'SI');
fidAddWin = [WindowFidData zeros(1,ftSize-fidSize)];

%% 移点
TempFidData=fidAddWin(:,1:ShiftNum);
FidData=[fidAddWin(:, ShiftNum+1:end) TempFidData];

%% 傅里叶变换
DataBeforePhase1 = ifftshift((ifft(FidData(1,:))));
figure(3);
plot(real(DataBeforePhase1));

%% 相位校正
DataSize = length(DataBeforePhase1);
PHC0= ReadTopspinParam(specPath, 'PHC0');
PHC1= ReadTopspinParam(specPath, 'PHC1');
PHC0=PHC0*(pi/180.0);
PHC1=PHC1*(pi/180.0)+ShiftResidual*360*(pi/180.0);
a_num = ((0:DataSize-1))/(DataSize);
PhaseDataAfterphc = DataBeforePhase1 .* exp(-1i*(PHC0+PHC1*a_num));
figure(4);
plot(real(PhaseDataAfterphc));
% figure(5);
% plot(imag(PhaseDataAfterphc));


%% 读取谱数据
% [SpecDataReal,SpecDataImg] = LoadBrukerSpec(specPath);
% SpecDataReal = SpecDataReal;
% figure(5);
% plot(real(SpecDataReal));
% 
% 
% PhaseDataAfterphc=real(PhaseDataAfterphc);
% PhaseDataAfterphc = PhaseDataAfterphc/max(real(PhaseDataAfterphc))*max(SpecDataReal);
% 
% PhaseDataAfterphc = PhaseDataAfterphc - mean(PhaseDataAfterphc(400:500));
% % figure(6);
% % plot(BaseLine);
% 
% figure(7);
% plot(real(PhaseDataAfterphc) ,'r');
% hold on;
% plot(SpecDataReal,'b');
end

