function [locodosydata]=locodosy(pfgnmrdata,numcomp,nwin,Specrange,Options,thresh,Nug,winstart,winend,Dlimit,minpercent,fn1)
% Local rank (locodosy) processing of
% PFG-NMR diffusion data (aka DOSY data)
%
% see also 'core_mn, decra_mn, dosy_mn, score_mn, and mcr_mn'
%
%-------------------------------INPUT--------------------------------------
% pfgnmrdata      Data structure containing the PFGNMR experiment. Must
%                 contain valid spectra, gradient levels and dosyconstant
%                 See dosyimport.m for information about the pfgnmrdata
%                 structure.
%
% numcomp         Number of components (spectra) to fit in each window.
%
% nwin            Number of windows that the spectrum will be divied into.
%
% winstart/winend An array of the start/end points of the spectral windows
%                 (PPM).
%
% Dlimit          The maximum value of diffusion coefficient allowed before
%                 the number of components is reduced in Auto LOCO DOSY.
%
%---------------------------INPUT - OPTIONAL-------------------------------
%
%
% Specrange       The spectral range (in ppm) in which the dosy fitting
%                 will be performed. if set to [0] defaults will be used.
%                 DEFAULT is [sp wp+sp];
%
% Options         Optional parameters
%
%                   Options(1): Shape of the decay
%                       0 (DEFAULT) pure exponetial
%                       1 correcting for non-uniform field gradients.
%                         Supply your own coefficients or use the default
%                         (Varian ID 5mm probe, Manchester 2006). Presently
%                         a maximum of 4 coefficients is supported.
%                   Options(2): plotting
%                        0 (DEFAULT) plot the result using dosyplot
%                        1  no plot
%                   Options(3): Algorithm type
%                        0  SCORE
%                        1  DECRA
%                        2  PARAFAC
%                   Options(4): Method window plots
%                        0  No window plots
%                        1  Window plots.
%
% thresh =        Noise threshold. Any data point below won't be used in
%                   the fitting. Expressed as % of highest peak. Default 5
%                   (%).
%
% Nug             array contaning coefficients for non-uniform field
%                 gradient. Set nug=[] for default values.
%
%
%--------------------------------------OUTPUT------------------------------
%   locodosydata          Structure containg the data obtained after the score fit.
%
%   fit_time           The time it took to run the fitting.

%     locodosy.m LOCODOSY processing of NMR data
%     Copyright (C) <2007>  <Mathias Nilsson>
%
%     This program is free software; you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation; either version 2 of the License, or
%     (at your option) any later version.
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License along
%     with this program; if not, write to the Free Software Foundation, Inc.,
%     51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
%
%     Dr. Mathias Nilsson
%     School of Chemistry, University of Manchester,
%     Oxford Road, Manchester M13 9PL, UK
%     Telephone: +44 (0) 161 275 4668
%     Fax: +44 (0)161 275 4598
%     mathias.nilsson@manchester.ac.uk

t_start=cputime;
%Initial check
if nargin==0
    disp(' ')
    disp(' locodosy')
    disp(' ')
    disp(' Type <<help locodosy>> for more info')
    return
elseif nargin<3
    error(' The inputs pfgnmrdata, ncomp and nwin must be given')
elseif nargin >12
    error('locodosy takes a maximum of 12 arguments')
end

dmin=0;
dmax=Dlimit;

lb=[];
ub=[];
Opts_score=[0 0 0 0 1 0];
opts=optimset('lsqcurvefit');
opts=optimset(opts,'Display','Off');
opts=optimset(opts,'TolFun',1e-8);
%nug=[9.280636e-1 -9.789118e-3 -3.834212e-4 2.51367e-5];
dscale=1e-10;
expfactor=pfgnmrdata.dosyconstant*dscale;
xdiff=linspace(dmin,dmax,fn1);
dd=xdiff(2) - xdiff(1);

