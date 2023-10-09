function scoreplot(scoredata)
% function scoreplot(scoredata)
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
elseif nargin >3
    error(' Too many inputs')
end

% normalise the components
% for k=1:scoredata.ncomp+scoredata.nfix
%     scoredata.COMPONENTS(k,:)=scoredata.COMPONENTS(k,:)/norm(scoredata.COMPONENTS(k,:));
% end

% scoredata.COMPONENTS=scoredata.COMPONENTS./max(max(scoredata.COMPONENTS));

scoredata.Dval=[scoredata.Dval scoredata.Dfix];
scoredata.YScaling=1;

if scoredata.useXtalkGUI==1 % Open the Cross-talk minimisation GUI
    %% ------------------------SCORE GUI figure----------------------
    hSCOREfigure=figure(...
        'Color',[0.9 0.9 0.9],...
        'NumberTitle','Off',...
        'Name','SCORE',...
        'units','normalized',...
        'position',[0.05 0.05 0.9 0.8]);
    %% ------------------------Plots Panel---------------------------
    hPlotsPanel=uipanel(...
        'Parent',hSCOREfigure,...
        'Units','Normalized',...
        'Position',[-0.14,0.21,1.25,0.79]);
    
    % plot the components.
    ax1=zeros(1,(scoredata.ncomp+scoredata.nfix));
    ax2=zeros(1,(scoredata.ncomp+scoredata.nfix));
    for k=1:scoredata.ncomp+scoredata.nfix
        ax1(k)=subplot(scoredata.ncomp+scoredata.nfix,6,[(k-1)*6+1 (k-1)*6+5],'Parent',hPlotsPanel);
        
        h=plot(scoredata.Ppmscale,scoredata.COMPONENTS(k,:),'Parent',ax1(k),'LineWidth',1);
        
        set(gca,'tag',num2str(k))
        set(gca,'Xdir','reverse');
        axis('tight')
        ylim([(min(min(scoredata.COMPONENTS))-0.1*max(max(scoredata.COMPONENTS))) max(max(scoredata.COMPONENTS))*1.1])
        set(h,'LineWidth',1)
        set(gca,'LineWidth',1)
        set(h,'HitTest','off')
        
        if k==1
            title('\fontname{ariel} \bf SCORE components')
        end
        if k==scoredata.ncomp
            xlabel('\fontname{ariel} \bf Chemical shift /ppm');
        end
        
        ax2(k)=subplot(scoredata.ncomp+scoredata.nfix,6,((k-1)*6+6),'Parent',hPlotsPanel);
        
        plot(scoredata.Gzlvl.^2,scoredata.DECAYS(:,k)/max(scoredata.DECAYS(:,k)),'LineWidth',1,'Parent',ax2(k));
        xlim([-0.1 1])
        axis('tight')
        ylim('auto');
        set(h,'LineWidth',1);
        set(gca,'LineWidth',1);
        str=['\fontname{ariel} \bf D : ' num2str((scoredata.Dval(k)),3)];
        text(0.4*max(scoredata.Gzlvl.^2),0.9,str);
        str=['\fontname{ariel} \bf % : ' num2str(100*(scoredata.relp(k)/sum(scoredata.relp)),3)];
        text(0.4*max(scoredata.Gzlvl.^2),0.80,str)
        if k==scoredata.ncomp + scoredata.nfix
            xlabel('\fontname{ariel} \bf Gradient amplitude squared (T m^{-1})^2');
        end
    end
    set(ax1,'FontName','Arial','FontWeight','bold','LineWidth',2);
    set(ax2,'FontName','Arial','FontWeight','bold','LineWidth',2);
    linkaxes(ax1,'x');
    linkaxes(ax2,'x');
    %% ------------------------Controls Panel------------------------
    hControlPanel=uipanel(...
        'Parent',hSCOREfigure,...
        'Units','Normalized',...
        'Position',[0,0,1,0.21]);
    
    hTitlePeakSelect=uicontrol(...
        'Parent',hControlPanel,...
        'Style','text',...
        'String','Peak Picking',...
        'FontWeight','bold',...
        'Units','Normalized',...
        'Position',[0.11 0.8 0.1 0.1]);    %#ok
    hTitleMinimisation=uicontrol(...
        'Parent',hControlPanel,...
        'Style','text',...
        'String','Minimisation',...
        'FontWeight','bold',...
        'Units','Normalized',...
        'Position',[0.42 0.8 0.1 0.1]);    %#ok
    hTitleManualD=uicontrol(...
        'Parent',hControlPanel,...
        'Style','text',...
        'String','Manual D. Editing',...
        'FontWeight','bold',...
        'Units','Normalized',...
        'Position',[0.75 0.8 0.1 0.1]);    %#ok
    hTitleScaling=uicontrol(...
        'Parent',hControlPanel,...
        'Style','text',...
        'String','Vertical Scale',...
        'FontWeight','bold',...
        'Units','Normalized',...
        'Position',[0.9 0.8 0.05 0.1]);    %#ok
    
    % Vertical Scale Controls
    hButtonZoomInY=uicontrol(...
        'parent',hControlPanel,...
        'style','pushbutton',...
        'string',[char(hex2dec('D7')) ' 2'],...
        'Visible','On',...
        'units','normalized',...
        'position',[0.9 0.45 0.05,0.2],...
        'callback',@ZoomInY_Callback);      %#ok
    hButtonZoomOutY=uicontrol(...
        'parent',hControlPanel,...
        'style','pushbutton',...
        'string',[char(hex2dec('F7')) ' 2'],...
        'Visible','On',...
        'units','normalized',...
        'position',[0.9 0.25 0.05,0.2],...
        'callback',@ZoomOutY_Callback);      %#ok
    
    % Manual Diffusion Coefficient Editing
    MenuCell=cell((scoredata.ncomp+scoredata.nfix),1);
    for k=1:(scoredata.ncomp+scoredata.nfix)
        MenuCell{k}=num2str(k);
    end
    hMenuCompNum=uicontrol(...
        'parent',hControlPanel,...
        'style','popupmenu',...
        'string',MenuCell,...
        'Visible','On',...
        'units','normalized',...
        'position',[0.75 0.7 0.03,0.07],...
        'callback',@CompListSelect_Callback);
    hTextCompNum=uicontrol(...
        'Parent',hControlPanel,...
        'Style','text',...
        'Visible','On',...
        'String','Component Number',...
        'Units','Normalized',...
        'Position',[0.65 0.7 0.1 0.07]);    %#ok
    hEditDval=uicontrol(...
        'Parent',hControlPanel,...
        'Style','edit',...
        'Visible','On',...
        'Units','Normalized',...
        'Position',[0.75 0.55 0.05 0.1],...
        'horizontalalignment','l',...
        'Callback',@EditDval_Callback);
    hTextDval=uicontrol(...
        'Parent',hControlPanel,...
        'Style','text',...
        'Visible','On',...
        'String','Diffusion Coeff.',...
        'Units','Normalized',...
        'Position',[0.65 0.55 0.1 0.07],...
        'horizontalalignment','c');         %#ok
    hButtonInc=uicontrol(...
        'parent',hControlPanel,...
        'style','pushbutton',...
        'string','+',...
        'Visible','On',...
        'units','normalized',...
        'position',[0.75 0.35 0.05,0.2],...
        'callback',@IncDval_Callback);      %#ok
    hButtonDec=uicontrol(...
        'parent',hControlPanel,...
        'style','pushbutton',...
        'string','-',...
        'Visible','On',...
        'units','normalized',...
        'position',[0.75 0.15 0.05,0.2],...
        'callback',@DecDval_Callback);      %#ok
    hBGroupIncVal=uibuttongroup(...
        'Parent',hControlPanel,...
        'Visible','On',...
        'Title','Inc. Size',...
        'TitlePosition','centertop',...
        'Units','Normalized',...
        'Position',[0.81 0.175 0.05 0.5 ]);
    hRadio1 = uicontrol(...
        'Parent',hBGroupIncVal,...
        'Style','RadioButton',...
        'String','1',...
        'Units','normalized',...
        'Position',[0.05 0.7 0.9 0.3]);
    hRadio01 = uicontrol(...
        'Parent',hBGroupIncVal,...
        'Style','RadioButton',...
        'String','0.1',...
        'Units','normalized',...
        'Position',[0.05 0.4 0.9 0.3]);
    hRadio001 = uicontrol(...
        'Parent',hBGroupIncVal,...
        'Style','RadioButton',...
        'String','0.01',...
        'Units','normalized',...
        'Position',[0.05 0.1 0.9 0.3]);
    
    % Minimise
    hButtonMinimise=uicontrol(...
        'parent',hControlPanel,...
        'style','pushbutton',...
        'string','MINIMISE!',...
        'Visible','On',...
        'units','normalized',...
        'position',[0.5 0.15 0.1,0.6],...
        'callback',@Minimise_Callback);     %#ok
    hButtonCalcSurface=uicontrol(...
        'parent',hControlPanel,...
        'style','pushbutton',...
        'string','Calc. Surface',...
        'Visible','On',...
        'units','normalized',...
        'position',[0.6 0.15 0.07,0.3],...
        'callback',@CalcSurface_Callback);     %#ok
    hEditDmax=uicontrol(...
        'Parent',hControlPanel,...
        'Style','edit',...
        'Visible','On',...
        'Units','Normalized',...
        'Position',[0.35 0.55 0.1 0.1],...
        'horizontalalignment','c',...
        'Tooltip','The maximum diffusion coefficient allowed',...
        'tag','Dmax',...
        'string',num2str(20));     %#ok
    hTextDmax=uicontrol(...
        'Parent',hControlPanel,...
        'Style','text',...
        'Visible','On',...
        'String','Max D. Coeff.',...
        'Units','Normalized',...
        'Position',[0.35 0.65 0.1 0.1]);    %#ok
    hEditDmin=uicontrol(...
        'Parent',hControlPanel,...
        'Style','edit',...
        'Visible','On',...
        'Units','Normalized',...
        'Position',[0.35 0.25 0.1 0.1],...
        'horizontalalignment','c',...
        'Tooltip','The ',...
        'tag','Dmin',...
        'string',num2str(0));     %#ok
    hTextDmin=uicontrol(...
        'Parent',hControlPanel,...
        'Style','text',...
        'Visible','On',...
        'String','Min D. Coeff.',...
        'Units','Normalized',...
        'Position',[0.35 0.35 0.1 0.1]);    %#ok
    % Peak Picking
    hButtonPeakPick=uicontrol(...
        'parent',hControlPanel,...
        'style','pushbutton',...
        'string','Pick Peaks',...
        'Visible','On',...
        'units','normalized',...
        'Tooltip','Set the points to be minimised in the other spectra',...
        'position',[0.05 0.55 0.1,0.2],...
        'callback',@PeakPick_Callback);     %#ok
    hButtonClearPicks=uicontrol(...
        'parent',hControlPanel,...
        'style','pushbutton',...
        'string','Clear Peaks',...
        'Visible','On',...
        'units','normalized',...
        'position',[0.11 0.3 0.1,0.2],...
        'callback',@ClearPicks_Callback);   %#ok
    hEditWidth=uicontrol(...
        'Parent',hControlPanel,...
        'Style','edit',...
        'Visible','On',...
        'Units','Normalized',...
        'Position',[0.16 0.55 0.1 0.1],...
        'horizontalalignment','c',...
        'Tooltip','The points to be minimised in the other spectra',...
        'tag','width',...
        'string',num2str(scoredata.np/100));     %#ok
    hTextCompNum=uicontrol(...
        'Parent',hControlPanel,...
        'Style','text',...
        'Visible','On',...
        'String','Window width (points)',...
        'Units','Normalized',...
        'Position',[0.16 0.65 0.1 0.1]);    %#ok
    %% ------------------------Parameters and Defaults---------------
    scoredata.NewDval=scoredata.Dval;
    scoredata.SelectedCompNum=1;
    guidata(hSCOREfigure,scoredata)
    set(hEditDval,'string',num2str(scoredata.NewDval(1)))
