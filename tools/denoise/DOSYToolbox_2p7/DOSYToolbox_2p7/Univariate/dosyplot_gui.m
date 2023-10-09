function dosyplot_gui(dosydata,clev,thresh)

%   dosyplot_gui(dosydata,clev,thresh);
%   dosyplot_gui.m: plots dosy data as obtained from dosy_mn.m, in an
%   interactive graphical user interface
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
    if clev<=0
        clev=7;
    end
else
    clev=7;
end
clvl=2.^(0:clev);
clvl=clvl(1:clev);
clvl=1./clvl;
clvl=[clvl -clvl];
if nargin > 2
    if thresh<0
        thresh=0.1;
    end
else
    if (dosydata.threshold)
        thresh=dosydata.threshold;
    else
        thresh=0.1;
    end
end



if strcmp(dosydata.type,'dosy')|| strcmp(dosydata.type,'ILT')...
        || strcmp(dosydata.type,'locodosy')|| strcmp(dosydata.type,'fdm/rrt')
    %DOSY type data
    dosy.org=dosydata.DOSY;
    
elseif strcmp(dosydata.type,'t1/t2')
    %relaxation data
    dosy.org=dosydata.T1;
else
    error('Unknown data type')
end





ppmscale.org=dosydata.Ppmscale;
spectrum.org=dosydata.Spectrum;
%dosy.org=dosydata.DOSY;
ScreenSize=get(0,'ScreenSize');
MaxDig=length(ppmscale.org);

%Auto set the digitisatio of the contour levels.
AutDigFac=round(MaxDig/(1.0*ScreenSize(3)));
if AutDigFac<1
    AutDigFac=1;
end
CurrDigFac=AutDigFac;
% AutDigFac=1
% CurrDigFac=1
% size(dosydata.DOSY)
% dosydata.DOSY=dosy.org(1:AutDigFac:end,:);
% size(dosydata.DOSY)

[dosydata.dosyrows,dosydata.dosycols]=size(dosy.org);

if strcmp(dosydata.type,'t1/t2')
    %relaxation data
    [dosydata.T1] = bilinearInterpolation(dosy.org, [round(dosydata.dosyrows/CurrDigFac) dosydata.dosycols]);
else
    [dosydata.DOSY] = bilinearInterpolation(dosy.org, [round(dosydata.dosyrows/CurrDigFac) dosydata.dosycols]);
end

dosydata.Spectrum=fft(ifft(spectrum.org),round(dosydata.dosyrows/CurrDigFac));
dosydata.Ppmscale=ppmscale.org(1:CurrDigFac:end);
dosydata.Ppmscale=dosydata.Ppmscale(1:round(dosydata.dosyrows/CurrDigFac));
CurrDig=length(dosydata.Ppmscale);


%-----GUI CONTROLS----------------------------------------------------------
%--------------------------------------------------------------------------


hMainFigure = figure(...
    'Units','pixels',...
    'MenuBar','figure',...
    'Name',[upper(dosydata.type) ' plotting'],...
    'NumberTitle','Off',...
    'Toolbar','Figure',...
    'OuterPosition',[0.0 0.0 1280 1024 ],...
    'Visible','off');



set(hMainFigure,'Units','Normalized');
set(hMainFigure, 'Position',[0.1 0.4 0.6 0.7]);
hDOSY = axes('Units','normalized',...
    'Position',[0.07 0.34 0.9 0.5]);
hSpec = axes('Units','normalized',...
    'Position',[0.07 0.85 0.9 0.1]);


%-----Panel for digitisation-----------------------------------------------
hDigPanel=uipanel(...
    'Parent',hMainFigure,...
    'Title','Spectrum digitisation',...
    'FontWeight','bold',...
    'ForegroundColor','Blue',...
    'TitlePosition','centertop',...
    'Visible','On',...
    'Units','Normalized',...
    'Position',[0.42,0.01,0.16,0.25]);
hButtonDigAuto = uicontrol(...
    'Parent',hDigPanel,...
    'Style','PushButton',...
    'String','Auto',...
    'Units','normalized',...
    'Position',[0.1 0.75 0.38 0.15],...
    'Callback',{@ButtonDigAuto_Callback});%#ok
hButtonDigMax = uicontrol(...
    'Parent',hDigPanel,...
    'Style','PushButton',...
    'String','Max',...
    'Units','normalized',...
    'Position',[0.5 0.75 0.38 0.15],...
    'Callback',{@ButtonDigMax_Callback});%#ok
hButtonDigMinus = uicontrol(...
    'Parent',hDigPanel,...
    'Style','PushButton',...
    'String',[char(hex2dec('F7')) ' 2'],...
    'Units','normalized',...
    'Position',[0.1 0.57 0.38 0.15],...
    'Callback',{@ButtonDigMinus_Callback});%#ok
hButtonDigPlus = uicontrol(...
    'Parent',hDigPanel,...
    'Style','PushButton',...
    'String',[char(hex2dec('D7')) ' 2'],...
    'Units','normalized',...
    'Position',[0.5 0.57 0.38 0.15],...
    'Callback',{@ButtonDigPlus_Callback});%#ok
hEditDig1=uicontrol(...
    'Parent',hDigPanel,...
    'Style','edit',...
    'Units','Normalized',...
    'BackgroundColor','w',...
    'Enable','Off',...
    'String',MaxDig,...
    'Position',[0.1 0.28 0.8 0.15 ],...
    'CallBack', {@EditDig1_Callback}); %#ok<NASGU>
hTextDig1=uicontrol(...
    'Parent',hDigPanel,...
    'Style','text',...
    'Units','Normalized',...
    'String','Max',...
    'Position',[0.1 0.42 0.8 0.1 ],...
    'horizontalalignment','Center');%#ok
hTextDig2=uicontrol(...
    'Parent',hDigPanel,...
    'Style','text',...
    'Units','Normalized',...
    'String','Current',...
    'Position',[0.1 0.18 0.8 0.1 ],...
    'horizontalalignment','Center');%#ok
hEditDig2=uicontrol(...
    'Parent',hDigPanel,...
    'Style','edit',...
    'Units','Normalized',...
    'BackgroundColor','w',...
    'Enable','Off',...
    'String',CurrDig,...
    'Position',[0.1 0.01 0.8 0.15 ],...
    'horizontalalignment','Center');

%-----Panel for Plot Control-----------------------------------------------
hPlotPanel=uipanel(...
    'Parent',hMainFigure,...
    'Title','Plot Control',...
    'FontWeight','bold',...
    'ForegroundColor','Blue',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.01,0.01,0.4,0.25]);
hTextZoom=uicontrol(...
    'Parent',hPlotPanel,...
    'Style','text',...
    'Units','Normalized',...
    'String','Zoom',...
    'Position',[0.15 0.9 0.2 0.1 ],...
    'horizontalalignment','c');%#ok
