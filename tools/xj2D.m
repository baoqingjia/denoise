close all; clear ;clc
FileDir='D:\topspin\1.9mm-H-X-20230603-multiHMQC\1.9mm-H-X-20230603-multiHMQC';
%FileDir='D:\NMRdata\3605';
% FilePath='E:\Qingjia_work\NewMatlabCode\matlabcode\2DHyperSeH2O\RealData\2\';
% FilePath='D:\Qingjia_work\NewMatlabCode\matlabcode\2DHyperSeH2O\RealData\2_testReco'

InitialScanNum=5010;
SpecNum=1;

initialfidPath=[FileDir filesep num2str(InitialScanNum) filesep];           
sw1 = ReadTopspinParam(initialfidPath, 'SW_h');    %FID信号总带宽
Nf1 = ReadTopspinParam(initialfidPath, 'TD');
sw2 = ReadTopspin2DParam(initialfidPath, 'SW_h');
Nf2 = ReadTopspin2DParam(initialfidPath, 'TD');

AcquPoint=[Nf1/2 Nf2];        %计算采样点数量
Ta1=AcquPoint(1)/sw1;         
Ta2=AcquPoint(2)/sw2;

%% 获取移点点数
DECIM =  ReadTopspinParam(initialfidPath, 'DECIM');      %表示bruker系统adc采集时的抽样率
DSPFVS = ReadTopspinParam(initialfidPath, 'DSPFVS');     %表示数字化后的信号采样率
DIGMOD = ReadTopspinParam(initialfidPath, 'DIGMOD');     %表示bruker系统数字化模式
GRPDLY = ReadTopspinParam(initialfidPath, 'GRPDLY');     %表示bruker系统出射信号是否经过了延迟线
NrPointsToShift = DetermineBrukerDigitalFilter(DECIM, DSPFVS, DIGMOD,GRPDLY);  %计算数字滤波器的移位量（即需要平移的数据点数）
ShiftNum =  round( NrPointsToShift );                    %计算整数移位数量
ShiftResidual= NrPointsToShift-ShiftNum;                 %计算小数移位数量

pDataDir = [initialfidPath 'pdata\1'];
specPath = [pDataDir '\2rr'];                            %处理参数记录在procs中
ftSize = ReadTopspinParam(specPath, 'SI');               %表示SI参数经过傅里叶变换后的磁共振信号采样点的数量
ftSize2D = ReadTopspin2DParam(specPath, 'SI');

%%
% rawdataAll=zeros([AcquPoint(1) 256 length(ScanNum)]);
% for iScan=1:length(ScanNum)
%     FilePath=[FileDir filesep num2str(ScanNum(iScan))];
%     filename= fullfile(FilePath, 'ser');
%     [fp, msg]=fopen(filename,'r','l');
%     if fp==-1  %如果打开文件不成功
%         msgbox(msg);  % 显示错误提示信息
%         return;  %退出程序
%     end
%     clear msg filename pathname fname;
%     dat=fread(fp,inf,'int32');
%     size(dat)
%     fidBruker=complex(dat(1:2:end-1), dat(2:2:end))';
%     size(fidBruker)
%     
%     rawdata=reshape(fidBruker,[AcquPoint(1) AcquPoint(2)]);
%     rawdataAll(:,:,iScan)=rawdata;
%     
%      dat=fread(fp,inf,'int32');
%     
%     % Nf2=size(rawdata,1)/Nf1;
%     fclose(fp);
%     
% end

SpecAll2Dtemp=zeros([ftSize ftSize2D SpecNum]);                   %读取磁共振波谱数据，将数据reshape成一个3D数组，存储在SpecAll2D中
for it=1:8
    ScanNum{it}=5010+2*it;
    fidPath=[FileDir filesep num2str(ScanNum{it}(1)) filesep];
    FilePath=[fidPath filesep ];
    filename= fullfile(FilePath, '\pdata\1\2rr');
    [fp, msg]=fopen(filename,'r','l');
    if fp==-1  %如果打开文件不成功
        msgbox(msg);  % 显示错误提示信息
        return;  %退出程序
    end
    clear msg filename pathname fname;
    dat=fread(fp,inf,'int32');

    rawdataReal=reshape(dat,[ftSize ftSize2D]);

    filenameImag= fullfile(FilePath, '\pdata\1\2ri');
    [fp, msg]=fopen(filenameImag,'r','l');
    if fp==-1  %如果打开文件不成功
        msgbox(msg);  % 显示错误提示信息
        return;  %退出程序
    end
    clear msg filename pathname fname;
    dat=fread(fp,inf,'int32');

    rawdataImag=reshape(dat,[ftSize ftSize2D]);
    SpecAll2Dtemp(:,:,it)=rawdataReal+1i*rawdataImag;
    SpecAll2D(:,:,it)=SpecAll2Dtemp(:,:,it);
    % Nf2=size(rawdata,1)/Nf1;
    fclose(fp);
    
