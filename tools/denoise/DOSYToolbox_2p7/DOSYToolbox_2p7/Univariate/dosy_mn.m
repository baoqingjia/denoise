function [dosydata]=dosy_mn(pfgnmrdata,thresh,Specrange,Diffrange,Options,Nugc)


%   [DOSY]=dosy_mn(pfgnmrdata,thresh,Specrange,Diffrange,Options,Nugc)
%   DOSY (diffusion-ordered spectroscopy) fitting of
%   PFG-NMR diffusion data (aka DOSY data)
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
%   ---------------------------INPUT - OPTIONAL-------------------------------
%   thresh =        Noise threshold. Any data point below won't be used in
%                   the fitting. Expressed as % of highest peak. Default 5
%                   (%).
%   Specrange       The spectral range (in ppm) in which the score fitting
%                   will be performed. if set to [0] defaults will be used.
%                   DEFAULT is [sp wp+sp];
%   Diffrange =     The range in diffusion coeeficients that will be
%                   calculated AND the number of data points in the
%                   diffusion dimension (fn1). DEFAULT is [0 20 128];
%                     Diffrange(1) - Min diffusion coefficient plotted.
%                              (0)   DEFAULT. (*10e-10 m2/s)
%                     Diffrange(2) - Max diffusion coefficient plotted.
%                              (20)  DEFAULT  (*10e-10 m2/s)
%                     Diffrange(3) - Number of datapoints in the diffusion
%                                    dimension
%                              (128) DEFAULT
%
%   Options =       Optional parameters. If not given or set to zero or [],
%                   defaults will be used. If you want Options(5) to be 2
%                   and not change others, simply write Options(5)=2. Even
%                   if Options hasn't been defined Options will contain
%                   zeros except its fifth element.
%
%           Options(1) - peak picking.
%             (0) DEFAULT does peak picking;
%             (1) fits each frequency individually
%
%           Options(2) - fitting functions.
%             (0)  DEFAULT: fits to a pure monoexponential.
%             (1)  fits to a function compensating for non-uniform
%                  gradients (NUG); Supply your own coefficients or use the
%                  default (Varian ID 5mm probe, Manchester 2006).Max 4
%                  coefficients is supported.
%
%           Options(3) - Multiexponential fiting. The max number of
%                        componets per peak/data point. Warning - the higer
%                        number the longer the calculation. 2 is often the
%                        practical limit.
%             (1)  DEFAULT: - monoexponental fit
%
%           Options(4) - The number of random starting values (Monte
%                        Carlo) that will be tried for the biexponetial
%                        fit. Default is 100. Higher exponentials will be
%                        corrspondingly increased (i.e 1000 as a default.
%                        If you get a successful fit with a low number of
%                        random starting values it probably means that the
%                        data is multiexponetial but you may not have found
%                        the globl minimum. It may be worthwhile to
%                        increase it to increase the likelyhood of getting
%                        a correct result.
%           Options(5) - The fitting routine used
%               (0) DEFAULT: - lsqcurvefit. Required the Otimization Toolbox
%                   and uses gradients. Probably the fastest and most reliable
%                   option.
%               (1) fminsearch: uses the Nelder-Mead simplex method.
%
%   Nugc =          Vector contaning coefficients for non-uniform field
%                   gradient correction. If not supplied default values
%                   from a Varian ID 5mm probe (Manchester 2006) will be
%                   used.
%
%   --------------------------------------OUTPUT------------------------------
%   dosydata       Structure containg the data obtained after dosy with
%                  the follwing elements:
%
%
%                  fit_time:   The time it took to run the fitting
%                  Gzlvl: vector of gradient amplitudes (T/m)
%                  wp: width of spectrum (ppm)
%                  sp: start of spectrum (ppm)
%                  Ppmscale: scale for plotting the spectrum
%                  filename: the name and path of the original file
%                  Options: options used for the fitting
%                  Nug: coeffients for the non-uniform field gradient
%                       compensation
%                  FITSTATS: amplitude and diffusion coeffcient with
%                            standard error for the fitted peaks
%                  FITTED: the fitted decys for each peak
%                  freqs: frequencies of the fitted peaks (ppm)
%                  RESIDUAL: difference between the fitted decay and the
%                            original (experimental) for all peaks
%                  ORIGINAL: experimental deacy of all fitted peaks
%                  type: type of data (i.e. dosy or something else)
%                  DOSY: matrix containing the DOSY plot
%                  Spectrum: the least attenuated spectrum
%                  fn1: number of data points (digitisation) in the
%                       diffusion dimension
%                  dmin: plot limit in the diffusion dimension 10-10 m^2/s)
%                  dmax: plot limit in the diffusion dimension 10-10 m^2/s)
%                  Dscale: Plot scale for the diffusion dimension
%                  threshold: theshold (%) over which peaks are included in
%                             the fit
%
%   Example:
%
%   See also: dosy_mn, score_mn, decra_mn, mcr_mn, varianimport,
%             brukerimport, jeolimport, peakpick_mn, dosyplot_mn,
%             dosyresidual, dosyplot_gui, scoreplot_mn, decraplot_mn,
%             mcrplot_mn
%
%   References:
%   Nilsson M, Connell, MA, Davis, AL, Morris, GA Anal. Chem.
%   2006; 78: 3040.