hZoomXYButton = uicontrol(...
    'Parent',hPlotPanel,...
    'Style','PushButton',...
    'String','XY',...
    'Units','normalized',...
    'Position',[0.05 0.8 0.1 0.1],...
    'Callback',@ZoomXYButton_Callback);%#ok
hZoomXButton = uicontrol(...
    'Parent',hPlotPanel,...
    'Style','PushButton',...
    'String','X',...
    'Units','normalized',...
    'Position',[0.15 0.8 0.1 0.1],...
    'Callback',@ZoomXButton_Callback);%#ok
hZoomYButton = uicontrol(...
    'Parent',hPlotPanel,...
    'Style','PushButton',...
    'String','Y',...
    'Units','normalized',...
    'Position',[0.25 0.8 0.1 0.1],...
    'Callback',@ZoomYButton_Callback);%#ok
hZoomOffButton = uicontrol(...
    'Parent',hPlotPanel,...
    'Style','PushButton',...
    'String','off',...
    'Units','normalized',...
    'Position',[0.35 0.8 0.1 0.1],...
    'Callback',@ZoomOffButton_Callback);%#ok
hTextpan=uicontrol(...
    'Parent',hPlotPanel,...
    'Style','text',...
    'Units','Normalized',...
    'String','Pan',...
    'Position',[0.65 0.9 0.2 0.1 ],...
    'horizontalalignment','c');%#ok
hpanXYButton = uicontrol(...
    'Parent',hPlotPanel,...
    'Style','PushButton',...
    'String','XY',...
    'Units','normalized',...
    'Position',[0.55 0.8 0.1 0.1],...
    'Callback',@panXYButton_Callback);%#ok
hpanXButton = uicontrol(...
    'Parent',hPlotPanel,...
    'Style','PushButton',...
    'String','X',...
    'Units','normalized',...
    'Position',[0.65 0.8 0.1 0.1],...
    'Callback',@panXButton_Callback);%#ok
hpanYButton = uicontrol(...
    'Parent',hPlotPanel,...
    'Style','PushButton',...
    'String','Y',...
    'Units','normalized',...
    'Position',[0.75 0.8 0.1 0.1],...
    'Callback',@panYButton_Callback);%#ok
hpanOffButton = uicontrol(...
    'Parent',hPlotPanel,...
    'Style','PushButton',...
    'String','off',...
    'Units','normalized',...
    'Position',[0.85 0.8 0.1 0.1],...
    'Callback',@panOffButton_Callback);%#ok

hTextScale=uicontrol(...
    'Parent',hPlotPanel,...
    'Style','text',...
    'Units','Normalized',...
    'String','Scale',...
    'Position',[0.2 0.65 0.2 0.1 ],...
    'horizontalalignment','l');%#ok
hButtonMult2 = uicontrol(...
    'Parent',hPlotPanel,...
    'Style','PushButton',...
    'String',[char(hex2dec('D7')) ' 2'],...
    'Units','Normalized',...
    'Position',[0.05 0.5 0.1 0.15],...
    'Callback',{@ButtonMult2_Callback});%#ok
hButtonDiv2 = uicontrol(...
    'Parent',hPlotPanel,...
    'Style','PushButton',...
    'String',[char(hex2dec('F7')) ' 2'],...
    'Units','Normalized',...
    'Position',[0.05 0.35 0.1 0.15],...
    'Callback',{@ButtonDiv2_Callback});%#ok
hButtonMult11 = uicontrol(...
    'Parent',hPlotPanel,...
    'Style','PushButton',...
    'String',[char(hex2dec('D7')) ' 1.1'],...
    'Units','Normalized',...
    'Position',[0.15 0.5 0.1 0.15],...
    'Callback',{@ButtonMult11_Callback});%#ok
hButtonDiv11 = uicontrol(...
    'Parent',hPlotPanel,...
    'Style','PushButton',...
    'String',[char(hex2dec('F7')) ' 1.1'],...
    'Units','Normalized',...
    'Position',[0.15 0.35 0.1 0.15],...
    'Callback',{@ButtonDiv11_Callback});%#ok
hButtonOrgscale = uicontrol(...
    'Parent',hPlotPanel,...
    'Style','Pushbutton',...
    'String','Original',...
    'Units','Normalized',...
    'Position',[0.05 0.19 0.2 0.15],...
    'Callback',{@ButtonOrgscale_Callback});%#ok
hButtonReplot = uicontrol(...
    'Parent',hPlotPanel,...
    'Style','Pushbutton',...
    'String','Replot',...
    'Units','Normalized',...
    'Position',[0.25 0.19 0.2 0.15],...
    'Callback',{@ButtonReplot_Callback});%#ok
hButtonPlotSep = uicontrol(...
    'Parent',hPlotPanel,...
    'Style','Pushbutton',...
    'String','Separate Plot',...
    'Units','Normalized',...
    'Position',[0.5 0.5 0.25 0.15],...
    'Callback',{@ButtonPlotSep_Callback});%#ok
hButtonPlotPub = uicontrol(...
    'Parent',hPlotPanel,...
    'Style','Pushbutton',...
    'String','Publication Plot',...
    'Units','Normalized',...
    'Position',[0.75 0.5 0.25 0.15],...
    'Callback',{@ButtonPlotPub_Callback});%#ok
hButtonStats = uicontrol(...
    'Parent',hPlotPanel,...
    'Style','Pushbutton',...
    'String','Stats',...
    'Units','Normalized',...
    'Position',[0.1 0.02 0.25 0.15],...
    'Callback',{@ButtonStats_Callback});%#ok
hlogscaleGroup=uibuttongroup(...
    'Visible','On',...
    'Parent',hPlotPanel,...
    'Title','',...
    'SelectionChangeFcn', {@Scale_Callback},...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.27 0.35 0.16 0.3]);
hRadioLog = uicontrol(...
    'Parent',hlogscaleGroup,...
    'Style','RadioButton',...
    'String','log',...
    'Units','normalized',...
    'Position',[0.05 0.65 0.9 0.3]);
hRadioLin = uicontrol(...
    'Parent',hlogscaleGroup,...
    'Style','RadioButton',...
    'String','lin',...
    'Value',1,...
    'Units','normalized',...
    'Position',[0.05 0.15 0.9 0.3]);
uicontrol(...
    'Parent',hPlotPanel,...
    'Style','text',...
    'Units','Normalized',...
    'String','Projections',...
    'FontWeight','bold',...
    'Position',[0.65 0.37 0.2 0.1 ],...
    'horizontalalignment','c');
hProjGroup=uibuttongroup(...
    'Visible','On',...
    'Parent',hPlotPanel,...
    'Title','',...
    'TitlePosition','centertop',...
    'BorderType','None',...
    'Units','Normalized',...
    'Position',[0.6 0.2 0.325 0.15]);
