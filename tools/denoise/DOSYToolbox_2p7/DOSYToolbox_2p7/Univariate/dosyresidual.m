function dosyresidual(dosydata,npeak)


%   dosyresidual (dosydata, npeak);
%   dosyresidual.m: plots the residual in dosy data as obtained from dosy_mn.m
%
%   --------------------------------INPUT------------------------------------
%   dosydata  =  The data structure from dosy_mn
%   npeak     =   peak number
%
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
%   dosyresidual(dosydata,npeak)
% --------------------------------INPUT------------------------------------
%   dosydata  =   The data structure from dosy_mn
%   npeak     =   peak number
%


figure('Color',[1 1 1],'NumberTitle','Off');
% axes(...
%   'FontName','Arial',...  
%     'Name','Residuals',...
%   'FontWeight','bold',...
%   'LineWidth',2)
hold on


 norm_max=max([max(dosydata.ORIGINAL(npeak.residpeak,:)) max(dosydata.FITTED(npeak.residpeak,:))]);
        
        if strcmp(dosydata.type,'dosy')|| strcmp(dosydata.type,'ILT') || strcmp(dosydata.type,'locodosy')
            %DOSY type data
            plot(dosydata.Gzlvl,(dosydata.ORIGINAL(npeak.residpeak,:)./norm_max),'+k','LineWidth',2)
            hold on
            plot(dosydata.Gzlvl,(dosydata.FITTED(npeak.residpeak,:)./norm_max),'--r','LineWidth',2)
            plot(dosydata.Gzlvl,(dosydata.RESIDUAL(npeak.residpeak,:)./norm_max),'--b','LineWidth',2)
            xlabel('\fontname{ariel} \bf Gradient amplitude (T m^{-1})')
            set(gca,'LineWidth',2);
            axis('tight')
            ylim('auto')
            ylabel('\fontname{ariel} \bf Amplitude')            
            str=['\fontname{ariel} \bf Peak Number: ' num2str(npeak.residpeak)];
            text(0.5*max(dosydata.Gzlvl),1.05,str);
            str=['\fontname{ariel} \bf Frequency: ' num2str(dosydata.freqs(npeak.residpeak),3) ' ppm'];
            text(0.5*max(dosydata.Gzlvl),0.95,str);
            nexp=length(find(dosydata.FITSTATS(npeak.residpeak,:)))/4;
            str=['\fontname{ariel} \bf Number of exponentials: ' num2str(nexp,1)];
            text(0.5*max(dosydata.Gzlvl),0.85,str);            
            str='\color{black} \bf +  Original';
            text(0.5*max(dosydata.Gzlvl),0.7,str);
            str='\color{red} \bf - -  Fitted';
            text(0.5*max(dosydata.Gzlvl),0.6,str);
            str='\color{blue} \bf - -  Residual';
            text(0.5*max(dosydata.Gzlvl),0.5,str);            
            
        elseif strcmp(dosydata.type,'t1/t2')
            %relaxation data
            plot(dosydata.Tau,(dosydata.ORIGINAL(npeak.residpeak,:)./norm_max),'+k','LineWidth',2)
            hold on
            plot(dosydata.Tau,(dosydata.FITTED(npeak.residpeak,:)./norm_max),'--r','LineWidth',2)
            plot(dosydata.Tau,(dosydata.RESIDUAL(npeak.residpeak,:)./norm_max),'--b','LineWidth',2)
            xlabel('\fontname{ariel} \bf Time (s)')
            set(gca,'LineWidth',2);
            axis('tight')
            ylim('auto')
            ylabel('\fontname{ariel} \bf Amplitude')                       
            str=['\fontname{ariel} \bf Peak Number: ' num2str(npeak.residpeak)];
            text(0.5*max(dosydata.Tau),1.05,str);
            str=['\fontname{ariel} \bf Frequency: ' num2str(dosydata.freqs(npeak.residpeak),3) ' ppm'];
            text(0.5*max(dosydata.Tau),0.95,str);
            nexp=length(find(dosydata.FITSTATS(npeak.residpeak,:)))/4;
            str=['\fontname{ariel} \bf Number of exponentials: ' num2str(nexp,1)];
            text(0.5*max(dosydata.Tau),0.85,str);            
            str='\color{black} \bf +  Original';
            text(0.5*max(dosydata.Tau),0.7,str);
            str='\color{red} \bf - -  Fitted';
            text(0.5*max(dosydata.Tau),0.6,str);
            str='\color{blue} \bf - -  Residual';
            text(0.5*max(dosydata.Tau),0.5,str);
            
        else
            error('Unknown data type')
        end
        
          
        hold off       



% 
% 
% 
% %npeak
% norm_max=max([max(dosydata.ORIGINAL(npeak.residpeak,:)) max(dosydata.FITTED(npeak.residpeak,:))]);
% 
% plot(dosydata.Gzlvl,(dosydata.ORIGINAL(npeak.residpeak,:)./norm_max),'+k','LineWidth',2)
% plot(dosydata.Gzlvl,(dosydata.FITTED(npeak.residpeak,:)./norm_max),'--r','LineWidth',2)
% plot(dosydata.Gzlvl,(dosydata.RESIDUAL(npeak.residpeak,:)./norm_max),'--b','LineWidth',2)
% 
% set(gca,'LineWidth',2);
% %axis('tight')
% axis('auto')
% ylim('auto')
% ylabel('\fontname{ariel} \bf Amplitude')
% xlabel('\fontname{ariel} \bf Gradient amplitude squared (T m^{-1})^2')
% 
%  str=['\fontname{ariel} \bf Frequency: ' num2str(dosydata.freqs(npeak.residpeak),3) ' ppm'];
%  text(0.5*max(dosydata.Gzlvl),0.95,str);
%  nexp=length(find(dosydata.FITSTATS(npeak.residpeak,:)))/4;
%  str=['\fontname{ariel} \bf Number of exponentials: ' num2str(nexp,1)];
%  text(0.5*max(dosydata.Gzlvl),0.85,str);
%  
%  str='\color{black} \bf +  Original';
%  text(0.5*max(dosydata.Gzlvl),0.7,str);
%  str='\color{red} \bf - -  Fitted';
%  text(0.5*max(dosydata.Gzlvl),0.6,str);
%  str='\color{blue} \bf - -  Residual';
%  text(0.5*max(dosydata.Gzlvl),0.5,str);
end

