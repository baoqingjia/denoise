function [Spec2D   ComFid] = Recio2DSpec_State(fid2D)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
fid2DCos=squeeze(fid2D(1,:,:));
Spec1DCos=(fft(fid2DCos,[],1));

fid2DSin=squeeze(fid2D(2,:,:));
Spec1DSin=(fft(fid2DSin,[],1));

ComSpec1D=real(Spec1DCos) + 1i*real(Spec1DSin);
% for i=1:size(ComSpec1D,2)
% ComSpec1D(:,i)=ComSpec1D(:,i)-ComSpec1D(128,i);
% end
ComFid=fft(ComSpec1D,[],1);

Spec2D=fft(fft(ComFid,[],1),[],2);
Spec2D=fftshift(Spec2D);

end

