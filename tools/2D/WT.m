close all; clear ;clc
FileDir='E:\topspindata\data\4mm-20230130';

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

%% 获取移点点数
DECIM =  ReadTopspinParam(initialfidPath, 'DECIM');
DSPFVS = ReadTopspinParam(initialfidPath, 'DSPFVS');
DIGMOD = ReadTopspinParam(initialfidPath, 'DIGMOD');
GRPDLY = ReadTopspinParam(initialfidPath, 'GRPDLY');
NrPointsToShift = DetermineBrukerDigitalFilter(DECIM, DSPFVS, DIGMOD,GRPDLY);
ShiftNum =  round( NrPointsToShift );
ShiftResidual= NrPointsToShift-ShiftNum;

pDataDir = [initialfidPath '/pdata/1'];
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

SpecAll2Dtemp=zeros([ftSize ftSize2D SpecNum]);
for it=1:16
    ScanNum{it}=99+it;
    fidPath=[FileDir filesep num2str(ScanNum{it}(1)) filesep];
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

%data=RealSpec2D{1};
data= real(sum(SpecAll2D, 3));
dataCell = cell(1, 128);  % 创建一个单元格数组用于存储每一列数据
for col = 1:128
    columnData = data(:, col);
    
    % 在此处进行对该列数据的操作
    % 可以根据需要对 columnData 进行处理
    
    dataCell{col} = columnData;
end

 
wname = 'db4';

denoisedMatrix = zeros(4096, 128);  % 存储去噪后的矩阵

for col = 1:128
    % 获取当前列的数据
    columnData = data(:, col);
    
    % 进行小波变换及去噪操作
    [c,l] = wavedec(columnData, 4, wname);
    thr = median(abs(c)) / 0.03;
    c_t = wthresh(c, 's', thr);
    denoisedData = waverec(c_t, l, wname);
    
    % 将去噪后的数据存储到 denoisedMatrix 中
    denoisedMatrix(:, col) = denoisedData;
end

% 显示去噪后的矩阵
  x=linspace(243.1,-156.9,4096);
 y=linspace(25.54,-24.55,128);
 [X,Y]=meshgrid(x,y);
v3= max(max(abs(denoisedMatrix(:,:))));
 v33=v3*(0.83.^(1:20));
 figure;contour(X,Y,denoisedMatrix',v33);





