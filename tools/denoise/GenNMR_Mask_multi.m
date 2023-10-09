function [mask2D] = GenNMR_Mask_multi(AcquPoint,Rate,Nmask)
%GENNMR_MASK_MULTI 此处显示有关此函数的摘要
%   此处显示详细说明
Nt1=AcquPoint;
R = Rate;
% prob = (exp(-[0:Nt1-1]'/Nt1 * 0.0001)+0.5)/R;
tol = 1;
amin = 0;
amax = 1000;
a = amax/2;

mask2D=zeros([AcquPoint Nmask]);
ScanIndex=zeros([AcquPoint Nmask]);
for iMask=1:Nmask
    Nt1=AcquPoint;
    prob = (exp(-[0:Nt1-1]'/Nt1 * 1)+0.05)/R;
    tol = 1;
    amin = 0;
    amax = 1000;
    a = amax/2;
    
    while(1)
        prob_r = prob * a  ; prob_r(find(prob_r > 1)) = 1;
        diff = sum(prob_r) - Nt1/R;
        if abs(diff) < tol
            break;
        end
        if diff >= 0
            amax = a;
            a = (amax + amin)/2;
        else
            amin = a;
            a = (amax + amin)/2;
        end
    end
    % idx = randperm(Nt1);
    % Nt1R = floor(Nt1/R);
    % mask = zeros(Nt1,2); mask(idx(1:Nt1R),1) = 1;
    while(1)
        mask = rand(Nt1,1);
        mask(:,1) = mask(:,1) < prob_r;
        mask(:,2)=mask(:,1);
        FinalScanIndex=find(mask(:,1)>0);
        if(length(FinalScanIndex)==round(AcquPoint/R))
            break;
        end
    end
    % FinalScanIndex = FinalScanIndex(randperm(length(FinalScanIndex)));
    
    
    mask2D(FinalScanIndex,iMask)=1;
    
%     ScanIndex(1:size(FinalScanIndex),iMask)=FinalScanIndex;
%     Scan_num(iMask)=length(FinalScanIndex);
%     
%     disp('sampling point is ')
%     disp(sum(mask2D(:,iMask),2));
%     disp('sampling rate is ')
%     disp(sum(mask2D(:,iMask),2)/AcquPoint);
end
end

