
function mcrplot(mcrdata)


%   function mcrplot(mcrdata)
%   mcrplot.m: plots mcr data as obtained from mcr_mn.m
%
%   --------------------------------INPUT------------------------------------
%   mcrdata  =  The data structure from mcr_mn
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
    disp(' MCRPLOT')
    disp('At least one input is needed')
    disp(' ')
    disp(' Type <<help mcrplot>> for more info')
    disp('  ')
    return
elseif nargin >2
    error(' Too many inputs')
end

%normalise the components
for k=1:mcrdata.ncomp
    mcrdata.COMPONENTS(k,:)=mcrdata.COMPONENTS(k,:)/norm(mcrdata.COMPONENTS(k,:));
end



figure('Color',[0.9 0.9 0.9],...
    'NumberTitle','Off',...
    'Name','MCR');
ax1=zeros(1,mcrdata.ncomp);
ax2=zeros(1,mcrdata.ncomp);
for k=1:mcrdata.ncomp
    ax1(k)=subplot(mcrdata.ncomp,6,[(k-1)*6+1 (k-1)*6+4]);

    h=plot(mcrdata.Ppmscale,mcrdata.COMPONENTS(k,:),'Parent',ax1(k),'LineWidth',1);

    set(gca,'Xdir','reverse');
    axis('tight')
    ylim([(min(min(mcrdata.COMPONENTS))-0.1*max(max(mcrdata.COMPONENTS))) max(max(mcrdata.COMPONENTS))*1.1])
    set(h,'LineWidth',1)
    set(gca,'LineWidth',1)
    if k==1
        title('\fontname{ariel} \bf MCR components')
    end
    if k==mcrdata.ncomp
        xlabel('\fontname{ariel} \bf Chemical shift /ppm');
    end

    ax2(k)=subplot(mcrdata.ncomp,6,[(k-1)*6+5 (k-1)*6+6]);
    plot(mcrdata.Gzlvl.^2,mcrdata.DECAYS(:,k)/abs(max(mcrdata.DECAYS(:,k))),'LineWidth',2,'Parent',ax2(k))
    %plot(mcrdata.Gzlvl.^2,mcrdata.DECAYS(:,k),'LineWidth',2,'Parent',ax2(k))
    axis('tight')
     %ylim([0 1])
    ylim('auto');
   
    set(h,'LineWidth',1);
    set(gca,'LineWidth',1);
    if isnumeric(mcrdata.Dval)
        str=['\fontname{ariel} \bf D : ' num2str((mcrdata.Dval(k)),3)];
        text(0.4*max(mcrdata.Gzlvl.^2),0.9,str);
    else
        str=['\fontname{ariel} \bf D : Not estimated'];
        text(0.4*max(mcrdata.Gzlvl.^2),0.9,str);
    end
        
    if k==mcrdata.ncomp
        xlabel('\fontname{ariel} \bf Gradient amplitude squared (T m^{-1})^2');
    end
end
set(ax1,'FontName','Arial','FontWeight','bold','LineWidth',2);
set(ax2,'FontName','Arial','FontWeight','bold','LineWidth',2);
linkaxes(ax1,'x');
linkaxes(ax2,'xy');

% for k=1:mcrdata.ncomp
%     figure
%     plot(mcrdata.Gzlvl.^2,mcrdata.DECAYS(:,k)/max(mcrdata.DECAYS(:,k)),'LineWidth',2);
% end
% % for k=1:mcrdata.ncomp
% %     figure
% %     plot(mcrdata.Gzlvl.^2,mcrdata.DECAYS(:,k)/norm(mcrdata.DECAYS(:,k)),'LineWidth',2);
% % end
% for k=1:mcrdata.ncomp
%     figure
%     plot(mcrdata.Gzlvl.^2,mcrdata.DECAYS(:,k),'LineWidth',2);
% end


end

%-------------------------------END of decraplot----------------------------