hRadioSum = uicontrol(...
    'Parent',hProjGroup,...
    'Style','RadioButton',...
    'String','Sum',...
    'Value',1,...
    'Units','normalized',...
    'Position',[0.55 0.2 0.4 0.9]);
hRadioSky = uicontrol(...
    'Parent',hProjGroup,...
    'Style','RadioButton',...
    'String','Sky',...
    'Units','normalized',...
    'Position',[0.05 0.2 0.4 0.9]);
hButtonPlotDproj = uicontrol(...
    'Parent',hPlotPanel,...
    'Style','Pushbutton',...
    'String','Diff',...
    'Units','Normalized',...
    'Position',[0.5 0.03 0.25 0.15],...
    'Callback',{@ButtonPlotDproj_Callback});%#ok
hButtonPlotDSpecproj = uicontrol(...
    'Parent',hPlotPanel,...
    'Style','Pushbutton',...
    'String','Spec',...
    'Units','Normalized',...
    'Position',[0.75 0.03 0.25 0.15],...
    'Callback',{@ButtonPlotSpecproj_Callback});%#ok

%-----Panel for DOSY residuals-----------------------------------------------
hResidPanel=uipanel(...
    'Parent',hMainFigure,...
    'Title','Residuals',...
    'FontWeight','bold',...
    'ForegroundColor','Blue',...
    'TitlePosition','centertop',...
    'Visible','Off',...
    'Units','Normalized',...
    'Position',[0.59,0.01,0.4,0.25]);
hButtonPlotResid = uicontrol(...
    'Parent',hResidPanel,...
    'Style','PushButton',...
    'String','Plot Residual',...
    'Units','normalized',...
    'Position',[0.1 0.8 0.28 0.15],...
    'Callback',{@ButtonPlotResid_Callback});%#ok
hButtonPlotResidSep = uicontrol(...
    'Parent',hResidPanel,...
    'Style','PushButton',...
    'String','Separate Plot',...
    'Units','normalized',...
    'Position',[0.1 0.5 0.28 0.15],...
    'Callback',{@ButtonPlotResidSep_Callback});%#ok
hEditFlip=uicontrol(...
    'Parent',hResidPanel,...
    'Style','edit',...
    'Units','Normalized',...
    'BackgroundColor','w',...
    'String',1,...
    'Position',[0.18 0.1 0.1 0.1 ],...
    'CallBack', {@EditFlip_Callback});
hButtonFlipPlus = uicontrol(...
    'Parent',hResidPanel,...
    'Style','PushButton',...
    'String','+1',...
    'Units','normalized',...
    'Position',[0.3 0.1 0.06 0.1],...
    'Callback',{@ButtonFlipPlus_Callback});                            %#ok
hButtonFlipMinus = uicontrol(...
    'Parent',hResidPanel,...
    'Style','PushButton',...
    'String','-1',...
    'Units','normalized',...
    'Position',[0.1 0.1 0.06 0.1],...
    'Callback',{@ButtonFlipMinus_Callback});                           %#ok
hTextPeakNumber=uicontrol(...
    'Parent',hResidPanel,...
    'Style','text',...
    'Units','Normalized',...
    'String','Peak Number',...
    'FontWeight','bold',...
    'Position',[0.03 0.25 0.4 0.1 ],...
    'horizontalalignment','c');%#ok
hButtonCompareResid = uicontrol(...
    'Parent',hResidPanel,...
    'Style','PushButton',...
    'String','Compare Fits',...
    'Units','normalized',...
    'Position',[0.6 0.8 0.28 0.15],...
    'Callback',{@ButtonCompareResid_Callback});%#ok
hEditComp1=uicontrol(...
    'Parent',hResidPanel,...
    'Style','edit',...
    'Units','Normalized',...
    'BackgroundColor','w',...
    'Enable','Off',...
    'String',1,...
    'Position',[0.6 0.62 0.1 0.1 ],...
    'CallBack', {@EditComp1_Callback});
hEditComp2=uicontrol(...
    'Parent',hResidPanel,...
    'Style','edit',...
    'Units','Normalized',...
    'BackgroundColor','w',...
    'Enable','Off',...
    'String',1,...
    'Position',[0.6 0.5 0.1 0.1 ],...
    'CallBack', {@EditComp2_Callback});
hEditComp3=uicontrol(...
    'Parent',hResidPanel,...
    'Style','edit',...
    'Units','Normalized',...
    'BackgroundColor','w',...
    'Enable','Off',...
    'String',1,...
    'Position',[0.6 0.38 0.1 0.1 ],...
    'CallBack', {@EditComp3_Callback});
hEditComp4=uicontrol(...
    'Parent',hResidPanel,...
    'Style','edit',...
    'Units','Normalized',...
    'BackgroundColor','w',...
    'Enable','Off',...
    'String',1,...
    'Position',[0.6 0.26 0.1 0.1 ],...
    'CallBack', {@EditComp4_Callback});
hEditComp5=uicontrol(...
    'Parent',hResidPanel,...
    'Style','edit',...
    'Units','Normalized',...
    'BackgroundColor','w',...
    'Enable','Off',...
    'String',1,...
    'Position',[0.6 0.14 0.1 0.1 ],...
    'CallBack', {@EditComp5_Callback});
hCheckComp1 = uicontrol(...
    'Parent',hResidPanel,...
    'Style','Checkbox',...
    'String','',...
    'Units','normalized',...
    'Value',0,...
    'Position',[0.54 0.62 0.05 0.1],...
    'Callback',{@CheckComp1_Callback});
hCheckComp2 = uicontrol(...
    'Parent',hResidPanel,...
    'Style','Checkbox',...
    'String','',...
    'Units','normalized',...
    'Value',0,...
    'Position',[0.54 0.50 0.05 0.1],...
    'Callback',{@CheckComp2_Callback});
hCheckComp3 = uicontrol(...
    'Parent',hResidPanel,...
    'Style','Checkbox',...
    'String','',...
    'Units','normalized',...
    'Value',0,...
    'Position',[0.54 0.38 0.05 0.1],...
    'Callback',{@CheckComp3_Callback});
hCheckComp4 = uicontrol(...
    'Parent',hResidPanel,...
    'Style','Checkbox',...
    'String','',...
    'Units','normalized',...
    'Value',0,...
    'Position',[0.54 0.26 0.05 0.1],...
    'Callback',{@CheckComp4_Callback});
hCheckComp5 = uicontrol(...
    'Parent',hResidPanel,...
    'Style','Checkbox',...
    'String','',...
    'Units','normalized',...
    'Value',0,...
    'Position',[0.54 0.14 0.05 0.1],...
    'Callback',{@CheckComp5_Callback});
hTextData=uicontrol(...
    'Parent',hResidPanel,...
    'Style','text',...
    'Units','Normalized',...
    'String','Data Type',...
    'FontWeight','bold',...
    'Position',[0.7 0.7 0.3 0.1 ],...
    'horizontalalignment','c');%#ok
