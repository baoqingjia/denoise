
function [icadata]=ica_mn(pfgnmrdata,ncomp)

%   ICA (Independent Component Analysis) fitting of
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
%
%   ncomp           Number of componets (spectra) to fit.
%
%
%   ---------------------------INPUT - OPTIONAL-------------------------------
%
%
%   --------------------------------------OUTPUT------------------------------
%   icadata        Structure containg the data obtained after ica with
%                  the follwing elements:
%                     
%                  COMPONENTS: The fitted spectra. In the optimal case 
%                              representing the true spectra of the 
%                              indiviual componets in the mixture
%                  DECAYS:     The decys of the fitted spectra
%                  fit_time:   The time it took to run the fitting
%                  Gzlvl: vector of gradient amplitudes (T/m)
%                  wp: width of spectrum (ppm)
%                  sp: start of spectrum (ppm)
%                  Ppmscale: scale for plotting the spectrum
%                  filename: the name and path of the original file
%                  Dval: fitted diffusion coeffcients (10^-10 m2s-1)
%                  ncomp: number of fitted components
%                  
%   Example:  
%
%   See also: dosy_mn, score_mn, decra_mn, mcr_mn, varianimport, 
%             brukerimport, jeolimport, peakpick_mn, dosyplot_mn, 
%             dosyresidual, dosyplot_gui, scoreplot_mn, decraplot_mn,
%             mcrplot_mn
%             
%   Based on the paper Journal of Chemometrics 2012, 26, 150.
%   and using the fastICA algorithm
%
%   This is a part of the DOSYToolbox        
%   Copyright  2007-2014  <Mathias Nilsson>%
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
   disp(' ICA ')
   disp(' ')
   disp(' Type <<help ica_mn>> for more info')
   return
elseif nargin<2
   error(' The inputs pfgnmrdata and ncomp must be given')
end

if nargin>2
    if Specrange==0
        %do nothing
    else
        if length(Specrange)~=2
            error('ICA: Specrange should have excatly 2 elements')
        end
        if Specrange(2)<Specrange(1)
            error('ICA: Second element of Specrange must be larger than the first')
        end
        if ((Specrange(1)<pfgnmrdata.sp) || Specrange(2)>(pfgnmrdata.sp+pfgnmrdata.wp))
            error('ICA: Specrange exceeds the spectral width (sp - sp+wp)i')
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

if nargin>3
    %loco plot options
else
    plot=1;
end

tic;
data=pfgnmrdata.SPECTRA';
grad2=pfgnmrdata.Gzlvl;
dscale=1e-10;
expfactor=pfgnmrdata.dosyconstant*dscale;
startspec=1;
endspec=pfgnmrdata.ngrad;

% Making sure the data is in the right format
grad2=grad2(:);
grad2=grad2.^2;
% Assuming more spectral points than gradient levels

[A,W,Y] =fastica(squeeze(pfgnmrdata.SPECTRA)', 'numOfIC',ncomp);

[m,n]=size(A);
icadata.filename=pfgnmrdata.filename;
icadata.Gzlvl=pfgnmrdata.Gzlvl; 

icadata.wp=pfgnmrdata.wp;
icadata.sp=pfgnmrdata.sp;
icadata.Ppmscale=pfgnmrdata.Ppmscale;
icadata.ncomp=m;
icadata.np=pfgnmrdata.np;

 A=A';
 A=A/norm(A,'fro');

for k=1:icadata.ncomp
    
    if sum(A(:,k)) < 0
        A(:,k)=-A(:,k);
        W(:,k)=-W(:,k);
    end
    A(:,k)=A(:,k)/max(A(:,k));
end

icadata.COMPONENTS=A';
icadata.DECAYS=W;

%fitting for the diffusion coefficients
model = @purexp;
opts=optimset('lsqcurvefit');
opts=optimset(opts,'Display','off');
%opts=optimset(opts,'TolFun',1e-15);
opts=optimset(opts,'Jacobian','on');
nug=1;

for k=1:icadata.ncomp
    fitparm(1)=icadata.DECAYS(1,k);

    fitparm(2)= (log(fitparm(1)) - log( icadata.DECAYS(:,k))')/(expfactor*grad2)';
    fitparm=real(fitparm);
    
    [fitd,resnorm,residual,exitflag,output,lambda,jacobian]=...
        lsqcurvefit(model,fitparm,grad2,...
        icadata.DECAYS(:,k),[-inf -inf],[Inf Inf],opts,expfactor,nug);    
    
    CM=full(inv(jacobian'*jacobian));
    
    tmp=sqrt(resnorm/(pfgnmrdata.ngrad-2)*sqrt(CM)) ;
    tmp(2);
    sderr(k)=abs(tmp(2,2));   %#ok<*AGROW>
    Dval(k)=fitd(2);
 
end

 


endt=toc;
h=fix(endt/3600);
m=fix((endt-3600*h)/60);
s=endt-3600*h - 60*m;
fit_time=[h m s];
disp(['ICA: Fitting time was: ' num2str(fit_time(1)) ' h  ' num2str(fit_time(2)) ' m and ' num2str(fit_time(3),2) ' s']);

icadata.sderr=sderr;
icadata.Dval=Dval;
relp=sum(abs(icadata.COMPONENTS),2);
icadata.relp=relp;

icadata.filename=pfgnmrdata.filename;
icadata.Gzlvl=pfgnmrdata.Gzlvl; 
icadata.fit_time=fit_time;
icadata.wp=pfgnmrdata.wp;
icadata.sp=pfgnmrdata.sp;
icadata.Ppmscale=pfgnmrdata.Ppmscale;
icadata.np=pfgnmrdata.np;


icaplot_mn(icadata)


end


function [y, J] = purexp(a,xdata,expfactor,nug) %#ok<INUSD>
% for fitting a number of pure exponentials

    y = a(1)*exp(-a(2)*expfactor.*xdata);


        J(:,1)=exp(-a(2)*expfactor.*xdata);
        J(:,2)=-expfactor.*xdata*a(1).*exp(-a(2)*expfactor.*xdata);

end



% function y = purexp(a,xdata,expfactor,nugc) %#ok
% % for fitting a number of pure exponentials
% y = a(1)*exp(-a(2)*expfactor.*xdata);
% end
% function y = nugexp(a,xdata,expfactor,nugc)
% %fitting non-uniform field gradient decays (NUG)
% y = a(1)*exp( - nugc(1)*(a(2)*expfactor.*xdata).^1 -...
%     nugc(2)*(a(2)*expfactor.*xdata).^2 -...
%     nugc(3)*(a(2)*expfactor.*xdata).^3 -...
%     nugc(4)*(a(2)*expfactor.*xdata).^4);
% end
% 