%
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


if nargin==0
    disp(' ')
    disp(' 2D DOSY')
    disp(' ')
    disp(' Type <<help dosy_mn>> for more info')
    disp('  ')
    return
elseif nargin<1
    error(' dosy_mn needs a pfgnmrdata stucture as input')
elseif nargin >6
    error(' Too many inputs')
end

t_start=cputime;

%Defaults
Opts=[0 0 0 100 0];
Diff=[0 20 128];
dosydata.filename=pfgnmrdata.filename;

% User options
if (nargin >1)
    th=thresh;
else
    th=0.1;
end
if nargin>2
    if Specrange==0
        %do nothing
    else
        if length(Specrange)~=2
            error('DOSY: Specrange should have excatly 2 elements')
        end
        if Specrange(1)<pfgnmrdata.sp
            disp('DOSY: Specrange(1) is too low. The minumum will be used')
            Specrange(1)=pfgnmrdata.sp;
        end
        if Specrange(2)>(pfgnmrdata.wp+pfgnmrdata.sp)
            disp('DOSY: Specrange(2) is too high. The maximum will be used')
            Specrange(2)=pfgnmrdata.wp+pfgnmrdata.sp;
        end
        for k=1:length(pfgnmrdata.Ppmscale)
            if (pfgnmrdata.Ppmscale(k)>Specrange(1))
                begin=k-1;
                k1=begin;
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
        pfgnmrdata.sp=pfgnmrdata.Ppmscale(k1);
        pfgnmrdata.wp=pfgnmrdata.Ppmscale(endrange)-pfgnmrdata.Ppmscale(k1);
        pfgnmrdata.Ppmscale=pfgnmrdata.Ppmscale(k1:endrange);
        pfgnmrdata.SPECTRA=pfgnmrdata.SPECTRA(k1:endrange,:);
        pfgnmrdata.np=length(pfgnmrdata.Ppmscale);
    end
end

if nargin>3
    if (length(Diffrange) ~= 3)
        if Diffrange==0
            %use defaults
            Diffrange=[0 20 128];
        else
            error('DOSY: Diffrange is a vector of size 3')
        end
    end;
    Diff=Diffrange;
end

