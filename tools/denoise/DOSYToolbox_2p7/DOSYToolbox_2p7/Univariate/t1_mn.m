function [t1data]=t1_mn(pfgnmrdata,thresh,Specrange,T1range,FitType)
%   [T1]=t1_mn(pfgnmrdata,thresh,Specrange)
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
%   FitType         The type of Fit e.g. T1 or T2
%
%   --------------------------------------OUTPUT------------------------------
%   t1data         Structure containg the data obtained after t1/t2fit with
%                  the follwing elements:
%
%
%                  fit_time:   The time it took to run the fitting%
%                  wp: width of spectrum (ppm)
%                  sp: start of spectrum (ppm)
%                  Ppmscale: scale for plotting the spectrum
%                  filename: the name and path of the original file
%
%
%   Example:
%
%   See also: dosy_mn, score_mn, decra_mn, mcr_mn, varianimport,
%             brukerimport, jeolimport, peakpick_mn, dosyplot_mn,
%             dosyresidual, dosyplot_gui, scoreplot_mn, decraplot_mn,
%             mcrplot_mn
%
%   References:
%
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
    disp(' T1/T2 fitting')
    disp(' ')
    disp(' Type <<help t1_mn>> for more info')
    disp('  ')
    return
elseif nargin<1
    error(' t1_mn needs a pfgnmrdata stucture as input')
elseif nargin >6
    error(' Too many inputs')
end


if FitType==1
    disp('T1 (3 parameter fit)')
    
elseif FitType==2
    disp('T2 (2 parameter fit) ')
    
else
    error('Unknown FitType')
end

t_start=cputime;

%Defaults

t1data.filename=pfgnmrdata.filename;
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
            error('T1/T2: Specrange should have excatly 2 elements')
        end
        if Specrange(1)<pfgnmrdata.sp
            disp('T1/T2: Specrange(1) is too low. The minumum will be used')
            Specrange(1)=pfgnmrdata.sp;
        end
        if Specrange(2)>(pfgnmrdata.wp+pfgnmrdata.sp)
            disp('T1/T2: Specrange(2) is too high. The maximum will be used')
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
    if (length(T1range) ~= 3)
        if T1range==0
            %use defaults
            T1range=[0 10 256];
        else
            error('T1/T2: Diffrange is a vector of size 3')
        end
    end
end
AutoPlotLimits=0;
if T1range(1)==0 && T1range(2)==0
    %automatically find the plot limits
    AutoPlotLimits=1;
end
fn1=T1range(3);

[nspec,nTau]=size(pfgnmrdata.SPECTRA);

T1=zeros(nspec,fn1);
Opts(1)=0;
if Opts(1)==0 %Use peak-picking
    [peak]=peakpick_mn(pfgnmrdata.SPECTRA(:,pfgnmrdata.flipnr),th);
    hp = waitbar(0,'T1/T2: Fitting after peak picking');
    [npeaks]=length(peak);
    disp(['T1/T2: Fitting on: ' num2str(npeaks) ' peaks'])
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
    hp = waitbar(0,'T1/T2: Fitting each frequency');
else
    error('T1/T2: Illegal (Opts(1)')
end

t1data.FITSTATS=zeros(npeaks,6);

opts=optimset('lsqcurvefit');
opts=optimset(opts,'Display','off');
opts=optimset(opts,'TolFun',1e-6);
opts=optimset(opts,'TolX',1e-6);
opts=optimset(opts,'Jacobian','on');
opts=optimset(opts,'MaxFunEvals',10000);