else % Produce a normal SCORE plot
    %% ------------------------NORMAL SCORE plot---------------------
    figure('Color',[0.9 0.9 0.9],...
        'NumberTitle','Off',...
        'Name','SCORE');
    
    ax1=zeros(1,(scoredata.ncomp+scoredata.nfix));
    ax2=zeros(1,(scoredata.ncomp+scoredata.nfix));
    for k=1:scoredata.ncomp+scoredata.nfix
        ax1(k)=subplot(scoredata.ncomp+scoredata.nfix,6,[(k-1)*6+1 (k-1)*6+4]);
        
        h=plot(scoredata.Ppmscale,scoredata.COMPONENTS(k,:),'Parent',ax1(k),'LineWidth',1);
        
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
        plot(scoredata.Gzlvl.^2,scoredata.DECAYS(:,k)/max(scoredata.DECAYS(:,k)),'LineWidth',1,'Parent',ax2(k))
        xlim([-0.1 1])
        
        axis('tight')
        ylim('auto');
        set(h,'LineWidth',1);
        set(gca,'LineWidth',1);
        str=['\fontname{ariel} \bf D : ' num2str((scoredata.Dval(k)),3)];
        text(0.4*max(scoredata.Gzlvl.^2),0.9,str);
        str=['\fontname{ariel} \bf % : ' num2str(100*(scoredata.relp(k)/sum(scoredata.relp)),3)];
        text(0.4*max(scoredata.Gzlvl.^2),0.80,str);
        
        if k==scoredata.ncomp + scoredata.nfix
            xlabel('\fontname{ariel} \bf Gradient amplitude squared (T m^{-1})^2');
        end
    end
    set(ax1,'FontName','Arial','FontWeight','bold','LineWidth',2);
    set(ax2,'FontName','Arial','FontWeight','bold','LineWidth',2);
    linkaxes(ax1,'x');
    linkaxes(ax2,'x');