if nargin >4
    nO=length(Options);
    Opts=zeros(1,4);
    if nO>5
        error('DOSY: Incorrect number of Options')
    else
        Opts(1:nO)=Options(1:nO);
    end
    if (Opts(3)<=0) || (Opts(3)>4)
        disp('DOSY: Illegal Options(3)');
        disp('DOSY: Using monoexponential fitting only')
        Opts(3)=1;
    else
        disp(['DOSY: Trying to fit ' num2str(Opts(3)) ' componets per peak'])
    end
    if Opts(4)==0
        Opts(4)=100;
    end
    nMC=Opts(4);
    if Opts(5)==0
        disp('using lsqcurvefit')
        FitType=0;
    elseif Opts(5)==1
        disp('using fminsearch')
        FitType=1;
    else
        disp('Illegal Options(5) - using default')
        disp('using lsqcurvefit')
        FitType=0;
    end
    
    
end
if nargin == 6
    if length(Nugc)>4
        error('DOSY: A maximum of 4 NUG coefficients is supported');
    else
        %we accept the coefficients
    end
end

if (Opts(2)>1) || (Opts(2)<0)
    disp('DOSY: Illegal Options(2)')
    disp('DOSY: Using pure exponential fit')
    Opts(2)=0;
end
if Opts(2)==1
    fitmodel = @nugexp;
    if FitType==0
        model = @nugexp;
    else
        model = @nugexp2;
    end
    if (exist('Nugc','var')==1)
        nug=zeros(1,4);
        nug(1:length(Nugc))=Nugc;
    else
        % Default coefficients (Varian ID 5mm probe, Manchester 2006)
        nug=[9.280636e-1 -9.789118e-3 -3.834212e-4 2.51367e-5];
    end
    display('DOSY: Fitting using NUG corrected decay-function');
else
    fitmodel = @purexp;
    if FitType==0
        model = @purexp;
    else
        model = @purexp2;
    end
    nug=[];
    display('DOSY: Fitting using standard pure exponential decay-function');
end;

%dmin=Diff(1);dmax=Diff(2);fn1=Diff(3);
%a=pfgnmrdata.SPECTRA
% Set some initial values
dscale=1e-10;
expfactor=pfgnmrdata.dosyconstant*dscale;
%a=pfgnmrdata.Gzlvl
pfgnmrdata.Gzlvl=pfgnmrdata.Gzlvl.^2;
if FitType==0
    opts=optimset('lsqcurvefit');
    opts=optimset(opts,'Display','off');
    %opts=optimset(opts,'TolFun',1e-15);
    opts=optimset(opts,'Jacobian','on');
else
    opts_fmin=optimset('fminsearch');
    opts_fmin=optimset(opts_fmin,'Display','Off');
    opts_fmin=optimset(opts_fmin,'MaxFunEvals',10000);
end
[nspec,ngrad]=size(pfgnmrdata.SPECTRA);
% xdiff=linspace(dmin,dmax,fn1);
% dd=xdiff(2) - xdiff(1);
fn1=Diff(3);
%th=max(pfgnmrdata.SPECTRA(:,1))*th/100;
DOSY=zeros(nspec,fn1);
if Opts(1)==0 %Use peak-picking
    [peak]=peakpick_mn(pfgnmrdata.SPECTRA(:,1),th);
    hp = waitbar(0,'DOSY: Fitting after peak picking');
    [npeaks]=length(peak);
    disp(['DOSY: Fitting on: ' num2str(npeaks) ' peaks'])
elseif (Opts(1)==1)
    peak(pfgnmrdata.np)=struct('max',0,'start',0,'stop',0);
    %npeaks=nspec;
    npeaks=0;
    for k=1:pfgnmrdata.np
        if pfgnmrdata.SPECTRA(k,1)>max(pfgnmrdata.SPECTRA(:,1))*th/100
            npeaks=npeaks+1;
            peak(npeaks).max=k;
            peak(npeaks).start=k;
            peak(npeaks).stop=k;
        end
    end
    hp = waitbar(0,'DOSY: Fitting each frequency');
else
    error('DOSY: Illegal (Opts(1)')
end
dosydata.FITSTATS=zeros(npeaks,4*Opts(3));
dosydata.FITTED=zeros(npeaks,ngrad);