if nargin>3
    if Specrange==0
        %do nothing
    else
        if length(Specrange)~=2
            error('locodosy: Specrange should have excatly 2 elements')
        end
        if Specrange(1)<pfgnmrdata.sp
            disp('locodosy: Specrange(1) is too low. The minumum will be used')
            Specrange(1)=pfgnmrdata.sp;
        end
        if Specrange(2)>(pfgnmrdata.wp-pfgnmrdata.sp)
            disp('locodosy: Specrange(2) is too high. The maximum will be used')
            Specrange(2)=pfgnmrdata.wp-pfgnmrdata.sp;
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
        pfgnmrdata.sp=Specrange(1);
        pfgnmrdata.wp=Specrange(2)-Specrange(1);
        pfgnmrdata.SPECTRA=pfgnmrdata.SPECTRA(begin:endrange,:,:);
        pfgnmrdata.np=length(pfgnmrdata.Ppmscale);
    end
    
end

Specrange=[pfgnmrdata.sp pfgnmrdata.wp+pfgnmrdata.sp];
%  Winsize=(Specrange(2)-Specrange(1))/nwin;

if nargin>4
    %user Options
    if length(Options)<2            %FIX
        error('locodosy: Options is a vector of length 2')
    end
    Opts=Options;
end

switch Opts(1)
    case 0
        disp('locodosy: Using monoexponential decay curve')
        model=@globfit;
        Opts_score(3)=0;
        
    case 1
        disp('locodosy: Using NUG decay curve')
        model=@globfitnug;
        Opts_score(3)=1;
        
    otherwise
        error('locodosy: Illegal Options(1)')
end

switch Opts(2)
    
    case 0
        disp('locodosy: Result will be plotted')
        
    case 1
        disp('locodosy: No plot')
        
    otherwise
        error('locodosy: Illegal Options(2)')
end

switch Opts(4)
    case 0
        % No SCORE plots
        Opts_score(4)=0;
    case 1
        % SCORE plots
        Opts_score(4)=1; 
end

DOSY=zeros(pfgnmrdata.np,fn1);

% Threshold
if (nargin >5)
    
    th=thresh;
else
    th=0.1;
end

if nargin > 6
    disp('locodosy: Using user supplied NUG coefficients')
    if length(Nug)>4
        disp('locodosy: Warning -A maximum of 4 NUG coefficients is supported');
        disp('locodosy: Coefficients truncated to 4');
        nug=Nug(1:4);
    elseif length(Nug)<=4
        disp('locodosy: Warning - 4 NUG coefficients are normally used');
        disp('locodosy: Coefficients appended by zeros');
        nug=[0 0 0 0];
        nug(1:length(Nug))=Nug;
    end
    
end

locodosydata.components=cell(nwin,1);
sderrcell=cell(nwin,1);
for m=1:nwin
    disp(['LOCODOSY: Processing window ' num2str(m)])
    warning('off','all')
    if m>length(numcomp)
        break;
    end

    ncomp=numcomp(1,m);
    % set the spectral region to perform score on.
    Range=[winstart(m) winend(m)];

    if Range(1)<pfgnmrdata.sp
        disp('locodosy: Range(1) is too low. The minumum will be used')
        Range(1)=pfgnmrdata.sp;
    end
    if Range(2)>(pfgnmrdata.wp+pfgnmrdata.sp)
        disp('locodosy: Specrange(2) is too high. Will not continue with this segment')
        %Range(2)=pfgnmrdata.wp+pfgnmrdata.sp;
        break;
    end
    for k=1:length(pfgnmrdata.Ppmscale)
        if (pfgnmrdata.Ppmscale(k)>Range(1))
            startrange=k-1;
            break;
        end
    end
    for k=startrange:length(pfgnmrdata.Ppmscale)
        if (pfgnmrdata.Ppmscale(k)>=Range(2))
            endrange=k;
            break;
        end
    end

    YDATA=pfgnmrdata.SPECTRA(startrange:endrange,:,:);
    switch Opts(3)
        case 0
            disp('locodosy: Using SCORE fitting')
            Fixed=[];
            mvdata=score_mn(pfgnmrdata,ncomp,Range,Opts_score,nug,Fixed);
        case 1
            disp('locodosy: Using DECRA fitting')
            mvdata=decra_mn(pfgnmrdata,ncomp,Range,Opts(4));
            mvdata.Dval=mvdata.Dval'*1e10;
        case 2
            disp('locodosy: Using PARAFAC fitting')