% end



 
end

 RealSpec2D{1}=real(SpecAll2D(:,:,1));
 RealSpec2D{2}=real(SpecAll2D(:,:,2));
 RealSpec2D{3}=real(SpecAll2D(:,:,3));
 RealSpec2D{4}=real(SpecAll2D(:,:,4));
 RealSpec2D{5}=real(SpecAll2D(:,:,5));
 RealSpec2D{6}=real(SpecAll2D(:,:,6));
 RealSpec2D{7}=real(SpecAll2D(:,:,7));
 RealSpec2D{8}=real(SpecAll2D(:,:,8));

 
 
 
 

 Realsum= real(sum(SpecAll2D, 3));                    %对SpecAll2D沿第三维进行求和，提取实部信息
 RealimgWaveletMultiframe = waveletMultiFrame(real(SpecAll2D), 'k', 6, 'p',6, 'maxLevel', 5, 'weightMode', 4, 'basis', 'dualTree');
 v2=max(max(abs(RealimgWaveletMultiframe(:,:))));     %计算变换结果的最大绝对值
 v22=v2*(0.855.^(1:20));
 x=linspace(243.1,-156.9,4096);
 y=linspace(25.54,-24.55,128);
 [X,Y]=meshgrid(x,y);
 figure;contour(X,Y,RealimgWaveletMultiframe',v22);   %绘制等高线图
% 
 v3= max(max(abs(Realsum(:,:))));
 v33=v3*(0.855.^(1:20));
 figure;contour(X,Y,Realsum',v33);
 
 figure; subplot(1,2,1); plot(sum(Realsum,2));subplot(1,2,2); plot(sum(RealimgWaveletMultiframe,2))


sigma=20;
z=abs(Realsum);
z=z/max(z(:))*256;
[NA, y_est] = BM3D(3, z, sigma);
figure;subplot(1,2,1);imagesc(abs(z))
subplot(1,2,2);imagesc(abs(y_est))
figure;subplot(1,2,1);plot(abs(sum(y_est,2)));subplot(1,2,2);plot((abs(sum(Realsum,2))))
v2=max(max(abs(y_est(:,:))));     %计算变换结果的最大绝对值
v22=v2*(0.855.^(1:20));
x=linspace(243.1,-156.9,4096);
y=linspace(25.54,-24.55,128);
[X,Y]=meshgrid(x,y);
figure;contour(X,Y,y_est',v22);   %绘制等高线图
% 
v3= max(max(abs(Realsum(:,:))));
v33=v3*(0.855.^(1:20));
figure;contour(X,Y,Realsum',v33);
 
figure; subplot(1,2,1); plot(sum(Realsum,2));subplot(1,2,2); plot(sum(y_est,2))
 
 
RankSet=4;                                    %表示需要保留的前RankSet个奇异值
[U,S,V] = svd((Realsum(1:end,:)),'econ');
svector=diag(S);
svector(RankSet+1:end)=0;
Sdenoise=diag(svector);
DenoisedSpecImag=U*Sdenoise*V';
    
v2=max(max(abs(DenoisedSpecImag(:,:))));     %计算变换结果的最大绝对值
v22=v2*(0.855.^(1:20));
x=linspace(243.1,-156.9,4096);
y=linspace(25.54,-24.55,128);
[X,Y]=meshgrid(x,y);
figure;contour(X,Y,DenoisedSpecImag',v22);   %绘制等高线图
% 
v3= max(max(abs(Realsum(:,:))));
v33=v3*(0.855.^(1:20));
figure;contour(X,Y,Realsum',v33);
figure;subplot(1,2,1);plot(abs(sum(DenoisedSpecImag,2)));subplot(1,2,2);plot((abs(sum(Realsum,2))))   %svd，原始
% 
% [x,y]=ginput(3);
% x=sort(x);
% x(1)=round(x(1));
% x(2)=round(x(2));
% x(3)=round(x(3));
% y(1)=round(y(1));
% y(2)=round(y(2));
% y(3)=round(y(3));
% disp('over')