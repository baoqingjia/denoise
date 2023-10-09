
function decraplot(decradata)


%   function decraplot(decradata)
%   decraplot.m: plots decra data as obtained from decra_mn.m
%
%   --------------------------------INPUT------------------------------------
%   decradata  =  The data structure from decra_mn
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
%   mathias.nilsson@manchester.ac.uk

if nargin==0
    disp(' ')
    disp(' ')
    disp(' DECRAPLOT')
    disp('At least one input is needed')
    disp(' ')
    disp(' Type <<help decraplot>> for more info')
    disp('  ')
    return
elseif nargin >2
    error(' Too many inputs')
end



figure('Color',[0.9 0.9 0.9],...
    'NumberTitle','Off',...
    'Name','DECRA');
ax1=zeros(1,decradata.ncomp);
ax2=zeros(1,decradata.ncomp);
for k=1:decradata.ncomp
    ax1(k)=subplot(decradata.ncomp,6,[(k-1)*6+1 (k-1)*6+4]);

    h=plot(decradata.Ppmscale,decradata.COMPONENTS(k,:),'Parent',ax1(k),'LineWidth',1);

     if isreal(decradata.COMPONENTS(k,:))==0        
        text(0.9*max(decradata.Ppmscale),0.5*(max(real(decradata.COMPONENTS(k,:)))...
            + min(real(decradata.COMPONENTS(k,:)))),...
            {'Warning! spectrum is complex' 'only real part plotted'},'Color','Red')
     end
    
    set(gca,'Xdir','reverse');
    axis('tight')    
    ylim('auto');
    yax=ylim();
    yax(1)=yax(1)-yax(2)*0.1;
    yax(2)=yax(2)*1.1;
    ylim(yax);
    %ylim([min(min(decradata.COMPONENTS))-0.1 max(max(decradata.COMPONENTS))+0.1])
    set(h,'LineWidth',1)
    set(gca,'LineWidth',1)
    
         
    if k==1
        title('\fontname{ariel} \bf DECRA components')
    end
    if k==decradata.ncomp
        xlabel('\fontname{ariel} \bf Chemical shift /ppm');
    end

    ax2(k)=subplot(decradata.ncomp,6,[(k-1)*6+5 (k-1)*6+6]);
    plot(decradata.Gzlvl.^2,decradata.DECAYS(:,k)/max(decradata.DECAYS(:,k)),'LineWidth',1,'Parent',ax2(k))
    axis('tight')
    ylim([-0.1   1.1]);
    set(h,'LineWidth',1);
    set(gca,'LineWidth',1);
    str=['\fontname{ariel} \bf D : ' num2str((decradata.Dval(k)*1e10),3)];
    text(0.4*max(decradata.Gzlvl.^2),0.95,str);
    str=['\fontname{ariel} \bf % : ' num2str(100*(decradata.relp(k)/sum(decradata.relp)),3)];
    text(0.4*max(decradata.Gzlvl.^2),0.80,str)
   
    if k==decradata.ncomp
        xlabel('\fontname{ariel} \bf Gradient amplitude squared (T m^{-1})^2');
    end
end
set(ax1,'FontName','Arial','FontWeight','bold','LineWidth',2);
set(ax2,'FontName','Arial','FontWeight','bold','LineWidth',2);
linkaxes(ax1,'x');
linkaxes(ax2,'x');

%-------------------------------END of decraplot----------------------------