%             error('LOCO PARAFAC not yet implemented')
            % PARAFAC specific variables - plotting off.
            PF_Options=[1e-6 1 1];
            PF_const=[0 0 0];
            PF_OldLoad=[];
            PF_FixMode=[];
            PF_Weights=[];
            
            % Call the n-way toolbox parafac module
            [Factors,it,err,corcondia] = parafac(YDATA,ncomp,... 
                PF_Options,PF_const,PF_OldLoad,PF_FixMode,PF_Weights);
            
            mvdata.COMPONENTS=Factors{1}'; % Component spectra
            mvdata.DECAYS=Factors{2}; % DOSY decays
            mvdata.t1decays=Factors{3}'; % T1 Decays
            
            mvdata.Dval=0;
            % Fit the decays extracted by parafac to get Dvals
            for n=1:ncomp
                fitparm(1)=mvdata.DECAYS(1,n); % AMPLITUDE OF THE FIRST BIT IN DOSY
                fitparm(2)= (log(fitparm(1)) - log(mvdata.DECAYS(:,n)))'/...
                    (expfactor*pfgnmrdata.Gzlvl(1:pfgnmrdata.ngrad).^2);
                for kk=1:length(fitparm)
                    if fitparm(kk)<=0
                        fitparm(kk)=1;
                    end
                end
                
                if Opts(1)==0
                    model1=@purexp;
                elseif Opts(1)==1
                    model1=@nugexp;
                end

                % LSQ CURVE FIT
                
                opts_fit=optimset('lsqcurvefit');
                opts_fit=optimset(opts,'Display','off');
                opts_fit=optimset(opts,'Jacobian','on');
                
                [fitd,resnorm,residual,exitflag,output,lambda,jacobian]=...
                    lsqcurvefit(model1,fitparm,pfgnmrdata.Gzlvl(1:pfgnmrdata.ngrad).^2,mvdata.DECAYS(:,n)',...
                    [-inf -inf],[Inf Inf],opts_fit,expfactor,nug);
                mvdata.Dval(n)=fitd(2);
            end    

            % set up the rest of mvdata
            mvdata.Gzlvl=pfgnmrdata.Gzlvl(1:pfgnmrdata.ngrad);
            mvdata.relp=sum(abs(mvdata.COMPONENTS),2);
            YDATA=YDATA(:,:,1);
            
            % Plotting
            if Options(4)==1
            mvdata.Ppmscale=pfgnmrdata.Ppmscale(startrange:endrange);    
            mvdata.ncomp=ncomp;
            mvdata.nfix=0;
            mvdata.Dfix=[];
            mvdata.relp=sum(abs(mvdata.COMPONENTS),2);
            scoreplot(mvdata)
            end
        otherwise
            error('locodosy: Illegal Options(3)')
    end
    
    if Opts(5)==1 && Opts(3)~=2
        [mvdata ncomp]=redomvproc(mvdata,pfgnmrdata,ncomp,Range,...
            Opts_score,Opts,nug,Dlimit,minpercent);
    end
    
    % After score does its work, store the components and their diffusion
    % coefficients in a cell so that they can be used later.
    locodosydata.components{m,1}=mvdata.COMPONENTS;
    locodosydata.components{m,2}=mvdata.Dval;
    relp=100*(mvdata.relp./sum(mvdata.relp));
    locodosydata.components{m,3}=relp;
    startguess=linspace(0.95,1.05,ncomp*2);
    for k=1:ncomp
        startguess(2*k)=startguess(2*k)*mvdata.Dval(k);
    end
    
    %Fit the components to the model to get the errors.
    
    [fitd,resnorm,residual,exitflag,output,lambda,jacobian]=...
        lsqcurvefit(model,startguess,mvdata.Gzlvl.^2,YDATA,...
        lb,ub,opts,mvdata.COMPONENTS,expfactor,nug);

    % Calculate errors from the above fit.
    CM=full(inv(jacobian'*jacobian));
    sderr=zeros(1,ncomp*2);
    for k=1:ncomp*2
        if imag(fitd(k))==0
            fitd(k)=real(fitd(k));
        end
        % SDERR WILL BE IMAGINARY WHEN THERE ARE TOO FEW GRADIENT INCREMENTS
        if isreal(fitd(k))
            sderr(k)=sqrt(resnorm/(pfgnmrdata.ngrad-ncomp*2))*sqrt(CM(k,k));
        else
            fitd(k)=Inf;
            sderr(k)=Inf;
            disp(['LOCODOSY: FITTED DIFFUSION COEFFICIENTS ARE NOT ALL' ...
                'REAL: PEAKS MISSING IN DOSY SPECTRUM'])
        end
    end
    for k=1:ncomp*2
        if imag(sderr(k))==0
            sderr(k)=real(sderr(k));
        end
        if ~isreal(sderr(k))
            fitd(k)=Inf;
            sderr(k)=Inf;
            disp(['LOCODOSY: CALCULATED ERRORS ARE NOT ALL REAL: PEAKS' ...
                'MISSING IN DOSY SPECTRUM'])
        end
    end
    ii=1;

    % Generate a DOSY spectral matrix
    for jj=1:ncomp
        DOSY(startrange:endrange,:)=DOSY(startrange:endrange,:)+...
            mvdata.COMPONENTS(jj,:)'*fitd(ii)*...
            (erf( (xdiff + dd/2 -mvdata.Dval(jj))/sderr(ii+1)) -...
            erf( (xdiff - dd/2 -mvdata.Dval(jj))/sderr(ii+1)));
        ii=ii+2;
    end
    
    % Save the errors for each component
    for ee=1:length(sderr)
        if mod(ee,2)
            %odd
        else
            sderr2((ee/2),1)=sderr(ee);
        end
    end
    sderrcell{m,1}=sderr2;
    newnumcomp(m,1)=ncomp;
    warning('on','all')
end

endt=cputime-t_start;
h=fix(endt/3600);
m=fix((endt-3600*h)/60);
s=endt-3600*h - 60*m;
fit_time=[h m s];
disp(['locodosy;: Fitting time was: ' num2str(fit_time(1)) ' h  ' num2str(fit_time(2)) ' m and ' num2str(fit_time(3),2) ' s']);

locodosydata.type='locodosy';
locodosydata.DOSY=DOSY;
locodosydata.fit_time=fit_time;

locodosydata.Gzlvl=mvdata.Gzlvl;
locodosydata.Spectrum=pfgnmrdata.SPECTRA(:,1);
locodosydata.Ppmscale=pfgnmrdata.Ppmscale';
locodosydata.sp=pfgnmrdata.sp;
locodosydata.wp=pfgnmrdata.wp;
locodosydata.np=pfgnmrdata.np;
locodosydata.fn1=fn1;
locodosydata.dmin=dmin;
locodosydata.dmax=dmax;
locodosydata.Dscale=linspace(dmin,dmax,fn1);
locodosydata.Options=Opts;
locodosydata.threshold=th*10;
locodosydata.Nug=nug;
locodosydata.sderrcell=sderrcell;
locodosydata.newnumcomp=newnumcomp;

if Opts(2)==0
    dosyplot_gui(locodosydata);
elseif Opts(2)==1
    %don't plot
else
    Disp('locodosy: Warning - unknown plot option')
end
end %end of locodosy
% Error calculation
function y=globfit(fitvar,xdata,speccomp,expfactor,nug) %#ok<INUSD>
p=min(size(speccomp));

% should use vectorised instead of for loop - but works for now
y=zeros(max(size(xdata)),max(size(speccomp)))';
m=1;
for i=1:p
    y= y+ fitvar(m)*speccomp(i,:)'*exp((-fitvar(m+1)*expfactor).*xdata);
    m=m+2;
end
end
function y=globfitnug(fitvar,xdata,speccomp,expfactor,nug)

p=min(size(speccomp));
% should use vectorised instead of for loop - but works for now
y=zeros(max(size(xdata)),max(size(speccomp)))';
m=1;

for i=1:p
    y= y+ fitvar(m)*speccomp(i,:)'*exp(...
        nug(1)*((-fitvar(m+1)*expfactor).*xdata).^1 + ...
        nug(2)*((-fitvar(m+1)*expfactor).*xdata).^2 + ...
        nug(3)*((-fitvar(m+1)*expfactor).*xdata).^3 + ...
        nug(4)*((-fitvar(m+1)*expfactor).*xdata).^4);
    m=m+2;
end
if sum(sum(isnan(y))) || sum(sum(isinf(y)))
    y=zeros(max(size(xdata)),max(size(speccomp)))';
end

end
% Fitting parafac Dvals
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
end
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
end
