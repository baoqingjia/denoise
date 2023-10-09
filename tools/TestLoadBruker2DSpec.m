close all; clear ;clc

FileDir='D:\NMRdata\800.202101-1.9mm-1H-17O-27Al\1.9mm-H-Al-20210109';
% FilePath='E:\Qingjia_work\NewMatlabCode\matlabcode\2DHyperSeH2O\RealData\2\';
% FilePath='D:\Qingjia_work\NewMatlabCode\matlabcode\2DHyperSeH2O\RealData\2_testReco'
ScanNum=4201;


fidPath=[FileDir filesep num2str(ScanNum(1)) filesep];
sw1 = ReadTopspinParam(fidPath, 'SW_h');
Nf1 = ReadTopspinParam(fidPath, 'TD');
sw2 = ReadTopspin2DParam(fidPath, 'SW_h');
Nf2 = ReadTopspin2DParam(fidPath, 'TD');

AcquPoint=[Nf1/2 Nf2];% unit Hz`
Ta1=AcquPoint(1)/sw1;
Ta2=AcquPoint(2)/sw2;

%% 获取移点点数
DECIM =  ReadTopspinParam(fidPath, 'DECIM');
DSPFVS = ReadTopspinParam(fidPath, 'DSPFVS');
DIGMOD = ReadTopspinParam(fidPath, 'DIGMOD');
GRPDLY = ReadTopspinParam(fidPath, 'GRPDLY');
NrPointsToShift = DetermineBrukerDigitalFilter(DECIM, DSPFVS, DIGMOD,GRPDLY);
ShiftNum =  round( NrPointsToShift );
ShiftResidual= NrPointsToShift-ShiftNum;

pDataDir = [fidPath '/pdata/1'];
specPath = [pDataDir '/rr'];  %% 处理参数记录在procs中
ftSize = ReadTopspinParam(specPath, 'SI');
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

SpecAll2D=zeros([ftSize ftSize2D length(ScanNum)]);
for iScan=1:length(ScanNum)
    FilePath=[fidPath filesep ];
    filename= fullfile(FilePath, '/pdata/1/2rr');
    [fp, msg]=fopen(filename,'r','l');
    if fp==-1  %如果打开文件不成功
        msgbox(msg);  % 显示错误提示信息
        return;  %退出程序
    end
    clear msg filename pathname fname;
    dat=fread(fp,inf,'int32');

    rawdataReal=reshape(dat,[ftSize ftSize2D]);

    filenameImag= fullfile(FilePath, '/pdata/1/2ri');
    [fp, msg]=fopen(filenameImag,'r','l');
    if fp==-1  %如果打开文件不成功
        msgbox(msg);  % 显示错误提示信息
        return;  %退出程序
    end
    clear msg filename pathname fname;
    dat=fread(fp,inf,'int32');

    rawdataImag=reshape(dat,[ftSize ftSize2D]);
    SpecAll2D(:,:,iScan)=rawdataReal+1i*rawdataImag;
    
    % Nf2=size(rawdata,1)/Nf1;
    fclose(fp);
    
end

RealSpec2D=real(SpecAll2D(:,:,1))';
% v1=3*max(max(abs(RealSpec2D(1:32,1:32))));
v1=3*max(max(abs(RealSpec2D(1:8,1:8))));
v=v1*(1.2.^(1:20));
figure;contour(real(SpecAll2D(:,:,1))',v)
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