model=@t1;
for i=1:npeaks
    disp(['T1/T2: Peak: ' num2str(i) ])
    waitbar(i/npeaks);
    ydata=pfgnmrdata.SPECTRA(peak(i).max,:);
    %ydata=[-35.56 -34.57 -32.51 -29.52 -23.03 -12.58 3.59 22.64 35.94 39.50 40.22 40.12] %should give T1 1.081
    ydata=ydata/norm(ydata);
    
    if FitType==1 %T1
        xdata=pfgnmrdata.d2;
        fitparm(2)=1 ;%should do a better guess from logfit
        M0=ydata(end);
        fitparm(1)=-M0;
        fitparm(3)=M0;
    elseif FitType==2 %T2
        if strcmp(pfgnmrdata.type,'Bruker')
            xdata=pfgnmrdata.d2;
            disp('Bruker data - using d2 as arrayed times')
        elseif strcmp(pfgnmrdata.type,'Varian')
            xdata=pfgnmrdata.bigtau;
            disp('Varian data - using bigtau as arrayed times')
        else
            error('Can not determine data type')
        end
        fitparm(2)=1 ;%should do a better guess from logfit
        M0=ydata(1);
        fitparm(1)=M0;
        % fitparm(3)=0;
        fitparm=fitparm(1:2);
        model=@t2;
        
    else
        error('Unknown FitType')
    end
    [fitd,resnorm,residual,exitflag,output,lambda,jacobian]=...
        lsqcurvefit(model,fitparm,xdata,...
        ydata,[],[],opts);
    
    
    
    CM=full(inv(jacobian'*jacobian));
    
    tmp=sqrt(resnorm/(length(xdata)-2)*sqrt(CM)) ;
    sderrt1(i)=abs(tmp(2));   %#ok<*AGROW>
    fittedt1(i)=fitd(2);
    fittedamp(i)=fitd(1);
    
    
    t1data.Tau=xdata;
    t1data.freqs(i)=pfgnmrdata.Ppmscale(peak(i).max);
    t1data.RESIDUAL(i,:)=residual;
    t1data.ORIGINAL(i,:)=ydata;
    t1data.FITTED(i,:)=model(fitd,xdata);
    t1data.FITSTATS(i,1:6)=[fittedamp(i) tmp(1) M0 tmp(3) fittedt1(i) sderrt1(i)];
    
    
end

% figure
% plot(t1data.FITTED(1,:))
% hold on
% plot(t1data.ORIGINAL(1,:))
tt=max(fittedt1)

if AutoPlotLimits==1
    t1min=0;
    [Val, Idx]=max(fittedt1);
    t1max=1.25*(Val+sderrt1(Idx));
else
    t1min=T1range(1);
    t1max=T1range(2);
end
xdiff=linspace(t1min,t1max,fn1);
dd=xdiff(2) - xdiff(1);

for k=1:(length(fittedt1))
    
    T1(peak(k).start:peak(k).stop,:)= real(pfgnmrdata.SPECTRA(peak(k).start:peak(k).stop,end))*-fittedamp(k)*...
        (erf( (xdiff + dd/2 -fittedt1(k))/sderrt1(k)) -...
        erf( (xdiff - dd/2 -fittedt1(k))/sderrt1(k)));
end

endt=cputime-t_start;
h=fix(endt/3600);
m=fix((endt-3600*h)/60);
s=endt-3600*h - 60*m;
fit_time=[h m s];
disp(['T1: Fitting time was: ' num2str(fit_time(1)) ' h  ' num2str(fit_time(2)) ' m and ' num2str(fit_time(3),2) ' s']);

t1data.type='t1/t2';
t1data.fit_time=fit_time;
t1data.T1=T1;
t1data.FitType=FitType;
if FitType==1 %T1
    t1data.Spectrum=pfgnmrdata.SPECTRA(:,end);
elseif FitType==2 %T2
    t1data.Spectrum=pfgnmrdata.SPECTRA(:,1);
else
    error('Unknown FitType')
end
t1data.Ppmscale=pfgnmrdata.Ppmscale';
t1data.sp=pfgnmrdata.sp;
t1data.wp=pfgnmrdata.wp;
t1data.np=pfgnmrdata.np;
t1data.fn1=fn1;
% t1data.dmin=dmin;
% t1data.dmax=dmax;
t1min
t1max
t1data.T1scale=linspace(t1min,t1max,fn1);
t1data.threshold=th;
t1data.d2=xdata;
%t1data
close(hp);
%t1plot(t1data,5,th);
%dosyplot_gui(t1data,5,th);


%-----------------------END of t1_mn-------------------------------------

%-----------------Auxillary functions--------------------------------------

    function [y, J] = t1(a,xdata)
        % for fitting a number of pure exponentials
        % this function works for both T1 and T2 but the initial guesses
        % should be different. However, I will use a 2 parameter for T2 as bot signal
        %and noise should decay to zero.
        %
        %T1: M(t)=(M(0) - M0)*exp(-t/T1)+M0
        %where M0 is the equilibrium Z magnetization and M(0) is the magnetization
        %at time zero (e.g., immediately after the 180° pulse for an inversion
        %recovery T1 experiment). Notice that this equation will fit inversion
        %recovery data (for which M(0) is approximately equal to -M0) or saturation
        %recovery data (for which M(0) is 0).
        %
        %T2:  M(t) = (M(0) - M(inf))*exp(-t/T2) + M(inf)
        %where M(0) is the magnetization at time zero (i.e., the full
        %magnetization excited by the observe pulse) and M(inf) is the
        %xy-magnetization at infinite time (zero unless the peak is sitting on an
        %offset baseline).        
        
        xdata=xdata';
        %y=zeros(1,length(xdata));
        y =(a(1) - a(3))*exp(-xdata/a(2)) + a(3);
        if nargin>1
            J=zeros(length(xdata),length(a));
            J(:,1)=exp(-xdata./a(2));
            J(:,2)=((a(1) - a(3))*exp(-xdata/a(2)).*xdata)./a(2).^2;
            J(:,3)=1- exp(-xdata./a(2));
            
        end
    end
    function [y, J] = t2(a,xdata)
        %T2:  M(t) = (M(0) - M(inf))*exp(-t/T2) + M(inf)
        %where M(0) is the magnetization at time zero (i.e., the full
        %magnetization excited by the observe pulse) and M(inf) is the
        %xy-magnetization at infinite time (zero unless the peak is sitting on an
        %offset baseline). So using:
        %T2: M(t) = M(0)*exp(-t/T2)
         xdata=xdata';
        %y=zeros(1,length(xdata));
        y =a(1)*exp(-xdata/a(2));
        if nargin>1
            J=zeros(length(xdata),length(a));
            J(:,1)=exp(-xdata./a(2));
            J(:,2)=(a(1)*exp(-xdata/a(2)).*xdata)./a(2).^2;
            
        end
    end


end
