clear; close all;
FidPath='E:\Qingjia_work\PVShare\PVData\Dynamic_PHIP\20220505_043234_Pd_pillar_S_1_22_05_05_1_1\54\'
% FidPath='E:\Qingjia_work\PVShare\PV5Data\38\';
% FidPath='C:\Users\dell\Downloads\16\16\';


ImagFile=[FidPath '\pdata\1\']

RawObj=RawDataObject(FidPath);
imageObj = ImageDataObject(ImagFile);
ImageData=imageObj.data;
TempSRdata0=squeeze(ImageData);
SliceOrient=ReadPVParam(FidPath, 'PVM_SPackArrSliceOrient') ;

%  figure;imagesc(TempSRdata0(:,:,1:end));colormap gray;

TempSRdata0=TempSRdata0(:,:,2:end);
RampTime=ReadPVParam(FidPath, 'PVM_RampTime');

if(size(TempSRdata0,3)>1)
     figure;imagesc(TempSRdata0(:,:,1));colormap gray;c=caxis;
figure;
imshow3Dfull(TempSRdata0(:,:,:,1,1))
else
    figure;imagesc(TempSRdata0);colormap gray;c=caxis;
end

h=figure;
movegui(h, 'onscreen');
title('Dynamics')
vidObj = VideoWriter([FidPath,'\','Dynamic.avi']);
vidObj.Quality = 100;
vidObj.FrameRate=6;
open(vidObj);

movegui(h, 'onscreen');
rect = get(h,'Position'); 
rect(1:2) = [0 0]; 
for t = 1: size(TempSRdata0,3)
  h = imagesc(abs(TempSRdata0(:,:,t)));axis equal; colormap gray;axis tight;caxis(c);
%   set(gcf,'outerposition',get(0,'screensize'));
%   text(5,30,['this is ', num2str(t),'images time go = ', num2str(t*6.4), 'S'],'Color','red','FontSize',10);
  movegui(h, 'onscreen');
  hold all;
  pause(0.001);
  drawnow;
  writeVideo(vidObj,getframe(gcf,rect));
end
close(vidObj); 

%%
%% calculate the air 
figure;imagesc(abs(TempSRdata0(:,:,10)))
h = imfreehand;
UseMask= createMask(h);

UseMask=repmat(UseMask,[1,1,size(TempSRdata0,3)]);
SingleImag=UseMask.*TempSRdata0;

SingleCurve=squeeze(sum(sum(SingleImag,1),2));
figure;
plot(SingleCurve)

TempSRdata0=permute(TempSRdata0,[3,1,2]);
sizeii = size(TempSRdata0)
FuckYou=reshape(tensor(TempSRdata0),[sizeii(1),sizeii(2),sizeii(3)]);
[core,U] = tensor_hosvd(FuckYou,[3 0 0]);
[T_hat] = tensor_ihosvd(core,U);
A_hat = double(T_hat);
XTest=reshape(A_hat,[sizeii(1),sizeii(2),sizeii(3)]);
XTest=permute(XTest,[2,3,1]);

figure;imshow3Dfull(XTest(:,:,:,1,1))

h=figure;
movegui(h, 'onscreen');
title('Dynamics')
vidObj = VideoWriter([FidPath,'\','DynamicDenose.avi']);
vidObj.Quality = 100;
vidObj.FrameRate=6;
open(vidObj);
 figure;imagesc(XTest(:,:,1));colormap gray;c=caxis;
 
movegui(h, 'onscreen');
rect = get(h,'Position'); 
rect(1:2) = [0 0]; 
for t = 1: size(TempSRdata0,3)
  h = imagesc(abs(XTest(:,:,t)));axis equal; colormap gray;axis tight;caxis(c);
%   set(gcf,'outerposition',get(0,'screensize'));
%   text(5,30,['this is ', num2str(t),'images time go = ', num2str(t*6.4), 'S'],'Color','red','FontSize',10);
  movegui(h, 'onscreen');
  hold all;
  pause(0.001);
  drawnow;
  writeVideo(vidObj,getframe(gcf,rect));
end
close(vidObj); 

SingleCurveDenoise=squeeze(sum(sum(UseMask.*XTest,1),2));
figure;
plot(SingleCurveDenoise)