hCheckOrig = uicontrol(...
    'Parent',hResidPanel,...
    'Style','Checkbox',...
    'String','Original',...
    'Units','normalized',...
    'Value',0,...
    'Position',[0.75 0.50 0.2 0.1],...
    'Callback',{@CheckOrig_Callback});
hCheckFitted = uicontrol(...
    'Parent',hResidPanel,...
    'Style','Checkbox',...
    'String','Fitted',...
    'Units','normalized',...
    'Value',0,...
    'Position',[0.75 0.35 0.2 0.1],...
    'Callback',{@CheckFitted_Callback});
hCheckResid = uicontrol(...
    'Parent',hResidPanel,...
    'Style','Checkbox',...
    'String','Residual',...
    'Units','normalized',...
    'Value',0,...
    'Position',[0.75 0.20 0.2 0.1],...
    'Callback',{@CheckResid_Callback});


if strcmp(dosydata.type,'dosy') || strcmp(dosydata.type,'ILT') || strcmp(dosydata.type,'t1/t2')
    set(hResidPanel,'Visible','On');
end
%-----End Panel for the flipping through spectra---------------------------
if strcmp(dosydata.type,'t1/t2')
    maxc=max(max(dosydata.T1));
else
maxc=max(max(dosydata.DOSY));
end
dosyguidata.clvl=clvl.*maxc.*(thresh/100);
dosyguidata.residpeak=1;
dosyguidata.comparepeaks=[1 1 1 1 1];
dosyguidata.compareuse=[0 0 0 0 0];
dosyguidata.comparetype=[0 0 0];

%dosydatagui.clvl=clvl/2;
guidata(hMainFigure,dosyguidata);


PlotSpectrum();
PlotContour();

movegui(hMainFigure,'center')
movegui(hMainFigure,'north')
set(hMainFigure,'Visible','on')
%---------Digitisation Callbacks-------------------------------------------

    function ButtonDigAuto_Callback(source,eventdata)%#ok
        dosyguidata=guidata(hMainFigure);
        CurrDigFac=AutDigFac;
if strcmp(dosydata.type,'t1/t2')
    %relaxation data
    [dosydata.T1] = bilinearInterpolation(dosy.org, [round(dosydata.dosyrows/CurrDigFac) dosydata.dosycols]);
else
    [dosydata.DOSY] = bilinearInterpolation(dosy.org, [round(dosydata.dosyrows/CurrDigFac) dosydata.dosycols]);
end
dosydata.Spectrum=fft(ifft(spectrum.org),round(dosydata.dosyrows/CurrDigFac));
        dosydata.Ppmscale=ppmscale.org(1:CurrDigFac:end);
        dosydata.Ppmscale=dosydata.Ppmscale(1:round(dosydata.dosyrows/CurrDigFac));
        CurrDig=length(dosydata.Ppmscale);
        
        set(hEditDig2,'String',CurrDig);
        guidata(hMainFigure,dosyguidata);
        PlotContour();
        PlotSpectrum();
    end
    function ButtonDigMax_Callback(source,eventdata)%#ok
        dosyguidata=guidata(hMainFigure);
        dosydata.DOSY=dosy.org;
        dosydata.Ppmscale=ppmscale.org;
        dosydata.Spectrum=spectrum.org;
        CurrDig=length(dosydata.Ppmscale);
        CurrDigFac=1;
        set(hEditDig2,'String',CurrDig);
        guidata(hMainFigure,dosyguidata);
        PlotContour();
        PlotSpectrum();
        guidata(hMainFigure,dosyguidata);
        
    end


    function ButtonDigMinus_Callback(source,eventdata)%#ok
        dosyguidata=guidata(hMainFigure);
        CurrDigFac=2*CurrDigFac;
if strcmp(dosydata.type,'t1/t2')
    %relaxation data
    [dosydata.T1] = bilinearInterpolation(dosy.org, [round(dosydata.dosyrows/CurrDigFac) dosydata.dosycols]);
else
    [dosydata.DOSY] = bilinearInterpolation(dosy.org, [round(dosydata.dosyrows/CurrDigFac) dosydata.dosycols]);
end
dosydata.Spectrum=fft(ifft(spectrum.org),round(dosydata.dosyrows/CurrDigFac));
        
        
        dosydata.Ppmscale=ppmscale.org(1:CurrDigFac:end);
        dosydata.Ppmscale=dosydata.Ppmscale(1:round(dosydata.dosyrows/CurrDigFac));
        CurrDig=length(dosydata.Ppmscale);
        set(hEditDig2,'String',CurrDig);
        guidata(hMainFigure,dosyguidata);
        PlotContour();
        PlotSpectrum();
    end
    function ButtonDigPlus_Callback(source,eventdata)%#ok
        dosyguidata=guidata(hMainFigure);
        CurrDigFac=round(CurrDigFac/2);
        if CurrDigFac < 1
            CurrDigFac=1;
        end
if strcmp(dosydata.type,'t1/t2')
    %relaxation data
    [dosydata.T1] = bilinearInterpolation(dosy.org, [round(dosydata.dosyrows/CurrDigFac) dosydata.dosycols]);
else
    [dosydata.DOSY] = bilinearInterpolation(dosy.org, [round(dosydata.dosyrows/CurrDigFac) dosydata.dosycols]);
end
dosydata.Spectrum=fft(ifft(spectrum.org),round(dosydata.dosyrows/CurrDigFac));
        dosydata.Ppmscale=ppmscale.org(1:CurrDigFac:end);
        dosydata.Ppmscale=dosydata.Ppmscale(1:round(dosydata.dosyrows/CurrDigFac));
        CurrDig=length(dosydata.Ppmscale);
        set(hEditDig2,'String',CurrDig);
        guidata(hMainFigure,dosyguidata);
        PlotContour();
        PlotSpectrum();
    end



