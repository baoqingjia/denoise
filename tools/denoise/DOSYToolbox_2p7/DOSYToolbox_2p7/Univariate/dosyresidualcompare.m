function dosyresidualcompare(dosydata,dosyguidata)


%   dosyresidualcompare (dosydata, npeak);
%   dosyresidualcompare.m: compares the residual in dosy data as obtained from dosy_mn.m
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


hCompfig=figure('Color',[1 1 1],...
    'NumberTitle','Off',...
    'Name','Compare data');

hCompare=axes(...
    'FontName','Arial',...
    'Parent',hCompfig,...
    'FontWeight','bold',...
    'LineWidth',2);


colarray=['k' 'r' 'b' 'g' 'c'];
colarray2={'black', 'red' ,'blue' ,'green', 'cyan'};
leg_index=[0 0 0];

if strcmp(dosydata.type,'dosy')|| strcmp(dosydata.type,'ILT') || strcmp(dosydata.type,'locodosy')
    %DOSY type data
    xdata=dosydata.Gzlvl;
elseif strcmp(dosydata.type,'t1')
    %relaxation data
    
    xdata=dosydata.Tau;
else
    error('Unknown data type')
end


hold on
%axes(hCompare)
for k=1:length(dosyguidata.comparepeaks)    
    if (dosyguidata.comparetype(1)==1)
        if dosyguidata.compareuse(k)==1
            norm_max=max(dosydata.ORIGINAL(dosyguidata.comparepeaks(k),:))  ;
           % disp('one')
            plot(hCompare,xdata,...
                (dosydata.ORIGINAL(dosyguidata.comparepeaks(k),:)./norm_max),['.' colarray(k)],'LineWidth',2);
            leg_index(1)=1;
        end
    end
    
    if (dosyguidata.comparetype(2)==1)
        if dosyguidata.compareuse(k)==1
            norm_max=max(dosydata.ORIGINAL(dosyguidata.comparepeaks(k),:))  ;
            plot(xdata,...
                (dosydata.FITTED(dosyguidata.comparepeaks(k),:)./norm_max),['-' colarray(k)],'LineWidth',2);
            leg_index(2)=1;
        end
    end
    
    if (dosyguidata.comparetype(3)==1)
        if dosyguidata.compareuse(k)==1
            norm_max=max(dosydata.ORIGINAL(dosyguidata.comparepeaks(k),:))  ;
            plot(xdata,...
                (dosydata.RESIDUAL(dosyguidata.comparepeaks(k),:)./norm_max),['--' colarray(k)],'LineWidth',2) ;
            leg_index(3)=1;
        end
    end
end
axis('tight')
leg_pre={'Original' 'Fitted', 'Residual'};
n=1;
for k=1:length(leg_index)
    if leg_index(k)==1
        leg_str{n}=cell2mat(leg_pre(k)) ; %#ok<AGROW>
        n=n+1;
    end
end


hleg=legend(leg_str);
set(hleg,'Box','off')

hold off

n=2;
for k=1:length(dosyguidata.comparepeaks)
    if dosyguidata.compareuse(k)==1     
        textptx=xlim(hCompare);
        textpty=ylim(hCompare);
        str=['\color{' cell2mat(colarray2(k)) '} \bf  Peak:' num2str(dosyguidata.comparepeaks(k))];
        text(0.4*(textptx(2)-textptx(1)),textpty(2)-n*0.05*(textpty(2)-textpty(1)),str);
        n=n+1;
    end
end


set(gca,'LineWidth',2);

%ylim([1 -1])
ylabel('\fontname{ariel} \bf Amplitude')
if strcmp(dosydata.type,'dosy')|| strcmp(dosydata.type,'ILT') || strcmp(dosydata.type,'locodosy')
    %DOSY type data
    xlabel('\fontname{ariel} \bf Gradient amplitude (T m^{-1})')
elseif strcmp(dosydata.type,'t1')
    %relaxation data
    
    xlabel('\fontname{ariel} \bf Time (s)')
else
    error('Unknown data type')
end


%n


end