end
%% ------------------------GUI Callbacks-------------------------
    function CompListSelect_Callback(source, eventdata)%#ok
        scoredata=guidata(hSCOREfigure);
        scoredata.SelectedCompNum=get(hMenuCompNum,'Value');
        set(hEditDval,'string',num2str(scoredata.NewDval(scoredata.SelectedCompNum)));
        guidata(hSCOREfigure,scoredata);
    end
    function IncDval_Callback(source, eventdata)%#ok
        scoredata=guidata(hSCOREfigure);
        switch get(hBGroupIncVal,'SelectedObject');
            case hRadio1
                D_Change=1;
            case hRadio01
                D_Change=0.1;
            case hRadio001
                D_Change=0.01;
        end
        menuhandle=findobj(gcf,'style','popupmenu');
        CompNum=get(menuhandle,'Value');
        scoredata.NewDval(CompNum)=scoredata.NewDval(CompNum)+D_Change;
        guidata(hSCOREfigure,scoredata);
        IncOrDecD();
        set(hEditDval,'string',num2str(scoredata.NewDval(CompNum)));
    end
    function DecDval_Callback(source, eventdata)%#ok
        scoredata=guidata(hSCOREfigure);
        switch get(hBGroupIncVal,'SelectedObject');
            case hRadio1
                D_Change=-1;
            case hRadio01
                D_Change=-0.1;
            case hRadio001
                D_Change=-0.01;
        end
        menuhandle=findobj(gcf,'style','popupmenu');
        CompNum=get(menuhandle,'Value');
        scoredata.NewDval(CompNum)=scoredata.NewDval(CompNum)+D_Change;
        guidata(hSCOREfigure,scoredata)
        IncOrDecD();
        set(hEditDval,'string',num2str(scoredata.NewDval(CompNum)));
    end
    function EditDval_Callback(source, eventdata)%#ok
        scoredata=guidata(hSCOREfigure);
        EditedDval=str2num(get(hEditDval,'string')); %#ok
        menuhandle=findobj(gcf,'style','popupmenu');
        CompNum=get(menuhandle,'Value');
        scoredata.NewDval(CompNum)=EditedDval;
        guidata(hSCOREfigure,scoredata);
        IncOrDecD();
    end
    function Minimise_Callback(source, eventdata)%#ok
        scoredata=guidata(hSCOREfigure);
        Picks=flipud(findobj(gcf,'tag','rect'));
        
        Dmin=str2double(get(findobj(gcf,'tag','Dmin'),'string'));
        Dmax=str2double(get(findobj(gcf,'tag','Dmax'),'string'));
        
        CompNum=zeros(length(Picks),1);
        for m=1:length(Picks)
            CompNum(m)=str2double(get(get(Picks(m),'parent'),'tag'));
        end
        
        xdata=cell(length(Picks),1);
        ydata=cell(length(Picks),1);
        for n=1:length(Picks)
            xdata{n}=get(Picks(n),'Xdata');
            ydata{n}=get(Picks(n),'Ydata');
        end
        
        Options=optimset('fmincon');
        Options=optimset(Options,'Display','Iter');
        Options=optimset(Options,'algorithm','active-set');
        Options=optimset(Options,'TolX',1e-12);
        Options=optimset(Options,'TolFun',1e-12);
        Options=optimset(Options,'MaxFunEvals',1000);
        
        for p=1:length(Picks)
            Left=find(scoredata.Ppmscale>xdata{p}(1),1,'first');
            Right=find(scoredata.Ppmscale>xdata{p}(2),1,'first');

            % fminsearch
            %             scoredata.NewDval(CompNum(p))=fminsearch(@RemoveCrossTalk,...
            %                 scoredata.NewDval(CompNum(p)),Options,...
            %                 scoredata,CompNum(p),Left,Right);
            
            % fmincon
            scoredata.NewDval(CompNum(p))=fmincon(@RemoveCrossTalk,...
                scoredata.NewDval(CompNum(p)),[],[],[],[],...
                Dmin,Dmax,[],Options,...
                scoredata,CompNum(p),Left,Right);
            
            guidata(hSCOREfigure,scoredata)
            IncOrDecD();
        end
        
        for q=1:length(CompNum)
            set(gcf,'CurrentAxes',findobj(gcf,'tag',num2str(CompNum(q))))
            patch(xdata{q},ydata{q},...
                'green','FaceAlpha',0.25,'tag','rect');
        end
        
    end
    function PeakPick_Callback(source, eventdata)%#ok
        scoredata=guidata(hSCOREfigure);
        axeshandles=flipud(findobj(gcf,'type','axes'));
        set(axeshandles(1:2:length(axeshandles)),'ButtonDownFcn',{@PeakPickPlot})
    end
    function ClearPicks_Callback(source, eventdata)%#ok
        scoredata=guidata(hSCOREfigure);
        regions=findobj(gcf,'tag','rect');
        delete(regions);
        guidata(hSCOREfigure,scoredata);
    end
    function CalcSurface_Callback(source, eventdata)%#ok
        scoredata=guidata(hSCOREfigure);
        
