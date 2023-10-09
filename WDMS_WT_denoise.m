close all; clear ;clc
% FileDir='E:\Qingjia_work\NewMatlabCode\matlabcode\CSI_simulate\CSI_simulate\PHIP_Dynamic_image\JMR_denoisePaper\4mm-20230130\';
% FileDir='E:\code\PHIP_Dynamic_image\4mm-20230130-2';
% InitialScanNum=100;
% SpecNum=16;

FileDir='E:\code\PHIP_Dynamic_image\400.4mm.20230906';
InitialScanNum=30;
SpecNum=8;

initialfidPath=[FileDir filesep num2str(InitialScanNum(1)) filesep];
sw1 = ReadTopspinParam(initialfidPath, 'SW_h');
Nf1 = ReadTopspinParam(initialfidPath, 'TD');
sw2 = ReadTopspin2DParam(initialfidPath, 'SW_h');
Nf2 = ReadTopspin2DParam(initialfidPath, 'TD');

AcquPoint=[Nf1/2 Nf2];% unit Hz`
Ta1=AcquPoint(1)/sw1;
Ta2=AcquPoint(2)/sw2;

%% 获取移点点数
DECIM =  ReadTopspinParam(initialfidPath, 'DECIM');
DSPFVS = ReadTopspinParam(initialfidPath, 'DSPFVS');
DIGMOD = ReadTopspinParam(initialfidPath, 'DIGMOD');
GRPDLY = ReadTopspinParam(initialfidPath, 'GRPDLY');
NrPointsToShift = DetermineBrukerDigitalFilter(DECIM, DSPFVS, DIGMOD,GRPDLY);
ShiftNum =  round( NrPointsToShift );
ShiftResidual= NrPointsToShift-ShiftNum;

pDataDir = [initialfidPath '/pdata/1'];
specPath = [pDataDir '/rr'];  %% 处理参数记录在procs�?
ftSize = ReadTopspinParam(specPath, 'SI');
ftSize2D = ReadTopspin2DParam(specPath, 'SI');

%%
SpecAll2Dtemp=zeros([ftSize ftSize2D SpecNum]);
for it=1:SpecNum
    ScanNum{it}=InitialScanNum-1+it;
    fidPath=[FileDir filesep num2str(ScanNum{it}(1)) filesep];
    FilePath=[fidPath filesep ];
    filename= fullfile(FilePath, '/pdata/1/2rr');
    [fp, msg]=fopen(filename,'r','l');
    if fp==-1  %如果打开文件不成�?
        msgbox(msg);  % 显示错误提示信息
        return;  %�?出程�?
    end
    clear msg filename pathname fname;
    dat=fread(fp,inf,'int32');

    rawdataReal=reshape(dat,[ftSize ftSize2D]);

    filenameImag= fullfile(FilePath, '/pdata/1/2ri');
    [fp, msg]=fopen(filenameImag,'r','l');
    if fp==-1  %如果打开文件不成�?
        msgbox(msg);  % 显示错误提示信息
        return;  %�?出程�?
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

 x=linspace(243.1,-156.9,ftSize);
 y=linspace(25.54,-24.55,ftSize2D);
 x=linspace(4.4,-56.2,ftSize);
 y=linspace(12.3,-64.2,ftSize2D);
 [X,Y]=meshgrid(x,y);
 
Realsum= real(sum(SpecAll2D, 3));
v1= max(max(abs(Realsum(:,:))));
v11=v1*(0.85.^(1:20));
figure;contour(X,Y,Realsum',v11);title('original');axis square;set(gca,'linewidth',1.5);set(gca,'xlim',[-32,-18]);set(gca,'xtick',[-30,-25,-20]);set(gca,'ylim',[-47,-3]);set(gca,'ytick',[-45,-35,-25,-15,-5]);set(gca,'xdir','reverse');set(gca,'ydir','reverse');

% figure;contour(X,Y,Realsum',v11);title('original');axis square;set(gca,'linewidth',1.5);set(gca,'xlim',[-10,110]);set(gca,'xtick',[0,50,100]);set(gca,'ytick',[-20,-10,0,10,20]);set(gca,'xdir','reverse');set(gca,'ydir','reverse');

 

 RealimgWaveletMultiframe = waveletMultiFrame(real(SpecAll2D), 'k', 6, 'p',12, 'maxLevel', 5, 'weightMode', 4, 'basis', 'dualTree');
 v2=max(max(abs(RealimgWaveletMultiframe(:,:))));
 v22=v2*(0.85.^(1:20));
 figure;contour(X,Y,RealimgWaveletMultiframe',v22);
figure;contour(X,Y,RealimgWaveletMultiframe',v22);title('WDMS');axis square;set(gca,'linewidth',1.5);set(gca,'xlim',[-10,110]);set(gca,'xtick',[0,50,100]);set(gca,'ytick',[-20,-10,0,10,20]);set(gca,'xdir','reverse');set(gca,'ydir','reverse');

 

IMDEN_WT = waveletdenoise(real(Realsum)/max(real(Realsum(:))),4,10,'mad',1000);%FileDir='E:\code\PHIP_Dynamic_image\400.4mm.20230906';
% IMDEN_WT = waveletdenoise(real(Realsum)/max(real(Realsum(:))));%FileDir='E:\code\PHIP_Dynamic_image\4mm-20230130-2';
v3=max(max(abs(IMDEN_WT(:,:))));
 v33=v3*(0.85.^(1:20));
 figure;contour(X,Y,IMDEN_WT',v33);
% figure;contour(X,Y,IMDEN_WT',v33);title('WT');axis square;set(gca,'linewidth',1.5);set(gca,'xlim',[-10,110]);set(gca,'xtick',[0,50,100]);set(gca,'ytick',[-20,-10,0,10,20]);set(gca,'xdir','reverse');set(gca,'ydir','reverse');

IMDEN_WDMS_WT = waveletdenoise(real(RealimgWaveletMultiframe)/max(real(RealimgWaveletMultiframe(:))),4,10,'mad',1000);%FileDir='E:\code\PHIP_Dynamic_image\400.4mm.20230906';
% IMDEN_WDMS_WT = waveletdenoise(real(RealimgWaveletMultiframe)/max(real(RealimgWaveletMultiframe(:))));%FileDir='E:\code\PHIP_Dynamic_image\4mm-20230130-2';
 v4=max(max(abs(IMDEN_WDMS_WT(:,:))));
 v44=v4*(0.85.^(1:20));
figure;contour(X,Y,IMDEN_WDMS_WT',v44);
% figure;contour(X,Y,IMDEN_WDMS_WT',v44);title('WDMS+WT');axis square;set(gca,'linewidth',1.5);set(gca,'xlim',[-10,110]);set(gca,'xtick',[0,50,100]);set(gca,'ytick',[-20,-10,0,10,20]);set(gca,'xdir','reverse');set(gca,'ydir','reverse');


%% shear other direction 
ShearingFactor=-7/9;
IMDENOrg1=Realsum;
[SizeTD1 SizeTD2]=size(IMDENOrg1);
Middle = SizeTD1/2;
Shifts = ((1:SizeTD1) - Middle)*ShearingFactor*sw1*SizeTD2/(SizeTD1*sw2);
MatrixOut_original=IMDENOrg1;
for QTEMP40=1:SizeTD1
    %first determine how many spectra need to be added to the
    %spectrum to be able to shear the first point (maximum shear)
    QTEMP2 = ceil(max(abs(Shifts(QTEMP40)))/SizeTD2);
    
    %first create a vector which the interpolation routine can use ...
    QTEMP3 = [];			%spectrum vector
    QTEMP4 = [];			%axis vector
    for QTEMP41 = 1:(2*QTEMP2 + 1)
        QTEMP3 = [QTEMP3 real(IMDENOrg1(QTEMP40, :))];			%this vector contains the repeated column from the spectrum
        QTEMP4 = [QTEMP4 ( (QTEMP41-QTEMP2-1)*SizeTD2 + (1:SizeTD2))];	%this vector contains the positions belonging to QTEMP3
    end
    
    MatrixOut_original(QTEMP40, :) = interp1(QTEMP4, QTEMP3, ((1:SizeTD2)+Shifts(QTEMP40)), 'spline');
end
%  figure;contour(X,Y,MatrixOut',v11);axis square;set(gca,'linewidth',1.5);set(gca,'xlim',[-10,110]);set(gca,'xtick',[0,50,100]);set(gca,'ytick',[-20,-10,0,10,20]);set(gca,'xdir','reverse');set(gca,'ydir','reverse');
figure;contour(X,Y,MatrixOut_original',v11);title('original');axis square;set(gca,'linewidth',1.5);set(gca,'xlim',[-32,-18]);set(gca,'xtick',[-30,-25,-20]);set(gca,'ylim',[-47,-3]);set(gca,'ytick',[-45,-35,-25,-15,-5]);set(gca,'xdir','reverse');set(gca,'ydir','reverse');



 
ShearingFactor=-7/9;
IMDENOrg1=RealimgWaveletMultiframe;
[SizeTD1 SizeTD2]=size(IMDENOrg1);
Middle = SizeTD1/2;
Shifts = ((1:SizeTD1) - Middle)*ShearingFactor*sw1*SizeTD2/(SizeTD1*sw2);
MatrixOut_WDMS=IMDENOrg1;
for QTEMP40=1:SizeTD1
    %first determine how many spectra need to be added to the
    %spectrum to be able to shear the first point (maximum shear)
    QTEMP2 = ceil(max(abs(Shifts(QTEMP40)))/SizeTD2);
    
    %first create a vector which the interpolation routine can use ...
    QTEMP3 = [];			%spectrum vector
    QTEMP4 = [];			%axis vector
    for QTEMP41 = 1:(2*QTEMP2 + 1)
        QTEMP3 = [QTEMP3 real(IMDENOrg1(QTEMP40, :))];			%this vector contains the repeated column from the spectrum
        QTEMP4 = [QTEMP4 ( (QTEMP41-QTEMP2-1)*SizeTD2 + (1:SizeTD2))];	%this vector contains the positions belonging to QTEMP3
    end
    
    MatrixOut_WDMS(QTEMP40, :) = interp1(QTEMP4, QTEMP3, ((1:SizeTD2)+Shifts(QTEMP40)), 'spline');
end
%  figure;contour(X,Y,MatrixOut',v22);axis square;set(gca,'linewidth',1.5);set(gca,'xlim',[-10,110]);set(gca,'xtick',[0,50,100]);set(gca,'ytick',[-20,-10,0,10,20]);set(gca,'xdir','reverse');set(gca,'ydir','reverse');
figure;contour(X,Y,MatrixOut_WDMS',v22);title('WDMS');axis square;set(gca,'linewidth',1.5);set(gca,'xlim',[-32,-18]);set(gca,'xtick',[-30,-25,-20]);set(gca,'ylim',[-47,-3]);set(gca,'ytick',[-45,-35,-25,-15,-5]);set(gca,'xdir','reverse');set(gca,'ydir','reverse');


IMDENOrg1=IMDEN_WT;
[SizeTD1 SizeTD2]=size(IMDENOrg1);
Middle = SizeTD1/2;
Shifts = ((1:SizeTD1) - Middle)*ShearingFactor*sw1*SizeTD2/(SizeTD1*sw2);
MatrixOut_WT=IMDENOrg1;
for QTEMP40=1:SizeTD1
    %first determine how many spectra need to be added to the
    %spectrum to be able to shear the first point (maximum shear)
    QTEMP2 = ceil(max(abs(Shifts(QTEMP40)))/SizeTD2);
    
    %first create a vector which the interpolation routine can use ...
    QTEMP3 = [];			%spectrum vector
    QTEMP4 = [];			%axis vector
    for QTEMP41 = 1:(2*QTEMP2 + 1)
        QTEMP3 = [QTEMP3 real(IMDENOrg1(QTEMP40, :))];			%this vector contains the repeated column from the spectrum
        QTEMP4 = [QTEMP4 ( (QTEMP41-QTEMP2-1)*SizeTD2 + (1:SizeTD2))];	%this vector contains the positions belonging to QTEMP3
    end
    
    MatrixOut_WT(QTEMP40, :) = interp1(QTEMP4, QTEMP3, ((1:SizeTD2)+Shifts(QTEMP40)), 'spline');
end
%  figure;contour(X,Y,MatrixOut',v33);axis square;set(gca,'linewidth',1.5);set(gca,'xlim',[-10,110]);set(gca,'xtick',[0,50,100]);set(gca,'ytick',[-20,-10,0,10,20]);set(gca,'xdir','reverse');set(gca,'ydir','reverse');
figure;contour(X,Y,MatrixOut_WT',v33);title('WT');axis square;set(gca,'linewidth',1.5);set(gca,'xlim',[-32,-18]);set(gca,'xtick',[-30,-25,-20]);set(gca,'ylim',[-47,-3]);set(gca,'ytick',[-45,-35,-25,-15,-5]);set(gca,'xdir','reverse');set(gca,'ydir','reverse');


IMDENOrg1=IMDEN_WDMS_WT;
[SizeTD1 SizeTD2]=size(IMDENOrg1);
Middle = SizeTD1/2;
Shifts = ((1:SizeTD1) - Middle)*ShearingFactor*sw1*SizeTD2/(SizeTD1*sw2);
MatrixOut_WDMS_WT=IMDENOrg1;
for QTEMP40=1:SizeTD1
    %first determine how many spectra need to be added to the
    %spectrum to be able to shear the first point (maximum shear)
    QTEMP2 = ceil(max(abs(Shifts(QTEMP40)))/SizeTD2);
    
    %first create a vector which the interpolation routine can use ...
    QTEMP3 = [];			%spectrum vector
    QTEMP4 = [];			%axis vector
    for QTEMP41 = 1:(2*QTEMP2 + 1)
        QTEMP3 = [QTEMP3 real(IMDENOrg1(QTEMP40, :))];			%this vector contains the repeated column from the spectrum
        QTEMP4 = [QTEMP4 ( (QTEMP41-QTEMP2-1)*SizeTD2 + (1:SizeTD2))];	%this vector contains the positions belonging to QTEMP3
    end
    
    MatrixOut_WDMS_WT(QTEMP40, :) = interp1(QTEMP4, QTEMP3, ((1:SizeTD2)+Shifts(QTEMP40)), 'spline');
end
%  figure;contour(X,Y,MatrixOut',v44);axis square;set(gca,'linewidth',1.5);set(gca,'xlim',[-10,110]);set(gca,'xtick',[0,50,100]);set(gca,'ytick',[-20,-10,0,10,20]);set(gca,'xdir','reverse');set(gca,'ydir','reverse');
figure;contour(X,Y,MatrixOut_WDMS_WT',v44);title('WDMS+WT');axis square;set(gca,'linewidth',1.5);set(gca,'xlim',[-32,-18]);set(gca,'xtick',[-30,-25,-20]);set(gca,'ylim',[-47,-3]);set(gca,'ytick',[-45,-35,-25,-15,-5]);set(gca,'xdir','reverse');set(gca,'ydir','reverse');

sum1=sum(Realsum,1);
sum2=sum(RealimgWaveletMultiframe,1);
sum3=sum(IMDEN_WT,1);
sum4=sum(IMDEN_WDMS_WT,1);
figure;plot(y,sum1/max(sum1(:)),'k');set(gca,'xdir','reverse');axis off;
figure;plot(y,sum2/max(sum2(:)),'k');set(gca,'xdir','reverse');axis off;
figure;plot(y,sum3/max(sum3(:)),'k');set(gca,'xdir','reverse');axis off;
figure;plot(y,sum4/max(sum4(:)),'k');set(gca,'xdir','reverse');axis off;