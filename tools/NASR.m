function [FidBack ] = NASR(FID,flag)
%NASR �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
% FID = 1:1:100;
% fidPath = '../data/simulateT2Data/resource/T2Decay/T2_con_2peak_155.5676_0.5_1.1233_0.4';
% FID = load(fidPath).';
[row,column] = size(FID);
N = numel(FID);
if row == N
    FID = FID.';
end
type = 3;
AccNum = 200;

switch type
    case 1                                                                 %% ���ȡ��һ���ֵ㣬ʣ��ĵ���β������
%         k1 = floor(9/10*N);
%         k = randperm(k1,1);
        k = floor(9/10*N);
        ExtractedFID= [];
        for i = 1:AccNum
            randIndex = randperm(N,k);
            randIndex =sort(randIndex);
            zero = zeros(1,N-length(randIndex));
            FID_new = [ FID(randIndex) zero];
            ExtractedFID = [ExtractedFID;  FID_new];
        end
    case 2                                                                 %%����ǰ��1%�ĵ㣬ʣ��ĵ����ȡ��һ���֣���β������
        holdSize = floor(N/100);
        holdIndex = 1:1:holdSize;      
        ExtractedFID= [];
        for i = 1:AccNum
            k1 = floor(2/3*(N-holdSize));
%             k = randperm(k1,1)+floor(1/10*(N-holdSize));
            k = randperm(k1,1);
            randIndex = holdSize + randperm(N-holdSize,k);
            randIndex =[holdIndex sort(randIndex)];
            zero = zeros(1,N-length(randIndex));
            FID_new = [ FID(randIndex) zero];
            ExtractedFID = [ExtractedFID; FID_new];
        end
    case 3
         mask2D=GenNMR_Mask_multi(length(FID),1.5,200);
         
         FidMatrix=repmat(FID,[200,1]);
         FidMatrix=FidMatrix.*mask2D';
         ExtractedFID=FidMatrix;
         disp('Mask over')
         
         
end

%  NusReco=RecoNUS_sampling(ExtractedFID,mask2D');

fftFID = fftshift(fft(ExtractedFID, N, 2));
Spec1 = fftshift(fft(FID));
figure(11);
subplot(1,2,1);plot(sum(real(fftFID(:,:)),1));
subplot(1,2,2);plot(real(Spec1));


tempSpec = real(fftFID)/max(abs(real(fftFID(:))));
RSD=std(tempSpec,1)./abs(mean(tempSpec,1));
% RSD=RSD/max(RSD(:));
Alfa=0.2;
Beta=80;
Sigma=0.1;
WeightedCurve=Alfa+(1-Alfa)./(1+exp(Beta*(RSD-Sigma)));


FidBack=ifft(fftshift(Spec1.*WeightedCurve));
figure;plot(abs(FidBack))


% fftFID = sum(fftFID);
figure(1);
subplot(1,2,1);plot(abs(Spec1));
subplot(1,2,2);plot(abs(Spec1.*WeightedCurve));
figure(11);
plot(1:N,abs(fftshift(fft(FID))),'b',1:N,abs(fftFID),'r');

if strcmp(flag,'T2')
    renewFID = abs(ifft(fftshift(fftFID)));
end
if strcmp(flag,'FID')
    renewFID = ifft(fftshift(fftFID));
end
figure(2);
plot(real(renewFID));

% acquPoints = 2048; %echoes number
% acquTime = 500; %ms
% t1 = linspace(0,acquTime,acquPoints).';
% figure(3);plot(t1,FID,'b',t1,renewFID/max(renewFID),'r');

end

