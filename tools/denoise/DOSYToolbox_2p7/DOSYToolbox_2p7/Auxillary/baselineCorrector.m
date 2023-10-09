function [ B ] = baselineCorrector( Y )
%implementation of the
%Distribution-Based Classification Method for Baseline Correction
% algoritm presented in Anal. Chem. 2013, 85, 1231-1239.
%Y is the spectroscopic intensities and hz is #points/ppm

    SDset = GetSD(Y, 20);
    
    sigma = FindNoiseSD(SDset, 0.999);
    
    SNvector = IsSignal(sigma, SDset, 3);
    
    sStart = GetSignalStart(SNvector);
    
    sEND = sort(1 + length(Y) - GetSignalStart(fliplr(SNvector)));
    
    R = GetTempBaseline(Y, sStart, sEND, 7);
    
    B = Smooth(R, 60);
    
    function SDset  = GetSD( Y, w)
        SDset=[];
        for i=1:length(Y)
            SDset(i)=std(Y(max(1,i-w):min(i+w,length(Y))));
        end
    end

    function  m2  = FindNoiseSD( SDset, ratio)
        m1=median(SDset);
        S=SDset <= 2*m1;
        tmp=(S.*SDset);
        SDset=tmp(tmp~=0);
        m2=median(SDset);
        while m2/m1<ratio
            m1=median(SDset);
            S=SDset <= 2*m1;
            tmp=S.*SDset;
            SDset=tmp(tmp~=0);
            m2=median(SDset);
        end
    end

    function SNvector=IsSignal(sigma,SDset,w)
        SNvector=SDset.*0;
        for i=1:length(SNvector)
            if SDset(i)>sigma*1.1;
                SNvector(max(1,i-w):min(i+w,length(SNvector)))=1;
            end
        end
    end

    function sStart=GetSignalStart(SNvector)
        sStart=[];
        for i=2:length(SNvector)
            if SNvector(i)-SNvector(i-1)>0
                sStart=[sStart i];
            end
            if SNvector(1)==1
                sStart(1)=1;
            end
        end
    end
    function R = GetTempBaseline(Y, sStart, sEnd,w)
        R=Y;
        for i=1:length(sStart)
            R(sStart(i))=mean(Y(max(1,(sStart(i)-w))):Y(min(sStart(i)+w,length(R))));
            R(sEND(i))=mean(Y(max(1,(sEND(i)-w))):Y(min(sEND(i)+w,length(R))));
            for j=sStart(i):sEND(i)
                R(j)=((Y(sEND(i))-Y(sStart(i)))*(j-sStart(i))/(sEND(i)-sStart(i))+Y(sStart(i)));
            end
        end
    end

    function B = Smooth(R,w)
        B=R;
        for i=1:length(R)
            B(i)=mean(R(max(1,i-w):min(i+w,length(R))));
        end
    end

    function I = GetDifference(LB,w,s,e)
        I=LB.*0;
        for i=(s+w):(e-w)
            I(i)=max(LB(max(1,i-w):min(i+w,length(I))))...
                -min(LB(max(1,i-w):min(i+w,length(I))));
        end
        I=I((start+w):(end-w));
    end
end





