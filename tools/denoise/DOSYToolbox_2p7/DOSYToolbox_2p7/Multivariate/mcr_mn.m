function [mcrdata]=mcr_mn(pfgnmrdata,ncomp,Specrange,Options,Nug,Ginit)


%   MCR-ALS (mutlivariate curve resolution alternating least squares) of
%   PFG-NMR diffusion data (aka DOSY data)
%
%
%   -------------------------------INPUT--------------------------------------
%   pfgnmrdata      Data structure containing the PFGNMR experiment.
%                   containing the following members:
%                       filename: the name and path of the original file
%                       np: number of (real) data points in each spectrum
%                       wp: width of spectrum (ppm)
%                       sp: start of spectrum (ppm)
%                       dosyconstant: gamma.^2*delts^2*DELTAprime
%                       Gzlvl: vector of gradient amplitudes (T/m)
%                       ngrad: number of gradient levels
%                       Ppmscale: scale for plotting the spectrum
%                       SPECTRA: spectra (processed)
%
%   ncomp           Number of componets (spectra) to fit.
%
%
%   ---------------------------INPUT - OPTIONAL-------------------------------
%
%   Specrange       The spectral range (in ppm) in which the mcr fitting
%                   will be performed. if set to [0] defaults will be used.
%                   DEFAULT is [sp wp+sp];
%
%   Options         Optional parameters
%
%                   Options(1): Initial guesses as spectra or decays
%                       0 Decays (DEFAULT)
%                       1 Spectra
%                   Options(2): Method to obtain the initial guesses
%                       0 Obtained by DECRA (DEFAULT) for either decays or
%                         spectra.
%                       1 Obtained by a PCA followd by a varimax rotation
%                         for either decays or spectra.
%                       2 Spectra: random values between 0 and max aplitude
%                         for corresponding frequency in the original least
%                         attenuated spectrum.
%                         Decays: obtained by monoexponential fitting of
%                         the summed amplitudes. Centered on the fitted
%                         value and differing by a factor of 1.5
%                       3 Spectra: 2 random values between 0 and max
%                         amplitude in the least attenuated spectrum.
%                         Decays: decasy calculated from diffusion
%                         coeffcients of random values between 0 and 25
%                         (m^2/s).
%                       4 User supplied in the vector Ginit.
%                   Options(3): Constraints on the decays
%                       0 No constraint (DEFAULT)
%                       1 Non negativity
%                       2 Non negativity - fast algorithm. Requires the
%                         N-way Toolbox by R. Bro (http://www.models.kvl.dk)%
%                   Options(4): Constraints on the spectra
%                       0 No constraint (DEFAULT)
%                       1 Non negativity
%                       2 Non negativity - fast algorithm. Requires the
%                         N-way Toolbox by R. Bro
%                         (http://www.models.kvl.dk)%
%                   Options(5): Forcing the decay to a predetermined shape
%                               (combiing hard and soft moddeling).
%                       0 No force (DEFAULT)
%                       1 pure exponetial
%                       2 correcting for non-uniform field gradients.
%                         Supply your own coefficients or use the default
%                         (Varian ID 5mm probe, Manchester 2006). Presently
%                         a maximum of 4 coefficients is supported.%
%   Nug             array contaning coefficients for non-uniform field
%                   gradient. Set nug=[] for default values.%
%   Ginit           Starting guesses for diffusion coefficients in 1e-10 m2/s%
%
%   --------------------------------------OUTPUT------------------------------
%   mcrdata        Structure containg the data obtained after the mcr with
%                  the follwing elements:
%
%                  COMPONENTS: The fitted spectra. In the optimal case
%                              representing the true spectra of the
%                              indiviual componets in the mixture
%                  DECAYS:     The decys of the fitted spectra
%                  RESIDUALS:  The residuals
%                  fit_time:   The time it took to run the fitting
%                  Gzlvl: vector of gradient amplitudes (T/m)
%                  wp: width of spectrum (ppm)
%                  sp: start of spectrum (ppm)
%                  Ppmscale: scale for plotting the spectrum
%                  filename: the name and path of the original file
%                  Dval: fitted diffusion coeffcients (10^-10 m2s-1)
%                  ncomp: number of fitted components
%                  Options: options used for the fitting
%                  Nug: coeffients for the non-uniform field gradient
%                       compensation
%   Example:
%
%   See also: dosy_mn, score_mn, decra_mn, mcr_mn, varianimport,
%             brukerimport, jeolimport, peakpick_mn, dosyplot_mn,
%             dosyresidual, dosyplot_gui, scoreplot_mn, decraplot_mn,
%             mcrplot_mn
%
%   This is a part of the DOSYToolbox
%   Copyright  2007-2008  <Mathias Nilsson>%
%   This program is free software; you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation; either version 2 of the License, or
%   (at your option) any later version.
%
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License along
%   with this program; if not, write to the Free Software Foundation, Inc.,
%   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
%
%   Dr. Mathias Nilsson
%   School of Chemistry, University of Manchester,
%   Oxford Road, Manchester M13 9PL, UK
%   Telephone: +44 (0) 161 306 4465
%   Fax: +44 (0)161 275 4598
%   mathias.nilsson@manchester.ac.uk
%
%   Some refernces to MCR of DOSY data
%   Huo R, Geurts, C, Brands, J, Wehrens, R, Buydens, LMC Magn. Reson. Chem. 2006; 44: 110.
%   Huo R, van de Molengraaf, RA, Pikkemaat, JA, Wehrens, R, Buydens, LMC J. Magn. Reson. 2005; 172: 346.
%   Huo R, Wehrens, R, Buydens, LMC J. Magn. Reson. 2004; 169: 257.
%   Huo R, Wehrens, R, Buydens, LMC Chemom. Intell. Lab. 2007; 85: 9.
%   Huo R, Wehrens, R, van Duynhoven, J, Buydens, LMC Anal. Chim. Acta 2003; 490: 231.
%   Van Gorkom LCM, Hancewicz, TM J. Magn. Reson. 1998; 130: 125.



tic
% Initial check
if nargin==0
    disp(' ')
    disp(' MCR ')
    disp(' ')
    disp(' Type <<help mcr_mn>> for more info')
    return
elseif nargin<2
    error(' The inputs pfgnmrdata and ncomp must be given')
elseif nargin >6
    error('mcr_mn takes a maximum of 6 arguments')
end

%Defaults and initialisations
Opts=[0 0 0 0 0];
itmax=500;
TolX=1e-4;
dscale=1e-10;
expfactor=pfgnmrdata.dosyconstant*dscale;
nugc=[9.280636e-1 -9.789118e-3 -3.834212e-4 2.51367e-5]; % Default coefficients (Varian ID 5mm probe, Manchester 2006)

if nargin>2 %fitting a limited part of the spectral width
    if Specrange==0
        %do nothing
    else
        if length(Specrange)~=2
            error('MCR: Specrange should have excatly 2 elements')
        end
        if Specrange(2)<Specrange(1)
            error('MCR: Second element of Specrange must be larger than the first')
        end
        if ((Specrange(1)<pfgnmrdata.sp) || Specrange(2)>(pfgnmrdata.sp+pfgnmrdata.wp))
            error('MCR: Specrange exceeds the spectral width (sp - sp+wp)i')
        end
        for k=1:length(pfgnmrdata.Ppmscale)
            if (pfgnmrdata.Ppmscale(k)>Specrange(1))
                begin=k-1;
                break;
            end
        end
        
        for k=begin:length(pfgnmrdata.Ppmscale)
            if (pfgnmrdata.Ppmscale(k)>=Specrange(2))
                endrange=k;
                break;
            end
        end
        %make a new stucture
        pfgnmrdata.sp=pfgnmrdata.Ppmscale(begin);
        pfgnmrdata.wp=pfgnmrdata.Ppmscale(endrange)-pfgnmrdata.Ppmscale(begin);
        pfgnmrdata.Ppmscale=pfgnmrdata.Ppmscale(begin:endrange);
        pfgnmrdata.SPECTRA=pfgnmrdata.SPECTRA(begin:endrange,:);
        pfgnmrdata.np=length(pfgnmrdata.Ppmscale);
    end
end


X=(pfgnmrdata.SPECTRA');

X=X+0.2*max(X(:))*0.05*(rand(size(X)));
% figure;plot(X(1:5,:)')

if nargin>3
    %user Options
    Opts=Options;
end
if Opts(1)==0
    disp('MCR: Initial guesses as decays')
    switch Opts(2)
        case 0
            disp('MCR: Using DECRA to estimate the decays')
            [decradata]=decra(pfgnmrdata,ncomp);
            Cin=decradata.DECAYS;
        case 1
            disp('MCR: Using PCA-varimax for initialisation of decays')
            %             [C, L]=princomp(pfgnmrdata.SPECTRA); %#ok<NASGU>
            %             tmp=rotatefactors(C,'Method','varimax');
            %             Cin=tmp(:,1:ncomp);
            %             figure
            %             plot(Cin)
            [LU, LR, FSr, VT] = erpPCA( pfgnmrdata.SPECTRA );
            %             figure
            %             plot(LU(:,1:ncomp))
            %             figure
            %             plot(LR(:,1:ncomp))
            
            Cin=LR(:,1:ncomp);
            
        case 2
            error('MCR: Options(2)=2 is not implemented yet')
            
        case 3
            error('MCR: Options(2)=3 is not implemented yet')
            
        case 4
            if nargin>5
                disp('MCR: Using user supplied starting guesses')
                if min(size(Ginit))~=ncomp
                    disp('MCR: Wrong format of Ginit')
                    error('MCR: Ginit must contain ncomp decays ')
                elseif (max(size(Ginit))~=pfgnmrdata.ngrad)
                    disp('MCR: Wrong format of Ginit')
                    error('MCR: Ginit has the wrong number of decay points (gradient levels)')
                else
                    Cin=Ginit;
                end
            else
                error('MCR: User supplied starting guesses must be supplied in Ginit')
            end
        otherwise
            error('MCR: Illegal Options(2)')
    end
    C0=Cin;
    S0=C0\X;
elseif Opts(1)==1
    disp('MCR: Initial guesses as spectra')
    switch Opts(2)
        case 0
            disp('MCR: Using DECRA to estimate the spectra')
            [decradata]=decra(pfgnmrdata,ncomp);
%             [purspec,purint,purity_spec]=simplisma(X,[1:size(X,2)],1,ncomp);
            Sin=decradata.COMPONENTS;
        case 1
            disp('MCR: Using PCA-varimax for initialisation of spectra')
            [LU, LR, FSr, VT] = erpPCA( pfgnmrdata.SPECTRA' );
            Sin=LR(:,1:ncomp)';
            
        case 2
            error('MCR: Options(2)=2 is not implemented yet')
            
        case 3
            error('MCR: Options(2)=3 is not implemented yet')
            
        case 4
            %Check Gin
            if nargin>5
                disp('MCR: Using user supplied starting guesses')
                if min(size(Ginit))~=ncomp
                    disp('MCR: Wrong format of Ginit')
                    error('MCR: Ginit must contain ncomp spectra ')
                elseif (max(size(Ginit))~=pfgnmrdata.np)
                    disp('MCR: Wrong format of Ginit')
                    error('MCR: Ginit has the wrong number of spectral points')
                else
                    Sin=Ginit;
                end
            else
                error('MCR: User supplied starting guesses must be supplied in Ginit')
            end
            
        otherwise
            error('MCR: Illegal Options(2)')
    end
    
    S0=Sin;
    C0=X/S0;
else
    error('MCR: illegal Options(1)')
end

if Opts(3)==0
    disp('MCR: No constaints on the decays')
elseif Opts(3)==1
    disp('MCR: Non negativity constraint on the decays')
elseif Opts(3)==2
    if (exist('fastnnls')==2) %#ok<EXIST>
        disp('MCR: Non negativity constraint (fast algorithm) on the decays')
    else
        disp('MCR: The N-way Toolbox by R. Bro (http://www.models.kvl.dk) is needed for the fast algorithm')
        disp('MCR: Using the MATLAB standard instead')
        Opts(3)=1;
    end
else
    error('MCR: Illegal Options(3)')
end

if Opts(4)==0
    disp('MCR: No constaints on the spectra')
elseif Opts(4)==1
    disp('MCR: Non negativity constraint on the spectra')
elseif Opts(4)==2
    if (exist('fastnnls')==2) %#ok<EXIST>
        disp('MCR: Non negativity constraint (fast algorithm) on the spectra')
    else
        disp('MCR: The N-way Toolbox by R. Bro (http://www.models.kvl.dk) is needed for the fast algorithm')
        disp('MCR: Using the MATLAB standard instead')
        Opts(4)=1;
    end
else
    error('MCR: Illegal Options(4)')
end

if Opts(5)==0
    %do nothing
    curveforce=0;
elseif Opts(5)==1
    %constain to a pure exponential
    disp('MCR: Constrain the decays to a pure exponential')
    model=@purexp;
    model2=@purexp2;
    curveforce=1;
elseif Opts(5)==2
    %constrain to a power series (NUG)
    disp('MCR: Constain the decays to a power series of an exponetial (NUG)')
    model=@nugexp;
    model2=@nugexp2;
    curveforce=1;
else
    error('MCR: Illegal Options(5)');
end

if nargin>4
    if ( (exist('Nug','var')==0) || (max(size(Nug)==[0 0])) )
        if (Opts(5)==2)
            disp('MCR: Using default NUG coefficients')
        end
        nugc=[9.280636e-1 -9.789118e-3 -3.834212e-4 2.51367e-5]; % Default coefficients (Varian ID 5mm probe, Manchester 2006)
    else
        nugc=zeros(1,4);
        nugc(1:length(nugc))=Nug;
        disp('MCR: Using user supplied NUG coefficients')
    end
end




it=1;
itdiv=1;
while it<itmax
    %--------------------------------
    %Constraining the decays
    %--------------------------------
   
    if Opts(3)==0       %no constraint
        C0=X/S0;
    elseif Opts(3)==1   %non negativity
        for k=1:pfgnmrdata.ngrad
            C0(k,:)=lsqnonneg(S0',X(k,:)');
        end
    elseif Opts(3)==2
        for k=1:pfgnmrdata.ngrad
            C0(k,:)=fastnnls(S0',X(k,:)');
        end
    else
        error('Illegal Options(3)');
    end
    dval='not_estimated';
    if curveforce==1
        dval=zeros(1,ncomp);
        opts=optimset('lsqcurvefit');
        opts=optimset(opts,'Display','off');
        %force decays to a predetermined shape
        for k=1:ncomp
            initval(1)=max(C0(:,k));
            if (initval(1)<=0)
                initval(1)=1;
            end
            
            opts_fmin=optimset('fminsearch');
            opts_fmin=optimset(opts_fmin,'Display','Off');
            opts_fmin=optimset(opts_fmin,'MaxFunEvals',10000);
            initval(2)=5; %very simple guess
            initval(2)= (log(initval(1)) - log(C0(:,k))')/(expfactor*pfgnmrdata.Gzlvl.^2); %
            initval=real(initval);
            
            [fitparam]=...
                fminsearch(model2,initval,opts_fmin,pfgnmrdata.Gzlvl.^2,expfactor,nugc,...
                C0(:,k)');
            
            
            fitparam=real(fitparam);
            
            C0(:,k)=model(fitparam,pfgnmrdata.Gzlvl.^2,expfactor,nugc);
            %We can't have any raising exponentials
            if C0(1,k)<0 %first try nneg estimated C0
                C0(k,:)=lsqnonneg(S0',X(k,:)');
                initval(1)=max(C0(:,k));
                if (initval(1)<=0)
                    initval(1)=1;
                end
                initval(2)=5; %very simple guess
                initval(2)= (log(initval(1)) - log(C0(:,k))')/(expfactor*pfgnmrdata.Gzlvl.^2); %
                [fitparam]=...
                    fminsearch(model2,initval,opts_fmin,pfgnmrdata.Gzlvl.^2,expfactor,nugc,...
                    C0(:,k)');
            end
            if C0(1,k)<0 %if that does not work reflect the exponential
                C0(k,:)=C0(k,:)*-1.0;
                initval(1)=max(C0(:,k));
                if (initval(1)<=0)
                    initval(1)=1;
                end
                initval(2)=5; %very simple guess
                initval(2)= (log(initval(1)) - log(C0(:,k))')/(expfactor*pfgnmrdata.Gzlvl.^2); %
                [fitparam]=...
                    fminsearch(model2,initval,opts_fmin,pfgnmrdata.Gzlvl.^2,expfactor,nugc,...
                    C0(:,k)');
            end
            dval(k)=fitparam(2);
        end
    end
    
    
    %--------------------------------
    %Constraining the spectra
    %--------------------------------
    if Opts(4)==0       %no constraint
        S0=C0\X;
    elseif Opts(4)==1   %non negativity
        for k=1:pfgnmrdata.np
            S0(:,k)=lsqnonneg(C0,X(:,k));
        end
    elseif Opts(4)==2
        for k=1:pfgnmrdata.np
            S0(:,k)=fastnnls(C0,X(:,k));
        end
    else
        error('MCR: Illegal Options(4)');
    end
    
    disp(['MCR: Iteration: ',num2str(it)]);
    
    %--------------------------------
    %get the residuals and checking the convergence
    %-------------------------------
    
    
    res=X-C0*S0;
    ssq=sum(sum(res.^2));
    if it==1
        resbest=res;
        ssqbest=ssq;
        Sbest=S0;
        Cbest=C0;
        itbest=it; %#ok<NASGU>
        sigma=sqrt(ssq/(pfgnmrdata.np*pfgnmrdata.ngrad)); %#ok<NASGU>
        sigmabest=sqrt(ssqbest/(pfgnmrdata.np*pfgnmrdata.ngrad)); %#ok<NASGU>
    elseif ssq<ssqbest
        
        itdiv=1;
        sigma=sqrt(ssq/(pfgnmrdata.np*pfgnmrdata.ngrad));
        sigmabest=sqrt(ssqbest/(pfgnmrdata.np*pfgnmrdata.ngrad));
        change=(sigmabest-sigma)/sigmabest;
        %disp(['Fit is improving. Change in sigma: ' num2str(change)])
        resbest=res;
        ssqbest=ssq;
        Sbest=S0;
        Cbest=C0;
        if ( change < TolX)
            %convergence
            disp('MCR: Convergence criteria satisfied')
            disp(['MCR: Change in sigma is less than: ' num2str(TolX)]);
            break
        end
        
        
    else
        %no improvement
        itdiv=itdiv+1;
        if itdiv>10
            disp('MCR: No improvement for 10 consequtive fits')
            break
        end
    end
    
    it=it+1;
    
    if it>itmax
        disp('MCR: Max number of iterations met')
    end
end



endt=toc;
h=fix(endt/3600);
m=fix((endt-3600*h)/60);
s=endt-3600*h - 60*m;
fit_time=[h m s];
disp(['MCR: Fitting time was: ' num2str(fit_time(1)) ' h  ' num2str(fit_time(2)) ' m and ' num2str(fit_time(3),2) ' s']);

% Cbest(size(Sbest,1)+1:end,:)=0;
figure;
for i=1:size(Cbest,2)
subplot(2,size(Cbest,2),i);plot(abs(Cbest(:,i)));
subplot(2,size(Cbest,2),i+size(Cbest,2));plot(abs(Sbest(i,:)));
end


for i=1:size(Cbest,2)
    if(max(abs(Cbest(:,i)))<0.1*max(abs(Cbest(:))))
        Cbest(:,i)=0;
    end
end
DenoiseData=(Cbest*Sbest);
figure;subplot(1,2,1);plot(abs(Cbest(:,:)));
subplot(1,2,2);plot(Sbest(:,:)');



figure;subplot(1,2,1);plot(X(8,:)');
subplot(1,2,2);plot(abs(DenoiseData(8,:)'));

figure;subplot(1,2,1);plot(abs(sum(X,1)));1
subplot(1,2,2);plot(abs(sum(DenoiseData,1)));






mcrdata.filename=pfgnmrdata.filename;
mcrdata.Gzlvl=pfgnmrdata.Gzlvl;
mcrdata.COMPONENTS=Sbest;
mcrdata.Dval=dval;
mcrdata.DECAYS=Cbest;
mcrdata.RESIDUALS=resbest;
%mcrdata.ssq=ssq;
mcrdata.fit_time=fit_time;
mcrdata.wp=pfgnmrdata.wp;
mcrdata.sp=pfgnmrdata.sp;
mcrdata.Ppmscale=pfgnmrdata.Ppmscale;
mcrdata.ncomp=ncomp;
mcrdata.Options=Opts;
%mcrdata.thresh=th;
mcrdata.Nug=nugc;
if nargin>5
    mcrdata.Ginit=Ginit;
end

if (isnumeric(mcrdata.Dval))
    [mcrdata.Dval, sortindex]=sort(mcrdata.Dval);
    mcrdata.DECAYS=mcrdata.DECAYS(:,sortindex);
    mcrdata.COMPONENTS=mcrdata.COMPONENTS(sortindex,:);
end


% mcrplot(mcrdata);
end
%-------------------------------END of mcr_mn------------------------------



%-------------------------------AUXILLIARY FUNCTIONS-----------------------

function y = purexp(a,xdata,expfactor,nugc) %#ok<INUSD>
% for fitting a number of pure exponentials
y = a(1)*exp(-a(2)*expfactor.*xdata);
%END of purexp
end

function y = nugexp(a,xdata,expfactor,nugc)
%fitting non-uniform field gradient decays (NUG)
y = a(1)*exp( - nugc(1)*(a(2)*expfactor.*xdata).^1 -...
    nugc(2)*(a(2)*expfactor.*xdata).^2 -...
    nugc(3)*(a(2)*expfactor.*xdata).^3 -...
    nugc(4)*(a(2)*expfactor.*xdata).^4);
%END of nugexp
end

function [sse, y] = nugexp2(a,xdata,expfactor,nugc,ydata)
%fitting non-uniform field gradient decays (NUG)
y = a(1)*exp( - nugc(1)*(a(2)*expfactor.*xdata).^1 -...
    nugc(2)*(a(2)*expfactor.*xdata).^2 -...
    nugc(3)*(a(2)*expfactor.*xdata).^3 -...
    nugc(4)*(a(2)*expfactor.*xdata).^4);
sse=ydata-y;
sse=sum(sse.^2,2);
%END of nugexp
end



function [sse, y] = purexp2(a,xdata,expfactor,nugc,ydata)
% for fitting a  pure exponential
y =  a(1)*exp(-a(2)*expfactor.*xdata);
sse=ydata-y;
sse=sum(sse.^2,2);
end




function [decradata]=decra(pfgnmrdata,ncomp,Specrange)

%   Specrange =     The spectral range (in ppm) in which the dosy fitting
%                   will be performed. if set to [0] defaults will be used.
%                   DEFAULT is [sp wp+sp];
% Explanation of Variables in the Matlab Script
% pspec                   -resolved spectra normalized to the g = 0 point in the experiment
%                         and representative of composition
% diff                    -diffusion coefficients calculated from the eigenvalues
% a                       -relative amounts of each resolved component scaled to g = 0
% fname                   -name of file (phasefile in Varian VNMR)
% constant                -(DELTA - delta/3)*gamma^2*delta^2 (rad s T-1)^2
% grad2                   -gradient values (T m-1)^2 -NOT gradient squared!
% spec                    -number of spectra in total
% startspec and endspec   -range of data to be used (gradient levels)
% startpoint and endpoint -expansion of data to be used (spectral points)
% ncom                    -number of components chosen
% incr                    -difference in g2 values (T m_1)2


%Based on the script in Antalek, B. Conc.Magn.Reson. 2002, 14(4), 225-258.

if nargin==0
    disp(' ')
    disp(' DECRA ')
    disp(' ')
    disp(' Type <<help decra_mn>> for more info')
    return
elseif nargin<2
    error(' The inputs pfgnmrdata and ncomp must be given')
end

if nargin>2
    if Specrange==0
        %do nothing
    else
        if length(Specrange)~=2
            error('Specrange should have excatly 2 elements')
        end
        if Specrange(2)<Specrange(1)
            error('Second element of Specrange must be larger than the first')
        end
        if ((Specrange(1)<pfgnmrdata.sp) || Specrange(2)>(pfgnmrdata.sp+pfgnmrdata.wp))
            error('Specrange exceeds the spectral width (sp - sp+wp)i')
        end
        for k=1:length(pfgnmrdata.Ppmscale)
            if (pfgnmrdata.Ppmscale(k)>Specrange(1))
                begin=k-1;
                break;
            end
        end
        for k=begin:length(pfgnmrdata.Ppmscale)
            if (pfgnmrdata.Ppmscale(k)>Specrange(2))
                endrange=k;
                break;
            end
        end
        %make a new stucture
        pfgnmrdata.sp=pfgnmrdata.Ppmscale(begin);
        pfgnmrdata.wp=pfgnmrdata.Ppmscale(endrange)-pfgnmrdata.Ppmscale(begin);
        pfgnmrdata.Ppmscale=pfgnmrdata.Ppmscale(begin:endrange);
        pfgnmrdata.SPECTRA=pfgnmrdata.SPECTRA(begin:endrange,:);
        pfgnmrdata.np=length(pfgnmrdata.Ppmscale);
    end
end

tic;
data=pfgnmrdata.SPECTRA';
grad2=pfgnmrdata.Gzlvl;
constant=pfgnmrdata.dosyconstant;
startspec=1;
endspec=pfgnmrdata.ngrad;

% Making sure the data is in the right format
grad2=grad2(:);
grad2=grad2.^2;
% Assuming more spectral points than gradient levels

%a constant difference between g2^2 is necessary
incr=grad2(2)-grad2(1);

%define two ranges (split the data set in two)
range1=(startspec:endspec-1);
range2=(startspec+1:endspec);

%create a common base for the two data sets using SVD
[vc,sc,uc]=svd(data(range1,:)',0);
sc=sc(1:ncomp,1:ncomp);
uc=uc(:,1:ncomp);
vc=vc(:,1:ncomp);

%project the two data sets onto the common base
%auv=sc;
buv=uc'*data(range2,:)*vc;

%solve the generalized eigenvalue problem
[v,s]=eig(buv*inv(sc));
%ev=diag(s);
[ev,sortindex]=sort(diag(s));
v=v(:,sortindex);

%calculate spectra and concentrations
pspec=pinv(vc*inv(sc)*v);
pint=uc*v;

%scale spectra and concentrations
total=sum(data(range1,:),2);
scalefactor=pint\total;
pint=pint*diag(scalefactor);
pspec=diag(1./scalefactor)*pspec;

%calculate proper composition
pint2=pint*diag(ev);
nrows=size(pint,1);
pintcomb=[pint(1,:);(pint(2:nrows,:)+pint2(1:nrows-1,:))/2; pint2(nrows,:)];
b=log(ev)/incr;
diff=-b/constant;
grad21=grad2(range1);
grad22=grad2(range2);
grad2comb=[grad21;grad22(nrows)];
a=zeros(1,length(ev));
for i=1:length(ev);
    expest0=exp(grad2comb*b(i));
    a(i)=expest0\pintcomb(:,i);
end;
pspec=diag(a)*pspec;
pint=pintcomb;
fit_time=toc;

decradata.filename=pfgnmrdata.filename;
decradata.Gzlvl=pfgnmrdata.Gzlvl;
decradata.COMPONENTS=pspec;
decradata.Dval=diff;
decradata.DECAYS=pint;
decradata.fit_time=fit_time;
decradata.wp=pfgnmrdata.wp;
decradata.sp=pfgnmrdata.sp;
decradata.Ppmscale=pfgnmrdata.Ppmscale;
decradata.ncomp=ncomp;
decradata.relp=a;
end

%-----------------END of DECRA---------------------------------------------
