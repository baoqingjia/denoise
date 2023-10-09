function [final, coeffin, coeffs] = WaveletDenoise1D_FromPython(level, data, region_spec, wave, threshold, alpha)
    threshlist = ['mod', 'hard', 'soft', 'gar'];
    if ~ismember(threshold, threshlist)
        error('Threshold method must be ''mod'', ''soft'', or ''hard''');
    end

    coeffs=swt((data),level, wave); %stationary wavelet transform
    
    [SWA,SWD]=swt((data),level, wave); %stationary wavelet transform
    coeffin = cat(1,SWA,SWD);
    % This section calculates the lambdas at each level and removes noise
    % from each using the chosen thresholding method
    for i = 1:size(SWA,1)
        tempSWA = SWA(i,:);
        tempSWD = SWD(i,:);
        lam = calc_lamb(tempSWA, region_spec); %lam comes from approx. component
        if strcmp(threshold,'soft')
            fincomp0 = soft_threshold(tempSWA, lam);
            fincomp1 = soft_threshold(tempSWD, lam);
        elseif strcmp(threshold,'hard')
            fincomp0 = hard_threshold(tempSWA, lam);
            fincomp1 = hard_threshold(tempSWD, lam);
        elseif strcmp(threshold,'mod')
            fincomp0 = mod_thresh(tempSWA, lam, alpha);
            fincomp1 = mod_thresh(tempSWD, lam, alpha);
        elseif strcmp(threshold,'gar')
            fincomp0 = gar_threshold(tempSWA, lam);
            fincomp1 = gar_threshold(tempSWD, lam);
        end

    end
    final =iswt(fincomp0,fincomp1, wave); %recontrusct the final denoised spectrum
end



function y=soft_threshold(x,lam)
y=(abs(x)-lam).*sign(x).*(abs(x)>lam);
end

function y=hard_threshold(x,lam)
y=x.*(abs(x)>lam);
end

function y=mod_thresh(x,lam,alpha)
pos_idx=find(abs(x)>=lam);
neg_idx=find(abs(x)<lam);
y=zeros(size(x));
y(pos_idx)=x(pos_idx)-alpha*(lam^4./x(pos_idx).^3);
y(neg_idx)=(1-alpha)*(x(neg_idx).^5/lam^4);
end

function y=gar_threshold(x,lam)
pos_idx=find(abs(x)>lam);
neg_idx=find(abs(x)<=lam);
y=zeros(size(x));
y(pos_idx)=x(pos_idx)-lam^2./x(pos_idx);
y(neg_idx)=0;
end

