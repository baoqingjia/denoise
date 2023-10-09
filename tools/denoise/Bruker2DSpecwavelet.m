close all; clear ;clc

% FileDir='I:\topspindata\topspindata\4mm-20230130';
% FilePath='E:\Qingjia_work\NewMatlabCode\matlabcode\2DHyperSeH2O\RealData\2\';
% FilePath='D:\Qingjia_work\NewMatlabCode\matlabcode\2DHyperSeH2O\RealData\2_testReco'
FileDir='E:\Qingjia_work\NewMatlabCode\matlabcode\CSI_simulate\CSI_simulate\PHIP_Dynamic_image\27Al-poorSN\';

InitialScanNum=100;
SpecNum=16;

initialfidPath=[FileDir filesep num2str(InitialScanNum(1)) filesep];
sw1 = ReadTopspinParam(initialfidPath, 'SW_h');
Nf1 = ReadTopspinParam(initialfidPath, 'TD');
sw2 = ReadTopspin2DParam(initialfidPath, 'SW_h');
Nf2 = ReadTopspin2DParam(initialfidPath, 'TD');

AcquPoint=[Nf1/2 Nf2];% unit Hz`
Ta1=AcquPoint(1)/sw1;
Ta2=AcquPoint(2)/sw2;

%% ��ȡ�Ƶ����
DECIM =  ReadTopspinParam(initialfidPath, 'DECIM');
DSPFVS = ReadTopspinParam(initialfidPath, 'DSPFVS');
DIGMOD = ReadTopspinParam(initialfidPath, 'DIGMOD');
GRPDLY = ReadTopspinParam(initialfidPath, 'GRPDLY');
NrPointsToShift = DetermineBrukerDigitalFilter(DECIM, DSPFVS, DIGMOD,GRPDLY);
ShiftNum =  round( NrPointsToShift );
ShiftResidual= NrPointsToShift-ShiftNum;

pDataDir = [initialfidPath '/pdata/1'];
specPath = [pDataDir '/rr'];  %% ���������¼��procs��
ftSize = ReadTopspinParam(specPath, 'SI');
ftSize2D = ReadTopspin2DParam(specPath, 'SI');

%%
% rawdataAll=zeros([AcquPoint(1) 256 length(ScanNum)]);
% for iScan=1:length(ScanNum)
%     FilePath=[FileDir filesep num2str(ScanNum(iScan))];
%     filename= fullfile(FilePath, 'ser');
%     [fp, msg]=fopen(filename,'r','l');
%     if fp==-1  %������ļ����ɹ�
%         msgbox(msg);  % ��ʾ������ʾ��Ϣ
%         return;  %�˳�����
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

SpecAll2Dtemp=zeros([ftSize ftSize2D SpecNum]);
for it=1:1
    ScanNum{it}=3603+it;
    fidPath=[FileDir filesep num2str(ScanNum{it}(1)) filesep];
    FilePath=[fidPath filesep ];
    filename= fullfile(FilePath, '/pdata/1/2rr');
    [fp, msg]=fopen(filename,'r','l');
    if fp==-1  %������ļ����ɹ�
        msgbox(msg);  % ��ʾ������ʾ��Ϣ
        return;  %�˳�����
    end
    clear msg filename pathname fname;
    dat=fread(fp,inf,'int32');

    rawdataReal=reshape(dat,[ftSize ftSize2D]);

    filenameImag= fullfile(FilePath, '/pdata/1/2ri');
    [fp, msg]=fopen(filenameImag,'r','l');
    if fp==-1  %������ļ����ɹ�
        msgbox(msg);  % ��ʾ������ʾ��Ϣ
        return;  %�˳�����
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

 Realsum= real(sum(SpecAll2D, 3));
 RealimgWaveletMultiframe = waveletMultiFrame(real(SpecAll2D), 'k', 6, 'p',6, 'maxLevel', 5, 'weightMode', 4, 'basis', 'dualTree');
 v2=max(max(abs(RealimgWaveletMultiframe(:,:))));
 v22=v2*(0.855.^(1:20));
 x=linspace(243.1,-156.9,4096);
 y=linspace(25.54,-24.55,128);
 [X,Y]=meshgrid(x,y);
 figure;contour(X,Y,RealimgWaveletMultiframe',v22);
% 
 v3= max(max(abs(Realsum(:,:))));
 v33=v3*(0.855.^(1:20));
 figure;contour(X,Y,Realsum',v33);
 
 figure; subplot(1,2,1); plot(sum(Realsum,2));subplot(1,2,2); plot(sum(RealimgWaveletMultiframe,2))


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