nmult_fit=zeros(npeaks,1);
for i=1:npeaks
    disp(['DOSY: Peak: ' num2str(i) ])
    waitbar(i/npeaks);
    drawnow %to allow for interrupt
    fitparm(1)=pfgnmrdata.SPECTRA(peak(i).max,1);
    fitparm(2)= (log(fitparm(1)) - log( pfgnmrdata.SPECTRA(peak(i).max,:)))/(expfactor*pfgnmrdata.Gzlvl);
    fitparm=real(fitparm);
    
    if FitType==0
        [fitd,resnorm,residual,exitflag,output,lambda,jacobian]=...
            lsqcurvefit(model,fitparm,pfgnmrdata.Gzlvl,...
            pfgnmrdata.SPECTRA(peak(i).max,:),[-inf -inf],[Inf Inf],opts,expfactor,nug);
        
    elseif FitType==1
        [fitd]=...
            fminsearch(model,fitparm,opts_fmin,pfgnmrdata.Gzlvl,expfactor,nug,...
            pfgnmrdata.SPECTRA(peak(i).max,:));
        [resnorm,jacobian,residual]=model(fitd,pfgnmrdata.Gzlvl,expfactor,nug,...
            pfgnmrdata.SPECTRA(peak(i).max,:));
    else
        error('unknown FitType')
    end
    
    CM=full(inv(jacobian'*jacobian));
    sderr=0;
    for jj=1:2
        sderr(jj)=sqrt(resnorm/(ngrad-2))*sqrt(CM(jj,jj));
    end
    sderr=real(sderr);
    rejectflag=0;
    
    sderr_mono=sderr;
    fitd_mono=fitd;
    resnorm_mono=resnorm;
    residual_mono=residual;
    if (Opts(3)>1 )%multiexponential fitting
        nmult=Opts(3);
        opts_m=optimset('lsqcurvefit'); %#ok<NASGU>
        opts_m=optimset(opts,'Display','off'); %#ok<NASGU>
        opts_m=optimset(opts,'Jacobian','on');
        opts_m_fmin=optimset('fminsearch');
        opts_m_fmin=optimset(opts_m_fmin,'Display','Off');
        opts_m_fmin=optimset(opts_m_fmin,'MaxFunEvals',10000);
        
        breakflag=0;
        while (nmult>1)
            u_limit=100*ones(1,nmult*2); %not allowing a diffusion coefficient over 100
            u_limit=u_limit(:);
            l_limit=zeros(1,nmult*2); %non-negativty
            nMC_real= round(sqrt(nMC).^nmult);
            CM_best=0; %#ok<NASGU>
            fitd_best=0;
            sderr_best=0;
            resnorm_best=0;
            %trying a Monte Carlo approach with the diffusion
            %coefficients distributed around the
            %monoexponential fit and the amlitude as random fractions of
            %the monoexponetially fitted one.
            for kk=1:nMC_real
                nn=1;
                ampltot=0;
                multifit=0;
                for mm=1:nmult
                    multifit(nn)=rand; %amplitudes
                    ampltot=ampltot+multifit(nn);
                    nn=nn+2;
                end
                nn=1;
                if bitand(1,nmult) %odd
                    multifit(nn+1)=rand.*fitd(2);
                    for iter=1:nmult
                        if bitand(1,iter) %odd
                            multifit(nn+1)=iter/2*rand.*fitd(2); %#ok<*AGROW>
                        else
                            multifit(nn+1)=iter*2*rand.*fitd(2);
                        end
                        nn=nn+2;
                    end
                else %even
                    for iter=1:nmult
                        if bitand(1,iter) %odd
                            multifit(nn+1)=iter/2*rand.*fitd(2);
                        else
                            multifit(nn+1)=iter*2*rand.*fitd(2);
                        end
                        nn=nn+2;
                    end
                end;
                nn=1;
                for mm=1:nmult
                    %                     mm
                    %                     nn
                    multifit(nn)=multifit(nn)*fitd(1)/ampltot;
                    nn=nn+2;
                end
                if FitType==0
                    %                     u_limit
                    %                     l_limit
                    %                     multifit
                    
                    
                    [fitd_m,resnorm_m,residual_m,exitflag_m,output_m,lambda_m,jacobian_m]=...
                        lsqcurvefit(model,multifit,pfgnmrdata.Gzlvl,...
                        pfgnmrdata.SPECTRA(peak(i).max,:),l_limit,u_limit,opts_m,expfactor,nug);
                elseif FitType==1
                    [fitd_m]=...
                        fminsearch(model,multifit,opts_m_fmin,pfgnmrdata.Gzlvl,expfactor,nug,...
                        pfgnmrdata.SPECTRA(peak(i).max,:));
                    [resnorm_m,jacobian_m,residual_m]=model(fitd_m,pfgnmrdata.Gzlvl,expfactor,nug,...
                        pfgnmrdata.SPECTRA(peak(i).max,:));
                else
                    error('unknown FitType')
                end
                
                
                
                
                
                if kk==1
                    resnorm_best=resnorm_m;
                    fitd_best=fitd_m;
                    jacobian_best=jacobian_m;
                    residual_best=residual_m;
                elseif resnorm_m<resnorm_best
                    fitd_best=fitd_m;
                    resnorm_best=resnorm_m;
                    jacobian_best=jacobian_m;
                    residual_best=residual_m;
                end
                
            end
            %check if we like the multiexponential fit more than the
            %monoexponential
            
            CM_best=full(inv(jacobian_best'*jacobian_best));
            for jj=1:nmult*2
                sderr_best(jj)=sqrt(resnorm_best/(ngrad-2*nmult))*sqrt(CM_best(jj,jj)); 
            end
            fitd=fitd_best;
            sderr=sderr_best;
            residual=residual_best;
            if resnorm_best<resnorm_mono && isreal(sderr_best)==1
                for mm=1:nmult*2
                    if sderr_best(mm)>fitd_best(mm)*0.2
                        %if stdev is more than 30% we reject
                        %the fit and revert to the monoexponetial values
                        fitd=fitd_mono;
                        sderr=sderr_mono;
                        residual=residual_mono;
                        breakflag=1;
                    end
                end
            else
                %multiexponential fit is worse
                fitd=fitd_mono;
                sderr=sderr_mono;
                residual=residual_mono;
                breakflag=1;
            end
            if breakflag==0
                % the multifit is accepted and we use this result
                % we dont use either mono or bi fit if tri is successful
                break
            end
            nmult=nmult-1;
        end     %end of while
    end
    
    %this is a kludge to allow for construction of the ODSY spectrum
    %outside the loop
    FITD{i}=fitd;
    SDERR{i}=sderr;
    
    
    
    nmult_fit(i)=length(sderr)/2;
    dosydata.freqs(i)=pfgnmrdata.Ppmscale(peak(i).max);
    dosydata.RESIDUAL(i,:)=residual;
    dosydata.ORIGINAL(i,:)=pfgnmrdata.SPECTRA(peak(i).max,:);
    kkk=1;
    kkkk=1;
    
    for kk=1:nmult_fit(i)
        dosydata.FITTED(i,:)= dosydata.FITTED(i,:) +...
            fitmodel(fitd(kkk:kkk+1),pfgnmrdata.Gzlvl,expfactor,nug);
        dosydata.FITSTATS(i,kkkk:kkkk+3)=[fitd(kkk) sderr(kkk) fitd(kkk+1) sderr(kkk+1)];
        kkk=kkk+2;
        kkkk=kkkk+4;
    end
    if Opts(3)>1
        if nmult_fit(i)==3
            disp('DOSY: Triexp fitting successful')
        elseif nmult_fit(i)==2
            disp('DOSY: Biexp fitting successful')
        else
            disp('DOSY: Monoexp fitting used')
        end
    end
    %     if rejectflag==0
    %         ii=1;
    %         for jj=1:nmult_fit
    %             DOSY(peak(i).start:peak(i).stop,:)=DOSY(peak(i).start:peak(i).stop,:)+...
    %                 abs(pfgnmrdata.SPECTRA(peak(i).start:peak(i).stop,1))*fitd(ii)*...
    %                 (erf( (xdiff + dd/2 -fitd(ii+1))/sderr(ii+1)) -...
    %                 erf( (xdiff - dd/2 -fitd(ii+1))/sderr(ii+1)));
    %             ii=ii+2;
    %         end
    %     end
end


%Making the DOSY spectrum

maxD=max(dosydata.FITSTATS(:,3));
dmin=Diff(1);dmax=Diff(2);
if dmax<=0
    dmax=maxD*1.1;
end

xdiff=linspace(dmin,dmax,fn1);
dd=xdiff(2) - xdiff(1);
for i=1:npeaks
    
end

for i=1:npeaks
    
    
    fitd=FITD{i};
    sderr=SDERR{i};
    ii=1;
    for jj=1:nmult_fit(i)
        
        DOSY(peak(i).start:peak(i).stop,:)=DOSY(peak(i).start:peak(i).stop,:)+...
            (abs(pfgnmrdata.SPECTRA(peak(i).start:peak(i).stop,1))/max(abs(pfgnmrdata.SPECTRA(peak(i).start:peak(i).stop,1))))   *0.5*fitd(ii)*...
            (erf( (xdiff + dd/2 -fitd(ii+1))/sderr(ii+1)) -...
            erf( (xdiff - dd/2 -fitd(ii+1))/sderr(ii+1)));
    end
end






endt=cputime-t_start;
h=fix(endt/3600);
m=fix((endt-3600*h)/60);
s=endt-3600*h - 60*m;
fit_time=[h m s];
disp(['DOSY: Fitting time was: ' num2str(fit_time(1)) ' h  ' num2str(fit_time(2)) ' m and ' num2str(fit_time(3),2) ' s']);

dosydata.type='dosy';
dosydata.fit_time=fit_time;
dosydata.DOSY=DOSY;
dosydata.Gzlvl=pfgnmrdata.Gzlvl;
dosydata.Spectrum=pfgnmrdata.SPECTRA(:,1);
dosydata.Ppmscale=pfgnmrdata.Ppmscale';
dosydata.sp=pfgnmrdata.sp;
dosydata.wp=pfgnmrdata.wp;
dosydata.np=pfgnmrdata.np;
dosydata.fn1=fn1;
dosydata.dmin=dmin;
dosydata.dmax=dmax;
dosydata.Dscale=linspace(dmin,dmax,fn1);
dosydata.Options=Opts;
dosydata.threshold=th;
dosydata.Nug=nug;
%dosydata
close(hp);
dosyplot_gui(dosydata,5,th);


%-----------------------END of dosy_mn-------------------------------------




%-----------------Auxillary functions--------------------------------------

function [sse, J,residual] = purexp2(a,xdata,expfactor,nug,ydata) %#ok<INUSL>
% for fitting a number of pure exponentials
p=length(a)/2;
y=zeros(1,length(xdata));
q=1;
for m=1:p
    y = y + a(q)*exp(-a(q+1)*expfactor.*xdata);
    q=q+2;
end

J=zeros(length(xdata),length(a));
q=1;
for m=1:p
    J(:,q)=exp(-a(q+1)*expfactor.*xdata);
    J(:,q+1)=-expfactor.*xdata*a(q).*exp(-a(q+1)*expfactor.*xdata);
    q=q+2;
end

sse=ydata-y;
sse=sum(sse.^2,2);
residual=y-ydata;
function [y, J] = purexp(a,xdata,expfactor,nug) %#ok<INUSD>
% for fitting a number of pure exponentials
p=length(a)/2;
y=zeros(1,length(xdata));
q=1;
for m=1:p
    y = y + a(q)*exp(-a(q+1)*expfactor.*xdata);
    q=q+2;
end

if nargin>1
    J=zeros(length(xdata),length(a));
    q=1;
    for m=1:p
        J(:,q)=exp(-a(q+1)*expfactor.*xdata);
        J(:,q+1)=-expfactor.*xdata*a(q).*exp(-a(q+1)*expfactor.*xdata);
        q=q+2;
    end
    

end
function [sse, J, residual]=nugexp2(a,xdata,expfactor,nug,ydata)
p=length(a)/2;
y=zeros(1,length(xdata));
q=1;
for  m=1:p
    y= y+ a(q)*exp(  -nug(1)*(a(q+1)*expfactor.*xdata).^1 -...
        nug(2)*(a(q+1)*expfactor.*xdata).^2 -...
        nug(3)*(a(q+1)*expfactor.*xdata).^3 -...
        nug(4)*(a(q+1)*expfactor.*xdata).^4);
    q=q+2;
end


    J=zeros(length(xdata),length(a));
    q=1;
    for  m=1:p
        J(:,q)=exp(  -nug(1)*(a(q+1)*expfactor.*xdata).^1 -...
            nug(2)*(a(q+1)*expfactor.*xdata).^2 -...
            nug(3)*(a(q+1)*expfactor.*xdata).^3 -...
            nug(4)*(a(q+1)*expfactor.*xdata).^4);

        J(:,q+1)= a(q)*exp(  -nug(1)*(a(q+1)*expfactor.*xdata).^1 -...
            nug(2)*(a(q+1)*expfactor.*xdata).^2 -...
            nug(3)*(a(q+1)*expfactor.*xdata).^3 -...
            nug(4)*(a(q+1)*expfactor.*xdata).^4).*...
            ( -nug(1)*(expfactor.*xdata).^1 -...
            2*nug(2)*(a(q+1)*(expfactor.*xdata).^2) -...
            3*nug(3)*( (a(q+1))^2*(expfactor.*xdata).^3) -...
            4*nug(4)*( (a(q+1))^2*(expfactor.*xdata).^4));
        q=q+2;
    end
    sse=ydata-y;
sse=sum(sse.^2,2);
residual=y-ydata;
function [y, J]=nugexp(a,xdata,expfactor,nug)
p=length(a)/2;
y=zeros(1,length(xdata));
q=1;
for  m=1:p
    y= y+ a(q)*exp(  -nug(1)*(a(q+1)*expfactor.*xdata).^1 -...
        nug(2)*(a(q+1)*expfactor.*xdata).^2 -...
        nug(3)*(a(q+1)*expfactor.*xdata).^3 -...
        nug(4)*(a(q+1)*expfactor.*xdata).^4);
    q=q+2;
end

if nargin>1
    J=zeros(length(xdata),length(a));
    q=1;
    for  m=1:p
        J(:,q)=exp(  -nug(1)*(a(q+1)*expfactor.*xdata).^1 -...
            nug(2)*(a(q+1)*expfactor.*xdata).^2 -...
            nug(3)*(a(q+1)*expfactor.*xdata).^3 -...
            nug(4)*(a(q+1)*expfactor.*xdata).^4);

        J(:,q+1)= a(q)*exp(  -nug(1)*(a(q+1)*expfactor.*xdata).^1 -...
            nug(2)*(a(q+1)*expfactor.*xdata).^2 -...
            nug(3)*(a(q+1)*expfactor.*xdata).^3 -...
            nug(4)*(a(q+1)*expfactor.*xdata).^4).*...
            ( -nug(1)*(expfactor.*xdata).^1 -...
            2*nug(2)*(a(q+1)*(expfactor.*xdata).^2) -...
            3*nug(3)*( (a(q+1))^2*(expfactor.*xdata).^3) -...
            4*nug(4)*( (a(q+1))^2*(expfactor.*xdata).^4));
        q=q+2;
    end
end




