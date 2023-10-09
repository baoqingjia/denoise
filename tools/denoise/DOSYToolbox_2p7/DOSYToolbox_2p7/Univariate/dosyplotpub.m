function dosyplotpub(dosydata,clev,thresh)

%   dosyplot(dosydata,clev,thresh);
%   dosyplot.m: plots dosy data as obtained from dosy_mn.m
%
%   --------------------------------INPUT------------------------------------
%   dosydata  =  The data structure from dosy_mn
%   clev      =   Number of contour levels
%   thresh    =   Threshold for contour levels as per cent of max peak height
%                 a negative value will set the default value (0.1 1% of
%                 max peak aplitude)
%
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
    disp(' DOSYPLOT')
    disp('At least one input is needed')
    disp(' ')
    disp(' Type <<help dosyplot>> for more info')
    disp('  ')
    return
end
if nargin >6
    error(' Too many inputs')
end


if nargin>1
    if length(clev)>1
        clvl=clev;
        %use inputted levels
    else
        if clev<=0
            clev=5;
        end
    end
else
    clev=5;
end

if nargin > 2
    if thresh<0
        thresh=0.1;
    end
else
    if isfield(dosydata,'threshold')
        thresh=dosydata.threshold;
    else
        thresh=0.1;
    end
end

%clev=3
if length(clev)==1
    clvl=2.^(0:clev);
    clvl=clvl(1:clev);
    clvl=1./clvl;
    maxc=max(max(dosydata.DOSY));
    clvl=clvl.*maxc.*(thresh/100);
end

disp('Plotting 2D-DOSY');
if isfield(dosydata,'type')
    if strcmp(dosydata.type,'lrank')
        figure('Color',[1 1 1],...
    'NumberTitle','Off',...
    'Name','LRANK-DOSY');
    else
        figure('Color',[1 1 1],...
    'NumberTitle','Off',...
    'Units','centimeters',...
    'Position',[0 0 29.7 21],...
    'Name','DOSY');
    end
else
hfig=figure('Color',[1 1 1],...
    'NumberTitle','Off',...
    ...'PaperOrientation','Landscape',...
    ...'PaperUnits','centimeters',...
    ...'PaperSize',[29.7 21],...
    'Units','centimeters',...
    'Position',[0 0 29.7 21],...
    'Name','DOSY');
end

ax(1)=subplot('Position',[0.1 0.1 0.75 0.70]);
clvl=[clvl -clvl];

[xax,yax]=meshgrid(dosydata.Ppmscale,dosydata.Dscale);
[C,hCont]=contour(ax(1),xax,yax,(dosydata.DOSY.*(dosydata.DOSY>0))',clvl,'k','Parent',ax(1));
hold(ax(1),'on')
[C,hCont]=contour(ax(1),xax,yax,(dosydata.DOSY.*(dosydata.DOSY<0))',clvl,'color',[0.75 0.75 0.75],'Parent',ax(1));
hold(ax(1),'off')

%if the data contains info on x and y limits - applky these.
if isfield(dosydata,'xlim')
    set(ax(1),'Xlim',dosydata.xlim);
end
if isfield(dosydata,'ylim')
    set(ax(1),'Ylim',dosydata.ylim);
end

set(ax(1),'LineWidth',1)
set(hCont,'LineWidth',1)
set(ax(1),'Ydir','reverse');



ylabel('{\bfDiffusion coefficient  /10^{-10}m^{2} s^{-1} }','FontSize',20);
%ylabel(hDOSY,'\bf Diffusion coefficient / 10^{-10} m^{2} s^{-1} ');
%ylabh = get(gca,'YLabel');
%set(ylabh,'Position',get(ylabh,'Position') + [5.2 0 0]) 


set(ax(1),'Xdir','reverse');
xlabel('{\bfChemical shift /ppm}','FontSize',20);
xlabh = get(gca,'XLabel');
set(xlabh,'Position',get(xlabh,'Position') + [0 .2 0]) 

%a=get(h,'LevelList')



ax(2)=subplot('Position',[0.1 0.82 0.75 0.15]);
h=plot( dosydata.Ppmscale, dosydata.Spectrum,'-k','Parent',ax(2) );


axis('tight')
axis('off')
set(h,'LineWidth',2)
set(h,'Color','black')
if isfield(dosydata,'type')
    if strcmp(dosydata.type,'lrank')
        title('\bf 2D LRANK-DOSY')
    else
        %title('\bf 2D DOSY')
    end
else
%title('\bf 2D DOSY')
end


set(gca,'Xdir','reverse');
set(ax,'FontName','Arial','FontWeight','bold','LineWidth',2);


linkaxes(ax,'x');

%---------------------END of dosyplot--------------------------------------