%---------Plot Control Callbacks-------------------------------------------
    function ZoomXYButton_Callback(source,eventdata)%#ok
        zoom off
        pan off
        zoom on
    end
    function ZoomXButton_Callback(source,eventdata)%#ok
        zoom off
        pan off
        zoom xon
    end
    function ZoomYButton_Callback(source,eventdata)%#ok
        zoom off
        pan off
        zoom yon
    end
    function ZoomOffButton_Callback(source,eventdata)%#ok
        zoom off
        pan off
    end
    function panXYButton_Callback(source,eventdata)%#ok
        pan off
        zoom off
        pan on
    end
    function panXButton_Callback(source,eventdata)%#ok
        pan off
        zoom off
        pan xon
    end
    function panYButton_Callback(source,eventdata)%#ok
        pan off
        zoom off
        pan yon
    end
    function panOffButton_Callback(source,eventdata)%#ok
        pan off
        zoom off
    end
    function ButtonMult2_Callback(source,eventdata)%#ok
        dosyguidata=guidata(hMainFigure);
        dosyguidata.clvl=dosyguidata.clvl/2;
        guidata(hMainFigure,dosyguidata);
        PlotContour()
        
    end
    function ButtonMult11_Callback(source,eventdata)%#ok
        dosyguidata=guidata(hMainFigure);
        dosyguidata.clvl=dosyguidata.clvl/1.1;
        PlotContour()
        guidata(hMainFigure,dosyguidata);
        
    end
    function ButtonDiv2_Callback(source,eventdata)%#ok
        dosyguidata=guidata(hMainFigure);
        dosyguidata.clvl=dosyguidata.clvl*2;
        
        guidata(hMainFigure,dosyguidata);
        PlotContour()
    end
    function ButtonDiv11_Callback(source,eventdata)%#ok
        dosyguidata=guidata(hMainFigure);
        dosyguidata.clvl=dosyguidata.clvl*1.1;
        guidata(hMainFigure,dosyguidata);
        PlotContour()
        
    end
    function ButtonOrgscale_Callback(source,eventdata) %#ok
        dosyguidata=guidata(hMainFigure);
        maxc=max(max(dosydata.DOSY));
        dosyguidata.clvl=clvl.*maxc.*(thresh/100);
        guidata(hMainFigure,dosyguidata);
        xlim([min(dosydata.Ppmscale) max(dosydata.Ppmscale)])
        if strcmp(dosydata.type,'dosy')|| strcmp(dosydata.type,'ILT')...
                || strcmp(dosydata.type,'locodosy')|| strcmp(dosydata.type,'fdm/rrt')
            %DOSY type data
            ylim([min(dosydata.Dscale) max(dosydata.Dscale)])
        elseif strcmp(dosydata.type,'t1/t2')
            %             %relaxation data
            ylim([min(dosydata.Dscale) max(dosydata.T1scale)])
        else
            error('Unknown data type')
        end
        PlotContour()
        
        PlotSpectrum()
        guidata(hMainFigure,dosyguidata);
    end
    function ButtonReplot_Callback(source,eventdata) %#ok
        dosyguidata=guidata(hMainFigure);
        tic
        PlotContour();
        %disp('replot')
        toc
    end
    function ButtonPlotSep_Callback(source,eventdata) %#ok
        dosyguidata=guidata(hMainFigure);
        % Create plotdata to fit the zooming.
        dosydata.xlim=xlim(hDOSY);
        dosydata.ylim=ylim(hDOSY);
        if strcmp(dosydata.type,'dosy')|| strcmp(dosydata.type,'ILT')...
                || strcmp(dosydata.type,'locodosy')|| strcmp(dosydata.type,'fdm/rrt')
            dosyplot(dosydata,dosyguidata.clvl);
        elseif strcmp(dosydata.type,'t1/t2')
            t1plot(dosydata,dosyguidata.clvl);
        else
            error('Unknown data type')
        end
    end
    function ButtonPlotPub_Callback(source,eventdata) %#ok
        dosyguidata=guidata(hMainFigure);
        % Create plotdata to fit the zooming.
        dosydata.xlim=xlim(hDOSY);
        dosydata.ylim=ylim(hDOSY);
        if strcmp(dosydata.type,'dosy')|| strcmp(dosydata.type,'ILT')...
                || strcmp(dosydata.type,'locodosy')|| strcmp(dosydata.type,'fdm/rrt')
            dosyplotpub(dosydata,dosyguidata.clvl);
        elseif strcmp(dosydata.type,'t1/t2')
            dosydata;
            t1plotpub(dosydata,dosyguidata.clvl);
        else
            error('Unknown data type')
        end
    end
    function ButtonStats_Callback(~,~)
        DTpath=which('DOSYToolbox');
        DTpath=DTpath(1:(end-13));
        %open([DTpath 'dosystats.txt']);
        if strcmp(dosydata.type,'dosy')|| strcmp(dosydata.type,'ILT')...
                || strcmp(dosydata.type,'locodosy')|| strcmp(dosydata.type,'fdm/rrt')
            UseFile=[DTpath 'dosystats.txt'];
            DefName='dosystats.txt';
            %type([DTpath 'dosystats.txt']);
        elseif strcmp(dosydata.type,'t1/t2')
            %type([DTpath 't1stats.txt']);
            UseFile=[DTpath 't1stats.txt'];
            DefName='t1stats.txt';
        else
            error('Unknown data type')
        end
        type(UseFile)
        
        [filename, pathname] = uiputfile('*.txt','Save statistics file',DefName);
        copyfile(UseFile,[pathname filename])
        
    end
    function Scale_Callback(~,~)
        switch get(hlogscaleGroup,'SelectedObject')
            case hRadioLog
                dosyguidata=guidata(hMainFigure);
                set(hDOSY,'YScale','log');
            case hRadioLin
                dosyguidata=guidata(hMainFigure);
                set(hDOSY,'YScale','linear');
            otherwise
                error('illegal choice')
        end
        
    end
    function ButtonPlotSpecproj_Callback(source,eventdata) %#ok
        dosyguidata=guidata(hMainFigure);
        % Create plotdata to fit the zooming.
        dosydata.xlim=xlim(hDOSY);
        dosydata.ylim=ylim(hDOSY);
        %         if strcmp(dosydata.type,'dosy')|| strcmp(dosydata.type,'ILT')...
        %                 || strcmp(dosydata.type,'locodosy')|| strcmp(dosydata.type,'fdm/rrt')
        %             dosyplotpub(dosydata,dosyguidata.clvl);
        %         elseif strcmp(dosydata.type,'t1/t2')
        %             dosydata
        %             t1plotpub(dosydata,dosyguidata.clvl);
        %         else
        %             error('Unknown data type')
        %         end
        
        
        figure('Color',[1 1 1],...
            'NumberTitle','Off',...
            ...'PaperOrientation','Landscape',...
            ...'PaperUnits','centimeters',...
            ...'PaperSize',[29.7 21],...
            'Units','centimeters',...
            'Position',[0 0 29.7 21],...
            'Name','Spectral Projection');
        
        DOSY=dosydata.DOSY;
        specscale=dosydata.Ppmscale;
        
        temp_ylim=ylim(hDOSY);
        high_y=find(dosydata.Dscale>temp_ylim(2));
        low_y=find(dosydata.Dscale<temp_ylim(1));
        DOSY(:,[high_y low_y])=[];
        
        
        temp_xlim=xlim(hDOSY);
        high_x=find(specscale>temp_xlim(2));
        low_x=find(specscale<temp_xlim(1));
        specscale([high_x' low_x'])=[];
        DOSY([high_x' low_x'],:)=[];
        
        switch get(hProjGroup,'SelectedObject')
            case hRadioSky
                specproj=sum(DOSY');
                Ylab='Skyline';
                
            case hRadioSum
                
                specproj=max(DOSY');
                Ylab='Sum';
                
            otherwise
                error('illegal choice')
        end
        
        
        
        
        
        h=plot(specscale,specproj,'LineWidth',2,'Color','black');
        set(gca,'Xdir','reverse');
        axis('tight')
        xlabel('\fontname{ariel} \bf Chemical shift /ppm');
        ylabel(['\fontname{ariel} \bf' Ylab ]);
        set(gca,'LineWidth',2);
        
        
        ylim([0-max(specproj)*0.1  max(specproj)*1.1]);
        
    end

    function ButtonPlotDproj_Callback(source,eventdata) %#ok
        dosyguidata=guidata(hMainFigure);
        % Create plotdata to fit the zooming.
        
        if strcmp(dosydata.type,'dosy')|| strcmp(dosydata.type,'ILT')...
                || strcmp(dosydata.type,'locodosy')|| strcmp(dosydata.type,'fdm/rrt')
            projname='Diffusion Projection';
            x_string='\bf Diffusion coefficient / 10^{-10} m^{2} s^{-1} ';
        elseif strcmp(dosydata.type,'t1/t2')
            projname='T1/T2 Projection';
            x_string='\bf T1/T2 /s';
        else
            error('Unknown data type')
        end
        
        
        figure('Color',[1 1 1],...
            'NumberTitle','Off',...
            ...'PaperOrientation','Landscape',...
            ...'PaperUnits','centimeters',...
            ...'PaperSize',[29.7 21],...
            'Units','centimeters',...
            'Position',[0 0 29.7 21],...
            'Name',projname);
        
        DOSY=dosydata.DOSY;
        specscale=dosydata.Dscale;
        temp_ylim=ylim(hDOSY);
        high_y=find(dosydata.Dscale>temp_ylim(2));
        low_y=find(dosydata.Dscale<temp_ylim(1));
        DOSY(:,[high_y low_y])=[];
        specscale([high_y low_y])=[];
        
        temp_xlim=xlim(hDOSY);
        high_x=find(specscale>temp_xlim(2));
        low_x=find(specscale<temp_xlim(1));
        
        DOSY([high_x' low_x'],:)=[];
        
        
        switch get(hProjGroup,'SelectedObject')
            case hRadioSky
                specproj=sum(DOSY);
                Ylab='Skyline';
                
            case hRadioSum
                
                specproj=max(DOSY);
                Ylab='Sum';
                
            otherwise
                error('illegal choice')
        end
        
        
        
        
        
        h=plot(specscale,specproj,'LineWidth',2,'Color','black');
        set(gca,'Xdir','reverse');
        axis('tight')
        xlabel(x_string);
        ylabel(['\fontname{ariel} \bf' Ylab ]);
        set(gca,'LineWidth',2);
        
        
        ylim([0-max(specproj)*0.1  max(specproj)*1.1]);
        
    end


%---------End of Plot Control Callbacks------------------------------------

%---------Plot Residual Callbacks------------------------------------------
    function ButtonPlotResid_Callback(source,eventdata) %#ok
        dosyguidata=guidata(hMainFigure);
        PlotResidual(dosyguidata.residpeak);
    end
    function ButtonPlotResidSep_Callback(source,eventdata) %#ok
        dosyguidata=guidata(hMainFigure);
        dosyresidual(dosydata,dosyguidata);
    end
    function EditComp1_Callback(source,eventdata) %#ok<INUSD>
        dosyguidata=guidata(hMainFigure);
        
        if isnan((str2double(get(hEditComp1,'string'))))
            disp('Must be a number')
            set(hEditComp1,'String',num2str(dosyguidata.comparepeaks(1)))
        else
            
            dosyguidata.comparepeaks(1)=...
                round((str2double(get(hEditComp1,'string'))));
            
            if dosyguidata.comparepeaks(1)>length(dosydata.freqs)
                dosyguidata.comparepeaks(1)=length(dosydata.freqs);
                set(hEditComp1,'String',num2str(dosyguidata.comparepeaks(1)))
            end
            if dosyguidata.comparepeaks(1)<0
                dosyguidata.comparepeaks(1)=1;
                set(hEditComp1,'String',num2str(dosyguidata.comparepeaks(1)))
            end
        end
        guidata(hMainFigure,dosyguidata);
    end
    function EditComp2_Callback(source,eventdata) %#ok<INUSD>
        dosyguidata=guidata(hMainFigure);
        if isnan((str2double(get(hEditComp2,'string'))))
            disp('Must be a number')
            set(hEditComp2,'String',num2str(dosyguidata.comparepeaks(2)))
        else
            dosyguidata.comparepeaks(2)=...
                round((str2double(get(hEditComp1,'string'))));
            
            if dosyguidata.comparepeaks(2)>length(dosydata.freqs)
                dosyguidata.comparepeaks(2)=length(dosydata.freqs);
                set(hEditComp1,'String',num2str(dosyguidata.comparepeaks(2)))
            end
            if dosyguidata.comparepeaks(2)<0
                dosyguidata.comparepeaks(2)=1;
                set(hEditComp1,'String',num2str(dosyguidata.comparepeaks(2)))
            end
        end
        guidata(hMainFigure,dosyguidata);
    end
    function EditComp3_Callback(source,eventdata) %#ok<INUSD>
        dosyguidata=guidata(hMainFigure);
        if isnan((str2double(get(hEditComp3,'string'))))
            disp('Must be a number')
            set(hEditComp3,'String',num2str(dosyguidata.comparepeaks(3)))
        else
            dosyguidata.comparepeaks(3)=...
                round((str2double(get(hEditComp3,'string'))));
            
            if dosyguidata.comparepeaks(3)>length(dosydata.freqs)
                dosyguidata.comparepeaks(3)=length(dosydata.freqs);
                set(hEditComp3,'String',num2str(dosyguidata.comparepeaks(3)))
            end
            if dosyguidata.comparepeaks(3)<0
                dosyguidata.comparepeaks(3)=1;
                set(hEditComp3,'String',num2str(dosyguidata.comparepeaks(3)))
            end
        end
        guidata(hMainFigure,dosyguidata);
    end
    function EditComp4_Callback(source,eventdata) %#ok<INUSD>
        dosyguidata=guidata(hMainFigure);
        if isnan((str2double(get(hEditComp4,'string'))))
            disp('Must be a number')
            set(hEditComp4,'String',num2str(dosyguidata.comparepeaks(4)))
        else
            dosyguidata.comparepeaks(4)=...
                round((str2double(get(hEditComp4,'string'))));
            
            if dosyguidata.comparepeaks(4)>length(dosydata.freqs)
                dosyguidata.comparepeaks(4)=length(dosydata.freqs);
                set(hEditComp4,'String',num2str(dosyguidata.comparepeaks(4)))
            end
            if dosyguidata.comparepeaks(4)<0
                dosyguidata.comparepeaks(4)=1;
                set(hEditComp4,'String',num2str(dosyguidata.comparepeaks(4)))
            end
        end
        guidata(hMainFigure,dosyguidata);
    end
    function EditComp5_Callback(source,eventdata) %#ok<INUSD>
        dosyguidata=guidata(hMainFigure);
        if isnan((str2double(get(hEditComp5,'string'))))
            disp('Must be a number')
            set(hEditComp5,'String',num2str(dosyguidata.comparepeaks(5)))
        else
            dosyguidata.comparepeaks(5)=...
                round((str2double(get(hEditComp5,'string'))));
            
            if dosyguidata.comparepeaks(5)>length(dosydata.freqs)
                dosyguidata.comparepeaks(5)=length(dosydata.freqs);
                set(hEditComp5,'String',num2str(dosyguidata.comparepeaks(5)))
            end
            if dosyguidata.comparepeaks(5)<0
                dosyguidata.comparepeaks(5)=1;
                set(hEditComp5,'String',num2str(dosyguidata.comparepeaks(5)))
            end
        end
        guidata(hMainFigure,dosyguidata);
    end
    function CheckComp1_Callback(source,eventdata)  %#ok<INUSD>
        if get(hCheckComp1,'Value')
            set(hEditComp1,'Enable','On')
        else
            set(hEditComp1,'Enable','Off')
        end
        guidata(hMainFigure,dosyguidata);
    end
    function CheckComp2_Callback(source,eventdata)  %#ok<INUSD>
        if get(hCheckComp2,'Value')
            set(hEditComp2,'Enable','On')
        else
            set(hEditComp2,'Enable','Off')
        end
        guidata(hMainFigure,dosyguidata);
    end
    function CheckComp3_Callback(source,eventdata)  %#ok<INUSD>
        if get(hCheckComp3,'Value')
            set(hEditComp3,'Enable','On')
        else
            set(hEditComp3,'Enable','Off')
        end
        guidata(hMainFigure,dosyguidata);
    end
    function CheckComp4_Callback(source,eventdata)  %#ok<INUSD>
        if get(hCheckComp4,'Value')
            set(hEditComp4,'Enable','On')
        else
            set(hEditComp4,'Enable','Off')
        end
        guidata(hMainFigure,dosyguidata);
    end
    function CheckComp5_Callback(source,eventdata)  %#ok<INUSD>
        if get(hCheckComp5,'Value')
            set(hEditComp5,'Enable','On')
        else
            set(hEditComp5,'Enable','Off')
        end
        guidata(hMainFigure,dosyguidata);
    end
    function CheckOrig_Callback(source,eventdata)  %#ok<INUSD>
        
        guidata(hMainFigure,dosyguidata);
    end
    function CheckFitted_Callback(source,eventdata)  %#ok<INUSD>
        
        guidata(hMainFigure,dosyguidata);
    end
    function CheckResid_Callback(source,eventdata)  %#ok<INUSD>
        if get(hCheckResid,'Value')
            dosyguidata.comparetype(3)=1;
        else
            dosyguidata.comparetype(3)=0;
        end
        guidata(hMainFigure,dosyguidata);
    end
    function ButtonCompareResid_Callback(source,eventdata) %#ok<INUSD>
        dosyguidata=guidata(hMainFigure);
        
        %Check data type
        if get(hCheckOrig,'Value')
            dosyguidata.comparetype(1)=1;
        else
            dosyguidata.comparetype(1)=0;
        end
        if get(hCheckFitted,'Value')
            dosyguidata.comparetype(2)=1;
        else
            dosyguidata.comparetype(2)=0;
        end
        if get(hCheckResid,'Value')
            dosyguidata.comparetype(3)=1;
        else
            dosyguidata.comparetype(3)=0;
        end
        
        
        %Check peak numbers
        if get(hCheckComp1,'Value')
            dosyguidata.comparepeaks(1)=str2double(get(hEditComp1,'String'));
            dosyguidata.compareuse(1)=1;
        else
            dosyguidata.compareuse(1)=0;
        end
        if get(hCheckComp2,'Value')
            dosyguidata.comparepeaks(2)=str2double(get(hEditComp2,'String'));
            dosyguidata.compareuse(2)=1;
        else
            dosyguidata.compareuse(2)=0;
        end
        if get(hCheckComp3,'Value')
            dosyguidata.comparepeaks(3)=str2double(get(hEditComp3,'String'));
            dosyguidata.compareuse(3)=1;
        else
            dosyguidata.compareuse(3)=0;
        end
        if get(hCheckComp4,'Value')
            dosyguidata.comparepeaks(4)=str2double(get(hEditComp4,'String'));
            dosyguidata.compareuse(4)=1;
        else
            dosyguidata.compareuse(4)=0;
        end
        if get(hCheckComp5,'Value')
            dosyguidata.comparepeaks(5)=str2double(get(hEditComp5,'String'));
            dosyguidata.compareuse(5)=1;
        else
            dosyguidata.compareuse(5)=0;
        end
        guidata(hMainFigure,dosyguidata);
        
        dosyresidualcompare(dosydata,dosyguidata);
    end

    function EditFlip_Callback(source,eventdata)                       %#ok
        
        dosyguidata=guidata(hMainFigure);
        dosyguidata.residpeak=round(str2double(get(hEditFlip,'String')));
        if dosyguidata.residpeak>length(dosydata.freqs)
            dosyguidata.residpeak=length(dosydata.freqs);
            set(hEditFlip,'String',num2str(dosyguidata.residpeak))
        end
        if dosyguidata.residpeak<1
            dosyguidata.residpeak=1;
            set(hEditFlip,'String',num2str(dosyguidata.residpeak))
        end
        guidata(hMainFigure,dosyguidata);
        PlotResidual(dosyguidata.residpeak);
    end
    function ButtonFlipPlus_Callback(source,eventdata) %#ok
        dosyguidata=guidata(hMainFigure);
        dosyguidata.residpeak=dosyguidata.residpeak+1;
        if dosyguidata.residpeak>length(dosydata.freqs)
            dosyguidata.residpeak=length(dosydata.freqs);
            set(hEditFlip,'String',num2str(dosyguidata.residpeak))
        end
        if dosyguidata.residpeak<1
            dosyguidata.residpeak=1;
            set(hEditFlip,'String',num2str(dosyguidata.residpeak))
        end
        set(hEditFlip,'String',num2str(dosyguidata.residpeak))
        guidata(hMainFigure,dosyguidata);
        PlotResidual(dosyguidata.residpeak);
    end
    function ButtonFlipMinus_Callback(source,eventdata)%#ok
        dosyguidata=guidata(hMainFigure);
        dosyguidata.residpeak=dosyguidata.residpeak-1;
        if dosyguidata.residpeak>length(dosydata.freqs)
            dosyguidata.residpeak=length(dosydata.freqs);
            set(hEditFlip,'String',num2str(dosyguidata.residpeak))
        end
        if dosyguidata.residpeak<1
            dosyguidata.residpeak=1;
            set(hEditFlip,'String',num2str(dosyguidata.residpeak))
        end
        set(hEditFlip,'String',num2str(dosyguidata.residpeak))
        guidata(hMainFigure,dosyguidata);
        PlotResidual(dosyguidata.residpeak);
        
    end

%---------End of Plot Residual Callbacks-----------------------------------


    function PlotContour()
        dosyguidata=guidata(hMainFigure);
        xxx=xlim();
        yyy=ylim();
        if strcmp(dosydata.type,'dosy')|| strcmp(dosydata.type,'ILT')...
                || strcmp(dosydata.type,'locodosy')|| strcmp(dosydata.type,'fdm/rrt')
            %DOSY type data
            [xax,yax]=meshgrid(dosydata.Ppmscale,dosydata.Dscale);
            
            
            [C,hContour1]=contour(hDOSY,xax,yax,(dosydata.DOSY.*(dosydata.DOSY>0))',dosyguidata.clvl,'b');
            
            
            dosyguidata.hContour1=hContour1;
            dosyguidata.hContour2=[];
            set(hContour1,'LineWidth',1)
            
            % dosydata.DOSY(dosydata.DOSY == 0) = NaN;
            
            if dosydata.DOSY<0
                hold(hDOSY,'on')
                [C,hContour2]=contour(hDOSY,xax,yax,(dosydata.DOSY.*(dosydata.DOSY<0))',dosyguidata.clvl,'color',[1 0.5 0]);
                hold(hDOSY,'off')
                
                dosyguidata.hContour2=hContour2;
                set(hContour2,'LineWidth',1)
            end
            ylabel(hDOSY,'\bf Diffusion coefficient m^{2} s^{-1} \times 10^{-10}');
            
        elseif strcmp(dosydata.type,'t1/t2')
            %relaxation data
            [xax,yax]=meshgrid(dosydata.Ppmscale,dosydata.T1scale);
            [C,hContour1]=contour(hDOSY,xax,yax,dosydata.T1',dosyguidata.clvl,'b');
            ylabel(hDOSY,'\bf T1/T2 coefficient (s)');
            dosyguidata.hContour1=hContour1;
            dosyguidata.hContour2=[];
            
            set(hContour1,'LineWidth',1)
            
        else
            error('Unknown data type')
        end
        
        %         disp('PC')
        %         toc
        set(hDOSY,'LineWidth',1)
        set(hDOSY,'Ydir','reverse');
        set(hDOSY,'Xdir','reverse');
        xlabel(hDOSY,'\bf Chemical shift (ppm)');
        ylim(yyy);
        xlim(xxx);
        
        linkaxes([hDOSY hSpec],'x')
        
        PlotSpectrum()
        
        guidata(hMainFigure,dosyguidata);
        
    end
    function PlotSpectrum()
        axes(hSpec)
        hResidLine=findobj(hSpec,'tag','ResidLine');
        delete(hResidLine)
        xxx=xlim();
        hSpecPlot=plot(hSpec,dosydata.Ppmscale, real(dosydata.Spectrum),'-b');
        axis(hSpec,'tight')
        axis(hSpec,'off')
        set(hSpec,'Xdir','reverse');
        set(hSpecPlot,'LineWidth',1)
        set(hSpecPlot,'Color','blue')
        xlim(xxx);
        
    end

    function PlotResidual(npeak)
        
        linkaxes([hDOSY hSpec],'off')
        axes(hDOSY)
        get(hMainFigure,'CurrentAxes');
        norm_max=max([max(dosydata.ORIGINAL(npeak,:)) max(dosydata.FITTED(npeak,:))]);
        
        
        if strcmp(dosydata.type,'dosy')|| strcmp(dosydata.type,'ILT')...
                || strcmp(dosydata.type,'locodosy')|| strcmp(dosydata.type,'fdm/rrt')
            %DOSY type data
            xdata=dosydata.Gzlvl;
            xlabel('\fontname{ariel} \bf Gradient amplitude (T m^{-1})')
        elseif strcmp(dosydata.type,'t1/t2')
            %relaxation data
            
            xdata=dosydata.Tau;
            xlabel('\fontname{ariel} \bf Time (s)')
        else
            error('Unknown data type')
        end
        
        
        plot(xdata,(dosydata.ORIGINAL(npeak,:)./norm_max),'+k','LineWidth',2)
        hold on
        plot(xdata,(dosydata.FITTED(npeak,:)./norm_max),'--r','LineWidth',2)
        plot(xdata,(dosydata.RESIDUAL(npeak,:)./norm_max),'--b','LineWidth',2)
        
        set(gca,'LineWidth',2);
        axis('tight')
        ylim('auto')
        
        if min(dosydata.FITTED(npeak,:)./norm_max) <0
            ylim([min(dosydata.FITTED(npeak,:)./norm_max)*1.1 1]);
        else
            ylim([-0.1 1]);
        end
        ylabel('\fontname{ariel} \bf Amplitude')
        str=['\fontname{ariel} \bf Peak Number: ' num2str(npeak)];
        text(0.5*max(xdata),0.85,str);
        str=['\fontname{ariel} \bf Frequency: ' num2str(dosydata.freqs(npeak),3) ' ppm'];
        text(0.5*max(xdata),0.75,str);
        nexp=length(find(dosydata.FITSTATS(npeak,:)))/4;
        str=['\fontname{ariel} \bf Number of exponentials: ' num2str(nexp,1)];
        text(0.5*max(xdata),0.65,str);
        str='\color{black} \bf +  Original';
        text(0.5*max(xdata),0.4,str);
        str='\color{red} \bf - -  Fitted';
        text(0.5*max(xdata),0.3,str);
        str='\color{blue} \bf - -  Residual';
        text(0.5*max(xdata),0.2,str);
        
        if strcmp(dosydata.type,'dosy')|| strcmp(dosydata.type,'ILT')...
                || strcmp(dosydata.type,'locodosy')|| strcmp(dosydata.type,'fdm/rrt')
            %DOSY type data
            xlabel('\fontname{ariel} \bf Gradient amplitude (T m^{-1})')
        elseif strcmp(dosydata.type,'t1/t2')
            %relaxation data
            xlabel('\fontname{ariel} \bf Time (s)')
        else
            error('Unknown data type')
        end
        
        hold off
        
        PlotSpectrum()
        axes(hSpec)
        line([dosydata.freqs(npeak) dosydata.freqs(npeak)], ylim,'Color', 'r','tag','ResidLine')
    end




end
%---------------------END of dosyplot_gui--------------------------------------



