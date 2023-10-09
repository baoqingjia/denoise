
function scoreplotpub(scoredata)


%   function scoreplot(scoredata)
%   scoreplot.m: plots score data as obtained from score_mn.m
%
%   --------------------------------INPUT------------------------------------
%   scoredata  =  The data structure from score_mn
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

if nargin==0
    disp(' ')
    disp(' ')
    disp(' SCOREPLOT')
    disp('At least one input is needed')
    disp(' ')
    disp(' Type <<help mcrplot>> for more info')
    disp('  ')
    return
elseif nargin >2
    error(' Too many inputs')
end


%normalise the components
for k=1:scoredata.ncomp+scoredata.nfix
    scoredata.COMPONENTS(k,:)=scoredata.COMPONENTS(k,:)/norm(scoredata.COMPONENTS(k,:));
end


%scoredata.ncomp=scoredata.ncomp+scoredata.nfix;
scoredata.Dval=[scoredata.Dval scoredata.Dfix];


% figure('Color',[1 1 1],...
%     'NumberTitle','Off',...
%     'Name','SCORE');

figure('Color',[0.9 0.9 0.9],...
    'NumberTitle','Off',...
    'Units','centimeters',...
    'Position',[0 0 29.7 21],...
    'Name','SCORE');


ax1=zeros(1,(scoredata.ncomp+scoredata.nfix));
ax2=zeros(1,(scoredata.ncomp+scoredata.nfix));
for k=1:scoredata.ncomp+scoredata.nfix
    ax1(k)=subplot(scoredata.ncomp+scoredata.nfix,6,[(k-1)*6+1 (k-1)*6+4]);

    h=plot(scoredata.Ppmscale,scoredata.COMPONENTS(k,:),'Parent',ax1(k),'LineWidth',2,'Color','black');

    set(gca,'Xdir','reverse');
    axis('tight')
    ylim([(min(min(scoredata.COMPONENTS))-0.1*max(max(scoredata.COMPONENTS))) max(max(scoredata.COMPONENTS))*1.1])
    set(h,'LineWidth',1)
    set(gca,'LineWidth',1)
    if k==1
        title('\fontname{ariel} \bf SCORE components')
    end
    if k==scoredata.ncomp
        xlabel('\fontname{ariel} \bf Chemical shift /ppm');
    end

    ax2(k)=subplot(scoredata.ncomp+scoredata.nfix,6,[(k-1)*6+5 (k-1)*6+6]);
    plot(scoredata.Gzlvl.^2,scoredata.DECAYS(:,k)/max(scoredata.DECAYS(:,k)),'Color','black','LineWidth',2,'Parent',ax2(k))
    xlim([-0.1 1])
   
    axis('tight')
    ylim('auto');
    set(h,'LineWidth',2);
    set(gca,'LineWidth',2);
     str=['\fontname{ariel} \bf D : ' num2str((scoredata.Dval(k)),3)];
     text(0.4*max(scoredata.Gzlvl.^2),0.9,str);
     str=['\fontname{ariel} \bf % : ' num2str(100*(scoredata.relp(k)/sum(scoredata.relp)),3)];
     text(0.4*max(scoredata.Gzlvl.^2),0.80,str)
    % axis off
%     if k>scoredata.ncomp
%         str='\fontname{ariel} \bf Fixed';
%         text(0.4*max(scoredata.Gzlvl.^2),0.7,str,'BackgroundColor','y');
%     end



    if k==scoredata.ncomp + scoredata.nfix
       xlabel('\fontname{ariel} \bf Gradient amplitude squared (T m^{-1})^2');
    end
end
set(ax1,'FontName','Arial','FontWeight','bold','LineWidth',2);
set(ax2,'FontName','Arial','FontWeight','bold','LineWidth',2);
linkaxes(ax1,'x');
linkaxes(ax2,'x');

%-------------------------------END ----------------------------

