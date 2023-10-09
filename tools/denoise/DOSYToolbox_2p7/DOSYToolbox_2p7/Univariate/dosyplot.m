function dosyplot(dosydata,clev,thresh)

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
            'Name','DOSY');
    end
else
    figure('Color',[1 1 1],...
        'NumberTitle','Off',...
        'Name','DOSY');
end

clvl=[clvl -clvl];

ax(1)=subplot('Position',[0.1 0.1 0.75 0.70]);


[xax,yax]=meshgrid(dosydata.Ppmscale,dosydata.Dscale);
[C,hCont]=contour(ax(1),xax,yax,(dosydata.DOSY.*(dosydata.DOSY>0))',clvl,'b','Parent',ax(1));
hold(ax(1),'on')
[C,hCont]=contour(ax(1),xax,yax,(dosydata.DOSY.*(dosydata.DOSY<0))',clvl,'color',[1 0.5 0],'Parent',ax(1));
hold(ax(1),'off')

%[C,hCont]=contour(xax,yax,dosydata.DOSY',clvl,'Parent',ax(1));




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
%ylabel('\bf Diffusion coefficient m^{2} s^{-1} \times 10^{-10}');
ylabel('\bf Diffusion coefficient / 10^{-10} m^{2} s^{-1} ');
set(ax(1),'Xdir','reverse');
xlabel('\bf Chemical shift /ppm');
%a=get(h,'LevelList')



ax(2)=subplot('Position',[0.1 0.82 0.75 0.15]);
h=plot( dosydata.Ppmscale, dosydata.Spectrum,'-b','Parent',ax(2) );


axis('tight')
axis('off')
set(h,'LineWidth',1)
set(h,'Color','blue')
if isfield(dosydata,'type')
    if strcmp(dosydata.type,'lrank')
        title('\bf 2D LRANK-DOSY')
    else
        title('\bf 2D DOSY')
    end
else
    title('\bf 2D DOSY')
end


set(gca,'Xdir','reverse');
set(ax,'FontName','Arial','FontWeight','bold','LineWidth',2);


linkaxes(ax,'x');

%---------------------END of dosyplot--------------------------------------