%         size(scoredata.SPECTRA(:,1))
%         size(scoredata.COMPONENTS(1,:))
%         
%         CompSpect=scoredata.SPECTRA(:,1)-scoredata.COMPONENTS(1,:)';
%         
%         figure
%         plot(CompSpect)
%         
%         Comp4Subtraction=CompSpect*scoredata.DECAYS(1,:);
%         figure
%         mesh(Comp4Subtraction)
%         
%         OTHERSPECTRA=scoredata.SPECTRA-Comp4Subtraction;
%         figure
%         plot(OTHERSPECTRA(:,1))
        
        
%         maxima=max(scoredata.COMPONENTS')
%         a=1/calcRMSnoise(scoredata.SPECTRA,scoredata.Ppmscale)
%         for c=1:length(maxima)
%             noise(c)=calcRMSnoise(scoredata.COMPONENTS(c,:)',scoredata.Ppmscale);
%         end
%             noise
%             snr=max(scoredata.COMPONENTS')./noise
        
                % Component Subtraction
                menuhandle=findobj(gcf,'style','popupmenu');
                CompNum=get(menuhandle,'Value');
                SubtractComponent_AC(scoredata,CompNum);
        
%               % Calculate 1D surface
%                 Picks=flipud(findobj(gcf,'tag','rect'));
%         
%                 Dmin=str2double(get(findobj(gcf,'tag','Dmin'),'string'));
%                 Dmax=str2double(get(findobj(gcf,'tag','Dmax'),'string'));
%         
%                 CompNum=zeros(length(Picks),1);
%                 for m=1:length(Picks)
%                     CompNum(m)=str2double(get(get(Picks(m),'parent'),'tag'));
%                 end
%         
%                 xdata=cell(length(Picks),1);
%                 for n=1:length(Picks)
%                     xdata{n}=get(Picks(n),'Xdata');
%                     ydata{n}=get(Picks(n),'Ydata');
%                 end
%         
%                 for p=1:length(Picks)
%         
%                     minimum=map_1Comp_surface(scoredata,CompNum(p));
%         
%                     scoredata.NewDval(CompNum(p))=minimum;
%         
%                 end
%         
%                 IncOrDecD(scoredata);
%         
%                 for q=1:length(CompNum)
%                     set(gcf,'CurrentAxes',findobj(gcf,'tag',num2str(CompNum(q))))
%                     patch(xdata{q},ydata{q},...
%                     'green','FaceAlpha',0.25,'tag','rect');
%                 end
    end
    function ZoomInY_Callback(source, eventdata)%#ok
        scoredata=guidata(hSCOREfigure);
        scoredata.YScaling=scoredata.YScaling/2;
        guidata(hSCOREfigure,scoredata);
        Replot()
    end
    function ZoomOutY_Callback(source, eventdata)%#ok
        scoredata=guidata(hSCOREfigure);
        scoredata.YScaling=scoredata.YScaling*2;
        guidata(hSCOREfigure,scoredata);
        Replot()
    end
%% ------------------------Utility Functions---------------------
    function IncOrDecD(source, eventdata)%#ok
        scoredata=guidata(hSCOREfigure);
        [S,C]= FixedDecomp_AC(scoredata);
        
%         for p=1:scoredata.ncomp+scoredata.nfix
%             scoredata.COMPONENTS(p,:)=S(p,:)/norm(S(p,:));
%         end
        
        scoredata.COMPONENTS=S;
        scoredata.DECAYS=C;
        scoredata.relp=sum(abs(scoredata.COMPONENTS),2);
        
        guidata(hSCOREfigure,scoredata);
        Replot()
        
    end
    function PeakPickPlot(source, eventdata)%#ok
        scoredata=guidata(hSCOREfigure);
        PreviousRect=findobj(gca,'tag','rect');
        delete(PreviousRect);
        
        cp=get(gco,'currentpoint');
        
        hWidthEditBox=findobj(gcf,'tag','width');
        Width_Points=str2double(get(hWidthEditBox,'string'));
        
        xlims=get(gca,'xlim');
        FractionOfScale=Width_Points/scoredata.np;
        Width=(xlims(2)-xlims(1))*FractionOfScale;
        
        Xleft=cp(1,1)-Width/2;
        Xright=cp(1,1)+Width/2;
        ylim=get(gca,'ylim');
        Ytop=ylim(2);
        Ybot=ylim(1);
        
        patch([Xleft Xright Xright Xleft],[Ytop,Ytop,Ybot,Ybot],...
            'cyan','FaceAlpha',0.25,'tag','rect');
    end
    function SSR=RemoveCrossTalk(Dval,scoredata,CompNum,lb,rb)
        scoredata.NewDval(CompNum)=Dval;
        [S C]=FixedDecomp_AC(scoredata);
        
        SSR=0;
        for n=1:(scoredata.ncomp+scoredata.nfix)
            if n~=CompNum
                SSR=SSR+sum(abs(S(n,lb:rb)));
            end
        end
        
    end
    function Replot(source, eventdata)%#ok
        scoredata=guidata(hSCOREfigure);
        axeshandles=flipud(findobj(gcf,'type','axes'));
        
        for m=1:scoredata.ncomp+scoredata.nfix
            
            set(gcf,'CurrentAxes',axeshandles(2*m-1))
            i=plot(scoredata.Ppmscale,scoredata.COMPONENTS(m,:),'Parent',gca,'LineWidth',1);
            set(gca,'tag',num2str(m))
            set(gca,'Xdir','reverse');
            axis('tight');
            ylim([(min(min(scoredata.COMPONENTS))-0.1*max(max(scoredata.COMPONENTS))) max(max(scoredata.COMPONENTS))*1.1])
            ylim(ylim()*scoredata.YScaling)
            set(i,'LineWidth',1)
            set(gca,'LineWidth',2)
            if m==1
                title('\fontname{ariel} \bf SCORE components')
            end
            if m==scoredata.ncomp
                xlabel('\fontname{ariel} \bf Chemical shift /ppm');
            end
            
            set(gcf,'CurrentAxes',axeshandles(2*m))
            j=plot(scoredata.Gzlvl.^2,scoredata.DECAYS(:,m)/max(scoredata.DECAYS(:,m)),'Parent',gca,'LineWidth',1);
            set(gcf,'CurrentObject',j)
            xlim([-0.1 1])
            axis('tight')
            ylim('auto');
            set(j,'LineWidth',1);
            set(gca,'LineWidth',2);
            str=['\fontname{ariel} \bf D : ' num2str((scoredata.NewDval(m)),4)];
            text(0.4*max(scoredata.Gzlvl.^2),0.9,str);
            str=['\fontname{ariel} \bf % : ' num2str(100*(scoredata.relp(m)/sum(scoredata.relp)),3)];
            text(0.4*max(scoredata.Gzlvl.^2),0.80,str);
            
            if m==scoredata.ncomp + scoredata.nfix
                xlabel('\fontname{ariel} \bf Gradient amplitude squared (T m^{-1})^2');
            end
        end
    end
end

