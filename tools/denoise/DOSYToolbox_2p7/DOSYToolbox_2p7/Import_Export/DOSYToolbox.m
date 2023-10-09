function DOSYToolbox()
%   DOSYToolbox() - GUI for processing DOSY (PFG-NMR) data
%   Please consult the manual for more information%
%
%   Example:  Start the graphical user interface by typing "DOSYToolbox"
%             in the command window
%
%   See also: dosy_mn, score_mn, decra_mn, mcr_mn, varianimport,
%             brukerimport, jeolimport, peakpick_mn, dosyplot_mn,
%             dosyresidual, dosyplot_gui, scoreplot_mn, decraplot_mn,
%             mcrplot_mn
%   Saving a file from the DOSYToolbox (*.nmr) results in a structure
%   containing the following members:
%       at: acquisition time (seconds)
%       baselinecorr: vectors for base line correction
%       baselinepoints: points to mark up the peak free baseline
%       bpoints: used for baseline correction
%       bpoints1: used for baseline correction
%       bpoints2: used for baseline correction
%       decradata: structure containing data from a DECRA fit
%       DELTA: diffusion time
%       DELTAOriginal: diffusion time as read in from datafile
%       DELTAprime: corrected diffusion time
%       delta: diffusin encoding time
%       deltaOriginal: diffusion encoding time as read in from datafile
%       DOSYdiffrange: vector containd bound for the DOSY plot
%       dosyconstant: gamma.^2*delts^2*DELTAprime
%       dosyconstantOriginal: dosyconstant as read in from datafile
%       dosydata: structure continaning data from a DOSY fit
%       DOSYopts: vector containing option for DOSY fit
%       exclude: vector containg information on spectral regions to excude
%                from analysis
%       excludelinepoints: used for exclude regions
%       expoints: sed for exclude regions
%       FID: Raw free induction decays
%       filename: file name of original data
%       flipnr: Which spectrum/fid to display
%       fn: Fourier number
%       gamma: magnetogyric ratio of the nucleus
%       gammaOriginal: magnetogyric ratio of the nucleus as read in from
%                      datafile
%       gw: value for gaussian window function
%       Gzlvl: vector of gradient amplitudes (T/m)
%       lb: value for lorentzian window function
%       lp: left phase
%       lpInd: used for phase corretion
%       mcrdata: structure containing data from a MCR fit
%       MCRopts: vector containing option for MCR fit
%       ncomp: number of components to fit
%       ngrad: number of gradient levels
%       np: number of complex data points per fid
%       nug: coefficients for non-uniform gradient correction
%       order: order of polynomial for baseline correction
%       pfgnmrdata: input data for e.g. DOSY fit
%       pivot: pivot point for phasing (ppm)
%       pivotxdata: used for phasing
%       pivotydata: used for phasing
%       plottype: plot spectrum or FID
%       prune: gradient levels to remove from analysis
%       RDcentrexdata: used for reference deconvolution
%       RDcentreydata: used for reference deconvolution
%       RDcentre: used for reference deconvolution
%       RDleftxdata: used for reference deconvolution
%       RDleftydata: used for reference deconvolution
%       RDleft: used for reference deconvolution
%       RDrightxdata: used for reference deconvolution
%       RDrightydata: used for reference deconvolution
%       RDright: used for reference deconvolution
%       reference: used to reference the spectrum
%       referencexdata: used to reference the spectrum
%       referenceydata: used to reference the spectrum
%       region: used for baseline correction
%       rp: right phase
%       rpInd: used for phasing
%       scoredata: structure containing data from a SCORE fit
%       SCOREopts: vector containing option for SCORE fit
%       sfrq: spectrometer frequency (MHz)
%       sp: start of spectrum (ppm)
%       Specscale: scale for plotting the spectrum
%       SPECTRA: spectra (processed)
%       sw: spectral width (ppm)
%       th: threshold
%       thresxdata: threshold data
%       thresydata: threshold data
%       Timescale: scale for plotting the FID
%       type: type of manufacturer (i.e. Varian, Bruker or Jeol)
%       version: DOSY Toolbox version
%       xlim: x limits for plot
%       xlim_fid: x limits for fid plot
%       ylim: y limits for  plot
%       ylim_fid: [-2087585 999760]
%       xlim_spec: x limits for spectrum plot
%       ylim_spec: y limits for spectrum plot
%
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
%% Initialisation

%Turning certain things on for local (University of Manchester) use.
NmrData.local='yes';
NmrData.local='no';

%diary('DOSYToolboxlog')



%set the version
NmrData.version='DOSY Toolbox development version (stable is 2.7)';
NmrData.version='DOSY Toolbox version 2.7';
%%  Gui controls
%%  Main Figure
hMainFigure = figure(...
    'Units','pixels',...
    'MenuBar','none',...
    ...'MenuBar','figure',...
    'Name',NmrData.version,...
    'NumberTitle','Off',...
    'DeleteFcn',@hMainFigure_DeleteFcn,...
    'Toolbar','Figure',...
    'OuterPosition',[0.0 0.0 1280 1024 ],...
    'Visible','off');
hAxes = axes('Parent',hMainFigure,...
    'Units','normalized',...
    'Position',[0.02 0.45 0.96 0.45],...
    'ButtonDownFcn',@Axes_ButtonDownFcn);
guidata(hMainFigure,NmrData);
%%  Control Figure
% hControlFig = figure(...
%     'Units','normalized',...
%     'MenuBar','none',...
%     ...'MenuBar','figure',...
%     'Name','Controls',...
%     'NumberTitle','Off',...
%     'Toolbar','none',...
%     'OuterPosition',[0.0 0.02 1.0 0.40],...
%     'Visible','off');
%%  Menus
hMenuFile=uimenu(...
    'Parent',hMainFigure,...
    'Label','DOSY Files');
hOpenMenu=uimenu(hMenuFile,'Label','Open',...
    'Enable','On');
uimenu(hOpenMenu,'Label','DOSY Toolbox Format (ASCII or binary)',...
    'Enable','On',...
    'Callback',@Import_DOSYToolboxASCII);
uimenu(hOpenMenu,'Label','Matlab format',...
    'Enable','On',...
    'Callback',@Open_data);
hImportMenu=uimenu(hMenuFile,'Label','Import',...
    'Enable','On');
uimenu(hImportMenu,'Label','Bruker',...
    'Enable','On',...
    'Callback',@Import_Bruker);
uimenu(hImportMenu,'Label','Bruker (Processed)',...
    'Enable','On',...
    'Callback',@Import_Bruker_Processed);
uimenu(hImportMenu,'Label','Varian',...
    'Enable','On',...
    'Callback',@Import_Varian);
uimenu(hImportMenu,'Label','Jeol Generic',...
    'Enable','On',...
    'Callback',@Import_JeolGeneric);
uimenu(hImportMenu,'Label','Bruker Array',...
    'Enable','On',...
    'Callback',@Import_Bruker_array);
uimenu(hImportMenu,'Label','Bruker Array (Processed)',...
    'Enable','On',...
    'Callback',@Import_Bruker_array_Processed);
uimenu(hImportMenu,'Label','Varian Array',...
    'Enable','On',...
    'Callback',@Import_Varian_Array)
if strcmp(NmrData.local,'yes')
    uimenu(hImportMenu,'Label','FireBird',...
    'Enable','Off',...
    'Callback',@Import_FireBird);
  uimenu(hImportMenu,'Label','Spinach',...
    'Enable','On',...
    'Callback',@Import_Spinach);
end



hSaveMenu=uimenu(hMenuFile,'Label','Save',...
    'Enable','On');
uimenu(hSaveMenu,'Label','Matlab format',...
    'Enable','On',...
    'Callback',@SaveDataMatlab);
hExportMenu=uimenu(hMenuFile,'Label','Export',...
    'Enable','On');
hToolboxBin=uimenu(hSaveMenu,'Label','Toolbox binary format',...
    'Enable','On');
hToolboxAsc=uimenu(hSaveMenu,'Label','Toolbox ASCII format',...
    'Enable','On');
uimenu(hToolboxAsc,'Label','Raw data',...
    'Enable','On',...
    'Callback',@SaveFIDDataToolboxASCII);
uimenu(hToolboxAsc,'Label','Inverse FT of complex spectrum',...
    'Enable','On',...
    'Callback',@SaveComplexSpecDataToolboxASCII);
uimenu(hToolboxAsc,'Label','Inverse FT of real spectrum',...
    'Enable','On',...
    'Callback',@SaveRealSpecDataToolboxASCII);
uimenu(hToolboxBin,'Label','Raw data',...
    'Enable','On',...
    'Callback',@SaveFIDDataToolboxBinary);
uimenu(hToolboxBin,'Label','Inverse FT of complex spectrum',...
    'Enable','On',...
    'Callback',@SaveComplexSpecDataToolboxBinary);
uimenu(hToolboxBin,'Label','Inverse FT of real spectrum',...
    'Enable','On',...
    'Callback',@SaveRealSpecDataToolboxBinary);
uimenu(hExportMenu,'Label','DOSY processing',...
    'Enable','On',...
    'Callback',@ExportDOSY);
uimenu(hExportMenu,'Label','PARAFAC processing',...
    'Enable','On',...
    'Callback',@ExportPARAFAC);
uimenu(hExportMenu,'Label','Time domain NMR data (ASCII)',...
    'Enable','On',...
    'Callback',@ExportTDData);
hBinnedMenu=uimenu(hExportMenu,'Label','Binned',...
    'Enable','On');
uimenu(hBinnedMenu,'Label','pfg format',...
    'Enable','On',...
    'Callback',@ExportBinnedMenuPfg);
uimenu(hBinnedMenu,'Label','csv format',...
    'Enable','On',...
    'Callback',@ExportBinnedMenuCsv);
uimenu(hMenuFile,'Label','Import Bruker',...
    'Enable','On',...
     'Separator','On',...
    'Callback',@Import_Bruker);
uimenu(hMenuFile,'Label','Import Bruker (Processed)',...
    'Enable','On',...
    'Callback',@Import_Bruker_Processed);
uimenu(hMenuFile,'Label','Import Varian',...
    'Enable','On',...
    'Callback',@Import_Varian);
uimenu(hMenuFile,'Label','Quit',...
    'Enable','On',...
    'Separator','On',...
    'Callback',@QuitDOSYToolbox);
hEditFile=uimenu(...
    'Parent',hMainFigure,...
    'Label','Edit DOSY');
uimenu(hEditFile,'Label','Settings',...
    'Enable','On',...
    'Callback',@Edit_Settings);
hExtraMenu=uimenu(...
    'Parent',hMainFigure,...
    'Label','Extra options');
uimenu(hExtraMenu,'Label','Close all but first window',...
    'Enable','On',...
    'Callback',@Extra_Close);
hMenuHelp=uimenu(...
    'Parent',hMainFigure,...
    'Label','DOSY Help');
uimenu(hMenuHelp,'Label','Online Help',...
    'Enable','On',...
    'Callback',@Help_Online);
uimenu(hMenuHelp,'Label','About the DOSY Toolbox',...
    'Enable','On',...
    'Callback',@Help_About);
%%  Panel for the flipping through spectra
hArrayPanel=uipanel(...
    'Parent',hMainFigure,...
    'Title','Arrays',...
    'FontWeight','bold',...
    'ForegroundColor','Blue',...
    'TitlePosition','centertop',...
    'Visible','off',...
    'Units','Normalized',...
    'Position',[0.01,0.01,0.3,0.2]);
hFlipPanel=uipanel(...
    'Parent',hMainFigure,...
    'Title','Gradient level',...
    'FontWeight','bold',...
    'TitlePosition','centertop',...
    'ForegroundColor','Blue',...
    'ResizeFcn' , @hFlipPanelResizeFcn,...
    'Units','Normalized',...
    'Position',[0.2,0.935,0.15,0.05]);
hTextFlip=uicontrol(...
    'Parent',hFlipPanel,...
    'Style','Text',...
    'Units','Normalized',...
    'String','/0',...
     'horizontalalignment','left',...
    'Position',[0.48 0.15 0.4 0.6 ]);
hEditFlip=uicontrol(...
    'Parent',hFlipPanel,...
    'Style','edit',...
    'Units','Normalized',...
    'BackgroundColor','w',...
    'String',1,...
    'Position',[0.3 0.2 0.15 0.7 ],...
    'CallBack', {@EditFlip_Callback});
hButtonFlipPlus = uicontrol(...
    'Parent',hFlipPanel,...
    'Style','PushButton',...
    'String','+1',...
    'Units','normalized',...
    'TooltipString','Next spectrum in the array',...
    'Position',[0.75 0.2 0.15 0.7],...
    'Callback',{@ButtonFlipPlus_Callback});
hButtonFlipMinus = uicontrol(...
    'Parent',hFlipPanel,...
    'Style','PushButton',...
    'String','-1',...
    'Units','normalized',...
    'TooltipString','Previous spectrum in the array',...
    'Position',[0.05 0.2 0.15 0.7],...
    'Callback',{@ButtonFlipMinus_Callback});
hFlipPanel2=uipanel(...
    'Parent',hMainFigure,...
    'Title','Second array',...
    'FontWeight','bold',...
    'TitlePosition','centertop',...
    'ResizeFcn' , @hFlipPanel2ResizeFcn,...
    'ForegroundColor','Blue',...
    'Units','Normalized',...
    'Position',[0.6,0.935,0.15,0.05]);
hTextFlip2=uicontrol(...
    'Parent',hFlipPanel2,...
    'Style','Text',...
    'Units','Normalized',...
      'horizontalalignment','left',...
    'String','/0',...
    'Position',[0.48 0.15 0.4 0.6 ]);
hEditFlip2=uicontrol(...
    'Parent',hFlipPanel2,...
    'Style','edit',...
    'Units','Normalized',...
    'BackgroundColor','w',...
    'String',1,...
    'Position',[0.3 0.2 0.15 0.7 ],...
    'CallBack', {@EditFlip2_Callback});
hButtonFlipPlus2 = uicontrol(...
    'Parent',hFlipPanel2,...
    'Style','PushButton',...
    'String','+1',...
    'Units','normalized',...
    'TooltipString','Next spectrum in the array',...
    'Position',[0.75 0.2 0.15 0.7],...
    'Callback',{@ButtonFlipPlus2_Callback});
hButtonFlipMinus2 = uicontrol(...
    'Parent',hFlipPanel2,...
    'Style','PushButton',...
    'String','-1',...
    'Units','normalized',...
    'TooltipString','Previous spectrum in the array',...
    'Position',[0.05 0.2 0.15 0.7],...
    'Callback',{@ButtonFlipMinus2_Callback});
hFlipPanelSpec=uipanel(...
    'Parent',hMainFigure,...
    'Title','Spectrum',...
    'FontWeight','bold',...
    'TitlePosition','centertop',...
    'ResizeFcn' , @hFlipPanelSpecResizeFcn,...
    'ForegroundColor','Blue',...
    'Units','Normalized',...
    'Position',[0.4,0.935,0.15,0.05]);
hTextFlipSpec=uicontrol(...
    'Parent',hFlipPanelSpec,...
    'Style','Text',...
    'Units','Normalized',...
      'horizontalalignment','left',...
    'String','/0',...
    'Position',[0.48 0.15 0.4 0.6 ]);
hEditFlipSpec=uicontrol(...
    'Parent',hFlipPanelSpec,...
    'Style','edit',...
    'Units','Normalized',...
    'BackgroundColor','w',...
    'String',1,...
    'Position',[0.3 0.2 0.15 0.7 ],...
    'CallBack', {@EditFlipSpec_Callback});
hButtonFlipPlusSpec = uicontrol(...
    'Parent',hFlipPanelSpec,...
    'Style','PushButton',...
    'String','+1',...
    'Units','normalized',...
    'TooltipString','Next spectrum in the array',...
    'Position',[0.75 0.2 0.15 0.7],...
    'Callback',{@ButtonFlipPlusSpec_Callback});
hButtonFlipMinusSpec = uicontrol(...
    'Parent',hFlipPanelSpec,...
    'Style','PushButton',...
    'String','-1',...
    'Units','normalized',...
    'TooltipString','Previous spectrum in the array',...
    'Position',[0.05 0.20 0.15 0.7],...
    'Callback',{@ButtonFlipMinusSpec_Callback});
%%  Panel for the phasing controls
hSliderPanel=uipanel(...
    'Parent',hMainFigure,...
    'Title','Phase Correction',...
    'FontWeight','bold',...
    'ForegroundColor','Blue',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.01,0.2,0.3,0.2]);
hPivotPanel=uipanel(...
    'Parent',hSliderPanel,...
    'Title','Pivot',...
    'FontWeight','bold',...
    'ForegroundColor','Black',...
    'TitlePosition','centertop',...
    'BorderType','None',...
    'Units','Normalized',...
    'Position',[0.4,0.65,0.2,0.35]);
hPivotButton = uicontrol(...
    'Parent',hPivotPanel,...
    'Style','PushButton',...
    'String','Set',...
    'Units','normalized',...
    'TooltipString','Set the pivot point',...
    'Position',[0.1 0.6 0.8 0.35],...
    'Callback',{@PivotButton_Callback});
hPivotCheck = uicontrol(...
    'Parent',hPivotPanel,...
    'Style','Checkbox',...
    'String','Show',...
    'Units','normalized',...
    'Position',[0.1 0.1 0.8 0.35],...
    'Callback',{@PivotCheck_Callback});
hScopeGroup = uibuttongroup(...
    'Parent',hSliderPanel,...
    'Units','normalized',...
    'Visible','On',...
    'Title','Scope',...
    'FontWeight','bold',...
    'TitlePosition','centertop',...
    'SelectionChangeFcn', {@GroupScope_Callback},...
    'Position',[0.3 0.05 0.4 0.4]);
hRadioScopeGlobal = uicontrol(...
    'Parent',hScopeGroup,...
    'Style','RadioButton',...
    'String','Global',...
    'Units','normalized',...
    'Position',[0.0 0.65 0.5 0.3]);
hRadioScopeIndividual = uicontrol(...
    'Parent',hScopeGroup,...
    'Style','RadioButton',...
    'String','Individual',...
    'Units','normalized',...
    'Position',[0.0 0.15 0.5 0.3]);
hPushCopyGtoI = uicontrol(...
    'Parent',hScopeGroup,...
    'Style','PushButton',...
    'String','G to I',...
    'Units','normalized',...
    'Position',[0.55 0.4 0.35 0.3],...
    'Callback',{@GtoIButton_Callback});
%   Zero order phasing
hPh0Panel=uipanel(...
    'Parent',hSliderPanel,...
    'Title','Zero order',...
    'FontWeight','bold',...
    'ForegroundColor','Black',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.0,0.5,0.4,0.5]);
hSliderPh0=uicontrol(...
    'Parent',hPh0Panel,...
    'Style','slider',...
    'Units','Normalized',...
    'Min' ,-360,'Max',360, ...
    'Position',[0.05,0.7,0.9,0.2], ...
    'Value', 0,...
    'SliderStep',[1/720 10/720], ...
    'CallBack', {@SliderPh0_Callback});
hEditPh0=uicontrol(...
    'Parent',hPh0Panel,...
    'Style','edit',...
    'BackgroundColor','w',...
    'Units','Normalized',...
    'Position',[0.4 0.4 0.2 0.2 ],...
    'CallBack', {@EditPh0_Callback});
hButtonPlusPh0 = uicontrol(...
    'Parent',hPh0Panel,...
    'Style','PushButton',...
    'String','+0.1',...
    'Units','normalized',...
    'Position',[0.52 0.05 0.2 0.2],...
    'Callback',{@ButtonPlusPh0_Callback});
hButtonMinusPh0 = uicontrol(...
    'Parent',hPh0Panel,...
    'Style','PushButton',...
    'String','-0.1',...
    'Units','normalized',...
    'Position',[0.28 0.05 0.2 0.2],...
    'Callback',{@ButtonMinusPh0_Callback});
hTextMaxPh0=uicontrol(...
    'Parent',hPh0Panel,...
    'Style','text',...
    'Units','Normalized',...
    'Position',[0.7 0.39 0.2 0.2 ],...
    'horizontalalignment','c');
hTextMinPh0=uicontrol(...
    'Parent',hPh0Panel,...
    'Style','text',...
    'Units','Normalized',...
    'Position',[0.1 0.39 0.2 0.2 ],...
    'horizontalalignment','c');

% First order phasing
hPh1Panel=uipanel(...
    'Parent',hSliderPanel,...
    'Title','First order',...
    'FontWeight','bold',...
    'ForegroundColor','Black',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.6,0.5,0.4,0.5]);
hSliderPh1=uicontrol(...
    'Parent',hPh1Panel,...
    'Style','slider',...
    'Units','Normalized',...
    'Min' ,-36000,'Max',36000, ...
    'Position',[0.05,0.7,0.9,0.2], ...
    'Value', 0,...
    'SliderStep',[1/7200 10/7200], ...
    'CallBack', {@SliderPh1_Callback});
hEditPh1=uicontrol(...
    'Parent',hPh1Panel,...
    'Style','edit',...
    'BackgroundColor','w',...
    'Units','Normalized',...
    'Position',[0.4 0.4 0.2 0.2 ],...
    'CallBack', {@EditPh1_Callback});
hButtonPlusPh1 = uicontrol(...
    'Parent',hPh1Panel,...
    'Style','PushButton',...
    'String','+0.1',...
    'Units','normalized',...
    'Position',[0.52 0.05 0.2 0.2],...
    'Callback',{@ButtonPlusPh1_Callback});
hButtonMinusPh1 = uicontrol(...
    'Parent',hPh1Panel,...
    'Style','PushButton',...
    'String','-0.1',...
    'Units','normalized',...
    'Position',[0.28 0.05 0.2 0.2],...
    'Callback',{@ButtonMinusPh1_Callback});
hTextMaxPh1=uicontrol(...
    'Parent',hPh1Panel,...
    'Style','text',...
    'Units','Normalized',...
    'Position',[0.7 0.39 0.3 0.2 ],...
    'horizontalalignment','c');
hTextMinPh1=uicontrol(...
    'Parent',hPh1Panel,...
    'Style','text',...
    'Units','Normalized',...
    'Position',[0.0 0.39 0.3 0.2 ],...
    'horizontalalignment','c');
hAutoButton = uicontrol(...
    'Parent',hSliderPanel,...
    'Style','PushButton',...
    'String','Auto',...
    'Enable','Off',...
    'Visible','Off',...
    'TooltipString','Automatic phase correction',...
    'Units','normalized',...
    'Position',[0.42 0.5 0.16 0.12],...
    'Callback',{@ButtonAutophase_Callback});
%%  Panel for Plot Control
hPlotPanel=uipanel(...
    'Parent',hMainFigure,...
    'Title','Plot Control',...
    'FontWeight','bold',...
    'ForegroundColor','Blue',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.01,0.01,0.3,0.2]);
hZoomPanel=uipanel(...
    'Parent',hPlotPanel,...
    'Title','Zoom/Pan',...
    'FontWeight','bold',...
    'ForegroundColor','Black',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.65,0.5,0.35,0.5]);
hpanXButton = uicontrol(...
    'Parent',hZoomPanel,...
    'Style','PushButton',...
    'String','X',...
    'Units','normalized',...
    'TooltipString','Interactive pan in the x-direction',...
    'Position',[0.0 0.5 0.25 0.45],...
    'Callback',@panXButton_Callback);
hpanXYButton = uicontrol(...
    'Parent',hZoomPanel,...
    'Style','PushButton',...
    'String','XY',...
    'Units','normalized',...
    'TooltipString','Interactive pan',...
    'Position',[0.0 0.05 0.25 0.45],...
    'Callback',@panXYButton_Callback);
hpanYButton = uicontrol(...
    'Parent',hZoomPanel,...
    'Style','PushButton',...
    'String','Y',...
    'Units','normalized',...
    'TooltipString','Interactive pan in the y-direction',...
    'Position',[0.25 0.5 0.25 0.45],...
    'Callback',@panYButton_Callback);
hpanOffButton = uicontrol(...
    'Parent',hZoomPanel,...
    'Style','PushButton',...
    'String','off',...
    'Units','normalized',...
    'TooltipString','Turn off the interactive pan',...
    'Position',[0.25 0.05 0.25 0.45],...
    'Callback',@panOffButton_Callback);
hZoomPanGroup = uibuttongroup(...
    'Parent',hZoomPanel,...
    'Units','normalized',...
    'Visible','On',...
    'Title','',...
    'Bordertype','none',...
    'FontWeight','bold',...
    'TitlePosition','centertop',...
    'SelectionChangeFcn', {@GroupZoomPan_Callback},...
    'Position',[0.5 0.0 0.5 1.0]);
hRadioZoom = uicontrol(...
    'Parent',hZoomPanGroup,...
    'Style','RadioButton',...
    'String','Zoom',...
    'Units','normalized',...
    'Position',[0.05 0.6 0.9 0.4]);
hRadioPan = uicontrol(...
    'Parent',hZoomPanGroup,...
    'Style','RadioButton',...
    'String','Pan',...
    'Units','normalized',...
    'Position',[0.05 0.1 0.9 0.4]);
hSeparatePlotPanel=uipanel(...
    'Parent',hPlotPanel,...
    'Title','Separate Plot',...
    'FontWeight','bold',...
    'ForegroundColor','Black',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.0,0.0,0.25,0.5]);
hButtonPlotCurrent = uicontrol(...
    'Parent',hSeparatePlotPanel,...
    'Style','PushButton',...
    'String','Plot',...
    'Units','Normalized',...
    'TooltipString','Plot the FID/Spectrum in a separate window',...
    'Position',[0.2 0.3 0.6 0.4],...
    'Callback',{@ButtonPlotCurrent_Callback});
hPlayFIDPanel=uipanel(...
    'Parent',hPlotPanel,...
    'Title','Play FID',...
    'FontWeight','bold',...
    'ForegroundColor','Black',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.25,0.0,0.25,0.5]);
hButtonPlayCurrentFid = uicontrol(...
    'Parent',hPlayFIDPanel,...
    'Style','PushButton',...
    'String','One',...
    'Units','Normalized',...
    'TooltipString','Listen to the displayed FID',...
    'Position',[0.2 0.5 0.6 0.4],...
    'Callback',{@ButtonPlayCurrentFid_Callback});
hButtonPlayAllFid = uicontrol(...
    'Parent',hPlayFIDPanel,...
    'Style','PushButton',...
    'String','All',...
    'Units','Normalized',...
    'TooltipString','Listen to the all the FIDs in the experiment',...
    'Position',[0.2 0.1 0.6 0.4],...
    'Callback',{@ButtonPlayAllFid_Callback});
hDisplayPanel=uipanel(...
    'Parent',hPlotPanel,...
    'Title','Display',...
    'FontWeight','bold',...
    'ForegroundColor','Black',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.35,0.5,0.3,0.5]);
hButtonFid = uicontrol(...
    'Parent',hDisplayPanel,...
    'Style','ToggleButton',...
    'String','Fid',...
    'Units','Normalized',...
    'TooltipString','Display the FID',...
    'Position',[0.0 0.5 0.35 0.45],...
    'Callback',{@ButtonFid_Callback});
hButtonSpec = uicontrol(...
    'Parent',hDisplayPanel,...
    'Style','ToggleButton',...
    'String','Spec',...
    'Units','Normalized',...
    'TooltipString','Display the spectrum',...
    'Position',[0.0 0.05 0.35 0.45],...
    'Callback', {@ButtonSpec_Callback});
hAbsPhaseGroup = uibuttongroup(...
    'Parent',hDisplayPanel,...
    'Units','normalized',...
    'Visible','On',...
    'Title','',...
    'Bordertype','none',...
    'FontWeight','bold',...
    'TitlePosition','centertop',...
    'SelectionChangeFcn', {@GroupAbsPhase_Callback},...
    'Position',[0.4 0.0 0.6 1.0]);
hRadioPhase = uicontrol(...
    'Parent',hAbsPhaseGroup,...
    'Style','RadioButton',...
    'String','Phase',...
    'Units','normalized',...
    'Position',[0.05 0.6 0.9 0.4]);
hRadioAbs = uicontrol(...
    'Parent',hAbsPhaseGroup,...
    'Style','RadioButton',...
    'String','Abs',...
    'Units','normalized',...
    'Position',[0.05 0.1 0.9 0.4]);
hScalePanel=uipanel(...
    'Parent',hPlotPanel,...
    'Title','Scale',...
    'FontWeight','bold',...
    'ForegroundColor','Black',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.0,0.5,0.35,0.5]);
hButtonMult2 = uicontrol(...
    'Parent',hScalePanel,...
    'Style','PushButton',...
    'String',[char(hex2dec('D7')) ' 2'],...
    'Units','Normalized',...
    'TooltipString','Increase the vertical scale by a factor 2',...
    'Position',[0.05 0.5 0.3 0.45],...
    'Callback',{@ButtonMult2_Callback});
hButtonDiv2 = uicontrol(...
    'Parent',hScalePanel,...
    'Style','PushButton',...
    'String',[char(hex2dec('F7')) ' 2'],...
    'Units','Normalized',...
    'TooltipString','Decrease the vertical scale by a factor 2',...
    'Position',[0.05 0.05 0.3 0.45],...
    'Callback',{@ButtonDiv2_Callback});
hButtonMult11 = uicontrol(...
    'Parent',hScalePanel,...
    'Style','PushButton',...
    'String',[char(hex2dec('D7')) ' 1.1'],...
    'Units','Normalized',...
    'Position',[0.35 0.5 0.3 0.45],...
    'TooltipString','Increase the vertical scale by a factor 1.1',...
    'Callback',{@ButtonMult11_Callback});
hButtonDiv11 = uicontrol(...
    'Parent',hScalePanel,...
    'Style','PushButton',...
    'String',[char(hex2dec('F7')) ' 1.1'],...
    'Units','Normalized',...
    'TooltipString','Decrease the vertical scale by a factor 1.1',...
    'Position',[0.35 0.05 0.3 0.45],...
    'Callback',{@ButtonDiv11_Callback});
hButtonAutoscale = uicontrol(...
    'Parent',hScalePanel,...
    'Style','Pushbutton',...
    'String','Auto',...
    'Units','Normalized',...
    'TooltipString','Automatic setting of the vertical scale',...
    'Position',[0.65 0.5 0.3 0.45],...
    'Callback',{@ButtonAutoscale_Callback});
hButtonFull = uicontrol(...
    'Parent',hScalePanel,...
    'Style','Pushbutton',...
    'String','Full',...
    'Units','Normalized',...
    'TooltipString','Display the whole FID/spectrum with autoscale',...
    'Position',[0.65 0.05 0.3 0.45],...
    'Callback',{@ButtonFull_Callback});
hViewPanel=uipanel(...
    'Parent',hPlotPanel,...
    'Title','View Mode',...
    'FontWeight','bold',...
    'ForegroundColor','Black',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.5,0.0,0.5,0.5]);
hButtonNormal = uicontrol(...
    'Parent',hViewPanel,...
    'Style','ToggleButton',...
    'String','Normal',...
    'Units','Normalized',...
    'Value',1,...
    'TooltipString','Normal plot area',...
    'Position',[0.0 0.5 0.3 0.4],...
    'Callback',{@ButtonNormal_Callback});
hButtonLarge = uicontrol(...
    'Parent',hViewPanel,...
    'Style','ToggleButton',...
    'String','Large',...
    'Units','Normalized',...
    'TooltipString','Large plot area',...
    'Position',[0.0 0.05 0.3 0.4],...
    'Callback', {@ButtonLarge_Callback});
hCheckPhase = uicontrol(...
    'Parent',hViewPanel,...
    'Style','Checkbox',...
    'String','Phase',...
    'Enable','Off',...
    'Units','normalized',...
    'Position',[0.35 0.5 0.3 0.45],...
    'Callback',{@CheckPhase_Callback});
hCheckArray = uicontrol(...
    'Parent',hViewPanel,...
    'Style','Checkbox',...
    'String','Array',...
    'Enable','Off',...
    'Units','normalized',...
    'Position',[0.35 0.05 0.3 0.45],...
    'Callback',{@CheckArray_Callback});
hCheckProcess = uicontrol(...
    'Parent',hViewPanel,...
    'Style','Checkbox',...
    'String','Proc',...
    'Enable','Off',...
    'Units','normalized',...
    'Position',[0.65 0.5 0.3 0.45],...
    'Callback',{@CheckProcess_Callback});
hCheckCorrect = uicontrol(...
    'Parent',hViewPanel,...
    'Style','Checkbox',...
    'String','Correct',...
    'Enable','Off',...
    'Units','normalized',...
    'Position',[0.65 0.05 0.3 0.45],...
    'Callback',{@CheckCorrect_Callback});
%%  Panel for Standard Processing
hProcessPanel=uipanel(...
    'Parent',hMainFigure,...
    'Title','Standard Processing',...
    'FontWeight','bold',...
    'TitlePosition','centertop',...
    'ForegroundColor','Blue',...
    'Units','Normalized',...
    'Position',[0.31,0.2,0.3,0.2]);
hFourierPanel=uipanel(...
    'Parent',hProcessPanel,...
    'Title','Fourier Transform',...
    'FontWeight','bold',...
    'ForegroundColor','Black',...
    'TitlePosition','centertop',...
    'Bordertype','none',...
    'Units','Normalized',...
    'Position',[0.0,0.7,1.0,0.3]);
hFTButton = uicontrol(...
    'Parent',hFourierPanel,...
    'Style','PushButton',...
    'String','FT',...
    'Units','normalized',...
    'TooltipString','Fourier transform the FID',...
    'Position',[0.05 0.2 0.15 0.6],...
    'Callback',{@FTButton_Callback});
hEditFn=uicontrol(...
    'Parent',hFourierPanel,...
    'Style','edit',...
    'Visible','On',...
    'BackgroundColor','w',...
    'Units','Normalized',...
    'TooltipString',...
    'Number of (complex) points used in the Fourier transform',...
    'Max',1,...
    'Position',[0.35 0.3 0.2 0.4 ],...
    'CallBack', {@EditFn_Callback});
hTextFn=uicontrol(...
    'Parent',hFourierPanel,...
    'Style','text',...
    'Units','Normalized',...
    'horizontalalignment','Left',...
    'FontWeight','bold',...
    'Position',[0.29 0.28 0.05 0.4 ],...
    'String','fn:' );
hFnButtonPlus = uicontrol(...
    'Parent',hFourierPanel,...
    'Style','PushButton',...
    'String','+',...
    'Units','normalized',...
    'TooltipString','Multiply current fn a factor 2',...
    'Position',[0.61 0.3 0.05 0.4],...
    'Callback',{@FnButtonPlus_Callback});
hFnButtonMinus = uicontrol(...
    'Parent',hFourierPanel,...
    'Style','PushButton',...
    'String','-',...
    'Units','normalized',...
    'TooltipString','Divide current fn a factor 2',...
    'Position',[0.56 0.3 0.05 0.4],...
    'Callback',{@FnButtonMinus_Callback});
hEditNp=uicontrol(...
    'Parent',hFourierPanel,...
    'Style','edit',...
    'Visible','On',...
    ...'BackgroundColor','g',...
    'Units','Normalized',...
    'Enable','Off',...
    'TooltipString','Number of (complex) points in the FID',...
    'Max',1,...
    'Position',[0.78 0.3 0.2 0.4 ],...
    'CallBack', {@EditNp_Callback});
hTextNp=uicontrol(...
    'Parent',hFourierPanel,...
    'Style','text',...
    'Units','Normalized',...
    'horizontalalignment','Left',...
    'FontWeight','bold',...
    'Position',[0.72 0.28 0.05 0.4 ],...
    'String','np:' );

hWindowFunctionPanel=uipanel(...
    'Parent',hProcessPanel,...
    'Title','Window function',...
    'FontWeight','bold',...
    'ForegroundColor','Black',...
    'BorderType','None',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.0 0.3 1.0 0.4]);
hEditLb=uicontrol(...
    'Parent',hWindowFunctionPanel,...
    'Style','edit',...
    'Visible','On',...
    'BackgroundColor','w',...
    'Units','Normalized',...
    'Enable','Off',...
    'TooltipString','Enter the line broadening function value',...
    'Max',1,...
    'Position',[0.05 0.2 0.05 0.3 ],...
    'CallBack', {@EditLb_Callback});
hCheckLb=uicontrol(...
    'Parent',hWindowFunctionPanel,...
    'Style','checkbox',...
    'Units','Normalized',...
    'Value',0,...
    'TooltipString','Use the line broadening function',...
    'Position',[0.11 0.275 0.05 0.2 ],...
    'CallBack', {@CheckLb_Callback} );
hTextLb=uicontrol(...
    'Parent',hWindowFunctionPanel,...
    'Style','text',...
    'Units','Normalized',...
    'FontWeight','bold',...
    'Horizontalalignment','left',...
    'Position',[0.025 0.6 0.2 0.3 ],...
    'String','Lorentzian' );
hEditGw=uicontrol(...
    'Parent',hWindowFunctionPanel,...
    'Style','edit',...
    'Visible','On',...
    'BackgroundColor','w',...
    'Units','Normalized',...
    'Enable','Off',...
    'TooltipString','Enter the gaussian function value',...
    'Max',1,...
    'Position',[0.25 0.20 0.05 0.3 ],...
    'CallBack', {@EditGw_Callback});
hTextGw=uicontrol(...
    'Parent',hWindowFunctionPanel,...
    'Style','text',...
    'Units','Normalized',...
    'FontWeight','bold',...
    'Horizontalalignment','left',...
    'Position',[0.22 0.6 0.2 0.3 ],...
    'String','Gaussian' );
hCheckGw=uicontrol(...
    'Parent',hWindowFunctionPanel,...
    'Style','checkbox',...
    'Units','Normalized',...
    'Value',0,...
    'TooltipString','Use the gaussian function',...
    'Position',[0.31 0.275 0.05 0.2 ],...
    'CallBack', {@CheckGw_Callback} );
hTextPlot=uicontrol(...
    'Parent',hWindowFunctionPanel,...
    'Style','text',...
    'Units','Normalized',...
    'String','Show in Plot',...
    'FontWeight','bold',...
    'Position',[0.60 0.6 0.3 0.3 ],...
    'horizontalalignment','c');
hPlotFID = uicontrol(...
    'Parent',hWindowFunctionPanel,...
    'Style','Checkbox',...
    'String','FID',...
    'Value',1,...
    'Enable','off',...
    'Units','normalized',...
    'Position',[0.6 0.4 0.2 0.25],...
    'Callback',{@PlotFID_Callback});
hPlotWinfunc = uicontrol(...
    'Parent',hWindowFunctionPanel,...
    'Style','Checkbox',...
    'String','WinFunc',...
    'Enable','off',...
    'Units','normalized',...
    'Position',[0.6 0.1 0.2 0.25],...
    'Callback',{@PlotWinfunc_Callback});
hPlotFIDWinfunc = uicontrol(...
    'Parent',hWindowFunctionPanel,...
    'Style','Checkbox',...
    'String','FID*WF',...
    'Enable','off',...
    'Units','normalized',...
    'Position',[0.75 0.4 0.2 0.25],...
    'Callback',{@PlotFIDWinfunc_Callback});


hReferencePanel=uipanel(...
    'Parent',hProcessPanel,...
    'Title','Reference',...
    'FontWeight','bold',...
    'ForegroundColor','Black',...
    'BorderType','None',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.0,0.1,1.0,0.2]);
hReferenceButton = uicontrol(...
    'Parent',hReferencePanel,...
    'Style','PushButton',...
    'String','Set',...
    'Units','normalized',...
    'TooltipString','Set the reference line',...
    'Position',[0.05 0.1 0.1 0.8],...
    'Callback',{@ReferenceButton_Callback});
hFindButton = uicontrol(...
    'Parent',hReferencePanel,...
    'Style','PushButton',...
    'String','Find',...
    'Units','normalized',...
    'TooltipString','Find the peak maximum',...
    'Position',[0.15 0.1 0.1 0.8],...
    'Callback',{@FindButton_Callback});
hChangeButton = uicontrol(...
    'Parent',hReferencePanel,...
    'Style','PushButton',...
    'String','Ref',...
    'Units','normalized',...
    'TooltipString','Apply the new reference value',...
    'Position',[0.5 0.1 0.1 0.8],...
    'Callback',{@ChangeButton_Callback});
hChangeEdit=uicontrol(...
    'Parent',hReferencePanel,...
    'Style','edit',...
    'Visible','On',...
    ...'BackgroundColor','g',...
    'Units','Normalized',...
    'TooltipString','Current reference value',...
    'Enable','Off',...
    'Max',1,...
    'Position',[0.62 0.1 0.1 0.8 ],...
    'CallBack', {@ChangeEdit_Callback});
hReferenceCheck = uicontrol(...
    'Parent',hReferencePanel,...
    'Style','CheckBox',...
    'String','Show',...
    'Units','normalized',...
    'TooltipString','Show the reference line',...
    'Position',[0.27 0.1 0.2 0.9],...
    'Callback',{@ReferenceCheck_Callback});
hShapeButton = uicontrol(...
    'Parent',hReferencePanel,...
    'Style','PushButton',...
    'String','Shape',...
    'Units','normalized',...
    'TooltipString','Check the lineshape',...
    'Position',[0.8 0.1 0.1 0.8],...
    'Callback',{@ShapeButton_Callback});
%%  Panel for Standard Correction
hCorrectionPanel=uipanel(...
    'Parent',hMainFigure,...
    'Title','Corrections',...
    'FontWeight','bold',...
    'TitlePosition','centertop',...
    'ForegroundColor','Blue',...
    'Units','Normalized',...
    'Position',[0.31,0.01,0.3,0.2]);
hTextBaseline=uicontrol(...
    'Parent',hCorrectionPanel,...
    'Style','text',...
    'Units','Normalized',...
    'FontWeight','bold',...
    'Position',[0.25 0.94 0.5 0.07 ],...
    'horizontalalignment','c',...
    'String','Baseline Correction' );
hBaselinePanel=uipanel(...
    'Parent',hCorrectionPanel,...
    'Units','Normalized',...
    'BorderType','None',...
    'Position',[0.0 0.74 1 0.2]);
hSetRegionsButton = uicontrol(...
    'Parent',hBaselinePanel,...
    'Style','PushButton',...
    'String','Set',...
    'Units','normalized',...
    'TooltipString','Mark the regions with signal',...
    'Position',[0.16 0.2 0.12 0.6],...
    'Callback',{@SetRegionsButton_Callback});
hAutoBaselineButton = uicontrol(...
    'Parent',hBaselinePanel,...
    'Style','PushButton',...
    'String','Auto',...
    'Units','normalized',...
    'TooltipString','Automatic baseline correction',...
    'Position',[0.03 0.2 0.12 0.6],...
    'Callback',{@AutoBaselineButton_Callback});
hClearRegionsButton = uicontrol(...
    'Parent',hBaselinePanel,...
    'Style','PushButton',...
    'String','Clear',...
    'Units','normalized',...
    'TooltipString','Clear the marked regions',...
    'Position',[0.28 0.2 0.12 0.6],...
    'Callback',{@ClearRegionsButton_Callback});
hBaselineCorrectButton = uicontrol(...
    'Parent',hBaselinePanel,...
    'Style','PushButton',...
    'String','Apply',...
    'Units','normalized',...
    'TooltipString','Apply baseline correction',...
    'Position',[0.4 0.2 0.12 0.6],...
    'Callback',{@BaselineCorrectButton_Callback});
hBaselineShow = uicontrol(...
    'Parent',hBaselinePanel,...
    'Style','Checkbox',...
    'String','Show',...
    'Units','normalized',...
    'TooltipString','Display the marked regions',...
    'Position',[0.53 0.2 0.2 0.6],...
    'Callback',{@BaselineShow_Callback});
hTextOrder=uicontrol(...
    'Parent',hBaselinePanel,...
    'Style','text',...
    'Units','Normalized',...
    'FontWeight','bold',...
    'horizontalalignment','l',...
    'Position',[0.7 0.2 0.17 0.5 ],...
    'String','order:' );
hEditOrder=uicontrol(...
    'Parent',hBaselinePanel,...
    'Style','edit',...
    'Visible','On',...
    'BackgroundColor','w',...
    'Units','Normalized',...
    'Enable','On',...
    'TooltipString','Enter polynomial order for baseline correction',...
    'Max',1,...
    'Position',[0.82 0.2 0.06 0.6 ],...
    'CallBack', {@EditOrder_Callback});
hOrderButtonPlus = uicontrol(...
    'Parent',hBaselinePanel,...
    'Style','PushButton',...
    'String','+',...
    'Units','normalized',...
    'TooltipString','Increase polynomial order for baseline correction',...
    'Position',[0.89 0.2 0.05 0.6],...
    'Callback',{@OrderButtonPlus_Callback});
hOrderButtonMinus = uicontrol(...
    'Parent',hBaselinePanel,...
    'Style','PushButton',...
    'String','-',...
    'Units','normalized',...
    'TooltipString','Decrease polynomial order for baseline correction',...
    'Position',[0.94 0.2 0.05 0.6],...
    'Callback',{@OrderButtonMinus_Callback});
hTextReferenceDeconvolution=uicontrol(...
    'Parent',hCorrectionPanel,...
    'Style','text',...
    'Units','Normalized',...
    'FontWeight','bold',...
    'Position',[0.2 0.62 0.6 0.1 ],...
    'horizontalalignment','c',...
    'String','Reference Deconvolution' );
hRDLimitsText = uicontrol(...
    'Parent',hCorrectionPanel,...
    'Style','Text',...
    'String','Limits',...
    'FontWeight','bold',...
    'Units','normalized',...
    'horizontalalignment','c',...
    'Position',[0 0.5 0.16 0.1]);
hRDshowLRCheck = uicontrol(...
    'Parent',hCorrectionPanel,...
    'Style','Checkbox',...
    'String','Show',...
    'Units','normalized',...
    'Value',0,...
    'TooltipString','Show the reference deconvolution lines',...
    'Position',[0.15 0.52 0.2 0.1],...
    'Callback',{@RDshowLRCheck_Callback});
hRDButtonLeft = uicontrol(...
    'Parent',hCorrectionPanel,...
    'Style','PushButton',...
    'String','Left',...
    'Units','normalized',...
    'TooltipString','Set left limit',...
    'Position',[0.02 0.4 0.12 0.1],...
    'Callback',{@RDButtonLeft_Callback});
hRDButtonRight = uicontrol(...
    'Parent',hCorrectionPanel,...
    'Style','PushButton',...
    'String','Right',...
    'Units','normalized',...
    'TooltipString','Set right limit',...
    'Position',[0.14 0.4 0.12 0.1],...
    'Callback',{@RDButtonRight_Callback});
hRDCentreText = uicontrol(...
    'Parent',hCorrectionPanel,...
    'Style','Text',...
    'String','Centre',...
    'FontWeight','bold',...
    'Units','normalized',...
    'horizontalalignment','c',...
    'Position',[0 0.25 0.16 0.1]);
hRDshowCheck = uicontrol(...
    'Parent',hCorrectionPanel,...
    'Style','Checkbox',...
    'String','Show',...
    'Units','normalized',...
    'Value',0,...
    'TooltipString','Show the reference deconolution lines',...
    'Position',[0.15 0.27 0.2 0.1],...
    'Callback',{@RDshowCheck_Callback});
hRDButtonSet = uicontrol(...
    'Parent',hCorrectionPanel,...
    'Style','PushButton',...
    'String','Set',...
    'Units','normalized',...
    'TooltipString','Set the center of the peak',...
    'Position',[0.02 0.15 0.12 0.1],...
    'Callback',{@RDButtonCentre_Callback});
hRDButtonFind = uicontrol(...
    'Parent',hCorrectionPanel,...
    'Style','PushButton',...
    'String','Find',...
    'Units','normalized',...
    'TooltipString','Find the max of the closest peak',...
    'Position',[0.14 0.15 0.12 0.1],...
    'Callback',{@RDButtonFind_Callback});
hRDButtonDelta = uicontrol(...
    'Parent',hCorrectionPanel,...
    'Style','PushButton',...
    'String','Delta',...
    'Units','normalized',...
    'TooltipString','Set the center of the peak',...
    'Position',[0.02 0.02 0.12 0.1],...
    'Callback',{@RDButtonDelta_Callback});
hRDButtonFiddle = uicontrol(...
    'Parent',hCorrectionPanel,...
    'Style','PushButton',...
    'String','FIDDLE',...
    'Units','normalized',...
    'TooltipString','Apply the reference deconvolution',...
    'Position',[0.31 0.02 0.2 0.15],...
    'Callback',{@RDButtonFiddle_Callback});
hRDTargetText = uicontrol(...
    'Parent',hCorrectionPanel,...
    'Style','Text',...
    'String','Lineshape',...
    'FontWeight','bold',...
    'Units','normalized',...
    'horizontalalignment','c',...
    'Position',[0.28 0.5 0.30 0.1]);
hTextLbRD=uicontrol(...
    'Parent',hCorrectionPanel,...
    'Style','text',...
    'Units','Normalized',...
    'FontWeight','bold',...
    'Position',[0.3 0.4 0.06 0.1 ],...
    'String','Lw:' );
hEditLbRD=uicontrol(...
    'Parent',hCorrectionPanel,...
    'Style','edit',...
    'Visible','On',...
    'BackgroundColor','w',...
    'Units','Normalized',...
    'Enable','Off',...
    'TooltipString','Enter the lorentzian width (Hz)',...
    'Max',1,...
    'Position',[0.38 0.4 0.1 0.1 ],...
    'CallBack', {@EditLbRD_Callback});
hCheckLbRD=uicontrol(...
    'Parent',hCorrectionPanel,...
    'Style','checkbox',...
    'Units','Normalized',...
    'Value',0,...
    'TooltipString','Use the lorentzian function',...
    'Position',[0.5 0.4 0.05 0.1 ],...
    'CallBack', {@CheckLbRD_Callback} );
hTextGwRD=uicontrol(...
    'Parent',hCorrectionPanel,...
    'Style','text',...
    'Units','Normalized',...
    'FontWeight','bold',...
    'Position',[0.3 0.25 0.07 0.1 ],...
    'String','Gw:' );
hEditGwRD=uicontrol(...
    'Parent',hCorrectionPanel,...
    'Style','edit',...
    'Visible','On',...
    'BackgroundColor','w',...
    'Units','Normalized',...
    'Enable','Off',...
    'TooltipString','Enter the gaussian width (Hz)',...
    'Max',1,...
    'Position',[0.38 0.25 0.1 0.1 ],...
    'CallBack', {@EditGwRD_Callback});
hCheckGwRD=uicontrol(...
    'Parent',hCorrectionPanel,...
    'Style','checkbox',...
    'Units','Normalized',...
    'Value',0,...
    'Enable','on',...
    'TooltipString','Use the gaussian function',...
    'Position',[0.5 0.25 0.05 0.1 ],...
    'CallBack', {@CheckGwRD_Callback} );
% hTextPeakRD=uicontrol(...
%     'Parent',hCorrectionPanel,...
%     'Style','text',...
%     'Units','Normalized',...
%     'FontWeight','bold',...
%     'Position',[0.6 0.5 0.2 0.1 ],...
%     'String','Peak' );
hBGroupPeak=uibuttongroup(...
    'Parent',hCorrectionPanel,...
    'Visible','On',...
    'Title','Peak',...
    'FontWeight','bold',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.65 0.05 0.3 0.45 ]);
hRadio1Peak1 = uicontrol(...
    'Parent',hBGroupPeak,...
    'Style','RadioButton',...
    'String','Singlet',...
    'Units','normalized',...
    'Position',[0.05 0.7 0.9 0.3]);
hRadio2Peak2 = uicontrol(...
    'Parent',hBGroupPeak,...
    'Style','RadioButton',...
    'String','TSP',...
    'Units','normalized',...
    'Position',[0.05 0.4 0.9 0.3]);
hRadio2Peak3 = uicontrol(...
    'Parent',hBGroupPeak,...
    'Style','RadioButton',...
    'String','TMS',...
    'Units','normalized',...
    'Position',[0.05 0.1 0.9 0.3]);
%-----End of Panel for Corrections-----------------------------------------
%%  Panel for Advanced Processing
hAPPanel=uipanel(...
    'Parent',hMainFigure,...
    'Title','Advanced Processing',...
    'FontWeight','bold',...
    'TitlePosition','centertop',...
    'ForegroundColor','Blue',...
    'Units','Normalized',...
    'Position',[0.61,0.01,0.38,0.39]);
hAPBG=uibuttongroup(...
    'Parent',hAPPanel,...
    'Visible','On',...
    'BorderType','None',...
    'Units','Normalized',...
    'Position',[0.0 0.85 1.0 0.15 ]);
hDOSYButton = uicontrol(...
    'Parent',hAPBG,...
    'Style','PushButton',...
    'String','DOSY',...
    'Units','normalized',...
    'TooltipString','Controls for DOSY processing',...
    'Position',[0.05 0.51 0.18 0.4],...
    'Callback',@DOSYButton_Callback);
hDECRAButton = uicontrol(...
    'Parent',hAPBG,...
    'Style','PushButton',...
    'String','DECRA',...
    'Units','normalized',...
    'TooltipString','Controls for DECRA processing',...
    'Position',[0.23 0.51 0.18 0.4],...
    'Callback',@DECRAButton_Callback);
hMCRButton = uicontrol(...
    'Parent',hAPBG,...
    'Style','PushButton',...
    'String','MCR',...
    'Units','normalized',...
    'Position',[0.41 0.51 0.18 0.4],...
    'TooltipString','Controls for MCR processing',...
    'Callback',@MCRButton_Callback);
hSCOREButton = uicontrol(...
    'Parent',hAPBG,...
    'Style','PushButton',...
    'String','SCORE',...
    'Enable','On',...
    'Units','normalized',...
    'TooltipString','Controls for SCORE processing',...
    'Position',[0.59 0.51 0.18 0.4],...
    'Callback',@SCOREButton_Callback);
hLRDOSYButton = uicontrol(...
    'Parent',hAPBG,...
    'Style','PushButton',...
    'String','LOCODOSY',...
    'Enable','Off',...
    'Visible','Off',...
    'TooltipString','Controls for locodosy processing',...
    'Units','normalized',...
    'Position',[0.77 0.51 0.18 0.4],...
    'Callback',@LRDOSYButton_Callback);
hPARAFACButton = uicontrol(...
    'Parent',hAPBG,...
    'Style','PushButton',...
    'String','PARAFAC',...
    'Enable','Off',...
    'Visible','Off',...
    'TooltipString','Controls for PARAFAC processing',...
    'Units','normalized',...
    'Position',[0.05 0.1 0.18 0.4],...
    'Callback',@PARAFACButton_Callback);
hBINButton = uicontrol(...
    'Parent',hAPBG,...
    'Style','PushButton',...
    'String','BIN',...
    'Enable','Off',...
    'Visible','Off',...
    'TooltipString','(Metabol)omics related processing',...
    'Units','normalized',...
    'Position',[0.23 0.1 0.18 0.4],...
    'Callback',@BINButton_Callback);
hicoshiftButton = uicontrol(...
    'Parent',hAPBG,...
    'Style','PushButton',...
    'String','icoshift',...
    'Units','normalized',...
    'TooltipString','Use correlation shifting alingment',...
    'Position',[0.05 0.1 0.18 0.4],...
    'Callback',{@icoshiftButton_Callback});
hINTEGRALButton = uicontrol(...
    'Parent',hAPBG,...
    'Style','PushButton',...
    'String','INTEGRATE',...
    'Enable','Off',...
    'Visible','Off',...
    'TooltipString','Controls for INTEGRALS',...
    'Units','normalized',...
    'Position',[0.41 0.1 0.18 0.4],...
    'Callback',@INTEGRALButton_Callback);
hBaselineButton = uicontrol(...
    'Parent',hAPBG,...
    'Style','PushButton',...
    'String','Baseline',...
    'Enable','Off',...
    'Visible','Off',...
    'TooltipString','Controls for Baseileine Correction',...
    'Units','normalized',...
    'Position',[0.41 0.51 0.18 0.4],...
    'Callback',@BaselineButton_Callback);
hFDMRRTButton = uicontrol(...
    'Parent',hAPBG,...
    'Style','PushButton',...
    'String','FDM/RRT',...
    'Enable','On',...
    'Visible','On',...
    'TooltipString','Controls for FDM/RRT processing',...
    'Units','normalized',...
    'Position',[0.23 0.1 0.18 0.4],...
    'Callback',@FDMRRTButton_Callback);
hILTButton = uicontrol(...
    'Parent',hAPBG,...
    'Style','PushButton',...
    'String','ILT',...
    'Enable','On',...
    'Visible','On',...
    'TooltipString','Controls for ILT processing',...
    'Units','normalized',...
    'Position',[0.41 0.1 0.18 0.4],...
    'Callback',@ILTButton_Callback);
hICAButton = uicontrol(...
    'Parent',hAPBG,...
    'Style','PushButton',...
    'String','ICA',...
    'Enable','On',...
    'Visible','Off',...
    'TooltipString','Independent Component Analysis',...
    'Units','normalized',...
    'Position',[0.59 0.1 0.18 0.4],...
    'Callback',@ICAButton_Callback);
% hFilterButton = uicontrol(...
%     'Parent',hAPBG,...
%     'Style','PushButton',...
%     'String','Filter',...
%     'Enable','Off',...
%     'Visible','Off',...
%     'TooltipString','',...
%     'Units','normalized',...
%     'Position',[0.59 0.1 0.18 0.4],...
%     'Callback',@FilterButton_Callback);
hAnalyzeButton = uicontrol(...
    'Parent',hAPBG,...
    'Style','PushButton',...
    'String','Analyze',...
    'Enable','Off',...
    'Visible','Off',...
    'TooltipString','Various analyzis tools',...
    'Units','normalized',...
    'Position',[0.59 0.1 0.18 0.4],...
    'Callback',@AnalyzeButton_Callback);
hT1Button = uicontrol(...
    'Parent',hAPBG,...
    'Style','PushButton',...
    'String','T1/T2',...
    'Enable','Off',...
    'Visible','Off',...
    'TooltipString','Controls for T1/T2 processing',...
    'Units','normalized',...
    'Position',[0.77 0.51 0.18 0.4],...
    'Callback',@T1Button_Callback);
hMoreButton = uicontrol(...
    'Parent',hAPBG,...
    'Style','PushButton',...
    'String','More',...
    'Enable','Off',...
    'Visible','Off',...
    'Fontweight','bold',...
    ... 'BackgroundColor',[1 1 0.5],...
    'TooltipString','',...
    'Units','normalized',...
    'Position',[0.79 0.05 0.15 0.4],...
    'Callback',@MoreButton_Callback);
hPSButton = uicontrol(...
    'Parent',hAPBG,...
    'Style','PushButton',...
    'String','pure shift',...
    'Enable','Off',...
    'Visible','Off',...
    'Units','normalized',...
    'TooltipString','Controls for pure shift processing',...
    'Position',[0.05 0.51 0.18 0.4],...
    'Callback',@PSButton_Callback);
hSynthesiseButton = uicontrol(...
    'Parent',hAPBG,...
    'Style','PushButton',...
    'String','Synth. DOSY',...
    'Enable','On',...
    'Visible','Off',...
    'Units','normalized',...
    'TooltipString','Synthesise a DOSY dataset',...
    'Position',[0.23 0.51 0.18 0.4],...
    'Callback',@SynthesiseButton_Callback);
hTestingButton = uicontrol(...
    'Parent',hAPBG,...
    'Style','PushButton',...
    'String','Testing',...
    'Enable','On',...
    'Visible','Off',...
    'Units','normalized',...
    'TooltipString','Synthesise a DOSY dataset',...
    'Position',[0.23 0.51 0.18 0.4],...
    'Callback',@TestingButton_Callback);
%set preferences for local version
    hRSCOREButton = uicontrol(...
    'Parent',hAPBG,...
    'Style','PushButton',...
    'String','RSCORE',...
    'Units','normalized',...
    'Visible','Off',...
    'Position',[0.59 0.51 0.18 0.4],...
    'TooltipString','Controls for RSCORE processing',...
    'Callback',@RSCOREButton_Callback);
    hROLSYButton = uicontrol(...
    'Parent',hAPBG,...
    'Style','PushButton',...
    'String','ROLSY',...
    'Units','normalized',...
    'Visible','Off',...
    'Position',[0.41 0.51 0.18 0.4],...
    'TooltipString','Controls for ROLSY processing',...
    'Callback',@ROLSYButton_Callback);
    hAlignButton = uicontrol(...
    'Parent',hAPBG,...
    'Style','PushButton',...
    'String','Align',...
    'Units','normalized',...
    'Visible','Off',...
    'Position',[0.59 0.51 0.18 0.4],...
    'TooltipString','Controls for aligning spectra',...
    'Callback',@AlignButton_Callback);

if strcmp(NmrData.local,'yes')
    set(hICAButton,'Visible','On')
 
end
%% ---------Common features

hThresholdButton = uicontrol(...
    'Style','ToggleButton',...
    'String','Thresh',...
    'Parent',hAPPanel,...
    'Visible','Off',...
    'Units','Normalized',...
    'TooltipString','Set threshold level',...
    'Position',[0.35 0.72 0.12 0.06],...
    'Callback',{@ThresholdButton_Callback});
hTextProcess=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','Off',...
    'FontWeight','bold',...
    'Position',[0.02 0.79 0.3 0.05 ],...
    'horizontalalignment','c',...
    'String','Process' );
hProcessButton = uicontrol(...
    'Parent',hAPPanel,...
    'Style','PushButton',...
    'Visible','Off',...
    'String','Run',...
    'Units','normalized',...
    'TooltipString','Process with curren parameters',...
    'Position',[0.02 0.72 0.15 0.06],...
    'Callback',@ProcessButton_Callback);
hReplotButton = uicontrol(...
    'Parent',hAPPanel,...
    'Style','PushButton',...
    'String','Replot',...
    'Visible','Off',...
    'Units','normalized',...
    'TooltipString','Replot the data from the last fit',...
    'Position',[0.17 0.72 0.15 0.06],...
    'Callback',@ReplotButton_Callback);
hExportButton = uicontrol(...
    'Parent',hAPPanel,...
    'Style','PushButton',...
    'Visible','Off',...
    'String','Export',...
    'Units','normalized',...
    'TooltipString','Export DOSY plot data to ASCII file',...
    'Position',[0.02 0.66 0.15 0.06],...
    'Callback',@ExportButton_Callback);
hPubplotButton = uicontrol(...
    'Parent',hAPPanel,...
    'Style','PushButton',...
    'String','Pubplot',...
    'Visible','Off',...
    'Enable','On',...
    'Units','normalized',...
    'TooltipString','Plot the data from the last fit in publication format',...
    'Position',[0.32 0.72 0.15 0.06],...
    'Callback',@PubplotButton_Callback);
hTextExclude=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','Off',...
    'FontWeight','bold',...
    'Position',[0.55 0.79 0.3 0.05 ],...
    'horizontalalignment','c',...
    'String','Exclude Regions' );
hExcludeShow = uicontrol(...
    'Parent',hAPPanel,...
    'Style','Checkbox',...
    'String','Use',...
    'Visible','Off',...
    'Units','normalized',...
    'Position',[0.8 0.72 0.15 0.06],...
    'Callback',{@ExcludeShow_Callback});
hClearExcludeButton = uicontrol(...
    'Parent',hAPPanel,...
    'Style','PushButton',...
    'String','Clear',...
    'Visible','Off',...
    'Units','normalized',...
    'TooltipString','Clear the marked regions',...
    'Position',[0.65 0.72 0.15 0.06],...
    'Callback',{@ClearExcludeButton_Callback});
hSetExcludeButton = uicontrol(...
    'Parent',hAPPanel,...
    'Style','PushButton',...
    'Visible','Off',...
    'String','Set',...
    'Units','normalized',...
    'TooltipString','Mark the regions to exclude from analysis',...
    'Position',[0.5 0.72 0.15 0.06],...
    'Callback',{@SetExcludeButton_Callback});
hEditNcomp=uicontrol(...
    'Parent',hAPPanel,...
    'Style','edit',...
    'Visible','Off',...
    'BackgroundColor','w',...
    'TooltipString',...
    'Number of components to search for in the mixture spectrum',...
    'Units','Normalized',...
    'Position',[0.13 0.58 0.07 0.05 ],...
    'CallBack', {@EditNcomp_Callback});
hTextNcomp=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Visible','Off',...
    'String','N.Free:',...
    'FontWeight','bold',...
    'TooltipString',...
    'Number of (estimated) components in the mixture spectrum',...
    'Units','Normalized',...
    'Position',[0.02 0.58 0.1 0.05 ],...
    'horizontalalignment','c');
hEditNgrad=uicontrol(...
    'Parent',hAPPanel,...
    'Style','edit',...
    'Visible','Off',...
    'BackgroundColor','w',...
    'TooltipString',...
    'List (space separated) gradient levels to exclude from analysis',...
    'Units','Normalized',...
    'Position',[0.34 0.58 0.15 0.05 ],...
    'CallBack', {@EditNgrad_Callback});
hTextNgrad=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Visible','Off',...
    'String','Prune:',...
    'TooltipString',...
    'List (space separated) gradient levels to exclude from analysis',...
    'FontWeight','bold',...
    'Units','Normalized',...
    'Position',[0.22 0.58 0.11 0.05 ],...
    'horizontalalignment','c');
hNgradUse = uicontrol(...
    'Parent',hAPPanel,...
    'Style','Checkbox',...
    'String','Use',...
    'Visible','Off',...
    'TooltipString','Turn on/off pruning',...
    'Units','normalized',...
    'Position',[0.5 0.58 0.15 0.06],...
    'Callback',{@NgradUse_Callback});
hAutoInclude=uicontrol(...
    'Parent',hAPPanel,...
    'Style','pushbutton',...
    'Visible','Off',...
    'String','Auto',...
    'Units','Normalized',...
    'TooltipString','Automatically select processing windows',...
    'Position',[0.50 0.65 0.15 0.06 ],...
    'CallBack', @fpeakclusters);
hBigplotButton = uicontrol(...
    'Parent',hAPPanel,...
    'Style','PushButton',...
    'String','Bigplot',...
    'Visible','Off',...
    'Enable','On',...
    'Units','normalized',...
    'TooltipString','Plot the data from the last fit in publication format',...
    'Position',[0.32 0.66 0.15 0.06],...
    'Callback',@BigplotButton_Callback);
% hBGroupResid=uibuttongroup(...
%     'Parent',hAPPanel,...
%     'Title','Display',...
%     'Visible','On',...
%     'TitlePosition','centertop',...
%     'Units','Normalized',...
%     'Position',[0.665 0.35 0.3 0.3 ]);
% hRadioResidSpec = uicontrol(...
%     'Parent',hBGroupResid,...
%     'Style','RadioButton',...
%     'String','Spectra',...
%     'Units','normalized',...
%     'Position',[0.05 0.7 0.9 0.2]);
% hRadioResidComp = uicontrol(...
%     'Parent',hBGroupResid,...
%     'Style','RadioButton',...
%     'String','Components',...
%     'Units','normalized',...
%     'Position',[0.05 0.4 0.9 0.3]);
% hRadioResidResid = uicontrol(...
%     'Parent',hBGroupResid,...
%     'Style','RadioButton',...
%     'String','Residuals',...
%     'Units','normalized',...
%     'Position',[0.05 0.1 0.9 0.3]);
%% ---------DOSY
hBGroupDOSYOpt1=uibuttongroup(...
    'Parent',hAPPanel,...
    'Title','Peak Pick',...
    'Visible','Off',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.045 0.35 0.3 0.2 ]);
hRadio1DOSYOpt1 = uicontrol(...
    'Parent',hBGroupDOSYOpt1,...
    'Style','RadioButton',...
    'String','Peak Pick',...
    'Units','normalized',...
    'Position',[0.05 0.7 0.9 0.3]);
hRadio2DOSYOpt1 = uicontrol(...
    'Parent',hBGroupDOSYOpt1,...
    'Style','RadioButton',...
    'String','All Frq',...
    'Units','normalized',...
    'Position',[0.05 0.3 0.9 0.3]);
hBGroupDOSYOpt2=uibuttongroup(...
    'Parent',hAPPanel,...
    'Visible','Off',...
    'Title','Fit Equation',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.355 0.35 0.3 0.2 ]);
hRadio1DOSYOpt2 = uicontrol(...
    'Parent',hBGroupDOSYOpt2,...
    'Style','RadioButton',...
    'String','Exp',...
    'Units','normalized',...
    'Position',[0.05 0.7 0.9 0.3]);
hRadio2DOSYOpt2 = uicontrol(...
    'Parent',hBGroupDOSYOpt2,...
    'Style','RadioButton',...
    'String','NUG',...
    'Units','normalized',...
    'Position',[0.05 0.3 0.9 0.3]);
hBGroupDOSYOpt3=uibuttongroup(...
    'Parent',hAPPanel,...
    'Visible','Off',...
    'Title','Fit Type',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.665 0.35 0.3 0.2 ],...
    'SelectionChangeFcn', {@FitType_Callback});
hRadio1DOSYOpt3 = uicontrol(...
    'Parent',hBGroupDOSYOpt3,...
    'Style','RadioButton',...
    'String','Monoexp',...
    'Units','normalized',...
    'Position',[0.05 0.7 0.9 0.3]);
hRadio2DOSYOpt3 = uicontrol(...
    'Parent',hBGroupDOSYOpt3,...
    'Style','RadioButton',...
    'String','Multiexp',...
    'Units','normalized',...
    'Position',[0.05 0.3 0.9 0.3]);
hBMultiexpPanel=uipanel(...
    'Parent',hAPPanel,...
    'Visible','Off',...
    'Title','Multiexp',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.045 0.01 0.3 0.3 ]);
hEditMultexp=uicontrol(...
    'Parent',hBMultiexpPanel,...
    'Style','edit',...
    'Visible','On',...
    'Enable','Off',...
    'BackgroundColor','w',...
    'Units','Normalized',...
    'TooltipString','Max number of components per peak',...
    'Max',1,...
    'Position',[0.05 0.6 0.2 0.2 ],...
    'CallBack', {@EditMultexp_Callback});
hTextMultexp=uicontrol(...
    'Parent',hBMultiexpPanel,...
    'Style','text',...
    'Visible','On',...
    'String','Exponentials',...
    'Units','Normalized',...
    'Position',[0.35 0.57 0.55 0.2 ],...
    'horizontalalignment','l');
hEditTries=uicontrol(...
    'Parent',hBMultiexpPanel,...
    'Style','edit',...
    'Visible','On',...
    'Enable','Off',...
    'BackgroundColor','w',...
    'Units','Normalized',...
    'TooltipString','Number of randomised starting guesses per peak',...
    'Max',1,...
    'Position',[0.05 0.2 0.2 0.2 ],...
    'CallBack', {@EditTries_Callback});
hTextTries=uicontrol(...
    'Parent',hBMultiexpPanel,...
    'Style','text',...
    'Visible','On',...
    'String','Rand. repeats',...
    'Units','Normalized',...
    'Position',[0.35 0.17 0.55 0.2 ],...
    'horizontalalignment','l');
hBPlotPanel=uipanel(...
    'Parent',hAPPanel,...
    'Visible','Off',...
    'Title','DOSY Plot',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.35 0.01 0.3 0.3 ]);
hEditDmin=uicontrol(...
    'Parent',hBPlotPanel,...
    'Style','edit',...
    'Visible','On',...
    'BackgroundColor','w',...
    'Units','Normalized',...
    'TooltipString','Minimum value of diffusion coefficient displayed',...
    'Max',1,...
    'Position',[0.05 0.7 0.2 0.2 ],...
    'CallBack', {@EditDmin_Callback});
hTextDmin=uicontrol(...
    'Parent',hBPlotPanel,...
    'Style','text',...
    'Visible','On',...
    'String','Min',...
    'Units','Normalized',...
    'Position',[0.35 0.67 0.2 0.2 ],...
    'horizontalalignment','l');
hEditDmax=uicontrol(...
    'Parent',hBPlotPanel,...
    'Style','edit',...
    'Visible','On',...
    'Enable','Off',...
    'BackgroundColor','w',...
    'Units','Normalized',...
    'TooltipString','Maximum value of diffusion coefficient displayed',...
    'Max',1,...
    'Position',[0.05 0.4 0.2 0.2 ],...
    'CallBack', {@EditDmax_Callback});
hCheckDmax=uicontrol(...
    'Parent',hBPlotPanel,...
    'Style','checkbox',...
    'Visible','On',...
    'Enable','On',...
    'String','Auto',...
    'Units','Normalized',...
    'TooltipString','Automatically set D max',...
    'Value',1,...
    'Position',[0.6 0.42 0.35 0.15 ],...
    'CallBack', {@CheckDmax_Callback});
hTextDmax=uicontrol(...
    'Parent',hBPlotPanel,...
    'Style','text',...
    'Visible','On',...
    'String','Max',...
    'Units','Normalized',...
    'Position',[0.35 0.37 0.2 0.2 ],...
    'horizontalalignment','l');
hEditDres=uicontrol(...
    'Parent',hBPlotPanel,...
    'Style','edit',...
    'Visible','On',...
    'BackgroundColor','w',...
    'Units','Normalized',...
    'Max',1,...
    'TooltipString','Number of data points in the diffusion dimension',...
    'Position',[0.05 0.1 0.2 0.2 ],...
    'CallBack', {@EditDres_Callback});
hTextDres=uicontrol(...
    'Parent',hBPlotPanel,...
    'Style','text',...
    'Visible','On',...
    'String','Digitization',...
    'Units','Normalized',...
    'Position',[0.35 0.07 0.5 0.2 ],...
    'horizontalalignment','l');
%% ---------SCORE
hBGroupSCOREOpt1=uibuttongroup(...
    'Parent',hAPPanel,...
    'Title','Fitting function',...
    'Visible','Off',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.68 0.5 0.3 0.2 ]);
hRadio1SCOREOpt1 = uicontrol(...
    'Parent',hBGroupSCOREOpt1,...
    'Style','RadioButton',...
    'String','Exp',...
    'Units','normalized',...
    'Position',[0.05 0.7 0.9 0.3]);
hRadio2SCOREOpt1 = uicontrol(...
    'Parent',hBGroupSCOREOpt1,...
    'Style','RadioButton',...
    'String','Nug',...
    'Units','normalized',...
    'Position',[0.05 0.3 0.9 0.3]);
hBGroupSCOREOpt2=uibuttongroup(...
    'Visible','Off',...
    'Parent',hAPPanel,...
    'Title','D guess',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.68 0.29 0.3 0.2 ]);
hRadio1SCOREOpt2 = uicontrol(...
    'Parent',hBGroupSCOREOpt2,...
    'Style','RadioButton',...
    'String','Fit',...
    'Units','normalized',...
    'Position',[0.05 0.7 0.9 0.3]);
hRadio2SCOREOpt2 = uicontrol(...
    'Parent',hBGroupSCOREOpt2,...
    'Style','RadioButton',...
    'String','Random',...
    'Units','normalized',...
    'Position',[0.05 0.3 0.9 0.3]);
hBGroupSCOREOpt3=uibuttongroup(...
    'Parent',hAPPanel,...
    'Visible','Off',...
    'Title','Constraint',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.68 0.01 0.3 0.27]);
hRadio1SCOREOpt3 = uicontrol(...
    'Parent',hBGroupSCOREOpt3,...
    'Style','RadioButton',...
    'String','none',...
    'Units','normalized',...
    'Position',[0.05 0.8 0.9 0.2]);
hRadio2SCOREOpt3 = uicontrol(...
    'Parent',hBGroupSCOREOpt3,...
    'Style','RadioButton',...
    'String','nneg',...
    'Units','normalized',...
    'Position',[0.05 0.5 0.9 0.2]);
hRadio4SCOREOpt3 = uicontrol(...
    'Parent',hBGroupSCOREOpt3,...
    'Style','RadioButton',...
    'Visible','Off',...
    'String','D. coeff.',...
    'Units','normalized',...
    'Position',[0.05 0.2 0.9 0.2]);
hBGroupSCOREOpt6=uibuttongroup(...
    'Parent',hAPPanel,...
    'Visible','Off',...
    'Title','Algorithm',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.35 0.01 0.3 0.27]);
hRadio1SCOREOpt6 = uicontrol(...
    'Parent',hBGroupSCOREOpt6,...
    'Style','RadioButton',...
    'String','SCORE',...
    'Units','normalized',...
    'Position',[0.05 0.8 0.9 0.2]);
hRadio2SCOREOpt6 = uicontrol(...
    'Parent',hBGroupSCOREOpt6,...
    'Style','RadioButton',...
    'String','OUTSCORE',...
    'Units','normalized',...
    'Position',[0.05 0.5 0.9 0.2]);
% Fixed values for SCORE %AC
hTableFixPeaks=uitable(...
    'parent',hAPPanel,...
    'units','normalized',...
    'columneditable',[true true],...
    'columnname',{'D','Use'},...
    'columnformat',{'numeric','logical'},...
    'columnwidth',{40,40},...
    'rowname',{'numbered'},...
    'position',[0.02 0.01 0.32 0.48],...
    'Data',[],...
    'Visible','Off');
hUseSynthDsButton=uicontrol(...
    'Parent',hAPPanel,...
    'Style','PushButton',...
    'Units','Normalized',...
    'Visible','Off',...
    'TooltipString','Import Dvals from Synthetic Data.',...
    'Position',[0.35 0.43 0.2 0.06],...
    'String','Use Synth.Fixed',...
    'CallBack', {@UseSynthDsButton_Callback});
hTextnfix=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','Off',...
    'FontWeight','bold',...
    'Position',[0.02 0.5 0.1 0.05 ],...
    'horizontalalignment','c',...
    'String','N.Fixed:' );
hEditnfix=uicontrol(...
    'Parent',hAPPanel,...
    'Style','edit',...
    'Visible','Off',...
    'BackgroundColor','w',...
    'enable','off',...
    'Units','Normalized',...
    'TooltipString','The number of fixed components to be used.',...
    'Position',[0.13 0.505 0.07 0.05]);
% crosstalk minimisation gui
hTextXtalk=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','Off',...
    'Position',[0.35 0.365 0.2 0.05 ],...
    'horizontalalignment','c',...
    'String','Cross-Talk Gui:' );
hXtalkShow = uicontrol(...
    'Parent',hAPPanel,...
    'Style','Checkbox',...
    'Visible','Off',...
    'Units','normalized',...
    'Position',[0.55 0.37 0.05 0.05],...
    'Callback',{@ExcludeShow_Callback});
%% ---------MCR
hBGroupMCROpt1=uibuttongroup(...
    'Parent',hAPPanel,...
    'Title','Init Guess',...
    'Visible','Off',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.045 0.35 0.3 0.2 ]);
hRadio1MCROpt1 = uicontrol(...
    'Parent',hBGroupMCROpt1,...
    'Style','RadioButton',...
    'String','Decay',...
    'Units','normalized',...
    'Position',[0.05 0.7 0.9 0.2]);
hRadio2MCROpt1 = uicontrol(...
    'Parent',hBGroupMCROpt1,...
    'Style','RadioButton',...
    'String','Spec',...
    'Units','normalized',...
    'Position',[0.05 0.3 0.9 0.2]);
hBGroupMCROpt2=uibuttongroup(...
    'Parent',hAPPanel,...
    'Visible','Off',...
    'Title','Init Method',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.355 0.35 0.3 0.2 ]);
hRadio1MCROpt2 = uicontrol(...
    'Parent',hBGroupMCROpt2,...
    'Style','RadioButton',...
    'String','DECRA',...
    'Units','normalized',...
    'Position',[0.05 0.7 0.9 0.2]);
hRadio2MCROpt2 = uicontrol(...
    'Parent',hBGroupMCROpt2,...
    'Style','RadioButton',...
    'String','Varimax',...
    'Units','normalized',...
    'Position',[0.05 0.3 0.9 0.2]);
hBGroupMCROpt3=uibuttongroup(...
    'Visible','Off',...
    'Parent',hAPPanel,...
    'Title','Dec constr',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.05 0.01 0.3 0.3 ]);
hRadio1MCROpt3 = uicontrol(...
    'Parent',hBGroupMCROpt3,...
    'Style','RadioButton',...
    'String','none',...
    'Units','normalized',...
    'Position',[0.05 0.8 0.9 0.2]);
hRadio2MCROpt3 = uicontrol(...
    'Parent',hBGroupMCROpt3,...
    'Style','RadioButton',...
    'String','nneg',...
    'Units','normalized',...
    'Position',[0.045 0.5 0.9 0.2]);
hBGroupMCROpt4=uibuttongroup(...
    'Parent',hAPPanel,...
    'Title','Spec constr',...
    'Visible','Off',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.355 0.01 0.3 0.3 ]);
hRadio1MCROpt4 = uicontrol(...
    'Parent',hBGroupMCROpt4,...
    'Style','RadioButton',...
    'String','none',...
    'Units','normalized',...
    'Position',[0.05 0.8 0.9 0.2]);
hRadio2MCROpt4 = uicontrol(...
    'Parent',hBGroupMCROpt4,...
    'Style','RadioButton',...
    'String','nneg',...
    'Units','normalized',...
    'Position',[0.05 0.5 0.9 0.2]);
hBGroupMCROpt5=uibuttongroup(...
    'Parent',hAPPanel,...
    'Visible','Off',...
    'Title','Force Decay',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.655 0.01 0.3 0.3 ]);
hRadio1MCROpt5 = uicontrol(...
    'Parent',hBGroupMCROpt5,...
    'Style','RadioButton',...
    'String','none',...
    'Units','normalized',...
    'Position',[0.05 0.8 0.9 0.2]);
hRadio2MCROpt5 = uicontrol(...
    'Parent',hBGroupMCROpt5,...
    'Style','RadioButton',...
    'String','exp',...
    'Units','normalized',...
    'Position',[0.05 0.5 0.9 0.2]);
hRadio3MCROpt5 = uicontrol(...
    'Parent',hBGroupMCROpt5,...
    'Style','RadioButton',...
    'String','NUG',...
    'Units','normalized',...
    'Position',[0.05 0.2 0.9 0.2]);
%% ---------locodosy
hBGrouplocodosyOpt1=uibuttongroup(...
    'Parent',hAPPanel,...
    'Title','Fit func',...
    'Visible','Off',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.045 0.15 0.15 0.2 ]);
hRadio1locodosyOpt1 = uicontrol(...
    'Parent',hBGrouplocodosyOpt1,...
    'Style','RadioButton',...
    'String','Exp',...
    'Units','normalized',...
    'Position',[0.05 0.7 0.9 0.3]);
hRadio2locodosyOpt1 = uicontrol(...
    'Parent',hBGrouplocodosyOpt1,...
    'Style','RadioButton',...
    'String','Nug',...
    'Units','normalized',...
    'Position',[0.05 0.3 0.9 0.3]);
hBGrouplocodosyalg=uibuttongroup(...
    'Parent',hAPPanel,...
    'Title','Method',...
    'Visible','Off',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.21 0.15 0.15 0.2 ],...
    'SelectionChangeFcn',@LRAlgorithmChange_Callback);
hRadio1locodosyalg = uicontrol(...
    'Parent',hBGrouplocodosyalg,...
    'Style','RadioButton',...
    'String','SCORE',...
    'Units','normalized',...
    'Position',[0.05 0.7 0.9 0.3 ]);
hRadio2locodosyalg = uicontrol(...
    'Parent',hBGrouplocodosyalg,...
    'Style','RadioButton',...
    'String','DECRA',...
    'Units','normalized',...
    'Position',[0.05 0.4 0.9 0.3]);
hRadio3locodosyalg = uicontrol(...
    'Parent',hBGrouplocodosyalg,...
    'Style','RadioButton',...
    'String','PARAFAC',...
    'Units','normalized',...
    'Position',[0.05 0.1 0.9 0.3]);
hBGroupRunType=uibuttongroup(...
    'Parent',hAPPanel,...
    'Title','Processing Approach',...
    'Visible','Off',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.045 0.35 0.32 0.2 ]);
hRadio2RunType = uicontrol(...
    'Parent',hBGroupRunType,...
    'Style','RadioButton',...
    'String','Automatic',...
    'TooltipString','Automatically determine number of components & process',...
    'Units','normalized',...
    'Position',[0.05 0.3 0.9 0.3]);
hRadio1RunType = uicontrol(...
    'Parent',hBGroupRunType,...
    'Style','RadioButton',...
    'String','Manual',...
    'TooltipString','Process with current parameters, manually change N.Comp. table',...
    'Units','normalized',...
    'Position',[0.05 0.7 0.9 0.3]);
hLRInclude=uicontrol(...
    'Parent',hAPPanel,...
    'Style','pushbutton',...
    'Visible','Off',...
    'String','Manual',...
    'Units','Normalized',...
    'TooltipString','Manually select processing windows',...
    'Position',[0.50 0.72 0.15 0.06 ],...
    'CallBack', {@LRInclude_Callback});
hLRClear=uicontrol(...
    'Parent',hAPPanel,...
    'Style','pushbutton',...
    'Visible','Off',...
    'String','Clear',...
    'Units','Normalized',...
    'Position',[0.65 0.72 0.15 0.06 ],...
    'CallBack', {@LRClear_Callback});
hLRWindowsShow = uicontrol(...
    'Parent',hAPPanel,...
    'Style','Checkbox',...
    'String','Show',...
    'Visible','Off',...
    'Units','normalized',...
    'TooltipString','Display the marked regions',...
    'Position',[0.82 0.72 0.15 0.06],...
    'Callback',{@LRWindowsShow_Callback});
hTextSelect=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','Off',...
    'FontWeight','bold',...
    'Position',[0.4 0.79 0.5 0.05 ],...
    'horizontalalignment','c',...
    'String','Segment the Spectrum' );
hTextsderrmultiplier=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Visible','Off',...
    'String','Err. Mult:',...
    'FontWeight','bold',...
    'Units','Normalized',...
    'Position',[0.37 0.41 0.15 0.05 ],...
    'horizontalalignment','l');
hEditsderrmultiplier=uicontrol(...
    'Parent',hAPPanel,...
    'Style','edit',...
    'Visible','Off',...
    'BackgroundColor','w',...
    'Units','Normalized',...
    'TooltipString','Clustering fuzziness factor',...
    'Position',[0.54 0.41 0.14 0.05 ]);
hTextDlimit=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','Off',...
    'FontWeight','bold',...
    'Position',[0.37 0.47 0.15 0.05 ],...
    'horizontalalignment','l',...
    'String','Diff. Limit:' );
hEditDlimit=uicontrol(...
    'Parent',hAPPanel,...
    'Style','edit',...
    'Visible','Off',...
    'BackgroundColor','w',...
    'Units','Normalized',...
    'TooltipString','The upper limit to D before a component is dismissed',...
    'Position',[0.54 0.47 0.14 0.05 ]);
hTextVlimit=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','Off',...
    'FontWeight','bold',...
    'Position',[0.37 0.35 0.15 0.05 ],...
    'horizontalalignment','l',...
    'String','Min %:' );
hEditVlimit=uicontrol(...
    'Parent',hAPPanel,...
    'Style','edit',...
    'Visible','Off',...
    'BackgroundColor','w',...
    'Units','Normalized',...
    'TooltipString','The minimum % of a window a component can represent',...
    'Position',[0.54 0.35 0.14 0.05 ]);
hTextSVDcutoff=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','Off',...
    'FontWeight','bold',...
    'Position',[0.37 0.29 0.15 0.05 ],...
    'horizontalalignment','l',...
    'String','SVD lim:' );
hEditSVDcutoff=uicontrol(...
    'Parent',hAPPanel,...
    'Style','edit',...
    'Visible','Off',...
    'BackgroundColor','w',...
    'Units','Normalized',...
    'TooltipString','The required amount of variance explained by SVD components',...
    'Position',[0.54 0.29 0.14 0.05 ]);
hTextDiffRes=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','Off',...
    'FontWeight','bold',...
    'Position',[0.37 0.23 0.15 0.05 ],...
    'horizontalalignment','l',...
    'String','D. Res.:' );
hEditDiffRes=uicontrol(...
    'Parent',hAPPanel,...
    'Style','edit',...
    'Visible','Off',...
    'BackgroundColor','w',...
    'Units','Normalized',...
    'TooltipString','The number of points plotted in the diffusion domain',...
    'Position',[0.54 0.23 0.14 0.05 ]);
hLRViewComponent=uicontrol(...
    'Parent',hAPPanel,...
    'Style','Pushbutton',...
    'Visible','Off',...
    'String','View Comp.',...
    'Units','Normalized',...
    'Position',[0.4 0.05 0.18 0.06],...
    'CallBack', {@LRViewComponent_Callback});
hDoSVDButton = uicontrol(...
    'Parent',hAPPanel,...
    'Style','PushButton',...
    'Visible','Off',...
    'String','Rank est',...
    'Units','normalized',...
    'TooltipString','Estimate the rank of each window',...
    'Position',[0.65 0.65 0.15 0.06],...
    'Callback',@LRDoSVDButton_Callback);
hSVDplotsShow = uicontrol(...
    'Parent',hAPPanel,...
    'Style','Checkbox',...
    'String','Plots',...
    'Visible','Off',...
    'Value',0,...
    'Units','normalized',...
    'Position',[0.82 0.65 0.15 0.06],...
    'Callback',{@ExcludeShow_Callback});
hRegionsTable=uitable(...
    'parent',hAPPanel,...
    'units','normalized',...
    'columneditable',true(1,100),...
    'columnname',{'N.Comp.'},...
    'columnformat',{[],'char'},...
    'rowname',{'numbered'},...
    'columnformat',{'numeric'},...
    'position',[0.69 0.02 0.3 0.6 ],...
    'Visible','Off',...
    'celleditcallback',@LRRegionsTable_Callback);
hTextmethodplots=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','Off',...
    'FontWeight','bold',...
    'Position',[0.37 0.17 0.2 0.05 ],...
    'horizontalalignment','l',...
    'String','Method plots' );
hLRmethodplots = uicontrol(...
    'Parent',hAPPanel,...
    'Style','Checkbox',...
    'Visible','Off',...
    'Units','normalized',...
    'TooltipString','Display the processing results for each window',...
    'Position',[0.59 0.17 0.05 0.06]);
hTextUseClustering=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','Off',...
    'FontWeight','bold',...
    'Position',[0.37 0.11 0.2 0.05 ],...
    'horizontalalignment','l',...
    'String','Clustering' );
hUseClustering = uicontrol(...
    'Parent',hAPPanel,...
    'Style','Checkbox',...
    'Visible','Off',...
    'Units','normalized',...
    'TooltipString','Whether to use clustering or not after processing',...
    'Position',[0.59 0.11 0.05 0.06]);
%% ---------PARAFAC
hPanelPARAFACConstrain=uipanel(...
    'Parent',hAPPanel,...
    'Title','Constrain',...
    'FontWeight','bold',...
    'Visible','Off',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.05 0.05 0.4 0.4 ]);
hTextMode=uicontrol(...
    'Parent',hPanelPARAFACConstrain,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','On',...
    'FontWeight','normal',...
    'Position',[0.25 0.9 0.2 0.1 ],...
    'horizontalalignment','c',...
    'String','Mode' );
hTextModeNr1=uicontrol(...
    'Parent',hPanelPARAFACConstrain,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','On',...
    'FontWeight','normal',...
    'Position',[0.1 0.79 0.5 0.1 ],...
    'horizontalalignment','l',...
    'String',' 1' ); %#ok<*NASGU>
hTextModeNr2=uicontrol(...
    'Parent',hPanelPARAFACConstrain,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','On',...
    'FontWeight','normal',...
    'Position',[0.30 0.79 0.5 0.1 ],...
    'horizontalalignment','l',...
    'String',' 2' );
hTextModeNr3=uicontrol(...
    'Parent',hPanelPARAFACConstrain,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','On',...
    'FontWeight','normal',...
    'Position',[0.50 0.79 0.5 0.1 ],...
    'horizontalalignment','l',...
    'String',' 3' );
hGroupMode1=uibuttongroup(...
    'Parent',hPanelPARAFACConstrain,...
    'Title','',...
    'FontWeight','normal',...
    'Bordertype','none',...
    'Visible','On',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.05 0.0 0.2 0.8 ]);
hRadioConst1none = uicontrol(...
    'Parent',hGroupMode1,...
    'Style','RadioButton',...
    'String','',...
    'Units','normalized',...
    'Position',[0.25 0.8 0.5 0.2]);
hRadioConst1ortho = uicontrol(...
    'Parent',hGroupMode1,...
    'Style','RadioButton',...
    'String','',...
    'Units','normalized',...
    'Position',[0.25 0.55 0.5 0.2]);
hRadioConst1nneg = uicontrol(...
    'Parent',hGroupMode1,...
    'Style','RadioButton',...
    'String','',...
    'Units','normalized',...
    'Position',[0.25 0.3 0.5 0.2]);
hRadioConst1unimod = uicontrol(...
    'Parent',hGroupMode1,...
    'Style','RadioButton',...
    'String','',...
    'Units','normalized',...
    'Position',[0.25 0.05 0.5 0.2]);
hGroupMode2=uibuttongroup(...
    'Parent',hPanelPARAFACConstrain,...
    'Title','',...
    'FontWeight','normal',...
    'Bordertype','none',...
    'Visible','On',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.25 0.0 0.2 0.8 ]);
hRadioConst2none = uicontrol(...
    'Parent',hGroupMode2,...
    'Style','RadioButton',...
    'String','',...
    'Units','normalized',...
    'Position',[0.25 0.8 0.5 0.2]);
hRadioConst2ortho = uicontrol(...
    'Parent',hGroupMode2,...
    'Style','RadioButton',...
    'String','',...
    'Units','normalized',...
    'Position',[0.25 0.55 0.5 0.2]);
hRadioConst2nneg = uicontrol(...
    'Parent',hGroupMode2,...
    'Style','RadioButton',...
    'String','',...
    'Units','normalized',...
    'Position',[0.25 0.3 0.5 0.2]);
hRadioConst2unimod = uicontrol(...
    'Parent',hGroupMode2,...
    'Style','RadioButton',...
    'String','',...
    'Units','normalized',...
    'Position',[0.25 0.05 0.5 0.2]);
hGroupMode3=uibuttongroup(...
    'Parent',hPanelPARAFACConstrain,...
    'Title','',...
    'FontWeight','normal',...
    'Bordertype','none',...
    'Visible','On',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.45 0.0 0.55 0.8 ]);
hRadioConst3none = uicontrol(...
    'Parent',hGroupMode3,...
    'Style','RadioButton',...
    'String','  none',...
    'Units','normalized',...
    'Position',[0.1 0.8 0.9 0.2]);
hRadioConst3ortho = uicontrol(...
    'Parent',hGroupMode3,...
    'Style','RadioButton',...
    'String','  orthogonal',...
    'Units','normalized',...
    'Position',[0.1 0.55 0.9 0.2]);
hRadioConst3nneg = uicontrol(...
    'Parent',hGroupMode3,...
    'Style','RadioButton',...
    'String','  nonnegative',...
    'Units','normalized',...
    'Position',[0.1 0.3 0.9 0.2]);
hRadioConst3unimod = uicontrol(...
    'Parent',hGroupMode3,...
    'Style','RadioButton',...
    'String','  unimodal',...
    'Units','normalized',...
    'Position',[0.1 0.05 0.9 0.2]);
hEditArray2=uicontrol(...
    'Parent',hAPPanel,...
    'Style','edit',...
    'Visible','Off',...
    'BackgroundColor','w',...
    'TooltipString',...
    'List (space separated) gradient levels to exclude from analysis',...
    'Units','Normalized',...
    'Position',[0.34 0.48 0.15 0.05 ],...
    'CallBack', {@EditArray2_Callback});
hTextArray2=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Visible','Off',...
    'String','Array2:',...
    'TooltipString',...
    'List (space separated) levels to exclude from analysis',...
    'FontWeight','bold',...
    'Units','Normalized',...
    'Position',[0.22 0.48 0.11 0.05 ],...
    'horizontalalignment','c');
hArray2Use = uicontrol(...
    'Parent',hAPPanel,...
    'Style','Checkbox',...
    'String','Use',...
    'Visible','Off',...
    'TooltipString','Turn on/off pruning',...
    'Units','normalized',...
    'Position',[0.5 0.48 0.15 0.06]);
hSepPlotUse = uicontrol(...
    'Parent',hAPPanel,...
    'Style','Checkbox',...
    'String','Separate Plots',...
    'Visible','Off',...
    'TooltipString','Turn on/off inherent PARAFAC plots',...
    'Units','normalized',...
    'Position',[0.7 0.48 0.25 0.06]);
hAutoPlotUse = uicontrol(...
    'Parent',hAPPanel,...
    'Style','Checkbox',...
    'String','Auto Plots',...
    'Value',1,...
    'Visible','Off',...
    'TooltipString','Turn on/off component plots',...
    'Units','normalized',...
    'Position',[0.7 0.58 0.15 0.06]);

hTextPrune2=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Visible','Off',...
    'String','Prune data',...
    'FontWeight','bold',...
    'Units','Normalized',...
    'Position',[0.40 0.64 0.15 0.05 ],...
    'horizontalalignment','c');
hTextGrad=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Visible','Off',...
    'String','Grads:',...
    'TooltipString',...
    'List (space separated) gradient levels to exclude from analysis',...
    'FontWeight','bold',...
    'Units','Normalized',...
    'Position',[0.22 0.58 0.11 0.05 ],...
    'horizontalalignment','c');
%% ---------BIN
hPlotSpecButton = uicontrol(...
    'Parent',hAPPanel,...
    'Style','PushButton',...
    'Visible','Off',...
    'String','Spec',...
    'Units','normalized',...
    'TooltipString','Plot current spectrum',...
    'Position',[0.02 0.52 0.15 0.06],...
    'Callback',@PlotSpecButton_Callback);
hPlotBinnedButton = uicontrol(...
    'Parent',hAPPanel,...
    'Style','PushButton',...
    'Visible','Off',...
    'String','Binned',...
    'Units','normalized',...
    'TooltipString','Plot current binned spectrum',...
    'Position',[0.17 0.52 0.15 0.06],...
    'Callback',@PlotBinnedButton_Callback);
hEditBin=uicontrol(...
    'Parent',hAPPanel,...
    'Style','edit',...
    'Visible','Off',...
    'BackgroundColor','w',...
    'TooltipString',...
    'Bin size in ppm',...
    'Units','Normalized',...
    'Position',[0.23 0.38 0.07 0.05 ],...
    'CallBack', {@EditBin_Callback});
hTextBin=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Visible','Off',...
    'String','Bin size (ppm):',...
    'FontWeight','bold',...
    'TooltipString',...
    'Bin size in ppm',...
    'Units','Normalized',...
    'Position',[0.02 0.38 0.2 0.05 ],...
    'horizontalalignment','c');
%% ---------icoshift
hButtonICOAlign = uicontrol(...
    'Parent',hAPPanel,...
    'Style','PushButton',...
    'Visible','Off',...
    'String','Align',...
    'Units','normalized',...
    'TooltipString','Align spectra using icoshift',...
    'Position',[0.05 0.72 0.15 0.06],...
    'Callback',@ButtonICOAlign_Callback);
% hTextiCOSHIFT=uicontrol(...
%     'Parent',hAPPanel,...
%     'Style','text',...
%     'Visible','Off',...
%     'String','iCOSHIFT',...
%     'FontWeight','bold',...
%     'TooltipString',...
%     'Bin size in ppm',...
%     'Units','Normalized',...
%     'Position',[0.02 0.6 0.15 0.05 ],...
%     'horizontalalignment','c');

hBGroupIcoshiftMode=uibuttongroup(...
    'Parent',hAPPanel,...
    'Title','Alignment Mode',...
    'Visible','Off',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.05 0.38 0.3 0.25 ],...
    'SelectionChangeFcn', {@GroupIcoshiftMode_Callback});
hRadio1IcoshiftMode = uicontrol(...
    'Parent',hBGroupIcoshiftMode,...
    'Style','RadioButton',...
    'String','Interactive',...
    'Units','normalized',...
    'Position',[0.05 0.7 0.9 0.3]);
hRadio2IcoshiftMode = uicontrol(...
    'Parent',hBGroupIcoshiftMode,...
    'Style','RadioButton',...
    'String','Fixed Interval',...
    'Units','normalized',...
    'Position',[0.05 0.375 0.9 0.3]);
hRadio3IcoshiftMode = uicontrol(...
    'Parent',hBGroupIcoshiftMode,...
    'Style','RadioButton',...
    'String','Whole',...
    'Units','normalized',...
    'Position',[0.05 0.05 0.9 0.3]);
hEditIntervals=uicontrol(...
    'Parent',hAPPanel,...
    'Style','edit',...
    'Visible','Off',...
    'Enable','Off',...
    'BackgroundColor','w',...
    'TooltipString',...
    'Normalisation factor',...
    'String',100,...
    'Units','Normalized',...
    'Position',[0.05 0.2 0.1 0.08 ],...
    'CallBack', {@EditIntervals_Callback});
hTextIntervals=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','Off',...
    'FontWeight','bold',...
    'Position',[0.05 0.28 0.2 0.05 ],...
    'horizontalalignment','l',...
    'String','Intervals' );
hBGroupIcoshiftTarget=uibuttongroup(...
    'Parent',hAPPanel,...
    'Title','Target Vector',...
    'Visible','Off',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.55 0.3 0.3 0.33 ],...
    'SelectionChangeFcn', {@GroupIcoshiftTarget_Callback});
hRadio1IcoshiftTarget = uicontrol(...
    'Parent',hBGroupIcoshiftTarget,...
    'Style','RadioButton',...
    'String','Average',...
    'Units','normalized',...
    'Position',[0.05 0.75 0.9 0.3]);
hRadio2IcoshiftTarget = uicontrol(...
    'Parent',hBGroupIcoshiftTarget,...
    'Style','RadioButton',...
    'String','Median',...
    'Units','normalized',...
    'Position',[0.05 0.5 0.9 0.3]);
hRadio3IcoshiftTarget = uicontrol(...
    'Parent',hBGroupIcoshiftTarget,...
    'Style','RadioButton',...
    'String','Max',...
    'Units','normalized',...
    'Position',[0.05 0.25 0.9 0.3]);
hRadio4IcoshiftTarget = uicontrol(...
    'Parent',hBGroupIcoshiftTarget,...
    'Style','RadioButton',...
    'String','Average2',...
    'Units','normalized',...
    'Position',[0.05 0.0 0.9 0.3]);
%% ---------INTEGRAL
hTextNormalise=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','Off',...
    'FontWeight','bold',...
    'Position',[0.05 0.57 0.3 0.05 ],...
    'horizontalalignment','c',...
    'String','Normalise' );
hBGroupNormalise=uibuttongroup(...
    'Parent',hAPPanel,...
    'Title','',...
    'Visible','Off',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.05 0.3 0.3 0.25 ],...
    'SelectionChangeFcn', {@GroupNormalise_Callback});
hRadio1Normalise = uicontrol(...
    'Parent',hBGroupNormalise,...
    'Style','RadioButton',...
    'String','Peak',...
    'Units','normalized',...
    'Position',[0.05 0.7 0.9 0.3]);
hRadio2Normalise = uicontrol(...
    'Parent',hBGroupNormalise,...
    'Style','RadioButton',...
    'String','Total',...
    'Units','normalized',...
    'Position',[0.05 0.375 0.9 0.3]);
hRadio3Normalise = uicontrol(...
    'Parent',hBGroupNormalise,...
    'Style','RadioButton',...
    'String','Absolute',...
    'Units','normalized',...
    'Position',[0.05 0.05 0.9 0.3]);
hEditNorm=uicontrol(...
    'Parent',hAPPanel,...
    'Style','edit',...
    'Visible','Off',...
    'BackgroundColor','w',...
    'TooltipString',...
    'Normalisation factor',...
    'String',100,...
    'Units','Normalized',...
    'Position',[0.05 0.15 0.1 0.05 ],...
    'CallBack', {@EditNorm_Callback});
hTextNorm=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','Off',...
    'FontWeight','bold',...
    'Position',[0.05 0.2 0.1 0.05 ],...
    'horizontalalignment','l',...
    'String','Norm' );
hEditNormPeak=uicontrol(...
    'Parent',hAPPanel,...
    'Style','edit',...
    'Visible','Off',...
    'BackgroundColor','w',...
    'String',1,...
    'TooltipString',...
    'Normalise to peak number',...
    'Units','Normalized',...
    'Position',[0.2 0.15 0.07 0.05 ],...
    'CallBack', {@EditNormPeak_Callback});
hTextNormPeak=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','Off',...
    'FontWeight','bold',...
    'Position',[0.2 0.2 0.1 0.05 ],...
    'horizontalalignment','l',...
    'String','Peak nr' );
hSetIntegralButton = uicontrol(...
    'Parent',hAPPanel,...
    'Style','PushButton',...
    'Visible','Off',...
    'String','Set',...
    'Units','normalized',...
    'TooltipString','Mark the integral regions',...
    'Position',[0.05 0.7 0.15 0.06],...
    'Callback',{@SetIntegralsButton_Callback});
hClearIntegralsButton = uicontrol(...
    'Parent',hAPPanel,...
    'Style','PushButton',...
    'String','Clear',...
    'Visible','Off',...
    'Units','normalized',...
    'TooltipString','Clear the marked regions',...
    'Position',[0.20 0.7 0.15 0.06],...
    'Callback',{@ClearIntegralsButton_Callback});
hTextIntegrals=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','Off',...
    'FontWeight','bold',...
    'Position',[0.05 0.77 0.3 0.05 ],...
    'horizontalalignment','c',...
    'String','Integrals' );
hIntegralsShow = uicontrol(...
    'Parent',hAPPanel,...
    'Style','Checkbox',...
    'String','Show',...
    'Visible','Off',...
    'Value',0,...
    'Units','normalized',...
    'Position',[0.36 0.7 0.15 0.06],...
    'Callback',{@IntegralsShow_Callback});
hIntegralsScale = uicontrol(...
    'Parent',hAPPanel,...
    'Style','Checkbox',...
    'String','Scale',...
    'Visible','Off',...
    'Value',0,...
    'Units','normalized',...
    'Position',[0.36 0.65 0.15 0.06],...
    'Callback',{@IntegralsScale_Callback});
hExportIntegralButton = uicontrol(...
    'Parent',hAPPanel,...
    'Style','PushButton',...
    'Visible','Off',...
    'String','Integrals',...
    'Units','normalized',...
    'TooltipString','Export Integrals',...
    'Position',[0.55 0.7 0.15 0.06],...
    'Callback',{@ExportIntegralButton_Callback});
hExportIntegralSetsButton = uicontrol(...
    'Parent',hAPPanel,...
    'Style','PushButton',...
    'String','Settings',...
    'Visible','Off',...
    'Units','normalized',...
    'TooltipString','Export Integral Settings',...
    'Position',[0.70 0.7 0.15 0.06],...
    'Callback',{@ExportIntegralSetButton_Callback});
hTextIntegralsExport=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','Off',...
    'FontWeight','bold',...
    'Position',[0.55 0.77 0.3 0.05 ],...
    'horizontalalignment','c',...
    'String','Export' );
hImportIntegralSetsButton = uicontrol(...
    'Parent',hAPPanel,...
    'Style','PushButton',...
    'String','Settings',...
    'Visible','Off',...
    'Units','normalized',...
    'TooltipString','Import Integral Settings',...
    'Position',[0.55 0.5 0.15 0.06],...
    'Callback',{@ImportIntegralSetButton_Callback});
hTextIntegralsImport=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','Off',...
    'FontWeight','bold',...
    'Position',[0.55 0.57 0.3 0.05 ],...
    'horizontalalignment','c',...
    'String','Import' );
%% ---------Baseline Correction

hXiRockePanel=uipanel(...
    'Parent',hAPPanel,...
    'Title','Xi and Rocke',...
    'FontWeight','bold',...
    'Visible','Off',...
    'TitlePosition','centertop',...
    'ForegroundColor','Black',...
    'Units','Normalized',...
    'Position',[0.0,0.0,0.4,0.85]);

hAuto1BaselineButton = uicontrol(...
    'Parent',hXiRockePanel,...
    'Style','PushButton',...
    'Visible','On',...
    'String','Go',...
    'Units','normalized',...
    'TooltipString','Do baseline correstion',...
    'Position',[0.3 0.85 0.4 0.1],...
    'Callback',{@Auto1BaselineButton_Callback});

hTextBaselineBin=uicontrol(...
    'Parent',hXiRockePanel,...
    'Style','Text',...
    'Units','Normalized',...
    'Fontweight','bold',...
    'String','Bins',...
    'horizontalalignment','center',...
    'Position',[0.1 0.7 0.3 0.1 ]);
hEditBaselineBin=uicontrol(...
    'Parent',hXiRockePanel,...
    'Style','edit',...
    'Units','Normalized',...
    'BackgroundColor','w',...
    'String',128,...
    'Position',[0.1 0.65 0.3 0.08 ],...
    'CallBack', {@EditBaselineBin_Callback});
hTextBaselineStar=uicontrol(...
    'Parent',hXiRockePanel,...
    'Style','Text',...
    'Units','Normalized',...
    'Fontweight','bold',...
    'String','a star',...
    'horizontalalignment','center',...
    'Position',[0.1 0.5 0.3 0.1 ]);
hEditBaselineStar=uicontrol(...
    'Parent',hXiRockePanel,...
    'Style','edit',...
    'Units','Normalized',...
    'BackgroundColor','w',...
    'String',1e-8,...
    'Position',[0.1 0.45 0.3 0.08 ],...
    'CallBack', {@EditBaselineStar_Callback});
hTextBaselineStd=uicontrol(...
    'Parent',hXiRockePanel,...
    'Style','Text',...
    'Units','Normalized',...
    'Fontweight','bold',...
    'String','Std mult',...
    'horizontalalignment','center',...
    'Position',[0.1 0.3 0.3 0.1 ]);
hEditBaselineStd=uicontrol(...
    'Parent',hXiRockePanel,...
    'Style','edit',...
    'Units','Normalized',...
    'BackgroundColor','w',...
    'String',1.25,...
    'Position',[0.1 0.25 0.3 0.08 ],...
    'CallBack', {@EditBaselineStd_Callback});

hPlotCheck = uicontrol(...
    'Parent',hXiRockePanel,...
    'Style','Checkbox',...    
    'String','Plot fits',...
    'Units','normalized',...
    'Value',0,...
    'Position',[0.55 0.61 0.4 0.15],...
    'Callback',{@PlotCheck_Callback});
%% ---------FDMRRT
hBGroupFDMRRTOpt1=uibuttongroup(...
    'Parent',hAPPanel,...
    'Title','Source',...
    'Visible','Off',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.045 0.35 0.3 0.2 ]);
hRadio1FDMRRTOpt1 = uicontrol(...
    'Parent',hBGroupFDMRRTOpt1,...
    'Style','RadioButton',...
    'String','Raw FID',...
    'Units','normalized',...
    'Position',[0.05 0.7 0.9 0.3]);
hRadio2FDMRRTOpt1 = uicontrol(...
    'Parent',hBGroupFDMRRTOpt1,...
    'Style','RadioButton',...
    'String','Processed Spectra',...
    'Units','normalized',...
    'Position',[0.05 0.3 0.9 0.3]);
hBGroupFDMRRTOpt2=uibuttongroup(...
    'Parent',hAPPanel,...
    'Visible','Off',...
    'Title','Algorithm',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.355 0.35 0.3 0.2 ]);
hRadio1FDMRRTOpt2 = uicontrol(...
    'Parent',hBGroupFDMRRTOpt2,...
    'Style','RadioButton',...
    'String','FDM',...
    'Units','normalized',...
    'Position',[0.05 0.7 0.9 0.3]);
hRadio2FDMRRTOpt2 = uicontrol(...
    'Parent',hBGroupFDMRRTOpt2,...
    'Style','RadioButton',...
    'String','RRT',...
    'Units','normalized',...
    'Position',[0.05 0.3 0.9 0.3]);
hBGroupFDMRRTOpt3=uibuttongroup(...
    'Parent',hAPPanel,...
    'Visible','Off',...
    'Title','Spectrum',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.655 0.35 0.3 0.2 ]);
hRadio1FDMRRTOpt3 = uicontrol(...
    'Parent',hBGroupFDMRRTOpt3,...
    'Style','RadioButton',...
    'String','Absolute Value',...
    'Units','normalized',...
    'Position',[0.05 0.7 0.9 0.3]);
hRadio2FDMRRTOpt3 = uicontrol(...
    'Parent',hBGroupFDMRRTOpt3,...
    'Style','RadioButton',...
    'String','Pseudoabsorption',...
    'Units','normalized',...
    'Position',[0.05 0.3 0.9 0.3]);
hTextCres=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Visible','Off',...
    'String','C resolution',...
    'Units','Normalized',...
    'Position',[0.64 0.1 0.20 0.05 ],...    
    'horizontalalignment','l');
hEditCres=uicontrol(...
    'Parent',hAPPanel,...
    'Style','edit',...
    'Visible','Off',...
    'BackgroundColor','w',...
    'Units','Normalized',...
    'Max',1,...
    'TooltipString','Number of data points in the diffusion dimension',...
    'Position',[0.5 0.1 0.1 0.05 ],...
    'CallBack', {@EditCres_Callback});
hEditN1=uicontrol(...
    'Parent',hAPPanel,...
    'Style','edit',...
    'Visible','Off',...
    'BackgroundColor','w',...
    'Units','Normalized',...
    'Position',[0.05 0.25 0.1 0.05 ],...
    'CallBack', {@FDMRRTN1_Callback});
hTextN1=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Visible','Off',...
    'String','Signal length',...
    'Units','Normalized',...
    'Position',[0.18 0.25 0.23 0.05 ],...
    'horizontalalignment','l');
hEditN2=uicontrol(...
    'Parent',hAPPanel,...
    'Style','edit',...
    'Visible','Off',...
    'BackgroundColor','w',...
    'Units','Normalized',...
    'Position',[0.05 0.2 0.1 0.05 ],...
    'CallBack', {@FDMRRTN2_Callback});
hTextN2=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Visible','Off',...
    'String','Traces',...
    'Units','Normalized',...
    'Position',[0.18 0.2 0.23 0.05 ],...
    'horizontalalignment','l');
hEditBasis=uicontrol(...
    'Parent',hAPPanel,...
    'Style','edit',...
    'Visible','Off',...
    'BackgroundColor','w',...
    'Units','Normalized',...
    'Position',[0.05 0.15 0.1 0.05 ],...
    'CallBack', {@FDMRRTBasis_Callback});
hTextBasis=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Visible','Off',...
    'String','Basis Functions',...
    'Units','Normalized',...
    'Position',[0.18 0.15 0.23 0.05 ],...
    'horizontalalignment','l');
hEditQ=uicontrol(...
    'Parent',hAPPanel,...
    'Style','edit',...
    'Visible','Off',...
    'BackgroundColor','w',...
    'Units','Normalized',...
    'Position',[0.05 0.1 0.1 0.05 ]);
hTextQ=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Visible','Off',...
    'String','Regularization',...
    'Units','Normalized',...
    'Position',[0.18 0.1 0.23 0.05 ],...
    'horizontalalignment','l');
hEditS=uicontrol(...
    'Parent',hAPPanel,...
    'Style','edit',...
    'Visible','Off',...
    'BackgroundColor','w',...
    'Units','Normalized',...
    'Position',[0.05 0.05 0.1 0.05 ]);
hTextS=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Visible','Off',...
    'String','Sigma (1E-10)',...
    'Units','Normalized',...
    'Position',[0.18 0.05 0.23 0.05 ],...
    'horizontalalignment','l');
%%--------- Filter
%% ---------ILT
hBGroupILTRegMet=uibuttongroup(...
    'Parent',hAPPanel,...
    'Title','Regularisation',...
    'Visible','Off',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.655 0.52 0.3 0.2 ]);
hRadio2ILTRegMet = uicontrol(...
    'Parent',hBGroupILTRegMet,...
    'Style','RadioButton',...
    'String','Tikhonov',...
    'Units','normalized',...
    'Position',[0.05 0.3 0.9 0.3]);
hRadio1ILTRegMet = uicontrol(...
    'Parent',hBGroupILTRegMet,...
    'Style','RadioButton',...
    'String','None',...
    'Units','normalized',...
    'Position',[0.05 0.7 0.9 0.3]);
hBGroupILTOptimLambda=uibuttongroup(...
    'Parent',hAPPanel,...
    'Visible','Off',...
    'Title','Optim Lambda',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.05 0.1 0.3 0.2 ]);
hRadio2ILTILTOptimLambd = uicontrol(...
    'Parent',hBGroupILTOptimLambda,...
    'Style','RadioButton',...
    'String','L-Curve',...
    'Units','normalized',...
    'Position',[0.05 0.4 0.9 0.3]);
hRadio1ILTILTOptimLambd = uicontrol(...
    'Parent',hBGroupILTOptimLambda,...
    'Style','RadioButton',...
    'String','Manual',...
    'Units','normalized',...
    'Position',[0.05 0.75 0.9 0.3]);
hRadio3ILTILTOptimLambd = uicontrol(...
    'Parent',hBGroupILTOptimLambda,...
    'Style','RadioButton',...
    'String','GCV',...
    'Units','normalized',...
    'Position',[0.05 0.05 0.9 0.3]);
hBGroupILTSmooth=uibuttongroup(...
    'Parent',hAPPanel,...
    'Visible','Off',...
    'Title','Smooth',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.655 0.32 0.3 0.2 ]);
hRadio3ILTILTOptimSmooth = uicontrol(...
    'Parent',hBGroupILTSmooth,...
    'Style','RadioButton',...
    'String','2nd derivative',...
    'Units','normalized',...
    'Position',[0.05 0.05 0.9 0.3]);
hRadio1ILTILTSmooth = uicontrol(...
    'Parent',hBGroupILTSmooth,...
    'Style','RadioButton',...
    'String','None',...
    'Units','normalized',...
    'Position',[0.05 0.75 0.9 0.3]);
hRadio2ILTILTOptiSmooth = uicontrol(...
    'Parent',hBGroupILTSmooth,...
    'Style','RadioButton',...
    'String','1st derivative',...
    'Units','normalized',...
    'Position',[0.05 0.4 0.9 0.3]);
hBGroupILTConstrain=uibuttongroup(...
    'Parent',hAPPanel,...
    'Title','Constraint',...
    'Visible','Off',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.355 0.52 0.3 0.2 ]);
hRadio2ILTConstrain = uicontrol(...
    'Parent',hBGroupILTConstrain,...
    'Style','RadioButton',...
    'String','Non-negativity',...
    'Units','normalized',...
    'Position',[0.05 0.3 0.9 0.3]);
hRadio1ILTConstrain = uicontrol(...
    'Parent',hBGroupILTConstrain,...
    'Style','RadioButton',...
    'String','None',...
    'Units','normalized',...
    'Position',[0.05 0.7 0.9 0.3]);

hEditLamda=uicontrol(...
    'Parent',hAPPanel,...
    'Style','edit',...
    'Visible','Off',...
    'BackgroundColor','w',...
    'String','1',...
    'Units','Normalized',...
    'Position',[0.5 0.1 0.1 0.05 ]);
hTextLamda=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Visible','Off',...
    'String','Manual Lamda',...
    'Units','Normalized',...
    'Position',[0.64 0.1 0.23 0.05 ],...
    'horizontalalignment','l');
%% ---------Analyze
hTextAnalyze=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','Off',...
    'FontWeight','bold',...
    'Position',[0.155 0.7 0.3 0.05 ],...
    'horizontalalignment','c',...
    'String','Analyze' );
hPlotOriginalButton = uicontrol(...
    'Parent',hAPPanel,...
    'Style','PushButton',...
    'Visible','Off',...
    'String','Original',...
    'Units','normalized',...
    'TooltipString','Plot original data',...
    'Position',[0.01 0.6 0.15 0.06],...
    'Callback',{@PlotOriginalButton_Callback});
hAnalyzeFreqButton = uicontrol(...
    'Parent',hAPPanel,...
    'Style','PushButton',...
    'Visible','Off',...
    'String','Freq',...
    'Units','normalized',...
    'TooltipString','Analyze frequcency shifts',...
    'Position',[0.01 0.6 0.15 0.06],...
    'Callback',{@AnalyzeFreqButton_Callback});
hAnalyzeResButton = uicontrol(...
    'Parent',hAPPanel,...
    'Style','PushButton',...
    'Visible','Off',...
    'String','Resol',...
    'Units','normalized',...
    'TooltipString','Analyze resolution changes',...
    'Position',[0.16 0.6 0.15 0.06],...
    'Callback',{@AnalyzeResButton_Callback});
hAnalyzeAmpButton = uicontrol(...
    'Parent',hAPPanel,...
    'Style','PushButton',...
    'Visible','Off',...
    'String','Ampl',...
    'Units','normalized',...
    'TooltipString','Analyze amplitude changes',...
    'Position',[0.31 0.6 0.15 0.06],...
    'Callback',{@AnalyzeAmpButton_Callback});
hAnalyzeTempButton = uicontrol(...
    'Parent',hAPPanel,...
    'Style','PushButton',...
    'Visible','Off',...
    'Enable','On',...
    'String','Temp',...
    'Units','normalized',...
    'TooltipString','Analyze temperature changes',...
    'Position',[0.01 0.53 0.15 0.06],...
    'Callback',{@AnalyzeTempButton_Callback});
hAnalyzePhaseButton = uicontrol(...
    'Parent',hAPPanel,...
    'Style','PushButton',...
    'Visible','Off',...
    'Enable','On',...
    'String','Phase',...
    'Units','normalized',...
    'TooltipString','Analyze phase changes',...
    'Position',[0.16 0.53 0.15 0.06],...
    'Callback',{@AnalyzePhaseButton_Callback});
hAnalyzeIntButton = uicontrol(...
    'Parent',hAPPanel,...
    'Style','PushButton',...
    'Visible','Off',...
    'Enable','On',...
    'String','Int',...
    'Units','normalized',...
    'TooltipString','Analyze integral changes',...
    'Position',[0.31 0.53 0.15 0.06],...
    'Callback',{@AnalyzeIntButton_Callback});
hDSSButton = uicontrol(...
    'Parent',hAPPanel,...
    'Style','PushButton',...
    'Visible','Off',...
    'Enable','On',...
    'String','DSS',...
    'Units','normalized',...
    'TooltipString','Display stacked spectra',...
    'Position',[0.71 0.53 0.15 0.06],...
    'Callback',{@DSSButton_Callback});
hTextStart=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','Off',...
    'FontWeight','bold',...
    'Position',[0.01 0.4 0.3 0.05 ],...
    'horizontalalignment','left',...
    'String','Start:' );
hEditStart=uicontrol(...
    'Parent',hAPPanel,...
    'Style','edit',...
    'Visible','Off',...
     'Enable','On',...
    'BackgroundColor','w',...
    'TooltipString',...
    'Normalisation factor',...
    'String',1,...
    'Units','Normalized',...
    'Position',[0.1 0.4 0.1 0.05 ],...
    'CallBack', {@EditStart_Callback});
hTextStop=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','Off',...
    'FontWeight','bold',...
    'Position',[0.01 0.3 0.3 0.05 ],...
    'horizontalalignment','left',...
    'String','Stop:' );
hEditStop=uicontrol(...
    'Parent',hAPPanel,...
    'Style','edit',...
    'Visible','Off',...
     'Enable','On',...
    'BackgroundColor','w',...
    'TooltipString',...
    'Normalisation factor',...
    'String',1,...
    'Units','Normalized',...
    'Position',[0.1 0.3 0.1 0.05 ],...
    'CallBack', {@EditStop_Callback});
hTextStep=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','Off',...
    'FontWeight','bold',...
    'Position',[0.01 0.2 0.3 0.05 ],...
    'horizontalalignment','left',...
    'String','Step:' );
hEditStep=uicontrol(...
    'Parent',hAPPanel,...
    'Style','edit',...
    'Visible','Off',...
     'Enable','On',...
    'BackgroundColor','w',...
    'TooltipString',...
    'Normalisation factor',...
    'String',1,...
    'Units','Normalized',...
    'Position',[0.1 0.2 0.1 0.05 ],...
    'CallBack', {@EditStep_Callback});
hTextChartWidth=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','Off',...
    'FontWeight','bold',...
    'Position',[0.6 0.4 0.3 0.05 ],...
    'horizontalalignment','left',...
    'String','Chart width (%):' );
hEditChartWidth=uicontrol(...
    'Parent',hAPPanel,...
    'Style','edit',...
    'Visible','Off',...
     'Enable','Off',...
    'BackgroundColor','w',...
    'TooltipString',...
    'Normalisation factor',...
    'String',50,...
    'Units','Normalized',...
    'Position',[0.85 0.4 0.1 0.05 ],...
    'CallBack', {@EditChartWidth_Callback});
hTextStopChart=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','Off',...
    'FontWeight','bold',...
    'Position',[0.6 0.3 0.3 0.05 ],...
    'horizontalalignment','left',...
    'String','Stop chart (%):' );
hEditStopChart=uicontrol(...
    'Parent',hAPPanel,...
    'Style','edit',...
    'Visible','Off',...
     'Enable','Off',...
    'BackgroundColor','w',...
    'TooltipString',...
    'Normalisation factor',...
    'String',50,...
    'Units','Normalized',...
    'Position',[0.85 0.3 0.1 0.05 ],...
    'CallBack', {@EditStopChart_Callback});
hTextHorizontalOffset=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','Off',...
    'FontWeight','bold',...
    'Position',[0.6 0.2 0.35 0.05 ],...
    'horizontalalignment','left',...
    'String','Horiz offset (%):' );
hEditHorizontalOffset=uicontrol(...
    'Parent',hAPPanel,...
    'Style','edit',...
    'Visible','Off',...
     'Enable','On',...
    'BackgroundColor','w',...
    'TooltipString',...
    'Normalisation factor',...
    'String',1,...
    'Units','Normalized',...
    'Position',[0.85 0.2 0.1 0.05 ],...
    'CallBack', {@EditHorizontalOffset_Callback});
hTextVerticalOffset=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','Off',...
    'FontWeight','bold',...
    'Position',[0.6 0.1 0.3 0.05 ],...
    'horizontalalignment','left',...
    'String','Vert offset (%):' );
hEditVerticalOffset=uicontrol(...
    'Parent',hAPPanel,...
    'Style','edit',...
    'Visible','Off',...
     'Enable','On',...
    'BackgroundColor','w',...
    'TooltipString',...
    'Normalisation factor',...
    'String',1,...
    'Units','Normalized',...
    'Position',[0.85 0.1 0.1 0.05 ],...
    'CallBack', {@EditVerticalOffset_Callback});
%% ---------T1/T2
hBGroupT1Opt2=uibuttongroup(...
    'Parent',hAPPanel,...
    'Visible','Off',...
    'Title','Fit Type',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.01 0.01 0.3 0.39 ]);
hRadio1T1Opt2 = uicontrol(...
    'Parent',hBGroupT1Opt2,...
    'Style','RadioButton',...
    'String','T1 (3 params)',...
    'Units','normalized',...
    'Position',[0.05 0.6 0.9 0.3]);
hRadio2T1Opt2 = uicontrol(...
    'Parent',hBGroupT1Opt2,...
    'Style','RadioButton',...
    'String','T2 (2 params)',...
    'Units','normalized',...
    'Position',[0.05 0.2 0.9 0.3]);
hPanelT1plotting = uipanel(...
    'Parent',hAPPanel,...
    'Title','Plotting options',...
    'Visible','Off',...
    'FontWeight','bold',...
    'TitlePosition','centertop',...
    'ForegroundColor','Black',...
    'Units','Normalized',...
    'Position',[0.61,0.01,0.38,0.59]);
hTextT1limits=uicontrol(...
    'Parent',hPanelT1plotting,...
    'Style','text',...
    'Visible','On',...
    'String','Plot limits',...
    'Units','Normalized',...
    'Position',[0.1 0.6 0.3 0.2 ],...
    'horizontalalignment','l');
hCheckT1limits=uicontrol(...
    'Parent',hPanelT1plotting,...
    'Style','checkbox',...
    'Units','Normalized',...
    'String','Auto',...
    'Value',1,...
    'TooltipString','Automatic setting of plot limits from fitted T1/T2 values',...
    'Position',[0.1 0.52 0.3 0.15 ],...
    'CallBack', {@CheckT1limits_Callback} );
hEditT1min=uicontrol(...
    'Parent',hPanelT1plotting,...
    'Style','edit',...
    'Visible','On',...
    'Enable','Off',...
    'BackgroundColor','w',...
    'Units','Normalized',...
    'horizontalalignment','l',...
    'TooltipString','Minimum value of T1/T2 coefficient displayed',...
    'Max',1,...
    'Position',[0.1 0.35 0.2 0.15 ],...
    'CallBack', {@EditT1min_Callback});
hTextT1min=uicontrol(...
    'Parent',hPanelT1plotting,...
    'Style','text',...
    'Visible','On',...
    'String','min T1/T2',...
    'Units','Normalized',...
    'Position',[0.35 0.325 0.3 0.15 ],...    
    'horizontalalignment','l');
hEditT1max=uicontrol(...
    'Parent',hPanelT1plotting,...
    'Style','edit',...
    'Visible','On',...
    'Enable','Off',...
    'BackgroundColor','w',...
    'horizontalalignment','l',...
    'Units','Normalized',...
    'TooltipString','Maximum value of T1/T2 coefficient displayed',...
    'Max',1,...
    'Position',[0.1 0.15 0.2 0.15 ],...
    'CallBack', {@EditT1max_Callback});
hTextT1max=uicontrol(...
    'Parent',hPanelT1plotting,...
    'Style','text',...
    'Visible','On',...
    'String','max T1',...
    'Units','Normalized',...
    'Position',[0.35 0.125 0.3 0.15 ],...
    'horizontalalignment','l');
hTextT1res=uicontrol(...
    'Parent',hPanelT1plotting,...
    'Style','text',...
    'Visible','On',...
    'String','Data points',...
    'Units','Normalized',...
    'Position',[0.6 0.6 0.35 0.2 ],...
    'horizontalalignment','l');
hEditT1res=uicontrol(...
    'Parent',hPanelT1plotting,...
    'Style','edit',...
    'Visible','On',...
    'BackgroundColor','w',...
    'Units','Normalized',...
    'Max',1,...
    'TooltipString','Number of data points in the T1/T2 dimension',...
    'Position',[0.6 0.52 0.3 0.15 ],...
    'CallBack', {@EditT1res_Callback});
%% ---------Pure shift
hButtonPureshiftConvert=uicontrol(...
    'Parent',hAPPanel,...
    'Style','PushButton',...
    'Units','Normalized',...
    'Visible','Off',...
    'TooltipString','Convert to pureshift spectrum',...
    'FontWeight','bold',...
    'Position',[0.725 0.475 0.2 0.1 ],...
    'String','ConvertZS',...
    'CallBack', {@PureshiftConvertZS_Callback});
hTextnfid=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','Off',...
    'ForegroundColor','Black',...
    'horizontalalignment','left',...
    'FontWeight','bold',...
    'Position',[0.05 0.6 0.1 0.04 ],...
    'String','nFID:' );
hEditnfid=uicontrol(...
    'Parent',hAPPanel,...
    'Style','edit',...
    'Visible','Off',...
    'BackgroundColor','w',...
    'Units','Normalized',...
    'TooltipString','Number if increments (FIDs) to use for the pureshift FID',...
    'Max',1,...
    'Position',[0.23 0.6 0.075 0.05 ],...
    'CallBack', {@Editnfid_Callback});
hTextnpoint=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','Off',...
    'ForegroundColor','black',...
    'horizontalalignment','left',...
    'FontWeight','bold',...
    'Position',[0.05 0.3 0.2 0.04 ],...
    'String','fid points:' );
hEditnpoints=uicontrol(...
    'Parent',hAPPanel,...
    'Style','edit',...
    'Visible','Off',...
    'BackgroundColor','w',...
    'Units','Normalized',...
    'TooltipString','Number of points to use for each increment',...
    'Max',1,...
    'Position',[0.23 0.3 0.075 0.05 ],...
    'CallBack', {@Editnpoints_Callback});
hTextnfirstfidpoints=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Visible','Off',...
    'Units','Normalized',...
    'ForegroundColor','black',...
    'horizontalalignment','left',...
    'FontWeight','bold',...
    'Position',[0.05 0.4 0.2 0.04 ],...
    'String','first points:' );
hEditnfirstfidpoints=uicontrol(...
    'Parent',hAPPanel,...
    'Style','edit',...
    'Visible','Off',...
    'BackgroundColor','w',...
    'Units','Normalized',...
    'TooltipString','Number of points to use for the first increment',...
    'Max',1,...
    'Position',[0.23 0.4 0.075 0.05 ],...
    'CallBack', {@Editfirstfidpoints_Callback});
hTextDropPoints=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','Off',...
    'ForegroundColor','black',...
    'horizontalalignment','left',...
    'FontWeight','bold',...
    'Position',[0.05 0.5 0.2 0.04 ],...
    'String','drop points:' );
hEditDropPoints=uicontrol(...
    'Parent',hAPPanel,...
    'Style','edit',...
    'Visible','Off',...
    'BackgroundColor','w',...
    'Units','Normalized',...
    'TooltipString','Number of initial points to remove for the each increment',...
    'Max',1,...
    'Position',[0.23 0.5 0.075 0.05 ],...
    'CallBack', {@EditDropPoints_Callback});
hButtonUnConvertPK=uicontrol(...
    'Parent',hAPPanel,...
    'Style','PushButton',...
    'Units','Normalized',...
    'Visible','Off',...
    'TooltipString','Retrieve original data',...
    'FontWeight','bold',...
    'Position',[0.725 0.175 0.2 0.1 ],...
    'String','UnConvert',...
    'CallBack', {@UnConvertPK_Callback});
%set preferences for local version
if strcmp(NmrData.local,'yes')
    hButtonPureshiftConvertPK=uicontrol(...
        'Parent',hAPPanel,...
        'Style','PushButton',...
        'Units','Normalized',...
        'Visible','Off',...
        'TooltipString','Convert to pureshift spectrum',...
        'FontWeight','bold',...
        'Position',[0.725 0.375 0.2 0.1 ],...
        'String','Convert PK',...
        'CallBack', {@PureshiftConvertPK_Callback});
end
%% ---------Synthesise DOSY
% Titles
hTextSynthParam=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','Off',...
    'FontWeight','bold',...
    'Position',[0.03 0.67 0.3 0.05],...
    'horizontalalignment','c',...
    'String','Spectral Parameters' );
hTextSynthGenDOSY=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','Off',...
    'FontWeight','bold',...
    'Position',[0.4 0.67 0.3 0.05],...
    'horizontalalignment','l',...
    'String','Peak Parameters' );
% Buttons
hRandomDOSYButton=uicontrol(...
    'Parent',hAPPanel,...
    'Style','PushButton',...
    'Units','Normalized',...
    'Visible','Off',...
    'TooltipString','Generate a DOSY dataset with random peaks',...
    'FontWeight','bold',...
    'Position',[0.07 0.75 0.2 0.05],...
    'String','Random DOSY',...
    'CallBack', {@RandomDOSYButton_Callback});
hUpdateSynthButton=uicontrol(...
    'Parent',hAPPanel,...
    'Style','PushButton',...
    'Units','Normalized',...
    'Visible','Off',...
    'TooltipString','Generate a DOSY dataset with the table parameters',...
    'FontWeight','bold',...
    'Position',[0.4 0.75 0.2 0.05],...
    'String','Generate DOSY',...
    'CallBack', {@UpdateSynthButton_Callback});
hUpdateTableButton=uicontrol(...
    'Parent',hAPPanel,...
    'Style','PushButton',...
    'Units','Normalized',...
    'Visible','Off',...
    'TooltipString','Update the Table based on Spectral parameters',...
    'FontWeight','bold',...
    'Position',[0.73 0.67 0.2 0.05],...
    'String','Update Table',...
    'CallBack', {@UpdateTableButton_Callback});
% Spectral Parameters
hTextnpeaks=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','Off',...
    'FontWeight','bold',...
    'Position',[0.05 0.59 0.15 0.05 ],...
    'horizontalalignment','r',...
    'String','No. Peaks:' );
hEditnpeaks=uicontrol(...
    'Parent',hAPPanel,...
    'Style','edit',...
    'Visible','Off',...
    'BackgroundColor','w',...
    'Units','Normalized',...
    'TooltipString','The number of peaks in the spectrum.',...
    'Position',[0.22 0.59 0.15 0.05 ]);
hTextsw=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Visible','Off',...
    'String','Spec. Width:',...
    'FontWeight','bold',...
    'Units','Normalized',...
    'Position',[0.05 0.53 0.15 0.05],...
    'horizontalalignment','r');
hEditsw=uicontrol(...
    'Parent',hAPPanel,...
    'Style','edit',...
    'Visible','Off',...
    'BackgroundColor','w',...
    'Units','Normalized',...
    'TooltipString','The spectral width in Hz',...
    'Position',[0.22 0.53 0.15 0.05]);
hTextnp=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','Off',...
    'FontWeight','bold',...
    'Position',[0.05 0.47 0.15 0.05],...
    'horizontalalignment','r',...
    'String','No. Points:' );
hEditnp=uicontrol(...
    'Parent',hAPPanel,...
    'Style','edit',...
    'Visible','Off',...
    'BackgroundColor','w',...
    'Units','Normalized',...
    'TooltipString','The number of points representing the dataset',...
    'Position',[0.22 0.47 0.15 0.05]);
hTextmingrad=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','Off',...
    'FontWeight','bold',...
    'Position',[0.05 0.41 0.15 0.05 ],...
    'horizontalalignment','r',...
    'String','Min. Grad.:' );
hEditmingrad=uicontrol(...
    'Parent',hAPPanel,...
    'Style','edit',...
    'Visible','Off',...
    'BackgroundColor','w',...
    'Units','Normalized',...
    'TooltipString','The minimum gradient in the DOSY T/m,',...
    'Position',[0.22 0.41 0.15 0.05 ]);
hTextmaxgrad=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','Off',...
    'FontWeight','bold',...
    'Position',[0.05 0.35 0.15 0.05 ],...
    'horizontalalignment','r',...
    'String','Max. Grad.:' );
hEditmaxgrad=uicontrol(...
    'Parent',hAPPanel,...
    'Style','edit',...
    'Visible','Off',...
    'BackgroundColor','w',...
    'Units','Normalized',...
    'TooltipString','The maximum gradient in the DOSY T/m',...
    'Position',[0.22 0.35 0.15 0.05 ]);
hTextni=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','Off',...
    'FontWeight','bold',...
    'Position',[0.05 0.29 0.15 0.05 ],...
    'horizontalalignment','r',...
    'String','No. G. levels:' );
hEditni=uicontrol(...
    'Parent',hAPPanel,...
    'Style','edit',...
    'Visible','Off',...
    'BackgroundColor','w',...
    'Units','Normalized',...
    'TooltipString','The number of increments/gradient levels of the DOSY',...
    'Position',[0.22 0.29 0.15 0.05 ]);
hTextnoise=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','Off',...
    'FontWeight','bold',...
    'Position',[0.05 0.23 0.15 0.05 ],...
    'horizontalalignment','r',...
    'String','S/N 1/:' );
hEditnoise=uicontrol(...
    'Parent',hAPPanel,...
    'Style','edit',...
    'Visible','Off',...
    'BackgroundColor','w',...
    'Units','Normalized',...
    'TooltipString','The amount of random noise',...
    'Position',[0.22 0.23 0.15 0.05 ]);
hText3Dplot=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','Off',...
    'FontWeight','bold',...
    'Position',[0.05 0.17 0.15 0.05 ],...
    'horizontalalignment','r',...
    'String','3D plot:' );
hCheck3Dplot = uicontrol(...
    'Parent',hAPPanel,...
    'Style','Checkbox',...
    'Visible','Off',...
    'Units','normalized',...
    'horizontalalignment','c',...
    'Position',[0.22 0.17 0.15 0.05]);
hTextUseNUG=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','Off',...
    'FontWeight','bold',...
    'Position',[0.05 0.11 0.15 0.05 ],...
    'horizontalalignment','r',...
    'String','Add NUG:' );
hCheckUseNUG = uicontrol(...
    'Parent',hAPPanel,...
    'Style','Checkbox',...
    'Visible','Off',...
    'Units','normalized',...
    'horizontalalignment','c',...
    'TooltipString',...
    'Use the settings menu to set Non Uniform Gradient coefficients',...
    'Position',[0.22 0.11 0.15 0.05]);
% Individual peaks
hTableSynthPeaks=uitable(...
    'parent',hAPPanel,...
    'units','normalized',...
    'columneditable',[true true true true true],...
    'columnname',{'Freq.','D','Amp','Lw','MP'},...
    'columnformat',{'numeric','numeric','numeric','numeric','numeric'},...
    'columnwidth',{'auto'},...
    'rowname',{'numbered'},...
    'position',[0.4 0.05 0.55 0.6 ],...
    'Data',zeros(10,5),...
    'Visible','Off');
%% ---------Align spectra
hAlignPanel=uipanel(...
    'Parent',hAPPanel,...
    'Title','',...
    'FontWeight','bold',...
    'ForegroundColor','Black',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Visible','Off',...
    'Position',[0.0,0.0,1.0,0.7]);
hAutoPanel=uipanel(...
    'Parent',hAlignPanel,...
    'Title','Auto',...
    'FontWeight','bold',...
    'ForegroundColor','Black',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Visible','On',...
    'Position',[0.0,0.0,0.5,0.9]);
hPushAutoAlign = uicontrol(...
    'Parent',hAutoPanel,...
    'Style','PushButton',...
    'String','Auto Find',...
    'Units','normalized',...
    'Visible','On',...
    'Position',[0.2 0.7 0.3 0.1],...
    'Callback',{@AutoAlignButton_Callback});
hPushZeroAlign = uicontrol(...
    'Parent',hAutoPanel,...
    'Style','PushButton',...
    'String','Clear All',...
    'Units','normalized',...
     'Visible','On',...
    'Position',[0.5 0.7 0.3 0.1],...
    'Callback',{@ZeroAlignButton_Callback});

% hPushApplyAlign = uicontrol(...
%     'Parent',hAutoPanel,...
%     'Style','PushButton',...
%     'String','Apply All',...
%     'FontWeight','bold',...
%     'Units','normalized',...
%      'Visible','On',...
%     'Position',[0.3 0.1 0.3 0.1],...
%     'Callback',{@ApplyAlignButton_Callback});

hCheckApplyFT=uicontrol(...
    'Parent',hAutoPanel,...
    'Style','checkbox',...
    'Units','Normalized',...
    'Value',0,...
    'TooltipString','Use the line broadening function',...
    'Position',[0.3 0.1 0.1 0.1 ]);
hTextAutoApply=uicontrol(...
    'Parent',hAutoPanel,...
    'Style','text',...
    'Units','Normalized',...
    'FontWeight','bold',...
    'Horizontalalignment','left',...
    'Position',[0.41 0.08 0.5 0.1 ],...
    'String','Apply when FT' );
hTextLinearAlign = uicontrol(...
    'Parent',hAutoPanel,...
    'Style','text',...
    'String','Add Linear (Hz):',...
    'Units','normalized',...
     'horizontalalignment','l',...
     'Visible','On',...
    'Position',[0.05 0.4 0.4 0.1]);
hTextLinearAlignUse = uicontrol(...
    'Parent',hAutoPanel,...
    'Style','text',...
    'String','Use',...
     'FontWeight','bold',...
    'horizontalalignment','l',...
    'Units','normalized',...
     'Visible','On',...
    'Position',[0.64 0.4 0.4 0.1]);
hEditLinear=uicontrol(...
    'Parent',hAutoPanel,...
    'Style','edit',...
    'BackgroundColor','w',...
    'Units','Normalized',...
    'String','0',...
    'Position',[0.4 0.4 0.1 0.1 ],...
    'CallBack', {@EditLinear_Callback});
hCheckApplyLinear=uicontrol(...
    'Parent',hAutoPanel,...
    'Style','checkbox',...
    'Units','Normalized',...
    'Value',0,...
    'TooltipString','Use the linear frequence shift',...
    'Position',[0.55 0.41 0.1 0.1 ]);
hManualPanel=uipanel(...
    'Parent',hAlignPanel,...
    'Title','Manual',...
    'FontWeight','bold',...
    'ForegroundColor','Black',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Visible','On',...
    'Position',[0.5,0.0,0.5,0.9]);
hShiftPanel=uipanel(...
    'Parent',hManualPanel,...
    'Title','Shift',...
    'FontWeight','bold',...
    'BorderType','None',...
    'ForegroundColor','Black',...
    'TitlePosition','centertop',...
    'Units','Normalized',...
    'Position',[0.0,0.35,1.0,0.65]);
hSliderShift=uicontrol(...
    'Parent',hShiftPanel,...
    'Style','slider',...    
    'Units','Normalized',... 
     'Min' ,-10000,'Max',10000, ...
    'Position',[0.05,0.7,0.9,0.2], ...
    'Value', 0,...
    'SliderStep',[1/20000 10/20000], ...
    'CallBack', {@SliderShift_Callback});
hEditShift=uicontrol(...
    'Parent',hShiftPanel,...
    'Style','edit',...
    'BackgroundColor','w',...
    'Units','Normalized',...
    'Position',[0.3 0.4 0.4 0.2 ],...
    'CallBack', {@EditShift_Callback});

hButtonPlusShift = uicontrol(...
    'Parent',hShiftPanel,...
    'Style','PushButton',...
    'String','+0.1',...
    'Units','normalized',...
    'Position',[0.52 0.05 0.2 0.2],...
    'Callback',{@ButtonPlusShift_Callback});
hButtonMinusShift = uicontrol(...
    'Parent',hShiftPanel,...
    'Style','PushButton',...
    'String','-0.1',...
    'Units','normalized',...
    'Position',[0.28 0.05 0.2 0.2],...
    'Callback',{@ButtonMinusShift_Callback});
hButtonPlusShift2 = uicontrol(...
    'Parent',hShiftPanel,...
    'Style','PushButton',...
    'String','+0.01',...
    'Units','normalized',...
    'Position',[0.72 0.05 0.2 0.2],...
    'Callback',{@ButtonPlusShift2_Callback});
hButtonMinusShift2 = uicontrol(...
    'Parent',hShiftPanel,...
    'Style','PushButton',...
    'String','-0.01',...
    'Units','normalized',...
    'Position',[0.08 0.05 0.2 0.2],...
    'Callback',{@ButtonMinusShift2_Callback});
hTextCurrent=uicontrol(...
    'Parent',hShiftPanel,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','On',...
    'FontWeight','bold',...
    'Position',[0.05 0.41 0.2 0.15],...
    'horizontalalignment','l',...
    'String','Current:' );
hCheckAutoApply=uicontrol(...
    'Parent',hManualPanel,...
    'Style','checkbox',...
    'Units','Normalized',...
    'Value',1,...
    'TooltipString','Use the line broadening function',...
    'Position',[0.3 0.1 0.1 0.1 ],...
    'CallBack', {@CheckAutoApply_Callback} );
hTextAutoApply=uicontrol(...
    'Parent',hManualPanel,...
    'Style','text',...
    'Units','Normalized',...
    'FontWeight','bold',...
    'Horizontalalignment','left',...
    'Position',[0.41 0.08 0.3 0.1 ],...
    'String','Auto Apply' );
%% ---------Testing
% Titles
hTextTesting=uicontrol(...
    'Parent',hAPPanel,...
    'Style','text',...
    'Units','Normalized',...
    'Visible','Off',...
    'FontWeight','bold',...
    'Position',[0.03 0.67 0.3 0.05],...
    'horizontalalignment','c',...
    'String','Testing text' );
%% Setup default values
set(hEditDres,'string',num2str(512));
set(hEditDmax,'string',num2str(20));
set(hEditDmin,'string',num2str(0));
set(hEditTries,'string',num2str(100));
set(hEditMultexp,'string',num2str(1));
set(hEditNcomp,'string',2);
set(hEditOrder,'string',2);
set(hEditLb,'string',num2str(0));
set(hEditGw,'string',num2str(1));
set(hEditLbRD,'string',num2str(1));
set(hEditGwRD,'string',num2str(1));
SliderPh1.value=get(hSliderPh1,'value');
SliderPh1.max=get(hSliderPh1,'max');
SliderPh1.min=get(hSliderPh1,'min');
set(hEditPh1,'string',SliderPh1.value);
set(hTextMaxPh1,'string',SliderPh1.max)
set(hTextMinPh1,'string',SliderPh1.min)
SliderPh0.value=get(hSliderPh0,'value');
SliderPh0.max=get(hSliderPh0,'max');
SliderPh0.min=get(hSliderPh0,'min');
set(hEditPh0,'string',SliderPh0.value);
set(hTextMaxPh0,'string',SliderPh0.max);
set(hTextMinPh0,'string',SliderPh0.min);
set(hEditBin,'string',num2str(0.02));
set(hBGroupNormalise,'SelectedObject',hRadio2Normalise)
set(hPARAFACButton,'Visible','on');
set(hPARAFACButton,'Enable','on');
set(hAutoButton,'Visible','on');
set(hAutoButton,'Enable','on');
set(hBINButton,'Visible','off');
set(hBINButton,'Enable','on');
set(hicoshiftButton,'Visible','off');
set(hicoshiftButton,'Enable','on');
set(hINTEGRALButton,'Visible','off');
set(hINTEGRALButton,'Enable','on');
set(hBaselineButton,'Visible','off');
set(hBaselineButton,'Enable','on');
set(hLRDOSYButton,'Visible','on');
set(hLRDOSYButton,'Enable','on');
set(hMoreButton,'Visible','on');
set(hMoreButton,'Enable','on');
set(hAnalyzeButton,'Visible','off');
set(hAnalyzeButton,'Enable','on');
set(hT1Button,'Visible','off');
set(hT1Button,'Enable','on');
set(hEditT1res,'string',num2str(256));
set(hEditT1max,'string',num2str(10));
set(hEditT1min,'string',num2str(0));
%AC
set(hEditDiffRes,'string',num2str(256));
set(hEditsw,'string',6000)
set(hEditnp,'string',32768)
set(hEditmingrad,'string',0.03)
set(hEditmaxgrad,'string',0.28)
set(hEditni,'string',32)
set(hEditnpeaks,'string',10)
set(hEditnoise,'string',0)
TMP={10,5};
for e=1:10
TMP{e,1}=0;
TMP{e,2}=false;
TMP{e,3}=0;
TMP{e,4}=1;
TMP{e,5}=0;
end
set(hTableFixPeaks,'Data',TMP)
%AC

%set preferences for local version
if strcmp(NmrData.local,'yes')
    %set(hFilterButton,'Visible','on');
    %set(hFilterButton,'Enable','on');
   
end
%% Initialise data
%NOTE: I think the compiled version is happier if I declare all variables
%and initiate the struct NmrData
NmrData.tmp='';
Initiate_NmrData();
%Put the Gui in a proper place and show it
guidata(hMainFigure,NmrData);

movegui(hMainFigure,'northwest')
set(hMainFigure,'Visible','on')
%set(hControlFig,'Visible','on')
%% Callbacks
%----------------MainFigure callbacks--------------------------------------
    function hMainFigure_DeleteFcn(eventdata, handles)      %#ok<*INUSD>
        QuitDOSYToolbox();
    end
%% ---------Menu callbacks------------------------------------------
    function Import_Varian(eventdata, handles)
        [vnmrdata]=varianimport;
        if ~isempty(vnmrdata)
            Initiate_NmrData();
            
            %NmrData=guidata(hMainFigure);
            % setting up the NmrData structure - I think it is safest to
            % initialise them all (for the compiled version)
            NmrData.type='Varian';
            NmrData.sfrq=vnmrdata.sfrq;
            NmrData.FID=vnmrdata.FID;
            NmrData.filename=vnmrdata.filename;
            NmrData.dosyconstant=vnmrdata.dosyconstant;
            NmrData.Gzlvl=vnmrdata.Gzlvl;
            NmrData.ngrad=vnmrdata.ngrad;
            %NmrData.procpar=vnmrdata.procpar;
            NmrData.np=vnmrdata.np;
            NmrData.ni=vnmrdata.ni;
            NmrData.sw=vnmrdata.sw;
            NmrData.sw1=vnmrdata.sw1;
            NmrData.at=vnmrdata.at;
            NmrData.sp=vnmrdata.sp;
            NmrData.sp1=vnmrdata.sp1;
            NmrData.rp=vnmrdata.procpar.rp;
            NmrData.rp1=vnmrdata.procpar.rp1;   %AC
            NmrData.lp=vnmrdata.procpar.lp;
            NmrData.lp1=vnmrdata.procpar.lp1;   %AC
            NmrData.gamma=vnmrdata.gamma;
            NmrData.DELTA=vnmrdata.DELTA;
            NmrData.delta=vnmrdata.delta;
            NmrData.gcal_orig=vnmrdata.DAC_to_G;
            if (isfield(vnmrdata,'arraydim'))
                NmrData.arraydim=vnmrdata.arraydim;
            else
                NmrData.arraydim=NmrData.ngrad;
            end
            if (isfield(vnmrdata,'sw1'))
                NmrData.sw1=vnmrdata.sw1;
            end
            if (isfield(vnmrdata,'nchunk'))
                NmrData.nchunk=vnmrdata.nchunk;
            end
            if (isfield(vnmrdata,'droppts'))
                NmrData.droppts=vnmrdata.droppts;
            end
            %MN 7Sep12 to accomodate for T1 data
            if (isfield(vnmrdata.procpar,'d2'))
                NmrData.d2=vnmrdata.procpar.d2;
                 NmrData.d2_org=vnmrdata.procpar.d2;
            end 
             %MN 6March14 to accomodate for T2 data
            if (isfield(vnmrdata.procpar,'bigtau'))
                NmrData.bigtau=vnmrdata.procpar.bigtau;
            end  
            %vnmrdata.procpar
            clear vnmrdata;            
            guidata(hMainFigure,NmrData);
            % NmrData
            Setup_NmrData();
        else
            %do nothing
        end         
    end
    function Import_Varian_Array(eventdata, handles)
        Initiate_NmrData();
        guidata(hMainFigure,NmrData);
        [dirpath]=uigetdir('*','Choose the folder containing the numbered experiments');
        dlg_title='Data structure';
        dlg_prompt = {'First experiment','Numbers between experiment:','Last experiment'};
        num_lines=1;
        answer=inputdlg(dlg_prompt,dlg_title,num_lines);
        nStart=str2num(answer{1});
        nJump= str2num(answer{2});
        nStop=str2num(answer{3});
        nExp= (nStop-nStart)/nJump +1;
        Explist=zeros(nExp,1);
        for k=1:nExp
            Explist(k)=nStart+(k-1)*nJump ;
        end
        for expnr = 1:nExp
            path=[dirpath '/' num2str(Explist(expnr)) '.fid'];
            [vnmrdata]=varianimport(path);
            if expnr==1
                nIncr=vnmrdata.arraydim;
                NmrData.rpInd=zeros(nExp*nIncr,1);
                NmrData.rpInd=zeros(nExp*nIncr,1);
            end
            NmrData.FID(:,((expnr-1)*nIncr+1):expnr*nIncr)=vnmrdata.FID(:,:);            
            NmrData.rpInd((expnr-1)*nIncr+1:expnr*nIncr)=vnmrdata.procpar.rp;
            NmrData.lpInd((expnr-1)*nIncr+1:expnr*nIncr)=vnmrdata.procpar.lp;
        end
        NmrData.type='Varian';
        NmrData.sfrq=vnmrdata.sfrq;
        %NmrData.FID=vnmrdata.FID;
        NmrData.filename=vnmrdata.filename;
        NmrData.dosyconstant=vnmrdata.dosyconstant;
        NmrData.Gzlvl=vnmrdata.Gzlvl;
        NmrData.ngrad=nIncr;
        %NmrData.procpar=vnmrdata.procpar;
        NmrData.np=vnmrdata.np;
        NmrData.fn=NmrData.np;
        NmrData.ni=vnmrdata.ni;
        NmrData.sw=vnmrdata.sw;
        NmrData.sw1=vnmrdata.sw1;
        NmrData.at=vnmrdata.at;
        NmrData.sp=vnmrdata.sp;
        NmrData.sp1=vnmrdata.sp1;
        NmrData.rp=vnmrdata.procpar.rp;
        NmrData.rp1=vnmrdata.procpar.rp1;   %AC
        NmrData.lp=vnmrdata.procpar.lp;
        NmrData.lp1=vnmrdata.procpar.lp1;   %AC
        NmrData.gamma=vnmrdata.gamma;
        NmrData.DELTA=vnmrdata.DELTA;
        NmrData.delta=vnmrdata.delta;
        NmrData.gcal_orig=vnmrdata.DAC_to_G;
        NmrData.arraydim=nExp*nIncr;
        if (isfield(vnmrdata,'sw1'))
            NmrData.sw1=vnmrdata.sw1;
        end
        if (isfield(vnmrdata,'nchunk'))
            NmrData.nchunk=vnmrdata.nchunk;
        end
        if (isfield(vnmrdata,'droppts'))
            NmrData.droppts=vnmrdata.droppts;
        end
        %MN 7Sep12 to accomodate for T1 data
        if (isfield(vnmrdata.procpar,'d2'))
            NmrData.d2=vnmrdata.procpar.d2;
            NmrData.d2_org=vnmrdata.procpar.d2;
        end
        clear vnmrdata;
        guidata(hMainFigure,NmrData);
        % NmrData
        Setup_NmrData();
        
    end
    function Import_JeolGeneric(eventdata, handles)
        %[jeoldata]=jeolimport;
        [jeoldata]=jeolimport_generic;
        if ~isempty(jeoldata)
            Initiate_NmrData();
            %NmrData=guidata(hMainFigure);
            % setting up the NmrData structure - I think it is safest to
            % initialise them all (for the compiled version)
            NmrData.type='Jeol';
            NmrData.lrfid=jeoldata.digshift;
            NmrData.sfrq=jeoldata.sfrq;
            NmrData.FID=jeoldata.FID;
            
            NmrData.filename=jeoldata.filename;
            NmrData.dosyconstant=jeoldata.dosyconstant;
            NmrData.Gzlvl=jeoldata.Gzlvl;
            NmrData.ngrad=jeoldata.ngrad;
            %NmrData.procpar=jeoldata.procpar;
            NmrData.np=jeoldata.np;
            NmrData.fn=NmrData.np;
            NmrData.sw=jeoldata.sw;
            NmrData.at=jeoldata.at;
            NmrData.sp=jeoldata.sp;
            NmrData.lp=jeoldata.lp;
            NmrData.rp=jeoldata.rp;
            NmrData.gamma=jeoldata.gamma;
            NmrData.DELTA=jeoldata.DELTA;
            NmrData.delta=jeoldata.delta;
            if (isfield(jeoldata,'arraydim'))
                NmrData.arraydim=jeoldata.arraydim;
            else
                NmrData.arraydim=NmrData.ngrad;
            end
            if (isfield(jeoldata,'sw1'))
                NmrData.sw1=jeoldata.sw1;
            end
            if (isfield(jeoldata,'droppts'))
                NmrData.droppts=jeoldata.droppts;
            end
            if (isfield(jeoldata,'tau'))
                NmrData.tau=jeoldata.tau;
            end
            
            clear jeoldata;
            guidata(hMainFigure,NmrData);
            Setup_NmrData();
        else
            %do nothing
        end
    end
    function Import_Bruker(eventdata, handles)
         FilePath=uigetdir(pwd,'Choose the directory containing the NMR experiment (ser or fid file)');
        [brukerdata]=brukerimport(0,FilePath);
        if ~isempty(brukerdata)
            Initiate_NmrData();
            %NmrData=guidata(hMainFigure);
            % setting up the NmrData structure - I think it is safest to
            % initialise them all (for the compiled version)
            %I'll keep all points and see if I can sort out the processing
            NmrData.type='Bruker';
            NmrData.lrfid=brukerdata.digshift;
            NmrData.sfrq=brukerdata.sfrq;
            NmrData.FID=brukerdata.FID;
            NmrData.filename=brukerdata.filename;
            NmrData.dosyconstant=brukerdata.dosyconstant;
            NmrData.Gzlvl=brukerdata.Gzlvl;
            NmrData.ngrad=brukerdata.ngrad;
            NmrData.acqus=brukerdata.acqus;
            NmrData.acqu2s=brukerdata.acqu2s;
            NmrData.np=brukerdata.np;
            NmrData.ni=brukerdata.ni;
            NmrData.fn=NmrData.np;
            NmrData.sw=brukerdata.sw;
            NmrData.at=brukerdata.at;
            NmrData.sp=brukerdata.sp;
            NmrData.sp1=brukerdata.sp1;
            NmrData.lp=brukerdata.lp;
            NmrData.rp=brukerdata.rp;            
            NmrData.gamma=brukerdata.gamma;
            NmrData.DELTA=brukerdata.DELTA;
            NmrData.delta=brukerdata.delta;
            if (isfield(brukerdata,'arraydim'))
                NmrData.arraydim=brukerdata.arraydim;
            else
                NmrData.arraydim=NmrData.ngrad;
            end
            if (isfield(brukerdata,'sw1'))
                NmrData.sw1=brukerdata.sw1;
            end
            if (isfield(brukerdata,'tau'))
                NmrData.tau=brukerdata.tau;
            end
            if (isfield(brukerdata,'droppts'))
                NmrData.droppts=brukerdata.droppts;
            end

            if isfield(brukerdata,'vdlist')
                NmrData.d2=brukerdata.vdlist';
                NmrData.d2_org=brukerdata.vdlist';
            end
            if isfield(brukerdata,'vclist')
                NmrData.vclist=brukerdata.vclist';
                NmrData.vclist_org=brukerdata.vclist';
            end
            if isfield(brukerdata,'vc_constant')
                NmrData.vc_constant=brukerdata.vc_constant';
                NmrData.vc_constant_org=brukerdata.vc_constant';
            end
           
            clear brukerdata;
            guidata(hMainFigure,NmrData);
            Setup_NmrData();
        else
            %do nothing
        end
    end
    function Import_Bruker_array(eventdata, handles)
        
        Initiate_NmrData();
        guidata(hMainFigure,NmrData);
        
        [dirpath]=uigetdir('*','Choose the folder containing the numbered experiments');
        dlg_title='Data structure';
        dlg_prompt = {'First experiment','Numbers between experiment:','Last experiment'};
        num_lines=1;
        answer=inputdlg(dlg_prompt,dlg_title,num_lines);
        nStart=str2num(answer{1});
        nJump= str2num(answer{2});
        nStop=str2num(answer{3});
        nExp= round((nStop-nStart)/nJump +1);  
        Explist=zeros(nExp,1);
        for k=1:nExp
            Explist(k)=nStart+(k-1)*nJump;           
        end
        if isunix==1
            OSslash='/';
        else
            OSslash='\';
        end
        for expnr = 1:nExp
            %path=[dirpath OSslash num2str(Explist(expnr)) OSslash];
            path=[dirpath OSslash num2str(Explist(expnr)) ];
            [brukerdata]=brukerimport(0,path);
            if expnr==1
                nIncr=brukerdata.arraydim;
            end
            
            NmrData.FID(:,((expnr-1)*nIncr+1):expnr*nIncr)=brukerdata.FID(:,:);            
        end       
        NmrData.type='Bruker';
        NmrData.lrfid=brukerdata.digshift;
        NmrData.sfrq=brukerdata.sfrq;
        
        NmrData.filename=brukerdata.filename;
        NmrData.dosyconstant=6.1e10;
       % NmrData.Gzlvl=[0.0345 0.1294 0.1797 0.2187 0.2517];
        %NmrData.Gzlvl=[0.0345 0.1294];
        NmrData.Gzlvl=brukerdata.Gzlvl;
        NmrData.ngrad=nIncr;
        NmrData.np=brukerdata.np;
        NmrData.ni=brukerdata.ni;
        NmrData.fn=NmrData.np;
        NmrData.sw=brukerdata.sw;
        NmrData.at=brukerdata.at;
        NmrData.sp=brukerdata.sp;
        NmrData.sp1=brukerdata.sp1;
        NmrData.lp=0;
        NmrData.rp=0;
        NmrData.gamma=2.6752e+08;
        NmrData.DELTA=0.1;
        NmrData.delta=0.03;
        NmrData.arraydim=nExp*nIncr;
        guidata(hMainFigure,NmrData);
        %NmrData
        Setup_NmrData();   
    end
    function Import_Bruker_Processed(eventdata, handles)
        FilePath=uigetdir(pwd,'Choose the directory containing the processed data (e.g 1r, 2rr, etc)');
        [brukerdata]=brukerimport(1,FilePath);
        if ~isempty(brukerdata)
            Initiate_NmrData();
            %NmrData=guidata(hMainFigure);
            % setting up the NmrData structure - I think it is safest to
            % initialise them all (for the compiled version)
            %I'll keep all points and see if I can sort out the processing
            NmrData.type='Bruker';
            NmrData.lrfid=brukerdata.digshift;
            NmrData.sfrq=brukerdata.sfrq;
            NmrData.FID=brukerdata.FID;
            NmrData.filename=brukerdata.filename;
            NmrData.dosyconstant=brukerdata.dosyconstant;
            NmrData.Gzlvl=brukerdata.Gzlvl;
            NmrData.ngrad=brukerdata.ngrad;
            NmrData.acqus=brukerdata.acqus;
            NmrData.acqu2s=brukerdata.acqu2s;
            NmrData.np=brukerdata.np;
            NmrData.ni=brukerdata.ni;
            NmrData.fn=NmrData.np;
            NmrData.sw=brukerdata.sw;
            NmrData.at=brukerdata.at;
            NmrData.sp=brukerdata.sp;
            NmrData.sp1=brukerdata.sp1;
            NmrData.lp=brukerdata.lp;
            NmrData.rp=brukerdata.rp;            
            NmrData.gamma=brukerdata.gamma;
            NmrData.DELTA=brukerdata.DELTA;
            NmrData.delta=brukerdata.delta;
            if (isfield(brukerdata,'arraydim'))
                NmrData.arraydim=brukerdata.arraydim;
            else
                NmrData.arraydim=NmrData.ngrad;
            end
            if (isfield(brukerdata,'sw1'))
                NmrData.sw1=brukerdata.sw1;
            end
            if (isfield(brukerdata,'tau'))
                NmrData.tau=brukerdata.tau;
            end
            if (isfield(brukerdata,'droppts'))
                NmrData.droppts=brukerdata.droppts;
            end
                %MN 17Jan13 to accomodate for T1 data
            if (isfield(brukerdata,'vdlist'))
                NmrData.d2=brukerdata.vdlist';
            end  
            clear brukerdata;
            guidata(hMainFigure,NmrData);
            Setup_NmrData();
        else
            %do nothing
        end
    end
    function Import_Bruker_array_Processed(eventdata, handles)
        
        Initiate_NmrData();
        guidata(hMainFigure,NmrData);
        warndlg('All processed data must be in ../pdata/1 for each experiment for array import to work properly','Import Array of Processed Data')
        uiwait(gcf)
        [dirpath]=uigetdir('*','Choose the folder containing the numbered experiments');
        dlg_title='Data structure';
        dlg_prompt = {'First experiment','Numbers between experiment:','Last experiment'};
        num_lines=1;
        answer=inputdlg(dlg_prompt,dlg_title,num_lines);
        nStart=str2num(answer{1});
        nJump= str2num(answer{2});
        nStop=str2num(answer{3});
        nExp= (nStop-nStart)/nJump +1; 
        Explist=zeros(nExp,1);
        for k=1:nExp
            Explist(k)=nStart+(k-1)*nJump;           
        end
         if isunix==1
            OSslash='/';
        else
            OSslash='\';
        end
        for expnr = 1:nExp
            path=[dirpath OSslash num2str(Explist(expnr)) OSslash 'pdata' OSslash '1']; %always use .../pdata/1
            [brukerdata]=brukerimport(1,path);
            if expnr==1
                nIncr=brukerdata.arraydim;
            end
            NmrData.FID(:,((expnr-1)*nIncr+1):expnr*nIncr)=brukerdata.FID(:,:);
            
        end       
        NmrData.type='Bruker';
        NmrData.lrfid=brukerdata.digshift;
        NmrData.sfrq=brukerdata.sfrq;        
        NmrData.filename=brukerdata.filename;
        NmrData.dosyconstant=6.1e10;
        NmrData.Gzlvl=brukerdata.Gzlvl;
        NmrData.ngrad=nIncr;
        NmrData.np=brukerdata.np;
        NmrData.ni=brukerdata.ni;
        NmrData.fn=NmrData.np;
        NmrData.sw=brukerdata.sw;
        NmrData.at=brukerdata.at;
        NmrData.sp=brukerdata.sp;
        NmrData.sp1=brukerdata.sp1;
        NmrData.lp=0;
        NmrData.rp=0;
        NmrData.gamma=2.6752e+08;
        NmrData.DELTA=0.1;
        NmrData.delta=0.03;
        NmrData.arraydim=nExp*nIncr;
        guidata(hMainFigure,NmrData);
        %NmrData
        Setup_NmrData();      
        
    end
    function Import_DOSYToolboxASCII(eventdata, handles)
        [filename, pathname] = uigetfile('*.*','Import DOSY Toolbox ASCII format');
        filepath=[pathname filename];
        statfil=fopen(filepath, 'rt');
       
        hp=msgbox('Reading data - this may take a while','Data Import');
        [ImportData]=ImportDOSYToolboxFormat(statfil);
        %FieldNames=fieldnames(ImportData)
        close(hp)
        Initiate_NmrData();
        NmrData=guidata(hMainFigure);
        % Import mandatory fields first
        NmrData.filename=filepath;
        if isfield(ImportData,'DOSYToolboxFormatVersion')
            DOSYToolboxFormatVersion=ImportData.DOSYToolboxFormatVersion.Value; 
        else
            error('File import. Mandatory "DOSY Toolbox Format Version" is missing ')
        end
        if isfield(ImportData,'DataClass')
            DataClass=ImportData.DataClass.Value;
        else
            error('File import. Mandatory "Data Class" is missing ')
        end
        if isfield(ImportData,'ComplexData')
            ComplexData=ImportData.ComplexData.Value;
        else
            error('File import. Mandatory "Complex Data" is missing ')
        end
        if isfield(ImportData,'PointsPerRow')
            NmrData.np=ImportData.PointsPerRow.Value;
        else
            error('File import. Mandatory "Points Per Row" is missing ')
        end
        if isfield(ImportData,'ObserveFrequency')
            NmrData.sfrq=ImportData.ObserveFrequency.Value;
        else
            error('File import. Mandatory "Observe Frequency" is missing ')
        end
        if isfield(ImportData,'SpectralWidth')
            NmrData.sw=ImportData.SpectralWidth.Value;
        else
            error('File import. Mandatory "Spectral Width" is missing ')
        end
        if isfield(ImportData,'AcquisitionTime')
            NmrData.at=ImportData.AcquisitionTime.Value;
        else
            error('File import. Mandatory "Acquisition Time" is missing ')
        end
        if isfield(ImportData,'LeftRotation')
            NmrData.lrfid=ImportData.LeftRotation.Value;
        end
        if isfield(ImportData,'LowestFrequency')
            NmrData.sp=ImportData.LowestFrequency.Value;
        else
            error('File import. Mandatory "Lowest Frequency" is missing ')
        end
        
        if isfield(ImportData,'NumberOfArrays')
            NumberOfArrays=ImportData.NumberOfArrays.Value;
        else
            error('File import. Mandatory "Number Of Arrays" is missing ')
        end
        if isfield(ImportData,'ObserveNucleus')
            ObserveNucleus=ImportData.ObserveNucleus.Value; 
        else
            error('File import. Mandatory "Observe Nucleus" is missing ')
        end
        %Import optional fields
        if isfield(ImportData,'RightPhase')
            NmrData.rp=ImportData.RightPhase.Value;
        else
            NmrData.rp=0;
        end
        if isfield(ImportData,'LeftPhase')
            NmrData.lp=ImportData.LeftPhase.Value;
        else
            NmrData.lp=0;
        end
        
        
        if isfield(ImportData,'SpectrometerDataSystem')
            NmrData.type=ImportData.SpectrometerDataSystem.Value;
        else
            NmrData.type='Unknown';
        end
        if isfield(ImportData,'DataType')
            DataType=ImportData.DataType.Value;
        else
            DataType='';
        end
        if isfield(ImportData,'BinaryFileName')
            BinaryFileName=ImportData.BinaryFileName.Value; 
        else
            BinaryFileName=''; 
        end
        if isfield(ImportData,'PulseSequenceName')
            PulseSequenceName=ImportData.PulseSequenceName.Value; 
        else
            PulseSequenceName=''; 
        end
        if isfield(ImportData,'FourierNumber')
            NmrData.fn=ImportData.FourierNumber.Value;
        else
            NmrData.fn=NmrData.np;
        end
        %If DOSY data
        if strcmp(DataType,'DOSY data') || strcmp(DataType,'DOSY') || strcmp(DataType,'SCORE residuals')
            disp(['Labelled as: ' DataType])
            %check for mandatory DOSY parameters
            if isfield(ImportData,'GradientShape')
                GradientShape=ImportData.GradientShape.Value;
            else
                GradientShape='Rectangular';
                %error('File import. Mandatory DOSY data parameter "Gradient Shape" is missing ')
            end
            if strcmpi(GradientShape,'Square') || strcmpi(GradientShape,'Rectangular')
                %all is fine
            else
                disp('Only rectangular gradient shapes supported at the moment, treating them as such')
                %error('File import.Compensation for non rectangular "Gradient Shape" is not yet implemented ')
            end
            
            if isfield(ImportData,'DiffusionDelay')
                NmrData.DELTA=ImportData.DiffusionDelay.Value;
            else
                error('File import. Mandatory DOSY data parameter "Diffusion Delay" is missing ')
            end
            if isfield(ImportData,'DiffusionEncodingTime')
                NmrData.delta=ImportData.DiffusionEncodingTime.Value;
            else
                NmrData.delta=1;
                %error('File import. Mandatory DOSY data parameter "Diffusion Encoding Time" is missing ')
            end
            if isfield(ImportData,'Dosygamma')
                Dosygamma=ImportData.Dosygamma.Value;
                NmrData.gamma=Dosygamma;
            else
                Dosygamma=1;
                NmrData.gamma=Dosygamma;
               % error('File import. Mandatory DOSY data parameter "Dosygamma" is missing ')
            end
            if isfield(ImportData,'PulseSequenceType')
                PulseSequenceType=ImportData.PulseSequenceType.Value;
            else
                error('File import. Mandatory DOSY data parameter "Pulse Sequence Type" is missing ')
            end
            if strcmpi(PulseSequenceType,'Other')
                if isfield(ImportData,'Dosytimecubed') && ~isempty(ImportData.Dosytimecubed)
                    NmrData.dosyconstant=ImportData.Dosytimecubed.Value.*Dosygamma.^2;
                    NmrData.DELTAprime=NmrData.dosyconstant/(Dosygamma.^2.*NmrData.delta.^2);
                else
                    error('File import. Mandatory (when pulse sequence is Other) DOSY data parameter "Dosytimecubed" is missing ')
                end
            elseif strcmpi(PulseSequenceType,'Bipolar')
                if isfield(ImportData,'Dosytimecubed') && ~isempty(ImportData.Dosytimecubed)
                    disp('File import. Parameter "Dosytimecubed" present - over rules calculation of corrected diffusion time for Bipolar sequence ')
                    NmrData.dosyconstant=ImportData.Dosytimecubed.Value.*Dosygamma.^2.*NmrData.DELTAprime;
                elseif isfield(ImportData,'Tau') && ~isempty(ImportData.Tau)
                    disp('File import. calculation of corrected diffusion time using Tau')
                    NmrData.DELTAprime=NmrData.DELTA-NmrData.delta/3-ImportData.Tau/2;
                    NmrData.dosyconstant=NmrData.gamma.^2.*NmrData.delta.^2.*...
                        NmrData.DELTAprime;
                else
                    error('File import. Parameter "Tau" (mandatory for Bipolar pulse sequences) missing')
                end
            elseif strcmpi(PulseSequenceType,'Unipolar')
                if isfield(ImportData,'Dosytimecubed') && ~isempty(ImportData.Dosytimecubed)
                    disp('File import. Parameter "Dosytimecubed" present - over rules calculation of corrected diffusion time for Unipolar sequence ')
                    NmrData.dosyconstant=ImportData.Dosytimecubed.Value.*Dosygamma.^2;
                else
                    disp('File import. calculation of corrected diffusion time')
                    NmrData.DELTAprime=NmrData.DELTA-NmrData.delta/3;
                    NmrData.dosyconstant=NmrData.gamma.^2.*NmrData.delta.^2.*...
                        NmrData.DELTAprime;
                end
            else
                error('File import. mandatory DOSY data parameter "Pulse Sequence Type" must be Other, Bipolar or Unipolar')
            end
            if isfield(ImportData,'GradientAmplitude')
                NmrData.ngrad=length(ImportData.GradientAmplitude.Value);
                for p=1:NmrData.ngrad
                    NmrData.Gzlvl(p)=str2double(ImportData.GradientAmplitude.Value{p});
                end
                %ImportData
                %ImportData.NumberOfRows.Value
                NmrData.arraydim=ImportData.NumberOfRows.Value;
                %NmrData.arraydim=NmrData.ngrad;
            else
                error('File import. Mandatory DOSY data parameter "Gradient Amplitude" is missing ')
            end
            %elseif strcmp(DataType,'SCORE components')
            
        elseif  ~isempty(DataType)
            disp(DataType)
            NmrData.Gzlvl=0;
            NmrData.dosyconstant=0;
            NmrData.gamma=267524618.573;
            NmrData.DELTA='non existing';
            NmrData.delta='non existing';
            NmrData.ngrad=1;
            if NumberOfArrays==0
                disp('No arrays ; Trying import as a 1D spectrum')
                NmrData.arraydim=1;
            elseif NumberOfArrays==1
                disp('Import as an arrayed data set with one array')
                %find the array
                fnames=fieldnames(ImportData);
                for fds=1:length(fnames)
                    if iscell(ImportData.(fnames{fds}).Value)
                        NmrData.arraydim=numel(ImportData.(fnames{fds}).Value);
                        %numel(ImportData.(fnames{fds}).Value)
                        break;
                    end
                end
            elseif NumberOfArrays==2
                disp('Import as an arrayed data set with two nested arrays')
                error('File import. This import option is not implemented yet')
            end
        else
            error('File import. Unkown data type - aborting')
        end
       
        %import phase array if present
        if isfield(ImportData,'LeftPhaseArray')
            disp('LPA')
            
            
            for p=1:NmrData.arraydim
                NmrData.lpInd(p)=str2double(ImportData.LeftPhaseArray.Value{p});
            end
        end
                   
        if isfield(ImportData,'RightPhaseArray')
            
            for p=1:NmrData.arraydim
                NmrData.rpInd(p)=str2double(ImportData.RightPhaseArray.Value{p});
            end
        
        end
        
        %If synthetic
        if isfield(ImportData,'NumberofSyntheticPeaks')
            NmrData.issynthetic=1;
            set(hEditnpeaks,'string',ImportData.NumberofSyntheticPeaks.Value)
            if isfield(ImportData,'LowestGradientStrength')
                set(hEditmingrad,'string',ImportData.LowestGradientStrength.Value)
            end
            if isfield(ImportData,'HighestGradientStrength')
                set(hEditmaxgrad,'string',ImportData.HighestGradientStrength.Value)
            end
            if isfield(ImportData,'NumberofDOSYIncrements')
                set(hEditni,'string',ImportData.NumberofDOSYIncrements.Value)
            end
            if isfield(ImportData,'SignaltoNoiseRatio')
                set(hEditnoise,'string',ImportData.SignaltoNoiseRatio.Value)
            end
            if isfield(ImportData,'PeakFrequencies')
                    SynthData(:,1)=str2double(ImportData.PeakFrequencies.Value);
                    SynthData(:,2)=str2double(ImportData.DiffusionCoefficients.Value); 
                    SynthData(:,3)=str2double(ImportData.PeakAmplitudes.Value); 
                    SynthData(:,4)=str2double(ImportData.LineWidthsLorentzian.Value); 
                    SynthData(:,5)=str2double(ImportData.LineWidthsGaussian.Value); 
                set(hTableSynthPeaks,'Data',SynthData)
            end
        end
        %Import Data Points
        if isfield(ImportData,'DataPoints')
            
            if strcmpi(DataClass,'FID')
                disp('FID data')
                if strcmpi(ImportData.BinaryFileName.ParmForm,'string')
                    disp('Binary Data')
                    filepath=filepath(1:(end-4));
                    filepath=[filepath '.bin'];
                    binfile=fopen(filepath, 'r','b');
                    FID=fread(binfile,'int64','b');
                    R=FID(1:length(FID)/2);
                    I=FID(length(FID)/2+1:end);
                    FID=complex(R,I);
                    NmrData.FID=reshape(FID,NmrData.np,NmrData.arraydim);
                else
                    NmrData.FID=reshape(ImportData.DataPoints.Value,NmrData.np,NmrData.arraydim);
                end
            elseif strcmpi(DataClass,'Spectra') || strcmpi(DataClass,'Spectrum')
                if strcmpi(ComplexData,'Yes')
                    disp('Spectra data (complex)')
                    if strcmpi(ImportData.BinaryFileName.ParmForm,'string')
                        disp('Binary Data')
                        filepath=filepath(1:(end-4));
                        filepath=[filepath '.bin'];
                        binfile=fopen(filepath, 'r','b');
                        FID=fread(binfile,'int64','b');
                        R=FID(1:length(FID)/2);
                        I=FID(length(FID)/2+1:end);
                        FID=complex(R,I);
                        NmrData.SPECTRA=reshape(FID,NmrData.np,NmrData.arraydim);
                    else
                        
                        NmrData.SPECTRA=reshape(ImportData.DataPoints.Value,NmrData.np,NmrData.arraydim);
                        
                    end
                    NmrData.SPECTRA=fftshift(NmrData.SPECTRA,1);
                    NmrData.FID=ifft(NmrData.SPECTRA);
                    NmrData.FID(1,:)=NmrData.FID(1,:).*2;
                    NmrData.at=NmrData.np/(NmrData.sw*NmrData.sfrq);
                elseif strcmpi(ComplexData,'No')
                    disp('Spectra data (real)')
                    if strcmpi(ImportData.BinaryFileName.ParmForm,'string')
                        disp('Binary Data')
                        filepath=filepath(1:(end-4));
                        filepath=[filepath '.bin'];
                        binfile=fopen(filepath, 'r','b');
                        FID=fread(binfile,'int64','b');
                        NmrData.SPECTRA=reshape(FID,NmrData.fn,NmrData.arraydim);
                    else
                        NmrData.SPECTRA=reshape(ImportData.DataPoints.Value,NmrData.fn,NmrData.arraydim);
                        
                    end
                    NmrData.SPECTRA=fftshift(NmrData.SPECTRA,1);
                    NmrData.FID=ifft(NmrData.SPECTRA);
                    NmrData.FID(1,:)=NmrData.FID(1,:)./2;
                    NmrData.FID=NmrData.FID(1:round(NmrData.fn/2),:);
                    NmrData.np=round(NmrData.fn/2);
                    NmrData.fn=NmrData.np*2;
                    NmrData.at=NmrData.np/(NmrData.sw*NmrData.sfrq);
                else
                    error('File import. Cannot determine if data is complex')
                end
            else
                error('File import. Unknown Data Class')
            end
        else
            error('File import. Mandatory DOSY data parameter "Data Points" is missing ')
        end
        %size(NmrData.FID)
        guidata(hMainFigure,NmrData);  
        Setup_NmrData();       
        NmrData=guidata(hMainFigure);
        
    end
    function Import_FireBird(eventdata, handles)
        [firebirddata]=firebirdimport;
        if ~isempty(firebirddata)
            Initiate_NmrData();
            %NmrData=guidata(hMainFigure);
            % setting up the NmrData structure - I think it is safest to
            % initialise them all (for the compiled version)
            NmrData.type='Firebird';
            NmrData.sfrq=firebirddata.sfrq;
            NmrData.FID=firebirddata.FID;
            NmrData.filename=firebirddata.filename;
            NmrData.dosyconstant=firebirddata.dosyconstant;
            NmrData.Gzlvl=firebirddata.Gzlvl;
            NmrData.ngrad=firebirddata.ngrad;
            %NmrData.procpar=vnmrdata.procpar;
            NmrData.np=firebirddata.np;
            NmrData.ni=firebirddata.ni;
            NmrData.sw=firebirddata.sw;
            NmrData.sw1=firebirddata.sw1;
            NmrData.at=firebirddata.at;
            NmrData.sp=firebirddata.sp;
           % NmrData.sp1=firebirddata.sp1;
            NmrData.rp=firebirddata.rp;
            NmrData.rp1=firebirddata.rp1;   %AC
            NmrData.lp=firebirddata.lp;
            NmrData.lp1=firebirddata.lp1;   %AC
            NmrData.gamma=firebirddata.gamma;
            NmrData.DELTA=firebirddata.DELTA;
            NmrData.delta=firebirddata.delta;
            NmrData.gcal_orig=firebirddata.DAC_to_G;
            if (isfield(firebirddata,'arraydim'))
                NmrData.arraydim=firebirddata.arraydim;
            else
                NmrData.arraydim=NmrData.ngrad;
            end
            if (isfield(firebirddata,'sw1'))
                NmrData.sw1=firebirddata.sw1;
            end
            if (isfield(firebirddata,'nchunk'))
                NmrData.nchunk=firebirddata.nchunk;
            end
            if (isfield(firebirddata,'droppts'))
                NmrData.droppts=firebirddata.droppts;
            end
            %MN 7Sep12 to accomodate for T1 data
            if (isfield(firebirddata,'d2'))
                NmrData.d2=firebirddata.d2;
            end      
    
            clear firebirddata;            
            guidata(hMainFigure,NmrData);
            % NmrData
            Setup_NmrData();
        else
            %do nothing
        end
       
    end
    function Import_Spinach(eventdata, handles)
         Initiate_NmrData();
        NmrData=guidata(hMainFigure);
        [filename, pathname] = uigetfile('*.spn','Open Spinach Data');
        filepath=[pathname filename];
        S=load(filepath,'-mat');
        S=S.SpinachData;
        % Copy over all relevant parameters
        names=fieldnames(S);
        for nstruct=1:length(names)
            NmrData.(names{nstruct})=S.(names{nstruct});
        end
        
        NmrData.type='Spinach';
        NmrData.at=NmrData.np/(NmrData.sw*NmrData.sfrq);
        NmrData.fn=NmrData.np;
        NmrData.rp=0;
        NmrData.lp=0;
        NmrData.delta='non existing';
        NmrData.DELTA='non existing';
        NmrData.dosyconstant=0;
        NmrData.arraydim=1;
        NmrData.ngrad=1;
        NmrData.filename=filepath;
        NmrData.fshift=0;
        
        guidata(hMainFigure,NmrData);
        Setup_NmrData();
        set(hEditFn,'string',num2str(NmrData.fn));
        set(hEditNp,'string',num2str(NmrData.np));
        set(hEditPh1,'string',num2str(NmrData.lp,4))
        set(hEditPh0,'string',num2str(NmrData.rp,4))
        set(hSliderPh0,'value',NmrData.rp);
        set(hSliderPh1,'value',NmrData.lp);
        set(hEditFlip,'string',num2str(NmrData.gradnr));
        set(hEditFlip2,'string',num2str(NmrData.array2nr));
        set(hEditFlipSpec,'string',num2str(NmrData.flipnr));
        set(hTextFlip,'string',['/' num2str(NmrData.ngrad)]);
        set(hTextFlip2,'string',['/' num2str(NmrData.narray2)]);
        set(hTextFlipSpec,'string',['/' num2str(NmrData.arraydim)]);
        hPlot=plot(hAxes,NmrData.Specscale,real(NmrData.SPECTRA(:,NmrData.flipnr)));
        set(hPlot,'HitTest','off')
       % xlim(NmrData.xlim);
        %ylim(NmrData.ylim);
        set(hAxes,'Xdir','Reverse')
        guidata(hMainFigure,NmrData);
        disp(NmrData.filename)
    end
    function Open_data( eventdata, handles)
        Initiate_NmrData();
        NmrData=guidata(hMainFigure);
        [filename, pathname] = uigetfile('*.nmr','Open NMR Data');
        filepath=[pathname filename];
        S=load(filepath,'-mat');
        S=S.NmrData;
        % Copy over all relevant parameters
        names=fieldnames(S);
        for nstruct=1:length(names)
            NmrData.(names{nstruct})=S.(names{nstruct});
        end
        NmrData.fshift=zeros(1,NmrData.arraydim);
        set(hEditFn,'string',num2str(NmrData.fn));
        set(hEditNp,'string',num2str(NmrData.np));
        set(hEditPh1,'string',num2str(NmrData.lp,4))
        set(hEditPh0,'string',num2str(NmrData.rp,4))
        set(hSliderPh0,'value',NmrData.rp);
        set(hSliderPh1,'value',NmrData.lp);
        set(hEditFlip,'string',num2str(NmrData.gradnr));
        set(hEditFlip2,'string',num2str(NmrData.array2nr));
        set(hEditFlipSpec,'string',num2str(NmrData.flipnr));
        set(hTextFlip,'string',['/' num2str(NmrData.ngrad)]);
        set(hTextFlip2,'string',['/' num2str(NmrData.narray2)]);
        set(hTextFlipSpec,'string',['/' num2str(NmrData.arraydim)]);
        hPlot=plot(hAxes,NmrData.Specscale,real(NmrData.SPECTRA(:,NmrData.flipnr)));
        set(hPlot,'HitTest','off')
        xlim(NmrData.xlim);
        ylim(NmrData.ylim);
        set(hAxes,'Xdir','Reverse')
        guidata(hMainFigure,NmrData);
        disp(NmrData.filename)
    end
    function SaveDataMatlab( eventdata, handles)
        NmrData=guidata(hMainFigure);
        [filename, pathname] = uiputfile('*.nmr','Save NMR Data');
        filepath=[pathname filename];
        NmrData.xlim= get(hAxes,'xlim');
        NmrData.ylim= get(hAxes,'ylim');
        guidata(hMainFigure,NmrData);
        save(filepath,'NmrData','-v7.3');
    end
    function SaveFIDDataToolboxASCII( eventdata, handles)
        [filename, pathname] = uiputfile('*.txt','Export data in ASCII format');
        filepath=[pathname filename];
        statfil=fopen(filepath, 'wt');        
        ExportDOSYToolboxFormat(statfil, 1, 1, filename, pathname);        
    end
    function SaveComplexSpecDataToolboxASCII( eventdata, handles)
        [filename, pathname] = uiputfile('*.txt','Export data in ASCII format');
        filepath=[pathname filename];
        statfil=fopen(filepath, 'wt');
        ExportDOSYToolboxFormat(statfil, 2, 1, filename, pathname);
      
    end
    function SaveRealSpecDataToolboxASCII( eventdata, handles)
        [filename, pathname] = uiputfile('*.txt','Export data in ASCII format');
        filepath=[pathname filename];
        statfil=fopen(filepath, 'wt');
        ExportDOSYToolboxFormat(statfil, 3, 1, filename, pathname);
     end
    function SaveFIDDataToolboxBinary( eventdata, handles)
        [filename, pathname] = uiputfile('*.txt','Export data in ASCII format');
        filepath=[pathname filename];
        statfil=fopen(filepath, 'wt');
        ExportDOSYToolboxFormat(statfil, 1, 2, filename, pathname);
    end
    function SaveComplexSpecDataToolboxBinary( eventdata, handles)
        [filename, pathname] = uiputfile('*.txt','Export data in ASCII format');
        filepath=[pathname filename];
        statfil=fopen(filepath, 'wt');
        ExportDOSYToolboxFormat(statfil, 2, 2, filename, pathname);
    end
    function SaveRealSpecDataToolboxBinary( eventdata, handles)
        [filename, pathname] = uiputfile('*.txt','Export data in ASCII format');
        filepath=[pathname filename];
        statfil=fopen(filepath, 'wt');
        ExportDOSYToolboxFormat(statfil, 3, 2, filename, pathname);
    end
    function QuitDOSYToolbox(eventdata, handles)
        if isfield(NmrData,'hEditParameters')
            close(NmrData.hEditParameters)
        end
        if isfield(NmrData,'hSettings')
            close(NmrData.hSettings)
        end
        delete(hMainFigure)
    end
    function ExportDOSY( eventdata, handles)
        [filename, pathname] = uiputfile('*.pfg','Save NMR Data for DOSY processing');
        filepath=[pathname filename];
        pfgdata=PreparePfgnmrdata();
        save(filepath,'pfgdata','-v7.3');
    end
    function ExportPARAFAC( eventdata, handles)
        [filename, pathname] = uiputfile('*.pfc','Save NMR Data for PARAFAC processing');
        filepath=[pathname filename];
        pfgnmrdata=PreparePfgnmr3Ddata();
        speclim=xlim();
        if speclim(1)<NmrData.sp
            speclim(1)=NmrData.sp;
        end
        if speclim(2)>(NmrData.sw+NmrData.sp)
            speclim(2)=(NmrData.sw+NmrData.sp);
        end
        Specrange=speclim;
        if length(Specrange)~=2
            error('SCORE: Specrange should have excatly 2 elements')
        end
        if Specrange(1)<pfgnmrdata.sp
            disp('SCORE: Specrange(1) is too low. The minumum will be used')
            Specrange(1)=pfgnmrdata.sp;
        end
        if Specrange(2)>(pfgnmrdata.wp+pfgnmrdata.sp)
            disp('SCORE: Specrange(2) is too high. The maximum will be used')
            Specrange(2)=pfgnmrdata.wp+pfgnmrdata.sp;
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
        pfgnmrdata.sp=pfgnmrdata.Ppmscale(begin);
        pfgnmrdata.wp=pfgnmrdata.Ppmscale(endrange)-pfgnmrdata.Ppmscale(begin);
        pfgnmrdata.Ppmscale=pfgnmrdata.Ppmscale(begin:endrange);
        pfgnmrdata.SPECTRA=pfgnmrdata.SPECTRA(begin:endrange,:,:);
        pfgnmrdata.np=length(pfgnmrdata.Ppmscale) ;
        save(filepath,'pfgnmrdata','-v7.3');
    end
    function ExportTDData( eventdata, handles)
        [filename, pathname] = uiputfile('*.txt','Save Time domain NMR Data');
        filepath=[pathname filename];
        statfil=fopen(filepath, 'wt');
        %print out FID data to file
        fprintf(statfil,'%-s  \n',['Time domain data for: ' NmrData.filename]);
        fprintf(statfil,'%-s\t\t\t  %s \n','Data type: ', NmrData.type);
        fprintf(statfil,'%-s\t\t\t %-f  \n','Spectrometer frequency (MHz): ', NmrData.sfrq);
        fprintf(statfil,'%-s\t\t %-d  \n','Number of complex points per FID: ', NmrData.np);
        fprintf(statfil,'%-s\t\t\t\t %-f  \n','Spectral width(ppm): ', NmrData.sw);
        fprintf(statfil,'%-s\t\t\t\t %-f  \n','Acquistion time: ', NmrData.at);
        fprintf(statfil,'%-s\t %-f  \n','Frequency at right end of spectrum (ppm): ', NmrData.sp);
        fprintf(statfil,'%-s\t %-f  \n','Diffusion encoding time (little delta) (s): ', NmrData.delta);
        fprintf(statfil,'%-s\t\t\t\t %-f  \n','Diffusion time (s): ', NmrData.DELTA);
        fprintf(statfil,'%-s\t\t\t\t %-f  \n','Magnetogyric ratio: ', NmrData.gamma);
        fprintf(statfil,'%-s\t\t\t\t\t %-f  \n','DOSYconstant: ', NmrData.dosyconstant);
        fprintf(statfil,'%-s\n','Gradient amplitues (T/m): ');
        for k=1:length(NmrData.Gzlvl)
            fprintf(statfil,'%-16f\n',NmrData.Gzlvl(k));
        end
        fprintf(statfil,'%-s\n','FID data points: ');
        fprintf(statfil,'%s\t\t%s\n','real', 'imag');
        for m=1:length(NmrData.FID(1,:))
            for k=1:length(NmrData.FID(:,m))
                fprintf(statfil,'%-16f\t%-16f\n',real(NmrData.FID(k,m)),...
                    imag(NmrData.FID(k,m)));
            end
        end
        fclose(statfil);
    end
    function ExportBinnedMenuPfg(option,eventdata, handles)
        ExportBinned(1)
    end
    function ExportBinnedMenuCsv(option,eventdata, handles)
        ExportBinned(2)
    end
    function ExportBinned(option,eventdata, handles)
        NmrData=guidata(hMainFigure);
        switch option
            case 0 %just plot
                
            case 1 %export pfg
                [filename, pathname] = uiputfile('*.pfg','Save Binned NMR Data in pfg format');
                filepath=[pathname filename];
            case 2 %export csv
                [filename, pathname] = uiputfile('*.csv','Save Binned NMR Data in csv format');
                filepath=[pathname filename];
            otherwise %
                error('illegal choice')
                
        end
        pfgnmrdata=PreparePfgnmr3Ddata();
        binsize=str2double(get(hEditBin,'string'));
        binnum=round(NmrData.sw/binsize +0.5);
        binpoints=round(NmrData.fn/binnum);
        tmpspec=real(pfgnmrdata.SPECTRA);
        pfgnmrdata.SPECTRA=zeros(round(binnum),pfgnmrdata.ngrad,pfgnmrdata.narray2);
        
        for arr2=1:pfgnmrdata.narray2
            for ngrad=1:pfgnmrdata.ngrad
                for k=1:binnum-1
                    pfgnmrdata.SPECTRA(k,ngrad,arr2)= sum(tmpspec...
                        ( (((k-1)*binpoints+1):k*binpoints),ngrad,arr2));
                end
            end
        end
        
        switch NmrData.shiftunits
            case 'ppm'
                pfgnmrdata.Ppmscale=...
                    linspace(NmrData.sp,(NmrData.sw+NmrData.sp),binnum);
            case 'Hz'
                pfgnmrdata.Ppmscale=...
                    linspace(NmrData.sp.*NmrData.sfrq,(NmrData.sw+NmrData.sp).*NmrData.sfrq,binnum);
            otherwise
                error('illegal choice')
        end
        
        speclim=xlim();
        if speclim(1)<NmrData.sp
            speclim(1)=NmrData.sp;
        end
        if speclim(2)>(NmrData.sw+NmrData.sp)
            speclim(2)=(NmrData.sw+NmrData.sp);
        end
        Specrange=speclim;
        if length(Specrange)~=2
            error('SCORE: Specrange should have excatly 2 elements')
        end
        if Specrange(1)<pfgnmrdata.sp
            disp('SCORE: Specrange(1) is too low. The minumum will be used')
            Specrange(1)=pfgnmrdata.sp;
        end
        if Specrange(2)>(pfgnmrdata.wp+pfgnmrdata.sp)
            disp('SCORE: Specrange(2) is too high. The maximum will be used')
            Specrange(2)=pfgnmrdata.wp+pfgnmrdata.sp;
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
        pfgnmrdata.sp=pfgnmrdata.Ppmscale(begin);
        pfgnmrdata.wp=pfgnmrdata.Ppmscale(endrange)-pfgnmrdata.Ppmscale(begin);
        pfgnmrdata.Ppmscale=pfgnmrdata.Ppmscale(begin:endrange);
        pfgnmrdata.SPECTRA=pfgnmrdata.SPECTRA(begin:endrange,:,:);
        pfgnmrdata.np=length(pfgnmrdata.Ppmscale);
        figure('Color',[0.9 0.9 0.9],...
            'NumberTitle','Off',...
            'Name','Current binned spectrum');
        subplot(2,1,1)
        bar(squeeze(pfgnmrdata.SPECTRA(:,1,NmrData.flipnr)));
        xlim([1 length(squeeze(pfgnmrdata.SPECTRA(:,1,NmrData.flipnr))) ])
        ylim('auto')
        set(gca,'Xdir','Reverse');
        subplot(2,1,2)
        plot(pfgnmrdata.Ppmscale,squeeze(pfgnmrdata.SPECTRA(:,1,NmrData.flipnr)));
        xlabel('\bf Chemical shift ');
        xlim([pfgnmrdata.Ppmscale(1) pfgnmrdata.Ppmscale(end)])
        ylim('auto')
        set(gca,'Xdir','Reverse');
        guidata(hMainFigure,NmrData);
        switch option
            case 0 %just plot
            case 1 %export pfg
                save(filepath,'pfgnmrdata','-v7.3');
            case 2 %export csv
                csvwrite(filepath,pfgnmrdata.SPECTRA);
            otherwise
                error('illegal choice')
        end
        
        
    end
    function Edit_Settings( eventdata, handles)
        NmrData=guidata(hMainFigure);
        if isfield(NmrData,'hSettings')
            close(NmrData.hSettings)
        end
        hSettings=figure(...
            'NumberTitle','Off',...
            'MenuBar','none',...
            'Units','Normalized',...
            'Visible','Off',...
            'DeleteFcn',@hSettings_DeleteFcn,...
            'Toolbar','none',...
            'ResizeFcn' , @hSettingsResizeFcn,...
            'Name','Settings');
        NmrData.hSettings=hSettings;
        hSettingsUiTabGroup=uitabgroup(...
            'Parent',hSettings,...
            'Position',[0.0 0.0 1.0 1.0],...
            'Units','Normalized');
        hSettingsUiTab1=uitab(...
            'Parent',hSettingsUiTabGroup,...
            'Title','Settings',...
            'Units','Normalized');
        hSettingsUiTab2=uitab(...
            'Parent',hSettingsUiTabGroup,...
            'Title','Diffusion',...
            'Units','Normalized');
        hSettingsUiTab3=uitab(...
            'Parent',hSettingsUiTabGroup,...
            'Title','NUG',...
            'Units','Normalized');
        hSettingsUiTab4=uitab(...
            'Parent',hSettingsUiTabGroup,...
            'Title','Relaxation',...
            'Units','Normalized');
        hScaleGroup=uibuttongroup(...
            'Parent',hSettingsUiTab1,...
            'Title','',...
            'FontWeight','bold',...
            'TitlePosition','centertop',...
            'Title','Scale values',...
            'ForegroundColor','Blue',...
            'Units','Normalized',...
            ...'SelectionChangeFcn', {@_Callback},...
            'Visible','On',...
            'Position',[0.25,0.2 ,0.25 ,0.2]);
        hEditScaleUp=uicontrol(...
            'Parent',hScaleGroup,...
            'Style','edit',...
            'Visible','On',...
            'BackgroundColor','w',...
            'Units','Normalized',...
            'TooltipString','Highest chemical shift value displayed',...
            'Max',1,...
            'Position',[0.1 0.6 0.4 0.3 ],...
            'CallBack', {@EditScaleUp_Callback});
        hTextUp=uicontrol(...
            'Parent',hScaleGroup,...
            'Style','text',...
            'Units','Normalized',...
            'horizontalalignment','left',...
            'FontWeight','bold',...
            'Position',[0.5 0.56 0.3 0.3 ],...
            'String','High' );
        hEditScaleDown=uicontrol(...
            'Parent',hScaleGroup,...
            'Style','edit',...
            'Visible','On',...
            'BackgroundColor','w',...
            'Units','Normalized',...
            'TooltipString','Highest chemical shift value displayed',...
            'Max',1,...
            'Position',[0.1 0.1 0.4 0.3 ],...
            'CallBack', {@EditScaleDown_Callback});
        hTextDown=uicontrol(...
            'Parent',hScaleGroup,...
            'Style','text',...
            'Units','Normalized',...
            'horizontalalignment','left',...
            'FontWeight','bold',...
            'Position',[0.5 0.06 0.3 0.3 ],...
            'String','Low' );
        hUnitsGroup=uibuttongroup(...
            'Parent',hSettingsUiTab1,...
            'Title','',...
            'FontWeight','bold',...
            'TitlePosition','centertop',...
            'Title','Horizontal scale',...
            'ForegroundColor','Blue',...
            'Units','Normalized',...
            'SelectionChangeFcn', {@Units_Callback},...
            'Visible','On',...
            'Position',[0.0,0.2 ,0.25 ,0.2]);
        hRadioPPM = uicontrol(...
            'Parent',hUnitsGroup,...
            'Style','RadioButton',...
            'String','ppm',...
            'FontWeight','Bold',...
            'Units','normalized',...
            'Position',[0.1 0.6 0.5 0.25]);
        hRadioHz = uicontrol(...
            'Parent',hUnitsGroup,...
            'Style','RadioButton',...
            'String','Hz',...
            'FontWeight','Bold',...
            'Units','normalized',...
            'Position',[0.1 0.2 0.5 0.25]);
        hDCGroup=uibuttongroup(...
            'Parent',hSettingsUiTab1,...
            'Title','',...
            'FontWeight','bold',...
            'TitlePosition','centertop',...
            'Title','DC correct FID',...
            'ForegroundColor','Blue',...
            'Units','Normalized',...
            'SelectionChangeFcn', {@DC_Callback},...
            'Visible','On',...
            'Position',[0.0,0.4 ,0.25 ,0.2]);
        hDCYesPPM = uicontrol(...
            'Parent',hDCGroup,...
            'Style','RadioButton',...
            'String','Yes',...
            'FontWeight','Bold',...
            'Units','normalized',...
            'Position',[0.1 0.6 0.5 0.25]);
        hDCNoPPM = uicontrol(...
            'Parent',hDCGroup,...
            'Style','RadioButton',...
            'String','No',...
            'FontWeight','Bold',...
            'Units','normalized',...
            'Position',[0.1 0.2 0.5 0.25]);
        
        
         hDCGroup=uibuttongroup(...
            'Parent',hSettingsUiTab1,...
            'Title','',...
            'FontWeight','bold',...
            'TitlePosition','centertop',...
            'Title','DC correct FID',...
            'ForegroundColor','Blue',...
            'Units','Normalized',...
            'SelectionChangeFcn', {@DC_Callback},...
            'Visible','On',...
            'Position',[0.0,0.4 ,0.25 ,0.2]);
        hDCYesPPM = uicontrol(...
            'Parent',hDCGroup,...
            'Style','RadioButton',...
            'String','Yes',...
            'FontWeight','Bold',...
            'Units','normalized',...
            'Position',[0.1 0.6 0.5 0.25]);
        hDCNoPPM = uicontrol(...
            'Parent',hDCGroup,...
            'Style','RadioButton',...
            'String','No',...
            'FontWeight','Bold',...
            'Units','normalized',...
            'Position',[0.1 0.2 0.5 0.25]);
        
        
        hDCLSSpecGroup=uibuttongroup(...
            'Parent',hSettingsUiTab1,...
            'Title','',...
            'FontWeight','bold',...
            'TitlePosition','centertop',...
            'Title','Left shift spectrum',...
            'ForegroundColor','Blue',...
            'Units','Normalized',...
            'SelectionChangeFcn', {@LSSpec_Callback},...
            'Visible','On',...
            'Position',[0.25,0.0 ,0.25 ,0.2]);
        hDCSpecLinPPM = uicontrol(...
            'Parent',hDCLSSpecGroup,...
            'Style','RadioButton',...
            'String','Linear',...
            'FontWeight','Bold',...
            'Units','normalized',...
            'Position',[0.01 0.6 0.5 0.25]);
        hDCSpecConPPM = uicontrol(...
            'Parent',hDCLSSpecGroup,...
            'Style','RadioButton',...
            'String','Const',...
            'FontWeight','Bold',...
            'Units','normalized',...
            'Position',[0.01 0.2 0.5 0.25]);
        hEditLSspec=uicontrol(...
            'Parent',hDCLSSpecGroup,...
            'Style','edit',...
            'Visible','On',...
            'BackgroundColor','w',...
            'Units','Normalized',...
            'TooltipString','The spectrum will be left shifted with lsspec data points',...
            'Max',1,...
            'Position',[0.51 0.3 0.3 0.25 ],...
            'CallBack', {@EditLSspec_Callback});
         hTextlsspec=uicontrol(...
            'Parent',hDCLSSpecGroup,...
            'Style','text',...
            'Units','Normalized',...
            'ForegroundColor','Blue',...
            'horizontalalignment','center',...
            'FontWeight','bold',...
            'Position',[0.51 0.55 0.3 0.2 ],...
             'String','lsspec' );
        
         hDCSpecGroup=uibuttongroup(...
            'Parent',hSettingsUiTab1,...
            'Title','',...
            'FontWeight','bold',...
            'TitlePosition','centertop',...
            'Title','DC correct spectrum',...
            'ForegroundColor','Blue',...
            'Units','Normalized',...
            'SelectionChangeFcn', {@DCSpec_Callback},...
            'Visible','On',...
            'Position',[0.25,0.4 ,0.25 ,0.2]);
        hDCSpecYesPPM = uicontrol(...
            'Parent',hDCSpecGroup,...
            'Style','RadioButton',...
            'String','Yes',...
            'FontWeight','Bold',...
            'Units','normalized',...
            'Position',[0.1 0.6 0.5 0.25]);
        hDCSpecNoPPM = uicontrol(...
            'Parent',hDCSpecGroup,...
            'Style','RadioButton',...
            'String','No',...
            'FontWeight','Bold',...
            'Units','normalized',...
            'Position',[0.1 0.2 0.5 0.25]);     
        
        
        
        hEditfpmult=uicontrol(...
            'Parent',hSettingsUiTab1,...
            'Style','edit',...
            'Visible','On',...
            'BackgroundColor','w',...
            'Units','Normalized',...
            'TooltipString','The first data point in the FID(s) will be multiplied with fpmult',...
            'Max',1,...
            'Position',[0.075 0.63 0.075 0.05 ],...
            'CallBack', {@Editfpmult_Callback});
        hTextfpmult=uicontrol(...
            'Parent',hSettingsUiTab1,...
            'Style','text',...
            'Units','Normalized',...
            'ForegroundColor','Blue',...
            'horizontalalignment','left',...
            'FontWeight','bold',...
            'Position',[0.075 0.68 0.1 0.04 ],...
            'String','fpmult' );
        hEditlrfid=uicontrol(...
            'Parent',hSettingsUiTab1,...
            'Style','edit',...
            'Visible','On',...
            'BackgroundColor','w',...
            'Units','Normalized',...
            'TooltipString','The number of data points to left rotate the FID(s)',...
            'Max',1,...
            'Position',[0.275 0.63 0.075 0.05 ],...
            'CallBack', {@Editlrfid_Callback});
        hTextlrfid=uicontrol(...
            'Parent',hSettingsUiTab1,...
            'Style','text',...
            'Units','Normalized',...
            'ForegroundColor','Blue',...
            'horizontalalignment','left',...
            'FontWeight','bold',...
            'Position',[0.275 0.68 0.1 0.04 ],...
            'String','lrfid' );
        hFittypeGroup=uibuttongroup(...
            'Parent',hSettingsUiTab1,...
            'Title','',...
            'FontWeight','bold',...
            'TitlePosition','centertop',...
            'Title','Fitting routine',...
            'ForegroundColor','Blue',...
            'Units','Normalized',...
            'SelectionChangeFcn', {@Fittype_Callback},...
            'Visible','On',...
            'Position',[0.6,0.3 ,0.3 ,0.2]);
        hFittypeLsq = uicontrol(...
            'Parent',hFittypeGroup,...
            'Style','RadioButton',...
            'String','lsqcurvefit (*)',...
            'FontWeight','Bold',...
            'Units','normalized',...
            'Position',[0.1 0.6 0.7 0.25]);
        hFittypeFmin = uicontrol(...
            'Parent',hFittypeGroup,...
            'Style','RadioButton',...
            'String','fminsearch',...
            'FontWeight','Bold',...
            'Units','normalized',...
            'Position',[0.1 0.2 0.7 0.25]);
        hTextFittpemult=uicontrol(...
            'Parent',hSettingsUiTab1,...
            'Style','text',...
            'Units','Normalized',...
            'ForegroundColor','Black',...
            'horizontalalignment','left',...
            'Position',[0.6 0.1 0.30 0.2 ],...
            'String','(*) Recommended [requires Optim Toolbox]' );%switch
        
        
        hEditNMRPanel=uipanel(...
            'Parent',hSettingsUiTab3,...
            'Title','Non Uniform Gradients',...
            'FontWeight','bold',...
            'ForegroundColor','Blue',...
            'Visible','Off',...
            'TitlePosition','centertop',...
            'Units','Normalized',...
            'Position',[0.0, 0.5 ,1.0, 0.5]);
        hTextNUGTable=uicontrol(...
            'Parent',hEditNMRPanel,...
            'Style','text',...
            'Units','Normalized',...
            'FontWeight','bold',...
            'horizontalalignment','c',...
            'Position',[0.7 0.83 0.25 0.1 ],...
            'String','NUG Coefficients' );
        hTableNUG=uitable(...
            'Data',{NmrData.probename; NmrData.gcal ;NmrData.nug(1) ;NmrData.nug(2) ;NmrData.nug(3) ;NmrData.nug(4) },...
            'Parent',hEditNMRPanel,...
            'Units','Normalized',...
            'ColumnEditable',true(1,6),...
            'ColumnName',{'Values'},...
            'RowName',{'probe' 'gcal' 'c1' 'c2' 'c3' 'c4'},...
            'ColumnFormat',{'char' 'numeric' 'numeric' 'numeric' 'numeric' 'numeric'},...
            'Position',[0.7 0.22 0.25 0.6 ],...
            'CellEditCallBack', {@TableNUG_Callback});
        hButtonReadNUG=uicontrol(...
            'Parent',hEditNMRPanel,...
            'Style','PushButton',...
            'Units','Normalized',...
            'Visible','on',...
            'TooltipString','Read in NUG data from file',...
            'FontWeight','bold',...
            'Position',[0.725 0.075 0.2 0.1 ],...
            'String','Import',...
            'CallBack', {@ReadNUG_Callback});
        hTextMancs=uicontrol(...
            'Parent',hEditNMRPanel,...
            'Style','text',...
            'Units','Normalized',...
            'Visible','off',...
            'FontWeight','bold',...
            'horizontalalignment','c',...
            'Position',[0.05 0.25 0.25 0.1 ],...
            'String','UoM Spectrometers' );
        hButtonv400=uicontrol(...
            'Parent',hEditNMRPanel,...
            'Style','PushButton',...
            'Units','Normalized',...
            'Visible','off',...
            'FontWeight','bold',...
            'Position',[0.05 0.1 0.1 0.1 ],...
            'String','v400',...
            'CallBack', {@Buttonv400_Callback});
        hButtonv500=uicontrol(...
            'Parent',hEditNMRPanel,...
            'Style','PushButton',...
            'Units','Normalized',...
            'Visible','off',...
            'FontWeight','bold',...
            'Position',[0.2 0.1 0.1 0.1 ],...
            'String','v500',...
            'CallBack', {@Buttonv500_Callback});
        
        hEditDOSYPanel=uipanel(...
            'Parent',hSettingsUiTab2,...
            'Title','Diffusion related parameters',...
            'FontWeight','bold',...
            'ForegroundColor','Blue',...
            'TitlePosition','centertop',...
            'Visible','off',...
            'Units','Normalized',...
            'Position',[0.0, 0.0 ,1.0, 1.0]);
        if ~strcmp(NmrData.Gzlvl,'non existing')
            hTableGzlvl=uitable(...
                'Data',NmrData.Gzlvl',...
                'Parent',hEditDOSYPanel,...
                'Units','Normalized',...
                'ColumnEditable',true(1,numel(NmrData.Gzlvl)),...
                'ColumnName',{'T/m'},...
                ...'RowName',{'probe' 'gcal' 'c1' 'c2' 'c3' 'c4'},...
                ...'ColumnFormat',{'char' 'numeric' 'numeric' 'numeric' 'numeric' 'numeric'},...
                'Position',[0.6 0.05 0.4 0.9 ],...
                'CellEditCallBack', {@TableGzlvl_Callback});
        end
        hEditDELTA=uicontrol(...
            'Parent',hEditDOSYPanel,...
            'Style','edit',...
            'Visible','On',...
            'BackgroundColor','w',...
            'Units','Normalized',...
            'TooltipString','Experimental diffusion time',...
            'Max',1,...
            'Position',[0.05 0.4 0.1 0.05 ],...
            'CallBack', {@EditDELTA_Callback});
        hTextDELTA=uicontrol(...
            'Parent',hEditDOSYPanel,...
            'Style','text',...
            'Units','Normalized',...
            'FontWeight','bold',...
            'FontName','Symbol',...
            'Position',[0.075 0.45 0.05 0.05 ],...8.841
            'String','D' );
        hEditDELTAprime=uicontrol(...
            'Parent',hEditDOSYPanel,...
            'Style','edit',...
            'Visible','On',...
            'BackgroundColor','w',...
            'Units','Normalized',...
            'TooltipString','Corrected diffusion time',...
            'Max',1,...
            'Position',[0.2 0.4 0.1 0.05 ],...
            'CallBack', {@EditDELTAprime_Callback});
        hTextDELTAprime2=uicontrol(...
            'Parent',hEditDOSYPanel,...
            'Style','text',...
            'Units','Normalized',...
            'FontWeight','bold',...
            ...'FontName','Symbol',...
            'Position',[0.25 0.45 0.02 0.05 ],...
            'String','''' );
        hTextDELTAprime=uicontrol(...
            'Parent',hEditDOSYPanel,...
            'Style','text',...
            'Units','Normalized',...
            'FontWeight','bold',...
            'FontName','Symbol',...
            'Position',[0.235 0.45 0.02 0.05 ],...
            'String','D' );
        hEditdelta=uicontrol(...
            'Parent',hEditDOSYPanel,...
            'Style','edit',...
            'Visible','On',...
            'BackgroundColor','w',...
            'Units','Normalized',...
            'TooltipString','Diffusion encoding time',...
            'Max',1,...
            'Position',[0.35 0.4 0.1 0.05 ],...
            'CallBack', {@Editdelta_Callback});
        hTextdelta=uicontrol(...
            'Parent',hEditDOSYPanel,...
            'Style','text',...
            'Units','Normalized',...
            'FontWeight','bold',...
            'FontName','Symbol',...
            'Position',[0.375 0.45 0.05 0.05 ],...
            'String','d' );
        hEditTau=uicontrol(...
            'Parent',hEditDOSYPanel,...
            'Style','edit',...
            'Visible','On',...
            'BackgroundColor','w',...
            'Units','Normalized',...
            'TooltipString','Time between pulses in a bipolar pulse pair',...
            'Max',1,...
            'Position',[0.35 0.25 0.1 0.05 ],...8.841
            'CallBack', {@EditTau_Callback});
        hTextTau=uicontrol(...
            'Parent',hEditDOSYPanel,...
            'Style','text',...
            'Units','Normalized',...
            'FontWeight','bold',...
            'horizontalalignment','c',...
            'FontName','Symbol',...
            'Position',[0.35 0.3 0.1 0.05 ],...
            'String','t' );
        hEditDosygamma=uicontrol(...
            'Parent',hEditDOSYPanel,...
            'Style','edit',...
            'Visible','On',...
            'BackgroundColor','w',...
            'Units','Normalized',...
            'TooltipString','Magnetogyric ratio of the studied nucleus',...
            'Max',1,...
            'Position',[0.05 0.25 0.25 0.05 ],...
            'CallBack', {@EditDosygamma_Callback});
        hTextgamma=uicontrol(...
            'Parent',hEditDOSYPanel,...
            'Style','text',...
            'Units','Normalized',...
            'FontWeight','bold',...
            'FontName','Symbol',...
            'Position',[0.15 0.3 0.05 0.05 ],...
            'String','g' );
        hEditDosyconstant=uicontrol(...
            'Parent',hEditDOSYPanel,...
            'Style','edit',...
            'Visible','On',...
            'BackgroundColor','w',...
            'Units','Normalized',...
            'TooltipString','',...
            'Max',1,...
            'Position',[0.05 0.1 0.25 0.05 ],...
            'CallBack', {@EditDosyconstant_Callback});
        hTextdosyconstant=uicontrol(...8.841
            'Parent',hEditDOSYPanel,...8.841
            'Style','text',...
            'Units','Normalized',...
            'FontWeight','bold',...
            'Position',[0.075 0.15 0.2 0.05 ],...
            'String','dosyconstant' );
        hButtonRestore = uicontrol(...
            'Parent',hEditDOSYPanel,...
            'Style','PushButton',...
            'String','Restore Original',...
            'Units','normalized',...
            'TooltipString','Restore original DOSY parameters',...
            'Position',[0.05 0.65 0.3 0.05],...
            'Callback',{@ButtonRestore_Callback});
        hTextMethods=uicontrol(...
            'Parent',hEditDOSYPanel,...
            'Style','text',...
            'Units','Normalized',...
            'FontWeight','bold',...EditScaleUp_Callback
            ...'ForegroundColor','Blue',...
            'horizontalalignment','l',...
            'Position',[0.05 0.9 0.4 0.05 ],...
            'String','Calculate diffusion parameters' );
        hTextPulseType=uicontrol(...
            'Parent',hEditDOSYPanel,...
            'Style','text',...
            'Units','Normalized',...
            'FontWeight','bold',...
            'horizontalalignment','l',...
            'Position',[0.05 0.85 0.4 0.05 ],...
            'String','by pulse secquence type' );
        hButtonMeth1 = uicontrol(...
            'Parent',hEditDOSYPanel,...
            'Style','PushButton',...
            'String','Monopolar',...
            'Units','normalized',...
            'TooltipString',...
            'Calculate corrected DELTA (and dosyconstant)',...
            'Position',[0.05 0.75 0.15 0.05],...
            'Callback',{@ButtonMeth1_Callback});
        hButtonMeth2 = uicontrol(...
            'Parent',hEditDOSYPanel,...
            'Style','PushButton',...
            'String','Bipolar',...
            'Units','normalized',...
            'TooltipString',...
            'Calculate corrected DELTA (and dosyconstant)',...
            'Position',[0.20 0.75 0.15 0.05],...
            'Callback',{@ButtonMeth2_Callback});
        %         hTextDELTAprimeb=uicontrol(...
        %             'Parent',hEditDOSYPanel,...
        %             'Style','text',...
        %             'Units','Normalized',...
        %             'FontWeight','bold',...
        %             'FontName','Symbol',...
        %             'Position',[0.7 0.8 0.1 0.1 ],...
        %             'String',': D-d/3' );%#ok
        
        
         hEditRelaxationPanel=uipanel(...
            'Parent',hSettingsUiTab4,...
            'Title','Relaxation related parameters',...
            'FontWeight','bold',...
            'ForegroundColor','Blue',...
            'TitlePosition','centertop',...
            'Visible','off',...
            'Units','Normalized',...
            'Position',[0.0, 0.0 ,1.0, 1.0]);
        if ~isempty(NmrData.d2)
            hTableTau=uitable(...
                'Data',NmrData.d2,...
                'Parent',hEditRelaxationPanel,...                
                'Units','Normalized',...
                'ColumnEditable',true(1,numel(NmrData.d2)),...
                'ColumnName',{'sec'},...
                ...'RowName',{'probe' 'gcal' 'c1' 'c2' 'c3' 'c4'},...
                ...'ColumnFormat',{'char' 'numeric' 'numeric' 'numeric' 'numeric' 'numeric'},...
                'Position',[0.5 0.05 0.2 0.9 ],...
                'CellEditCallBack', {@TableTau_Callback});
             uicontrol(...
                    'Parent',hEditRelaxationPanel,...
                    'Style','text',...
                    'Units','Normalized',...
                    'FontWeight','bold',...
                    'horizontalalignment','l',...
                    'Position',[0.525 0.95 0.4 0.05 ],...
                    'String','Delays (vdlist)' );
                
                
                uicontrol(...
                    'Parent',hEditRelaxationPanel,...
                    'Style','text',...
                    'Units','Normalized',...
                    'FontWeight','bold',...
                    'horizontalalignment','l',...
                    'Position',[0.05 0.45 0.4 0.05 ],...
                    'String','Revert to original values' );
                
                hButtonVCRevert = uicontrol(...
                    'Parent',hEditRelaxationPanel,...
                    'Style','PushButton',...
                    'String','Revert',...
                    'Units','normalized',...
                    'TooltipString',...
                    'Revert to original values',...
                    'Position',[0.1 0.40 0.15 0.05],...
                    'Callback',{@ButtonVCRevert_Callback});
            
            if isfield(NmrData,'vclist')
          
                hTableVclist=uitable(...
                    'Data',NmrData.vclist,...
                    'Parent',hEditRelaxationPanel,...
                    'Units','Normalized',...
                    'ColumnEditable',true(1,numel(NmrData.vclist)),...
                    'ColumnName',{'count'},...
                    ...'RowName',{'probe' 'gcal' 'c1' 'c2' 'c3' 'c4'},...
                    ...'ColumnFormat',{'char' 'numeric' 'numeric' 'numeric' 'numeric' 'numeric'},...
                    'Position',[0.75 0.05 0.2 0.9 ],...
                    'CellEditCallBack', {@TableVclist_Callback});
                uicontrol(...
                    'Parent',hEditRelaxationPanel,...
                    'Style','text',...
                    'Units','Normalized',...
                    'FontWeight','bold',...
                    'horizontalalignment','l',...
                    'Position',[0.775 0.95 0.4 0.05 ],...
                    'String','Counter (vclist)' );
                
                
                hEditVCLIST=uicontrol(...
                    'Parent',hEditRelaxationPanel,...
                    'Style','edit',...
                    'Visible','On',...
                    'BackgroundColor','w',...
                    'Units','Normalized',...
                    'TooltipString','Constant for converting vclist to vdlist',...
                    'Max',1,...
                    'Position',[0.1 0.7 0.15 0.05 ],...
                    'CallBack', {@EditVCLIST_Callback});
                set(hEditVCLIST,'string',num2str(NmrData.vc_constant));
                
                uicontrol(...
                    'Parent',hEditRelaxationPanel,...
                    'Style','text',...
                    'Units','Normalized',...
                    'FontWeight','bold',...
                    'horizontalalignment','l',...
                    'Position',[0.05 0.85 0.4 0.05 ],...
                    'String','Convert counter to delays' );
                
                hButtonVCConvert = uicontrol(...
                    'Parent',hEditRelaxationPanel,...
                    'Style','PushButton',...
                    'String','Convert',...
                    'Units','normalized',...
                    'TooltipString',...
                    'Constant for converting vclist to vdlist using vc constant)',...
                    'Position',[0.1 0.80 0.15 0.05],...
                    'Callback',{@ButtonVCConvert_Callback});
            end
        end
        
        

        
        
        
        
        set(hEditDELTA,'string',num2str(NmrData.DELTA));
        set(hEditdelta,'string',num2str(NmrData.delta));
        set(hEditTau,'string',num2str(NmrData.tau));
        set(hEditDosygamma,'string',num2str(NmrData.gamma));
        set(hEditDosyconstant,'string',num2str(NmrData.dosyconstant));
        set(hEditDELTAprime,'string',num2str(NmrData.DELTAprime));
        set(hEditNMRPanel,'Visible','On');
        set(hEditDOSYPanel,'Visible','On');
        set(hEditRelaxationPanel,'Visible','On');
        set(hEditfpmult,'string',num2str(NmrData.fpmult));
        set(hEditlrfid,'string',num2str(NmrData.lrfid));
        set(hEditLSspec,'string',num2str(NmrData.lsspec));
        if NmrData.linshift==1
            set(hDCLSSpecGroup,'SelectedObject',hDCSpecLinPPM)
    
        else
            set(hDCLSSpecGroup,'SelectedObject',hDCSpecConPPM)
        end        
        
        if isfield('NmrData','xlim_spec')
            scale=NmrData.xlim_spec;
        else
            scale=[0 0];
        end
        set(hEditScaleUp,'string',num2str(scale(2)));
        set(hEditScaleDown,'string',num2str(scale(1)));
        
        switch NmrData.dc
            case 1
                set(hDCGroup,'SelectedObject',hDCYesPPM)
            case 0
                set(hDCGroup,'SelectedObject',hDCNoPPM)
            otherwise
                error('illegal choice')
        end        
        switch NmrData.dcspec
            case 1
                set(hDCSpecGroup,'SelectedObject',hDCSpecYesPPM)
            case 0
                set(hDCSpecGroup,'SelectedObject',hDCSpecNoPPM)
            otherwise
                error('illegal choice')
        end        
        switch NmrData.FitType
            case 0
                set(hFittypeGroup,'SelectedObject',hFittypeLsq)
            case 1
                set(hFittypeGroup,'SelectedObject',hFittypeFmin)
            otherwise
                error('illegal choice')
        end
        switch NmrData.shiftunits
            case 'ppm'
                set(hRadioPPM,'Value',1)
            case 'Hz'
                set(hRadioHz,'Value',1)
            otherwise
                error('illegal choice')
        end
        
        %set local data version
        if strcmp(NmrData.local,'yes')
            set(hButtonv500,'Visible','on');
            set(hButtonv400,'Visible','on');
            set(hTextMancs,'Visible','on');
        end
        guidata(hMainFigure,NmrData);
        function TableGzlvl_Callback( eventdata, handles)
            NmrData=guidata(hMainFigure);
            tmpgrad=get(hTableGzlvl,'Data');
            if sum(isnan(tmpgrad)>0)
                disp('Only numeric values can be entered as gradient amplitudes')
            else
                NmrData.Gzlvl=tmpgrad';
            end
            set(hTableGzlvl,'Data',NmrData.Gzlvl')
            
            guidata(hMainFigure,NmrData);
            
        end
        function EditScaleUp_Callback( eventdata, handles)
            NmrData=guidata(hMainFigure);
            scaleup=str2double(get(hEditScaleUp,'string'));
            if isnan(scaleup>0)
            else
                set(hEditScaleUp,'string',num2str(scaleup));
                
                set(hAxes,'Xlim',[NmrData.xlim_spec(1) scaleup]);
                NmrData.xlim_spec=[NmrData.xlim_spec(1) scaleup];
                
            end
            guidata(hMainFigure,NmrData);
        end
        function EditScaleDown_Callback( eventdata, handles)
            NmrData=guidata(hMainFigure);
            scaledown=str2double(get(hEditScaleDown,'string'));
            if isnan(scaledown>0)
            else
                set(hEditScaleDown,'string',num2str(scaledown));
                set(hAxes,'Xlim',[scaledown NmrData.xlim_spec(2)]);
                NmrData.xlim_spec=[scaledown NmrData.xlim_spec(2)];
                
            end
            guidata(hMainFigure,NmrData);
        end
        function TableTau_Callback( eventdata, handles)
            NmrData=guidata(hMainFigure);
            tmpgrad=get(hTableTau,'Data');
            if sum(isnan(tmpgrad)>0)
                disp('Only numeric values can be entered as delay times')
            else
                NmrData.d2=tmpgrad';
            end
            set(hTableTau,'Data',NmrData.d2)
            
            guidata(hMainFigure,NmrData);
            
        end
        function TableVclist_Callback( eventdata, handles)
            NmrData=guidata(hMainFigure);
            tmpgrad=get(hTableVclist,'Data');
            if sum(isnan(tmpgrad)>0)
                disp('Only numeric values can be entered as counter ')
            else
                NmrData.vclist=round(tmpgrad)';
            end
            set(hTableVclist,'Data',NmrData.vclist')
            
            guidata(hMainFigure,NmrData);
            
        end
        function EditVCLIST_Callback( eventdata, handles)
            NmrData=guidata(hMainFigure);
            NmrData.vc_constant=str2double(get(hEditVCLIST,'string'));
            set(hEditVCLIST,'string',num2str(NmrData.vc_constant));
            guidata(hMainFigure,NmrData);
        end

        function ButtonVCConvert_Callback( eventdata, handles)
            NmrData=guidata(hMainFigure);
            NmrData.d2=NmrData.vclist.*NmrData.vc_constant;
            guidata(hMainFigure,NmrData);
            set(hTableTau,'Data',NmrData.d2)
            
        end
        
        function ButtonVCRevert_Callback( eventdata, handles)
            NmrData=guidata(hMainFigure);
            NmrData.d2=NmrData.d2_org;
            set(hTableTau,'Data',NmrData.d2_org)
             if isfield(NmrData,'vclist')
                 NmrData.vclist=NmrData.vclist_org;
                 set(hTableVclist,'Data',NmrData.vclist)
                 NmrData.vc_constant=NmrData.vc_constant_org;
                  set(hEditVCLIST,'string',num2str(NmrData.vc_constant));
             end

            guidata(hMainFigure,NmrData);
        end
        function Buttonv500_Callback( eventdata, handles)
            %Manchester Varian 500 MHz Triple probe
            NmrData=guidata(hMainFigure);
            NmrData.nug=[1 -0.024654 -0.000973 0.000114];
            NmrData.probename='v500';
            NmrData.gcal=0.001996;
            set(hTableNUG,'Data',{NmrData.probename; NmrData.gcal ;NmrData.nug(1) ;NmrData.nug(2) ;NmrData.nug(3) ;NmrData.nug(4) });
            guidata(hMainFigure,NmrData);
            
        end
        function Buttonv400_Callback( eventdata, handles)
            %Manchester Varian 400 MHz Triple probe
            NmrData=guidata(hMainFigure);
            NmrData.nug=[9.280636e-1 -9.789118e-3 -3.834212e-4 2.51367e-5];
            NmrData.probename='v400';
            NmrData.gcal=0.00101;
            set(hTableNUG,'Data',{NmrData.probename; NmrData.gcal ;NmrData.nug(1) ;NmrData.nug(2) ;NmrData.nug(3) ;NmrData.nug(4) });
            guidata(hMainFigure,NmrData);
            
        end
        function TableNUG_Callback( eventdata, handles)
            
            NmrData=guidata(hMainFigure);
            tmp=get(hTableNUG,'Data');
            NmrData.probename=tmp{1};
            NmrData.gcal=tmp{2};
            NmrData.nug(1)=tmp{3};
            NmrData.nug(2)=tmp{4};
            NmrData.nug(3)=tmp{5};
            NmrData.nug(4)=tmp{6};
            guidata(hMainFigure,NmrData);
            
            set(hTableNUG,'Data',{NmrData.probename; NmrData.gcal ;NmrData.nug(1) ;NmrData.nug(2) ;NmrData.nug(3) ;NmrData.nug(4) });
            guidata(hMainFigure,NmrData);
        end
        function ReadNUG_Callback( eventdata, handles)
            %Read in NUG data from file
            [FileName,PathName] =uigetfile('*.*','Choose the file containing nug data');
            nugfile=[PathName FileName];
            nugid=fopen(nugfile,'rt');
            nugline=fgetl(nugid);
            iter=1;
            while ischar(nugline)
                nugdata{iter}=nugline; %#ok<AGROW>
                nugline=fgetl(nugid);
                iter=iter+1;
            end
            if length(nugdata)>6
                disp('The number of lines in the file containing nug data are more than expected. ')
                disp('Only the first 4 coefficients will be used')
                disp('Make sure that the format of the file is correct')
            elseif length(nugdata)<3
                disp('The number of lines in the file containing nug data are fewer than three.')
                disp('At least three lines are necessary')
                disp('Make sure that the format of the file is correct')
                disp('Cannot use this file')
                return
            elseif length(nugdata)<4
                disp('The number of lines in the file containing nug data are fewer than four.')
                disp('Only one nug coefficient is not useful - but I will allow it')
                disp('The remaining coeficients will be set to zero')
                disp('Make sure that the format of the file is correct')
            elseif length(nugdata)<6
                disp('The number of lines in the file containing nug data are fewer than expected.')
                disp('The remaining coeficients will be set to zero')
                disp('Make sure that the format of the file is correct')
            else
                %we assume that the file was fine
            end
            NmrData.probename=nugdata{1};
            NmrData.gcal=str2double(nugdata{2});
            NmrData.nug=[0 0 0 0];
            for iter=3:length(nugdata)
                NmrData.nug(iter-2)=str2double(nugdata{iter});
            end
            set(hTableNUG,'Data',{NmrData.probename; NmrData.gcal ;NmrData.nug(1) ;NmrData.nug(2) ;NmrData.nug(3) ;NmrData.nug(4) });
            guidata(hMainFigure,NmrData);
        end
        function ButtonMeth1_Callback( eventdata, handles)
            NmrData=guidata(hMainFigure);
            NmrData.DELTAprime=NmrData.DELTA-NmrData.delta/3;
            set(hEditDELTAprime,'string',num2str(NmrData.DELTAprime));
            NmrData.dosyconstant=NmrData.gamma.^2.*NmrData.delta.^2.*...
                NmrData.DELTAprime;
            set(hEditDosyconstant,'string',num2str(NmrData.dosyconstant));
            guidata(hMainFigure,NmrData);
        end
        function ButtonMeth2_Callback( eventdata, handles)
            NmrData=guidata(hMainFigure);
            NmrData.DELTAprime=NmrData.DELTA-NmrData.delta/3-NmrData.tau/2;
            set(hEditDELTAprime,'string',num2str(NmrData.DELTAprime));
            NmrData.dosyconstant=NmrData.gamma.^2.*NmrData.delta.^2.*...
                NmrData.DELTAprime;
            set(hEditDosyconstant,'string',num2str(NmrData.dosyconstant));
            guidata(hMainFigure,NmrData);
        end
        function ButtonRestore_Callback( eventdata, handles)
            NmrData=guidata(hMainFigure);
            NmrData.dosyconstant=NmrData.dosyconstantOriginal;
            NmrData.DELTA=NmrData.DELTAOriginal;
            NmrData.delta=NmrData.deltaOriginal;
            NmrData.tau=NmrData.tauOriginal;
            NmrData.gamma=NmrData.gammaOriginal;
            NmrData.DELTAprime=NmrData.dosyconstant./...
                (NmrData.gamma.^2.*NmrData.delta.^2);
            set(hEditDELTA,'string',num2str(NmrData.DELTA));
            set(hEditdelta,'string',num2str(NmrData.delta));
            set(hEditTau,'string',num2str(NmrData.tau));
            set(hEditDELTAprime,'string',num2str(NmrData.DELTAprime));
            set(hEditDosyconstant,'string',num2str(NmrData.dosyconstant));
            set(hEditDosygamma,'string',num2str(NmrData.gamma));
            guidata(hMainFigure,NmrData);
        end
        function EditDosyconstant_Callback( eventdata, handles)
            NmrData=guidata(hMainFigure);
            NmrData.dosyconstant=str2double(get(hEditDosyconstant,'string'));
            NmrData.DELTAprime=NmrData.dosyconstant./...
                (NmrData.gamma.^2.*NmrData.delta.^2);
            guidata(hMainFigure,NmrData);
            set(hEditDELTAprime,'string',num2str(NmrData.DELTAprime));
            
        end
        function EditDELTAprime_Callback( eventdata, handles)
            NmrData=guidata(hMainFigure);
            NmrData.DELTAprime=str2double(get(hEditDELTAprime,'string'));
            NmrData.dosyconstant=...
                NmrData.gamma.^2.*NmrData.delta.^2.*NmrData.DELTAprime;
            set(hEditDosyconstant,'string',num2str(NmrData.dosyconstant));
            guidata(hMainFigure,NmrData);
        end
        function EditDosygamma_Callback( eventdata, handles)
            NmrData=guidata(hMainFigure);
            NmrData.gamma=str2double(get(hEditDosygamma,'string'));
            NmrData.dosyconstant=(NmrData.gamma.^2).*(NmrData.delta.^2).*NmrData.DELTAprime;
            guidata(hMainFigure,NmrData);
            set(hEditDosyconstant,'string',num2str(NmrData.dosyconstant));
            set(hEditDosygamma,'string',num2str(NmrData.gamma));
        end
        function EditDELTA_Callback( eventdata, handles)
            NmrData=guidata(hMainFigure);
            NmrData.DELTA=str2double(get(hEditDELTA,'string'));
            set(hEditDELTA,'string',num2str(NmrData.DELTA));
            NmrData.DELTAprime='Calculate';
            NmrData.dosyconstant='Calculate';
            set(hEditDosyconstant,'string',num2str(NmrData.dosyconstant));
            set(hEditDELTAprime,'string',NmrData.DELTAprime);
            guidata(hMainFigure,NmrData);
        end
        function Editdelta_Callback( eventdata, handles)
            NmrData=guidata(hMainFigure);
            NmrData.delta=str2double(get(hEditdelta,'string'));
            set(hEditdelta,'string',num2str(NmrData.delta));
            NmrData.DELTAprime='Calculate';
            NmrData.dosyconstant='Calculate';
            set(hEditDosyconstant,'string',num2str(NmrData.dosyconstant));
            set(hEditDELTAprime,'string',NmrData.DELTAprime);
            guidata(hMainFigure,NmrData);
        end
        function EditTau_Callback( eventdata, handles)
            NmrData=guidata(hMainFigure);
            NmrData.tau=str2double(get(hEditTau,'string'));
            set(hEditTau,'string',num2str(NmrData.tau));
            NmrData.DELTAprime='Calculate';
            NmrData.dosyconstant='Calculate';
            set(hEditDosyconstant,'string',num2str(NmrData.dosyconstant));
            set(hEditDELTAprime,'string',NmrData.DELTAprime);
            guidata(hMainFigure,NmrData);
        end
        function hSettingsResizeFcn(varargin)
            % Figure resize callback
        end
        function Units_Callback(source,eventdata)
            NmrData=guidata(hMainFigure);
            NmrData.xlim_spec=xlim(hAxes);
            guidata(hMainFigure,NmrData);
            switch get(hUnitsGroup,'SelectedObject')
                case hRadioPPM
                    NmrData.shiftunits='ppm';
                    NmrData.xlim_spec=NmrData.xlim_spec./NmrData.sfrq;
                    NmrData.RDleft=NmrData.RDleft./NmrData.sfrq;
                    NmrData.RDright=NmrData.RDright./NmrData.sfrq;
                    NmrData.RDcentre=NmrData.RDcentre./NmrData.sfrq;
                case hRadioHz
                    NmrData.shiftunits='Hz';
                    NmrData.xlim_spec=NmrData.xlim_spec.*NmrData.sfrq;
                    NmrData.RDleft=NmrData.RDleft.*NmrData.sfrq;
                    NmrData.RDright=NmrData.RDright.*NmrData.sfrq;
                    NmrData.RDcentre=NmrData.RDcentre.*NmrData.sfrq;
                otherwise
                    error('illegal choice')
            end
            guidata(hMainFigure,NmrData);
            figure(hMainFigure)
            PlotSpectrum();
            figure(hSettings)
        end
        function hSettings_DeleteFcn(eventdata, handles)    %#ok<*INUSD>
            NmrData=guidata(hMainFigure);
            NmrData=rmfield(NmrData,'hSettings');
            guidata(hMainFigure,NmrData);
        end
        function Editfpmult_Callback( eventdata, handles)
            NmrData=guidata(hMainFigure);
            NmrData.fpmult=str2double(get(hEditfpmult,'string'));
            set(hEditfpmult,'string',num2str(NmrData.fpmult));
            guidata(hMainFigure,NmrData);
        end
        function Editlrfid_Callback( eventdata, handles)
            NmrData=guidata(hMainFigure);
            NmrData.lrfid=round(str2double(get(hEditlrfid,'string')));
            set(hEditlrfid,'string',num2str(NmrData.lrfid));
            guidata(hMainFigure,NmrData);
        end
        function EditLSspec_Callback( eventdata, handles)
            NmrData=guidata(hMainFigure);
            NmrData.lsspec=round(str2double(get(hEditLSspec,'string')));
            set(hEditLSspec,'string',num2str(NmrData.lsspec));
            guidata(hMainFigure,NmrData);
        end
        function DC_Callback( eventdata, handles)
            zoom off
            pan off
            switch get(hDCGroup,'SelectedObject')
                case hDCYesPPM
                    NmrData.dc=1;
                case hDCNoPPM
                    NmrData.dc=0;
                otherwise
                    error('illegal choice')
            end            
            guidata(hMainFigure,NmrData);
        end
        function LSSpec_Callback(eventdata, handles)
            if get(hDCLSSpecGroup,'SelectedObject')==hDCSpecLinPPM
                NmrData.linshift=1;
            else
                NmrData.linshift=0;
            end
            guidata(hMainFigure,NmrData);
        end
        function DCSpec_Callback( eventdata, handles)
            zoom off
            pan off
            switch get(hDCSpecGroup,'SelectedObject')
                case hDCSpecYesPPM
                    NmrData.dcspec=1;
                case hDCSpecNoPPM
                    NmrData.dcspec=0;
                otherwise
                    error('illegal choice')
            end
            guidata(hMainFigure,NmrData);
        end
        function Fittype_Callback( eventdata, handles)
            zoom off
            pan off
            switch get(hFittypeGroup,'SelectedObject')
                case hFittypeLsq
                    NmrData.FitType=0;
                case hFittypeFmin
                    NmrData.FitType=1;
                otherwise
                    error('illegal choice')
            end
            
            guidata(hMainFigure,NmrData);
        end
        guidata(hMainFigure,NmrData);
        set(hSettings,'Visible','On');
    end
    function Extra_Close(eventdata,handles)
        fighandles = findobj(0, 'type', 'figure');
        fighandles=sort(fighandles);
        for k1=2:length(fighandles)
            close(fighandles(k1));
        end
    end
    function Help_Online(eventdata,handles)
        hHelpOnline=figure(...
            'NumberTitle','Off',...
            'MenuBar','none',...
            'Units','Normalized',...
            'Toolbar','none',...
            'Name','Online Help');
        hHelpPanel=uipanel(...
            'Parent',hHelpOnline,...
            'Title','Documentation',...
            'FontWeight','bold',...
            'ForegroundColor','Blue',...
            'TitlePosition','centertop',...
            'Units','Normalized',...
            'Position',[0.0, 0.0 ,1.0, 1.0]);
        
        CellArrayString=cell(1,3);
        CellArrayString{1,1}='Documentation is avaliable at the DOSY Toolbox Wiki';
        CellArrayString{1,2}='';
        CellArrayString{1,3}='http://dosytoolbox.chemistry.manchester.ac.uk';
        
        hTextOnline=uicontrol(...
            'Parent',hHelpPanel,...
            'Style','text',...
            'Units','Normalized',...
            'horizontalalignment','center',...
            'FontWeight','bold',...
            'Position',[0.1 0.7 0.8 0.15 ],...
            'String',CellArrayString);
        
        hButtonOnline=uicontrol(...
            'Parent',hHelpPanel,...
            'Style','PushButton',...
            'Units','Normalized',...
            'horizontalalignment','center',...
            'FontWeight','bold',...
            'Position',[0.25 0.2 0.5 0.15 ],...
            'String','Start Browser',...
            'Callback',@StartBrowser);
        
        function StartBrowser(eventdata,handles)
            web http://dosytoolbox.chemistry.manchester.ac.uk
        end
        
    end
    function Help_About(eventdata,handles)
        hHelpAbout=figure(...
            'NumberTitle','Off',...
            'MenuBar','none',...
            'Units','Normalized',...
            'Toolbar','none',...
            'Name','About');
        hHelpAboutPanel=uipanel(...
            'Parent',hHelpAbout,...
            'Title','Contact Details and License',...
            'FontWeight','bold',...
            'ForegroundColor','Blue',...
            'TitlePosition','centertop',...
            'Units','Normalized',...
            'Position',[0.0, 0.0 ,1.0, 1.0]);
        
        CellArrayString=cell(1,12);
        CellArrayString{1,1}='The DOSYToolbox - version 2.7';
        CellArrayString{1,2}='12 July 2016';
        CellArrayString{1,3}='';
        CellArrayString{1,4}='A freeware programme for analysis of NMR data';
        CellArrayString{1,5}='Licenced under the GNU General Public License';
        CellArrayString{1,6}='Copyright (C) <2016>  <Mathias Nilsson>';
        CellArrayString{1,7}='';
        CellArrayString{1,8}='Mathias Nilsson ';
        CellArrayString{1,9}='School of Chemistry, University of Manchester';
        CellArrayString{1,10}='Oxford Road, Manchester M13 9PL, UK';
        CellArrayString{1,11}='mathias.nilsson@manchester.ac.uk';
        CellArrayString{1,12}='http://personalpages.manchester.ac.uk/staff/mathias.nilsson/';
        CellArrayString{1,13}='http://nmr.chemistry.manchester.ac.uk/';
        
        
        hTextOnline=uicontrol(...
            'Parent',hHelpAboutPanel,...
            'Style','text',...
            'Units','Normalized',...
            'horizontalalignment','center',...
            'FontWeight','bold',...
            'Position',[0.1 0.1 0.8 0.7 ],...
            'String',CellArrayString);
        
        
    end
%----------------End of Menu callbacks-------------------------------------
%% ---------Flip panel callbacks------------------------------------
    function EditFlip_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        %Det which spectrum in the decay to plot
        NmrData.gradnr=round(str2double(get(hEditFlip,'String')));
        if NmrData.gradnr>NmrData.ngrad
            NmrData.gradnr=NmrData.ngrad;
        end
        if NmrData.gradnr<1
            NmrData.gradnr=1;
        end
        NmrData.xlim_spec=xlim();
        NmrData.ylim_spec=ylim();
        NmrData.flipnr=(NmrData.array2nr-1).*(NmrData.ngrad) + NmrData.gradnr;
        set(hEditFlipSpec,'String',num2str(NmrData.flipnr))
        set(hEditFlip,'String',num2str(NmrData.gradnr))
        guidata(hMainFigure,NmrData);
        switch get(hScopeGroup,'SelectedObject')
            case hRadioScopeGlobal
                set(hEditPh1,'string',num2str(NmrData.lp,4))
                set(hEditPh0,'string',num2str(NmrData.rp,4))
                set(hSliderPh0,'value',NmrData.rp);
                set(hSliderPh1,'value',NmrData.lp);
            case hRadioScopeIndividual
                set(hEditPh1,'string',num2str(NmrData.lpInd(NmrData.flipnr),4))
                set(hEditPh0,'string',num2str(NmrData.rpInd(NmrData.flipnr),4))
                set(hSliderPh0,'value',NmrData.rpInd(NmrData.flipnr));
                set(hSliderPh1,'value',NmrData.lpInd(NmrData.flipnr));
            otherwise
                error('illegal choice')
        end
        guidata(hMainFigure,NmrData);
        PlotSpectrum();
    end
    function ButtonFlipPlus_Callback(source,eventdata)
        %Set which spectrum in the decay to plot
        NmrData=guidata(hMainFigure);
        NmrData.gradnr=NmrData.gradnr+1;
        set(hEditFlip,'String',num2str(NmrData.gradnr))
        guidata(hMainFigure,NmrData);
        EditFlip_Callback();
        
    end
    function ButtonFlipMinus_Callback(source,eventdata)
        %Set which spectrum in the decay to plot
        NmrData=guidata(hMainFigure);
        NmrData.gradnr=NmrData.gradnr-1;
        set(hEditFlip,'String',num2str(NmrData.gradnr))
        guidata(hMainFigure,NmrData);
        EditFlip_Callback();
    end
    function EditFlip2_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        %Det which spectrum in the decay to plot
        NmrData.array2nr=round(str2double(get(hEditFlip2,'String')));
        if NmrData.array2nr>NmrData.narray2;
            NmrData.array2nr=NmrData.narray2;
        elseif NmrData.array2nr<1
            NmrData.array2nr=1;
        end
        NmrData.xlim_spec=xlim();
        NmrData.ylim_spec=ylim();
        NmrData.flipnr=(NmrData.array2nr-1).*NmrData.ngrad + NmrData.gradnr;
        set(hEditFlipSpec,'String',num2str(NmrData.flipnr))
        set(hEditFlip2,'String',num2str(NmrData.array2nr))
        guidata(hMainFigure,NmrData);
        switch get(hScopeGroup,'SelectedObject')
            case hRadioScopeGlobal
                set(hEditPh1,'string',num2str(NmrData.lp,4))
                set(hEditPh0,'string',num2str(NmrData.rp,4))
                set(hSliderPh0,'value',NmrData.rp);
                set(hSliderPh1,'value',NmrData.lp);
            case hRadioScopeIndividual
                set(hEditPh1,'string',num2str(NmrData.lpInd(NmrData.flipnr),4))
                set(hEditPh0,'string',num2str(NmrData.rpInd(NmrData.flipnr),4))
                set(hSliderPh0,'value',NmrData.rpInd(NmrData.flipnr));
                set(hSliderPh1,'value',NmrData.lpInd(NmrData.flipnr));
            otherwise
                error('illegal choice')
        end
        guidata(hMainFigure,NmrData);
        PlotSpectrum();
    end
    function ButtonFlipPlus2_Callback(source,eventdata)
        %Set which spectrum in the decay to plot
        NmrData=guidata(hMainFigure);
        NmrData.array2nr=NmrData.array2nr+1;
        set(hEditFlip2,'String',num2str(NmrData.array2nr))
        guidata(hMainFigure,NmrData);
        EditFlip2_Callback();
    end
    function ButtonFlipMinus2_Callback(source,eventdata)
        %Set which spectrum in the decay to plot
        NmrData=guidata(hMainFigure);
        NmrData.array2nr=NmrData.array2nr-1;
        set(hEditFlip2,'String',num2str(NmrData.array2nr))
        guidata(hMainFigure,NmrData);
        EditFlip2_Callback();
    end
    function EditFlipSpec_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        %Det which spectrum in the decay to plot
        NmrData.flipnr=round(str2double(get(hEditFlipSpec,'String')));
        if NmrData.flipnr>NmrData.arraydim;
            NmrData.flipnr=NmrData.arraydim;
        elseif NmrData.flipnr<1
            NmrData.flipnr=1;
        end
        NmrData.xlim_spec=xlim();
        NmrData.ylim_spec=ylim();
        set(hEditFlipSpec,'String',num2str(NmrData.flipnr))
        NmrData.gradnr=mod((NmrData.flipnr-1),NmrData.ngrad) +1;
        set(hEditFlip,'String',num2str(NmrData.gradnr))
        
        NmrData.array2nr=(NmrData.flipnr-NmrData.gradnr)./NmrData.ngrad +1 ;
        
        set(hEditFlip2,'String',num2str(NmrData.array2nr))
        guidata(hMainFigure,NmrData);
        switch get(hScopeGroup,'SelectedObject')
            case hRadioScopeGlobal
                set(hEditPh1,'string',num2str(NmrData.lp,4))
                set(hEditPh0,'string',num2str(NmrData.rp,4))
                set(hSliderPh0,'value',NmrData.rp);
                set(hSliderPh1,'value',NmrData.lp);
            case hRadioScopeIndividual
                set(hEditPh1,'string',num2str(NmrData.lpInd(NmrData.flipnr),4))
                set(hEditPh0,'string',num2str(NmrData.rpInd(NmrData.flipnr),4))
                set(hSliderPh0,'value',NmrData.rpInd(NmrData.flipnr));
                set(hSliderPh1,'value',NmrData.lpInd(NmrData.flipnr));
            otherwise
                error('illegal choice')
        end
        set(hEditShift,'string',num2str(NmrData.fshift(NmrData.flipnr),6));
        guidata(hMainFigure,NmrData);
        PlotSpectrum();
    end
    function ButtonFlipPlusSpec_Callback(source,eventdata)
        %Set which spectrum in the decay to plot
        NmrData=guidata(hMainFigure);
        NmrData.flipnr=NmrData.flipnr+1;
        set(hEditFlipSpec,'String',num2str(NmrData.flipnr))
        guidata(hMainFigure,NmrData);
        EditFlipSpec_Callback();
        
    end
    function ButtonFlipMinusSpec_Callback(source,eventdata)
        %Set which spectrum in the decay to plot
        NmrData=guidata(hMainFigure);
        NmrData.flipnr=NmrData.flipnr-1;
        set(hEditFlipSpec,'String',num2str(NmrData.flipnr))
        guidata(hMainFigure,NmrData);
        EditFlipSpec_Callback();
    end
    function hFlipPanelResizeFcn(varargin)
       
        
    end
    function hFlipPanel2ResizeFcn(varargin)
       
    end
    function hFlipPanelSpecResizeFcn(varargin)
    
    end
%-------------End of Flip panel callbacks----------------------------------
%% ---------Phase panel Callbacks-----------------------------------
    function PivotButton_Callback( eventdata, handles)
        zoom off; pan off
        set(hPivotCheck,'Value',1)
        set(hMainFigure,'WindowButtonDownFcn','')
        set(hAxes,'ButtonDownFcn',@Pivot_function)
    end
    function PivotCheck_Callback( eventdata, handles)
        zoom off
        pan off
        button_state = get(hPivotCheck,'Value');
        if button_state == 1
            Pivot_function();
        elseif button_state == 0
            hPivot=findobj(hAxes,'tag','Pivot');
            delete(hPivot);
            set(hAxes,'ButtonDownFcn','');
        end
    end
    function GtoIButton_Callback ( eventdata, handles)
         NmrData=guidata(hMainFigure);
        switch get(hScopeGroup,'SelectedObject')
            case hRadioScopeGlobal            
                for k=1:NmrData.arraydim
                   NmrData.lpInd(k)=NmrData.lp;
                   NmrData.rpInd(k)=NmrData.rp;
                end
                
            case hRadioScopeIndividual
                disp('only works with global scope')
                
            otherwise
                error('illegal choice')
        end
       
     
        guidata(hMainFigure,NmrData);

    end
    function GroupScope_Callback( eventdata, handles)
        NmrData=guidata(hMainFigure);
        switch get(hScopeGroup,'SelectedObject')
            case hRadioScopeGlobal

                 PhaseSpectrum...
                         (0,0,20)
                tmpflip=NmrData.flipnr;
                set(hScopeGroup,'SelectedObject',hRadioScopeGlobal)
                set(hPushCopyGtoI,'Enable','On')
            case hRadioScopeIndividual
                %disp('scope individual')                
                PhaseSpectrum...
                         (0,0,20)
                tmpflip=NmrData.flipnr;
                set(hScopeGroup,'SelectedObject',hRadioScopeIndividual)
                set(hPushCopyGtoI,'Enable','Off')
            otherwise
                error('illegal choice')
        end
        NmrData.flipnr=tmpflip;
        guidata(hMainFigure,NmrData);
        PlotSpectrum();
    end
    function SliderPh0_Callback(source,eventdata)
        %Phase the spectrum: zeroth order
        NmrData=guidata(hMainFigure);
        
        switch get(hScopeGroup,'SelectedObject')
            case hRadioScopeGlobal
                rpChange=get(hSliderPh0,'value')-NmrData.rp;
                lpChange=get(hSliderPh1,'value')-NmrData.lp;
            case hRadioScopeIndividual
                rpChange=get(hSliderPh0,'value')-...
                    NmrData.rpInd(NmrData.flipnr);
                lpChange=get(hSliderPh1,'value')-...
                    NmrData.lpInd(NmrData.flipnr);
            otherwise
                error('illegal choice')
        end
        
        AbsPhase=0;
        PhaseSpectrum(lpChange,rpChange,AbsPhase);
        PlotSpectrum();
    end
    function EditPh0_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        AbsPhase=2;
        %get(hEditPh0,'value')
        switch get(hScopeGroup,'SelectedObject')
            case hRadioScopeGlobal
                rpChange=str2double(get(hEditPh0,'String'))-NmrData.rp;
                lpChange=0;
            case hRadioScopeIndividual
                rpChange=str2double(get(hEditPh0,'String'))-NmrData.rpInd(NmrData.flipnr);
                lpChange=0;
            otherwise
                error('illegal choice')
        end
        PhaseSpectrum(lpChange,rpChange,AbsPhase);
        PlotSpectrum();
    end
    function SliderPh1_Callback(source,eventdata)
        %Phase the spectrum: zeroth order
        NmrData=guidata(hMainFigure);
        AbsPhase=0;
        switch get(hScopeGroup,'SelectedObject')
            case hRadioScopeGlobal
                rpChange=get(hSliderPh0,'value')-NmrData.rp;
                lpChange=get(hSliderPh1,'value')-NmrData.lp;
            case hRadioScopeIndividual
                rpChange=get(hSliderPh0,'value')-NmrData.rpInd(NmrData.flipnr);
                lpChange=get(hSliderPh1,'value')-NmrData.lpInd(NmrData.flipnr);
            otherwise
                error('illegal choice')
        end
        PhaseSpectrum(lpChange,rpChange,AbsPhase);
        PlotSpectrum();
        
    end
    function EditPh1_Callback(source,eventdata)
        %Phase the spectrum: zeroth order
        NmrData=guidata(hMainFigure);
        AbsPhase=2;
        switch get(hScopeGroup,'SelectedObject')
            case hRadioScopeGlobal
                rpChange=0;
                lpChange=str2double(get(hEditPh1,'String'))-NmrData.lp;
            case hRadioScopeIndividual
                rpChange=0;
                lpChange=str2double(get(hEditPh1,'String'))-NmrData.lpInd(NmrData.flipnr);
            otherwise
                error('illegal choice')
        end
        PhaseSpectrum(lpChange,rpChange,AbsPhase);
        PlotSpectrum();
    end
    function ButtonPlusPh0_Callback(source,eventdata)
        %Phase the spectrum: zeroth order
        AbsPhase=0;
        rpChange=0.1;
        lpChange=0;
        PhaseSpectrum(lpChange,rpChange,AbsPhase);
        PlotSpectrum();
    end
    function ButtonMinusPh0_Callback(source,eventdata)
        %Phase the spectrum: zeroth order
        AbsPhase=0;
        rpChange=-0.1;
        lpChange=0;
        PhaseSpectrum(lpChange,rpChange,AbsPhase);
        PlotSpectrum();
    end
    function ButtonPlusPh1_Callback(source,eventdata)
        %Phase the spectrum: zeroth order
        AbsPhase=0;
        rpChange=0;
        lpChange=0.5;
        PhaseSpectrum(lpChange,rpChange,AbsPhase);
        PlotSpectrum();
    end
    function ButtonMinusPh1_Callback(source,eventdata)
        AbsPhase=0;
        rpChange=0;
        lpChange=-0.5;
        PhaseSpectrum(lpChange,rpChange,AbsPhase);
        PlotSpectrum();
    end
    function ButtonAutophase_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        fac=fminsearch('entropy_fun',[0 0],optimset('TolX',1e-14),NmrData.SPECTRA(:,NmrData.flipnr));
           lpChange=-fac(2);
        rpChange=-fac(1);
        AbsPhase=2;
        
        PhaseSpectrum(lpChange,rpChange,AbsPhase);
        guidata(hMainFigure,NmrData);
        PlotSpectrum();
    end
%----------End of Phase panel Callbacks------------------------------------
%% ---------Plot Control Callbacks----------------------------------
    function GroupZoomPan_Callback( eventdata, handles)
        NmrData=guidata(hMainFigure);
        zoom off
        pan off
        switch get(hZoomPanGroup,'SelectedObject')
            case hRadioZoom
                
            case hRadioPan
                
            otherwise
                error('illegal choice')
        end
        guidata(hMainFigure,NmrData);
    end
    function panXYButton_Callback(source,eventdata)
        zoom off
        pan off
        switch get(hZoomPanGroup,'SelectedObject')
            case hRadioZoom
                zoom on
            case hRadioPan
                pan on
            otherwise
                error('illegal choice')
        end
    end
    function panXButton_Callback(source,eventdata)
        zoom off
        pan off
        switch get(hZoomPanGroup,'SelectedObject')
            case hRadioZoom
                zoom xon
            case hRadioPan
                pan xon
            otherwise
                error('illegal choice')
        end
    end
    function panYButton_Callback(source,eventdata)
        zoom off
        pan off
        switch get(hZoomPanGroup,'SelectedObject')
            case hRadioZoom
                zoom yon
            case hRadioPan
                pan yon
            otherwise
                error('illegal choice')
        end
    end
    function panOffButton_Callback(source,eventdata)
        pan off
        zoom off
    end
    function GroupAbsPhase_Callback(source,eventdata)
        % Display the data in absolute value mode.
        pan off
        zoom off
        NmrData=guidata(hMainFigure);
        if NmrData.plottype==0
            NmrData.xlim_fid=xlim();
            NmrData.ylim_fid=ylim();
        elseif NmrData.plottype==1
            NmrData.xlim_spec=xlim();
            NmrData.ylim_spec=ylim();
        else
            error('Illegal plot type')
        end
        switch get(hAbsPhaseGroup,'SelectedObject')
            case hRadioPhase
                NmrData.disptype=1;
            case hRadioAbs
                NmrData.disptype=0;
            otherwise
                error('illegal choice')
        end
        
        guidata(hMainFigure,NmrData);
        PlotSpectrum();
        NmrData.xlim_fid=xlim();
        NmrData.ylim_fid=ylim();
        guidata(hMainFigure,NmrData);
        
        
    end
    function ButtonPlotCurrent_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        if NmrData.plottype==0
            NmrData.xlim_fid=xlim();
            NmrData.ylim_fid=ylim();
        elseif NmrData.plottype==1
            NmrData.xlim_spec=xlim();
            NmrData.ylim_spec=ylim();
        else
            error('Illegal plot type')
        end
        NmrData.plotsep=1;
        guidata(hMainFigure,NmrData);
        PlotSpectrum();
        NmrData.plotsep=0;
        guidata(hMainFigure,NmrData);
    end
    function ButtonLarge_Callback(source,eventdata)
        % Display the Fid.
        NmrData=guidata(hMainFigure);
        pan off
        zoom off
        switch get(hButtonLarge,'value')
            case 1
                set(hFlipPanel,'Visible','Off')
                set(hFlipPanel2,'Visible','Off')
                set(hFlipPanelSpec,'Visible','Off')
                set(hProcessPanel,'Visible','Off')
                set(hCorrectionPanel,'Visible','Off')
                set(hAPPanel,'Visible','Off')
                set(hSliderPanel,'Visible','Off')
                set(hAxes,'Position',[0.02 0.25 0.96 0.73])
                set(hButtonNormal,'value',0)
                set(hCheckPhase,'Enable','On')
                set(hCheckArray,'Enable','On')
                set(hCheckProcess,'Enable','On')
                set(hCheckCorrect,'Enable','On')
                NmrData.panelpos=[0 0];
                guidata(hMainFigure,NmrData);
                CheckPhase_Callback();
                CheckProcess_Callback();
                CheckCorrect_Callback();
                CheckArray_Callback();
            case 0
                
            otherwise
        end
        guidata(hMainFigure,NmrData);
    end
    function ButtonNormal_Callback(source,eventdata)
        % Display the Fid.
        NmrData=guidata(hMainFigure);
        pan off
        zoom off
        switch get(hButtonNormal,'value')
            case 1
                set(hAxes,'Position',[0.02 0.45 0.96 0.45])
                set(hArrayPanel,'Visible','Off')
                set(hFlipPanel,'Parent',hMainFigure,'Position',[0.2,0.935,0.15,0.05])
                set(hFlipPanel2,'Parent',hMainFigure,'Position',[0.6,0.935,0.15,0.05])
                set(hFlipPanelSpec,'Parent',hMainFigure,'Position',[0.4,0.935,0.15,0.05])
                set(hProcessPanel,'Position',[0.31,0.2,0.3,0.2])
                set(hCorrectionPanel,'Position',[0.31,0.01,0.3,0.2])
                set(hSliderPanel,'Position',[0.01,0.2,0.3,0.2])
                set(hFlipPanel,'Visible','On')
                set(hFlipPanel2,'Visible','On')
                set(hFlipPanelSpec,'Visible','On')
                set(hProcessPanel,'Visible','On')
                set(hCorrectionPanel,'Visible','On')
                set(hAPPanel,'Visible','On')
                set(hSliderPanel,'Visible','On')
                set(hCheckPhase,'Enable','Off')
                set(hCheckArray,'Enable','Off')
                set(hCheckProcess,'Enable','Off')
                set(hCheckCorrect,'Enable','Off')
                set(hButtonLarge,'value',0)
            case 0
                
                
            otherwise
        end
        guidata(hMainFigure,NmrData);
    end
    function CheckPhase_Callback(source,eventdata)
        %Show phase panel in large mode
        NmrData=guidata(hMainFigure);
        pan off
        zoom off
        if get(hCheckPhase,'Value')
            if NmrData.panelpos(1)==0
                %position one free
                set(hSliderPanel,'Position',[0.31,0.01,0.3,0.2])
                set(hSliderPanel,'Visible','On')
                NmrData.panelpos(1)=hSliderPanel;
            elseif NmrData.panelpos(2)==0
                set(hSliderPanel,'Position',[0.61,0.01,0.3,0.2])
                set(hSliderPanel,'Visible','On')
                NmrData.panelpos(2)=hSliderPanel;
            else
                errordlg('Remove a current panel first','Too many panels already');
                set(hCheckPhase,'Value',0)
            end
        else
            set(hSliderPanel,'Visible','Off')
            if NmrData.panelpos(1)==hSliderPanel
                NmrData.panelpos(1)=0;
            elseif NmrData.panelpos(2)==hSliderPanel
                NmrData.panelpos(1)=0;
            else
                % disp('Unknown panel position')
            end
        end
        
        guidata(hMainFigure,NmrData);
    end
    function CheckProcess_Callback(source,eventdata)
        %Show phase panel in large mode
        NmrData=guidata(hMainFigure);
        pan off
        zoom off
        %get(hCheckProcess,'Value')
        if get(hCheckProcess,'Value')
            if NmrData.panelpos(1)==0
                %position one free
                set(hProcessPanel,'Position',[0.31,0.01,0.3,0.2])
                set(hProcessPanel,'Visible','On')
                NmrData.panelpos(1)=hProcessPanel;
            elseif NmrData.panelpos(2)==0
                set(hProcessPanel,'Position',[0.61,0.01,0.3,0.2])
                set(hProcessPanel,'Visible','On')
                NmrData.panelpos(2)=hProcessPanel;
            else
                errordlg('Remove a current panel first','Too many panels already');
                set(hCheckProcess,'Value',0)
            end
        else
            set(hProcessPanel,'Visible','Off')
            if NmrData.panelpos(1)==hProcessPanel
                NmrData.panelpos(1)=0;
            elseif NmrData.panelpos(2)==hProcessPanel
                NmrData.panelpos(2)=0;
            else
                %disp('Unknown panel position')
            end
        end
        
        guidata(hMainFigure,NmrData);
    end
    function CheckCorrect_Callback(source,eventdata)
        %Show phase panel in large mode
        NmrData=guidata(hMainFigure);
        pan off
        zoom off
        %get(hCheckProcess,'Value')
        if get(hCheckCorrect,'Value')
            if NmrData.panelpos(1)==0
                %position one free
                set(hCorrectionPanel,'Position',[0.31,0.01,0.3,0.2])
                set(hCorrectionPanel,'Visible','On')
                NmrData.panelpos(1)=hCorrectionPanel;
            elseif NmrData.panelpos(2)==0
                set(hCorrectionPanel,'Position',[0.61,0.01,0.3,0.2])
                set(hCorrectionPanel,'Visible','On')
                NmrData.panelpos(2)=hCorrectionPanel;
            else
                errordlg('Remove a current panel first','Too many panels already');
                set(hCheckCorrect,'Value',0)
            end
        else
            set(hCorrectionPanel,'Visible','Off')
            if NmrData.panelpos(1)==hCorrectionPanel
                NmrData.panelpos(1)=0;
            elseif NmrData.panelpos(2)==hCorrectionPanel
                NmrData.panelpos(2)=0;
            else
                % disp('Unknown panel position')
            end
        end
        
        guidata(hMainFigure,NmrData);
    end
    function CheckArray_Callback(source,eventdata)
        %Show phase panel in large mode
        NmrData=guidata(hMainFigure);
        pan off
        zoom off
        %get(hCheckProcess,'Value')
        if get(hCheckArray,'Value')
            if NmrData.panelpos(1)==0
                %position one free
                set(hArrayPanel,'Position',[0.31,0.01,0.3,0.2])
                set(hFlipPanel,'Parent',hArrayPanel,'Position',[0.01,0.6,0.47,0.3],...
                    'Visible','On')
                set(hFlipPanel2,'Parent',hArrayPanel,'Position',[0.51,0.6,0.47,0.3],...
                    'Visible','On')
                set(hFlipPanelSpec,'Parent',hArrayPanel,'Position',[0.26,0.2,0.47,0.3],...
                    'Visible','On')
                
                
                set(hArrayPanel,'Visible','On')
                NmrData.panelpos(1)=hArrayPanel;
            elseif NmrData.panelpos(2)==0
                set(hArrayPanel,'Position',[0.61,0.01,0.3,0.2])
                set(hFlipPanel,'Parent',hArrayPanel,'Position',[0.01,0.6,0.47,0.3],...
                    'Visible','On')
                set(hFlipPanel2,'Parent',hArrayPanel,'Position',[0.51,0.6,0.47,0.3],...
                    'Visible','On')
                set(hFlipPanelSpec,'Parent',hArrayPanel,'Position',[0.26,0.2,0.47,0.3],...
                    'Visible','On')
                set(hArrayPanel,'Visible','On')
                NmrData.panelpos(2)=hArrayPanel;
            else
                errordlg('Remove a current panel first','Too many panels already');
                set(hCheckArray,'Value',0)
            end
        else
            set(hFlipPanel,'Visible','Off','Parent',hMainFigure,'Position',[0.2,0.935,0.15,0.05]);
            set(hFlipPanel2, 'Visible','Off','Parent',hMainFigure,'Position',[0.6,0.935,0.15,0.05]);
            set(hFlipPanelSpec, 'Visible','Off','Parent',hMainFigure,'Position',[0.4,0.935,0.15,0.05]);
            set(hArrayPanel,'Visible','Off')
            if NmrData.panelpos(1)==hArrayPanel
                NmrData.panelpos(1)=0;
            elseif NmrData.panelpos(2)==hArrayPanel
                NmrData.panelpos(2)=0;
            else
                %   disp('Unknown panel position')
            end
        end
        
        guidata(hMainFigure,NmrData);
    end
    function ButtonPlayCurrentFid_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        str=['Playing FID nr: ' num2str(NmrData.flipnr)];
        text(0.5*NmrData.at,0.4*max(real(NmrData.FID(:,NmrData.flipnr))),str,'Color','Black','Fontweight','bold')
        soundsc(real(NmrData.FID(:,NmrData.flipnr))./max(abs(real(NmrData.FID(:,1)))),4096)
        pause(0.5)
        PlotSpectrum();
    end
    function ButtonPlayAllFid_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        
        startnr=NmrData.flipnr;
        for k=1:NmrData.arraydim
            NmrData.flipnr=k;
            guidata(hMainFigure,NmrData);
            PlotSpectrum();
            str=['Playing FID nr: ' num2str(k)];
            text(0.5*NmrData.at,0.4*max(real(NmrData.FID(:,1))),str,'Color','Black','Fontweight','bold');
            drawnow
            sound(real(NmrData.FID(:,k))./max(abs(real(NmrData.FID(:,1)))),4096)
            pause(0.3)
            
        end
        NmrData.flipnr=startnr;
        guidata(hMainFigure,NmrData);
        PlotSpectrum();
    end
    function ButtonFid_Callback(source,eventdata)
        % Display the Fid.
        NmrData=guidata(hMainFigure);
        pan off
        zoom off
        switch get(hButtonFid,'value')
            case 1
                NmrData.plottype=0; %FID
                set(hPlotFID,'Enable','on');
                set(hPlotWinfunc,'Enable','on');
                set(hPlotFIDWinfunc,'Enable','on');
                NmrData.xlim_spec=xlim();
                NmrData.ylim_spec=ylim();
                guidata(hMainFigure,NmrData);
                PlotSpectrum();
                NmrData.xlim_fid=xlim();
                NmrData.ylim_fid=ylim();
                guidata(hMainFigure,NmrData);
                set(hButtonSpec,'value',0)
                
            case 0
                
                
            otherwise
        end
        guidata(hMainFigure,NmrData);
    end
    function ButtonSpec_Callback(source,eventdata)
        % Display the spectrum.
        
        NmrData=guidata(hMainFigure);
        pan off
        zoom off
        get(hButtonFid,'value')
        switch get(hButtonSpec,'value')
            case 1
                NmrData.plottype=1; %FID
                set(hPlotFID,'Enable','off');
                set(hPlotWinfunc,'Enable','off');
                set(hPlotFIDWinfunc,'Enable','off')
                NmrData.xlim_fid=xlim();
                NmrData.ylim_fid=ylim();
                guidata(hMainFigure,NmrData);
                PlotSpectrum();
                NmrData.xlim_spec=xlim();
                NmrData.ylim_spec=ylim();
                guidata(hMainFigure,NmrData);
                set(hButtonFid,'value',0)
                
            case 0
                
                
            otherwise
        end
    end
    function ButtonMult2_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        if NmrData.plottype==0
            NmrData.xlim_fid=xlim();
        elseif NmrData.plottype==1
            NmrData.xlim_spec=xlim();
        else
            error('Illegal plot type')
        end
        if get(hIntegralsScale,'Value')
            NmrData.Intscale=NmrData.Intscale*2;
            guidata(hMainFigure,NmrData);
            DrawIntLine();
        else
            ylim(ylim()/2);
            if NmrData.plottype==0
                NmrData.ylim_fid=ylim();
            elseif NmrData.plottype==1
                NmrData.ylim_spec=ylim();
            else
                error('Illegal plot type')
            end
        end
        guidata(hMainFigure,NmrData);
        PlotSpectrum();
        
    end
    function ButtonMult11_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        if NmrData.plottype==0
            NmrData.xlim_fid=xlim();
        elseif NmrData.plottype==1
            NmrData.xlim_spec=xlim();
        else
            error('Illegal plot type')
        end
        if get(hIntegralsScale,'Value')
            NmrData.Intscale=NmrData.Intscale*1.1;
            guidata(hMainFigure,NmrData);
            DrawIntLine();
        else
            ylim(ylim()/1.1);
            if NmrData.plottype==0
                NmrData.ylim_fid=ylim();
            elseif NmrData.plottype==1
                NmrData.ylim_spec=ylim();
            else
                error('Illegal plot type')
            end
            guidata(hMainFigure,NmrData);
            PlotSpectrum();
        end
    end
    function ButtonDiv2_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        if NmrData.plottype==0
            NmrData.xlim_fid=xlim();
        elseif NmrData.plottype==1
            NmrData.xlim_spec=xlim();
        else
            error('Illegal plot type')
        end
        if get(hIntegralsScale,'Value')
            NmrData.Intscale=NmrData.Intscale/2;
            guidata(hMainFigure,NmrData);
            DrawIntLine();
        else
            ylim(ylim()*2);
            if NmrData.plottype==0
                NmrData.ylim_fid=ylim();
            elseif NmrData.plottype==1
                NmrData.ylim_spec=ylim();
            else
                error('Illegal plot type')
            end
        end
        guidata(hMainFigure,NmrData);
        PlotSpectrum();
    end
    function ButtonDiv11_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        if NmrData.plottype==0
            NmrData.xlim_fid=xlim();
        elseif NmrData.plottype==1
            NmrData.xlim_spec=xlim();
        else
            error('Illegal plot type')
        end
        if get(hIntegralsScale,'Value')
            NmrData.Intscale=NmrData.Intscale/1.1;
            guidata(hMainFigure,NmrData);
            DrawIntLine();
        else
            ylim(ylim()*1.1);
            if NmrData.plottype==0
                NmrData.ylim_fid=ylim();
            elseif NmrData.plottype==1
                NmrData.ylim_spec=ylim();
            else
                error('Illegal plot type')
            end
        end
        guidata(hMainFigure,NmrData);
        PlotSpectrum();
    end
    function ButtonAutoscale_Callback(source,eventdata)
        %Autoscale the spectrum.
        NmrData=guidata(hMainFigure);
        if get(hIntegralsScale,'Value')
            NmrData.Intscale=1;
            guidata(hMainFigure,NmrData);
            DrawIntLine();
        else
            set(hBaselineShow,'Value',0);
            ylim('auto');
            yax=ylim();
            yax(1)=yax(1)-yax(2)*0.1;
            yax(2)=yax(2)*1.1;
            if NmrData.plottype==0
                NmrData.xlim_fid=xlim();
                NmrData.ylim_fid=yax;
            elseif NmrData.plottype==1
                NmrData.xlim_spec=xlim();
                NmrData.ylim_spec=yax;
            else
                error('Illegal plot type')
            end
            guidata(hMainFigure,NmrData);
            PlotSpectrum()
        end
    end
    function ButtonFull_Callback(source,eventdata)
        %Display full FID/Spectrum
        
        axis('tight')
        NmrData=guidata(hMainFigure);
        if NmrData.plottype==0
            NmrData.xlim_fid=xlim();
        elseif NmrData.plottype==1
            NmrData.xlim_spec=xlim();
        else
            error('Illegal plot type')
        end
        guidata(hMainFigure,NmrData);
        PlotSpectrum()
        
    end
%---------End of Plot Control Callbacks------------------------------------
%% ---------Standard Processing Callbacks---------------------------
%Baseline correction
    function BaselineShow_Callback( eventdata, handles)
        zoom off
        pan off
        button_state = get(hBaselineShow,'Value');
        if button_state == 1
            Baseline_function();
        elseif button_state == 0
            hBaseline=findobj(hAxes,'tag','baseline');
            delete(hBaseline)  %
        end
        %PlotSpectrum();
    end
    function AutoBaselineButton_Callback( eventdata, handles)
        NmrData=guidata(hMainFigure);
        zoom off
        pan off
      
        if NmrData.plottype==1
            NmrData.xlim_spec=xlim();
            NmrData.ylim_spec=ylim();
        end
       
        Auto_Baseline_function();
        guidata(hMainFigure,NmrData);
        %PlotSpectrum();
        
    end
    function SetRegionsButton_Callback( eventdata, handles)
        NmrData=guidata(hMainFigure);
        zoom off
        pan off
        set(hMainFigure,'WindowButtonDownFcn',@Baseline_function)
        if NmrData.plottype==1
            NmrData.xlim_spec=xlim();
            NmrData.ylim_spec=ylim();
        end
        set(hBaselineShow,'Value',1)
        hBaseline=findobj(hAxes,'tag','baseline');
        delete(hBaseline)
        Baseline_function();
        guidata(hMainFigure,NmrData);
        PlotSpectrum();
        
    end
    function ClearRegionsButton_Callback( eventdata, handles)
        zoom off
        pan off
        NmrData=guidata(hMainFigure);
        NmrData.BasePoints=[];
        NmrData.baselinepoints=[];
        NmrData.region=ones(1,NmrData.fn);
        set(hMainFigure,'WindowButtonDownFcn',@Baseline_function)
        hBaseline=findobj(hAxes,'tag','baseline');
        delete(hBaseline)  %
        guidata(hMainFigure,NmrData);
        PlotSpectrum();
    end
    function BaselineCorrectButton_Callback( eventdata, handles)
        NmrData=guidata(hMainFigure);
        NmrData.xlim_spec=xlim();
        NmrData.ylim_spec=ylim();
        %NmrData.baselinecorr=zeros(NmrData.fn,NmrData.ngrad);
        NmrData.baselinecorr=zeros(NmrData.fn,NmrData.arraydim);
        if ~isempty(NmrData.baselinepoints)
            for k=1:NmrData.arraydim
                basefit=polyfit(NmrData.Specscale(isnan(NmrData.region))'...
                    ,NmrData.SPECTRA(isnan(NmrData.region),k),NmrData.order);
                NmrData.baselinecorr(:,k)=polyval(basefit,NmrData.Specscale);
            end
        else
            NmrData.baselinecorr=0;
        end
        NmrData.SPECTRA=NmrData.SPECTRA-NmrData.baselinecorr;
        guidata(hMainFigure,NmrData);
        %ButtonAutoscale_Callback();
        PlotSpectrum();
    end
    function EditOrder_Callback(eventdata, handles)
        NmrData=guidata(hMainFigure);
        if NmrData.order<0
            NmrData.order=0;
            set(hEditOrder,'string',num2str(NmrData.order))
        else
            NmrData.order=round(str2double(get(hEditOrder,'string')));
        end
        guidata(hMainFigure,NmrData);
        
    end
    function OrderButtonPlus_Callback(eventdata, handles)
        NmrData=guidata(hMainFigure);
        NmrData.order=NmrData.order+1;
        set(hEditOrder,'string',num2str(NmrData.order))
        guidata(hMainFigure,NmrData);
    end
    function OrderButtonMinus_Callback(eventdata, handles)
        NmrData=guidata(hMainFigure);
        if NmrData.order<1
            NmrData.order=0;
            set(hEditOrder,'string',num2str(NmrData.order))
        else
            NmrData.order=NmrData.order-1;
            set(hEditOrder,'string',num2str(NmrData.order))
            NmrData.order=round(str2double(get(hEditOrder,'string')));
        end
        guidata(hMainFigure,NmrData);
    end
%FT and Window functions
    function FTButton_Callback( eventdata, handles)
        zoom off
        pan off
        set(hMainFigure,'WindowButtonDownFcn','')
        set(hIntegralsShow,'Value',0)
        set(hBaselineShow,'Value',0)
        set(hExcludeShow,'Value',0)
        set(hLRWindowsShow,'Value',0)
        set(hPivotCheck,'Value',0)
        set(hReferenceCheck,'Value',0)
        set(hRDshowLRCheck,'Value',0)
        set(hRDshowCheck,'Value',0)
        set(hButtonFid,'value',0)
        set(hButtonSpec,'value',1)
        
        NmrData.fn=round(str2double(get(hEditFn,'string')));
        guidata(hMainFigure,NmrData);
        Winfunc=GetWinfunc('FTButton_Callback');
        NmrData=guidata(hMainFigure);
        set(hThresholdButton,'Value',get(hThresholdButton,'Min'))
        hThresh=findobj(hAxes,'tag','threshold');
        delete(hThresh)
        hPivot=findobj(hAxes,'tag','Pivot');
        delete(hPivot)
        NmrData.Specscale=linspace...
            (NmrData.sp,...
            (NmrData.sw+NmrData.sp),...
            NmrData.fn);
        NmrData.SPECTRA=zeros(NmrData.fn,NmrData.ngrad);
        %keep the origial FID
        orgfid = NmrData.FID;
        
        %leftshift the fid
        if NmrData.lrfid>0
            %left shift the fid
            for k=1:NmrData.arraydim
                NmrData.FID(:,k)= circshift(NmrData.FID(:,k),-NmrData.lrfid);
            end
        end
        
        %Apply frequency shift if desired
        if get(hCheckApplyFT,'Value')
            disp('Applying frequency shifts (alignment)')
            fshift=NmrData.fshift;
            if get(hCheckApplyLinear,'Value')      
                linStep=str2double(get(hEditLinear,'String'))./NmrData.sfrq;
                linarray=linspace(0,linStep*(NmrData.arraydim-1),NmrData.arraydim);
                fshift=fshift+linarray;
            end
            Timescale=linspace(0,NmrData.at,NmrData.np)';
            for k=1:NmrData.arraydim
                NmrData.FID(:,k)= NmrData.FID(:,k).*exp(1i.*fshift(k)*2*pi.*Timescale);
            end
        end
        
        
        
        %DC correction
        tmpfid=zeros(NmrData.fn,NmrData.arraydim);
        dcpoints=round(5*NmrData.np/20);
        for k=1:NmrData.arraydim
            if NmrData.fn>=NmrData.np                
                if NmrData.dc
                    tmpfid(1:NmrData.np,k)=NmrData.FID(1:NmrData.np,k) - mean(orgfid(dcpoints:end,k));
                else
                    tmpfid(1:NmrData.np,k)=NmrData.FID(1:NmrData.np,k);
                end
            else
                if NmrData.dc
                    tmpfid(1:NmrData.fn,k)=NmrData.FID(1:NmrData.fn,k) - mean(orgfid(dcpoints:end,k));
                else
                    tmpfid(1:NmrData.fn,k)=NmrData.FID(1:NmrData.fn,k);
                end
            end
            
        end
        
        %remove shifted points before any zerofilling
        if NmrData.fn>=NmrData.np
            tmpfid((NmrData.np-NmrData.lrfid):NmrData.np,:)=0;
           % tmpfid((end-NmrData.lrfid):end,:)=NmrData.FID((end-NmrData.lrfid):end,:);
            NmrData.FID=zeros(NmrData.fn,NmrData.arraydim);
            NmrData.FID(:,:)=tmpfid.*repmat(Winfunc,1,NmrData.arraydim);
        else
            NmrData.FID=tmpfid.*repmat(Winfunc,1,NmrData.arraydim);
           % NmrData.FID((NmrData.fn+1):end,:)=[];
        end
        NmrData.FID(1,:)=NmrData.FID(1,:).*NmrData.fpmult;
        NmrData.SPECTRA=fft(NmrData.FID);
        %NmrData.SPECTRA=fft(NmrData.FID,NmrData.fn);
        NmrData.FID=orgfid;
        NmrData.SPECTRA=flipud((fftshift(NmrData.SPECTRA,1)));
        %         Baseline_function();
        %         IntLine_function();
        
        guidata(hMainFigure,NmrData);
        switch get(hScopeGroup,'SelectedObject')
            case hRadioScopeGlobal
                PhaseSpectrum(NmrData.lp,NmrData.rp,1)
            case hRadioScopeIndividual
                disp('Using individual phases for arrayed spectra')
                PhaseSpectrum(0,0,10)
                
%                 fliptmp=NmrData.flipnr;
%                 for m=1:NmrData.arraydim
%                     NmrData.flipnr=m;
%                     guidata(hMainFigure,NmrData);
%                     PhaseSpectrum...
%                         (NmrData.lpInd(m),NmrData.rpInd(m),1)
%                 end
%                 NmrData.flipnr=fliptmp;
                guidata(hMainFigure,NmrData);
            otherwise
                error('illegal choice')
        end
        
        NmrData.plottype=1;
        
        if NmrData.dcspec
            dcpoints=round(2*NmrData.fn/20);
            for k=1:NmrData.arraydim
                NmrData.SPECTRA(:,k)=NmrData.SPECTRA(:,k)-mean(NmrData.SPECTRA([round(dcpoints/10):dcpoints end-dcpoints:end-round(dcpoints/10)],k));
            end
        end
        

        
        for k=1:NmrData.arraydim   
           
                NmrData.SPECTRA(:,k)=circshift(NmrData.SPECTRA(:,k), NmrData.lsspec + NmrData.linshift*NmrData.lsspec*(k-1));
        end
        guidata(hMainFigure,NmrData);
        PlotSpectrum();
    end
    function EditFn_Callback(eventdata, handles)
        NmrData=guidata(hMainFigure);
        %NmrData.fn=round(str2double(get(hEditFn,'string')));
        fn=round(str2double(get(hEditFn,'string')));
        if isnan(NmrData.fn)
            disp('Illegal fourier number - defaulting to np')
            %NmrData.fn=NmrData.np;
            fn=NmrData.np;
        end
        %set(hEditFn,'String',num2str(NmrData.fn))
        set(hEditFn,'String',num2str(fn))
        guidata(hMainFigure,NmrData);
    end
    function FnButtonPlus_Callback(eventdata, handles)
        NmrData=guidata(hMainFigure);
        %         NmrData.fn=2^nextpow2(NmrData.fn+1);
        %         set(hEditFn,'string',num2str(NmrData.fn))
        fn=round(str2double(get(hEditFn,'string')));
        fn=2^nextpow2(fn+1);
        set(hEditFn,'string',num2str(fn))
        guidata(hMainFigure,NmrData);
    end
    function FnButtonMinus_Callback(eventdata, handles)
        NmrData=guidata(hMainFigure);
        %         NmrData.fn=2^nextpow2(NmrData.fn/2);
        %         set(hEditFn,'string',num2str(NmrData.fn))
        fn=round(str2double(get(hEditFn,'string')));
        fn=2^nextpow2(fn/2);
        set(hEditFn,'string',num2str(fn))
        guidata(hMainFigure,NmrData);
    end
    function EditLb_Callback(eventdata, handles)
        NmrData=guidata(hMainFigure);
        NmrData.lb=(str2double(get(hEditLb,'string')));
        guidata(hMainFigure,NmrData);
        if NmrData.plottype==0
            %ButtonFid_Callback();
            PlotSpectrum();
        end
        %ButtonFid_Callback();
    end
    function CheckLb_Callback(eventdata, handles)
        NmrData=guidata(hMainFigure);
        if get(hCheckLb,'Value')
            set(hEditLb,'Enable','On')
            NmrData.lb=str2double(get(hEditLb,'string'));
        else
            set(hEditLb,'Enable','Off')
        end
        
        guidata(hMainFigure,NmrData);
        if NmrData.plottype==0
            %ButtonFid_Callback();
            PlotSpectrum();
        end
    end
    function EditGw_Callback(eventdata, handles)
        NmrData=guidata(hMainFigure);
        gwtmp=NmrData.gw;
        NmrData.gw=(str2double(get(hEditGw,'string')));
        if NmrData.gw==0
            errordlg('gw = 0 is illegal','gw error')
            NmrData.gw=gwtmp;
            set(hEditGw,'String',num2str(gwtmp))
        end
        
        guidata(hMainFigure,NmrData);
        if NmrData.plottype==0
            %ButtonFid_Callback();
            PlotSpectrum();
        end
        %ButtonFid_Callback();
    end
    function CheckGw_Callback(eventdata, handles)
        NmrData=guidata(hMainFigure);
        if get(hCheckGw,'Value')
            set(hEditGw,'Enable','On')
            NmrData.gw=(str2double(get(hEditGw,'string')));
        else
            set(hEditGw,'Enable','Off')
        end
        if NmrData.plottype==0
            %ButtonFid_Callback();
            PlotSpectrum();
        end
        guidata(hMainFigure,NmrData);
    end
    function PlotFID_Callback( eventdata, handles)
        zoom off
        pan off
        button_state = get(hPlotFID,'Value');
        if button_state == 1
            
        elseif button_state == 0
            
        end
        if NmrData.plottype==0
            %ButtonFid_Callback();
            PlotSpectrum();
        end
    end
    function PlotWinfunc_Callback( eventdata, handles)
        zoom off
        pan off
        button_state = get(hPlotWinfunc,'Value');
        if button_state == 1
            
        elseif button_state == 0
            
        end
        if NmrData.plottype==0
           % ButtonFid_Callback();
            PlotSpectrum();
        end
    end
    function PlotFIDWinfunc_Callback( eventdata, handles)
        zoom off
        pan off
        button_state = get(hPlotFIDWinfunc,'Value');
        if button_state == 1
            
        elseif button_state == 0
            
        end
        if NmrData.plottype==0
            %ButtonFid_Callback();
            PlotSpectrum();
        end
    end
%Reference
    function ReferenceButton_Callback( eventdata, handles)
        zoom off
        pan off
        set(hReferenceCheck,'Value',1)
        set(hMainFigure,'WindowButtonDownFcn','')
        set(hAxes,'ButtonDownFcn',@Reference_function)
    end
    function FindButton_Callback( eventdata, handles)        
        set(hMainFigure,'WindowButtonDownFcn','')
        zoom off
        pan off
        NmrData=guidata(hMainFigure);
        switch NmrData.shiftunits
            case 'ppm'
                startunit='ppm';
            case 'Hz'
                NmrData.shiftunits='ppm';
                NmrData.xlim_spec=NmrData.xlim_spec./NmrData.sfrq;
                NmrData.reference=NmrData.reference./NmrData.sfrq;
                startunit='Hz';
            otherwise
                error('illegal choice')
        end
        
        hReference=findobj(hAxes,'tag','Reference');
        delete(hReference)
        xpoint=(NmrData.reference-NmrData.sp)/NmrData.sw;
        xpoint=round(xpoint*NmrData.fn);
        ppmsearch=0.01;
        xmax=xpoint+round(ppmsearch/NmrData.sw*NmrData.fn);
        xmin=xpoint-round(ppmsearch/NmrData.sw*NmrData.fn);
        tempspec=real(NmrData.SPECTRA(:,NmrData.flipnr));
        tempspec([1:xmin xmax:end],:)=tempspec([1:xmin xmax:end],:).*0.0;
        [~, maxpoint]=max(tempspec);
        maxpoint=maxpoint-1;
        maxpoint=maxpoint/NmrData.fn;
        maxpoint=maxpoint*NmrData.sw;
        maxpoint=maxpoint + NmrData.sp;
        NmrData.reference=maxpoint;
        switch startunit
            case 'ppm'
                %all fine
            case 'Hz'
                NmrData.shiftunits='Hz';
                NmrData.xlim_spec=NmrData.xlim_spec.*NmrData.sfrq;
                NmrData.reference=NmrData.reference.*NmrData.sfrq;
            otherwise
                error('illegal choice')
        end
        NmrData.referencexdata=[NmrData.reference NmrData.reference];
        NmrData.referenceydata=get(hAxes,'ylim');
        line(NmrData.referencexdata,NmrData.referenceydata,...
            'color','magenta','linewidth', 1.0,...
            'tag','Reference');
        drawnow
        set(hReferenceCheck,'Value',1)
        set(hAxes,'ButtonDownFcn',@Reference_function)
        set(hChangeEdit,'string',num2str(NmrData.reference,'%1.3f'));
        guidata(hMainFigure,NmrData);
        
    end
    function ChangeButton_Callback( eventdata, handles)
        set(hMainFigure,'WindowButtonDownFcn','')
        %Reference the spectrum
        NmrData=guidata(hMainFigure);
        zoom off
        pan off
        set(hReferenceCheck,'Value',1)
        set(hAxes,'ButtonDownFcn',@Reference_function)
        new_ref=inputdlg('Enter the new reference value (ppm)','Reference',1,{'0'});
        new_ref=str2double(new_ref);
        NmrData.sp=NmrData.sp-(NmrData.reference-new_ref);
        NmrData.Specscale=linspace...
            (NmrData.sp,...
            (NmrData.sw+NmrData.sp),...
            NmrData.fn);
        NmrData.xlim_spec=xlim()-(NmrData.reference-new_ref);
        NmrData.ylim_spec=ylim();
        NmrData.reference=new_ref;
        NmrData.referencexdata=[NmrData.reference NmrData.reference];
        NmrData.referenceydata=get(hAxes,'ylim');
        set(hChangeEdit,'string',num2str(NmrData.reference,'%1.3f'));
        guidata(hMainFigure,NmrData);
        PlotSpectrum();
    end
    function ReferenceCheck_Callback( eventdata, handles)
        NmrData=guidata(hMainFigure);
        set(hMainFigure,'WindowButtonDownFcn','')
        if get(hReferenceCheck,'Value')
            % Toggle button is pressed-take approperiate action
            line(NmrData.referencexdata,NmrData.referenceydata,...
                'color','magenta','linewidth', 1.0,...
                'tag','Reference');
            set(hAxes,'ButtonDownFcn',@Reference_function)
            set(hChangeEdit,'string',num2str(NmrData.reference,'%1.3f'));
            drawnow
        else
            % Toggle button is not pressed-take appropriate action
            hReference=findobj(hAxes,'tag','Reference');
            delete(hReference)
            set(hChangeEdit,'string','');
            set(hAxes,'ButtonDownFcn','')
        end
        guidata(hMainFigure,NmrData);
    end
    function ShapeButton_Callback(eventdata, handles)
        % find the peak width at half height
        % very klunky prliminary version
        % MN    5Oct2007
        
        %lets try and do some FT interpolation
        
        %find the max point
        FindButton_Callback();
        PeakMax=(NmrData.reference-NmrData.sp)/NmrData.sw;
        PeakMax=round(PeakMax*NmrData.fn);        
        StartSpec=real(NmrData.SPECTRA(:,NmrData.flipnr));
        amp=StartSpec(PeakMax);
        k=1;
        while StartSpec(PeakMax+k)>amp/2
            k=k+1;
            if PeakMax+k>length(StartSpec)
                break
            end
        end
        
        RightSpecPoint=k;
        if PeakMax+10*RightSpecPoint>length(StartSpec)
            RightSpecPoint= length(StartSpec)-PeakMax;
        else
            RightSpecPoint=10*RightSpecPoint;
        end
        
        k=1;
        while StartSpec(PeakMax-k)>amp/2
            k=k+1;
            if PeakMax-k<1
                break
            end
        end        
        
        LeftSpecPoint=k;
        if PeakMax-10*LeftSpecPoint<1
            LeftSpecPoint= 1-PeakMax;
        else
            LeftSpecPoint=10*LeftSpecPoint;
        end
        OutSpec=StartSpec(PeakMax-LeftSpecPoint:PeakMax+RightSpecPoint);
        PeakMaxOut=LeftSpecPoint+2;        
        PeakWidth=EstimatePeakshape(OutSpec,PeakMaxOut);        
        disp(['Peak width at half height is: ' num2str(PeakWidth,3) ' Hz'])
        plotval=ylim();
        plotval=plotval(2)/2;
        hText=findobj(hAxes,'tag','shapetext');
        delete(hText);
        text(NmrData.reference,plotval,['Peak width at half height is: ' num2str(PeakWidth,3) ' Hz'],'tag','shapetext')
        
        return        
    end
%Reference deconvolution
    function RDButtonLeft_Callback( eventdata, handles)
        zoom off
        pan off
        set(hMainFigure,'WindowButtonDownFcn','')
        set(hAxes,'ButtonDownFcn',@RDLeft_function)
    end
    function RDButtonRight_Callback( eventdata, handles)
        zoom off
        pan off
        set(hMainFigure,'WindowButtonDownFcn','')
        set(hAxes,'ButtonDownFcn',@RDRight_function)
    end
    function RDButtonCentre_Callback( eventdata, handles)
        zoom off
        pan off
        set(hMainFigure,'WindowButtonDownFcn','')
        set(hAxes,'ButtonDownFcn',@RDCentre_function)
    end
    function RDButtonFind_Callback( eventdata, handles)
        zoom off
        pan off
        set(hMainFigure,'WindowButtonDownFcn','')
        NmrData=guidata(hMainFigure);
        switch NmrData.shiftunits
            case 'ppm'
                startunit='ppm';
            case 'Hz'
                NmrData.shiftunits='ppm';
                NmrData.xlim_spec=NmrData.xlim_spec./NmrData.sfrq;
                NmrData.RDcentre=NmrData.RDcentre./NmrData.sfrq;                
                startunit='Hz';
            otherwise
                error('illegal choice')
        end
       
        hRDcentre=findobj(hAxes,'tag','RDcentre');
        delete(hRDcentre)
        xpoint=(NmrData.RDcentre-NmrData.sp)/NmrData.sw;
        xpoint=round(xpoint*NmrData.fn);
        ppmsearch=0.01;
        xmax=xpoint+round(ppmsearch/NmrData.sw*NmrData.fn);
        xmin=xpoint-round(ppmsearch/NmrData.sw*NmrData.fn);
        tempspec=real(NmrData.SPECTRA(:,NmrData.flipnr));
        tempspec([1:xmin xmax:end],:)=tempspec([1:xmin xmax:end],:).*0.0;
        [~, maxpoint]=max(tempspec);
        maxpoint=maxpoint-1;
        maxpoint=maxpoint/NmrData.fn;
        maxpoint=maxpoint*NmrData.sw;
        maxpoint=maxpoint + NmrData.sp;
        NmrData.RDcentre=maxpoint;
        switch startunit
            case 'ppm'
                %all fine
            case 'Hz'
                NmrData.shiftunits='Hz';
                NmrData.xlim_spec=NmrData.xlim_spec.*NmrData.sfrq;
                NmrData.RDcentre=NmrData.RDcentre.*NmrData.sfrq;
            otherwise
                error('illegal choice')
        end
        NmrData.RDcentrexdata=[NmrData.RDcentre NmrData.RDcentre];
        NmrData.RDcentreydata=get(hAxes,'ylim');
        line(NmrData.RDcentrexdata,NmrData.RDcentreydata,...
            'color','black','linewidth', 1.0,...
            'tag','RDcentre');
        %set(hReferenceCheck,'Value',1)
        guidata(hMainFigure,NmrData);
        set(hAxes,'ButtonDownFcn',@RDcentre_function)
        guidata(hMainFigure,NmrData);
        
    end
    function CheckLbRD_Callback(eventdata, handles)
        NmrData=guidata(hMainFigure);
        if get(hCheckLbRD,'Value')
            set(hEditLbRD,'Enable','On')
            %NmrData.lb=str2double(get(hEditLb,'string'));
        else
            set(hEditLbRD,'Enable','Off')
        end
        guidata(hMainFigure,NmrData);
    end
    function CheckGwRD_Callback(eventdata, handles)
        NmrData=guidata(hMainFigure);
        if get(hCheckGwRD,'Value')
            set(hEditGwRD,'Enable','On')
            %NmrData.lb=str2double(get(hEditLb,'string'));
        else
            set(hEditGwRD,'Enable','Off')
        end
        guidata(hMainFigure,NmrData);
    end
    function EditGwRD_Callback(eventdata, handles)
        gw=(str2double(get(hEditGwRD,'string')));
        if gw==0
            errordlg('gw = 0 is illegal','gw error')
            set(hEditGwRD,'String',num2str(1))
        end
    end
    function EditLbRD_Callback(eventdata, handles)
        %add some safety
    end
    function RDButtonFiddle_Callback( eventdata, handles)
        NmrData=guidata(hMainFigure);
        if NmrData.plottype==0
            NmrData.xlim_fid=xlim();
            NmrData.ylim_fid=ylim();
        elseif NmrData.plottype==1
            NmrData.xlim_spec=xlim();
            NmrData.ylim_spec=ylim();
        else
            error('Illegal plot type')
        end
        %check that the limits have been set
        if isempty(NmrData.RDleft)==1
            errordlg('Please set left limit for the reference peak','Reference deconvolution error')
            return
        end
        if isempty(NmrData.RDright)==1
            errordlg('Please set right limit for the reference peak','Reference deconvolution error')
            return
        end
        if isempty(NmrData.RDcentre)==1
            errordlg('Please set centre for the reference peak','Reference deconvolution error')
            return
        end
        %check zerofilling
        if NmrData.fn<2*NmrData.np
            disp('Warning - data should be zerofilled at least once')
        end
        %get the lineshape factor
        gw=Inf;
        lb=0;
        if strcmpi(get(hEditLbRD,'Enable'),'off')==1 && strcmpi(get(hEditGwRD,'Enable'),'off')
            errordlg('Please set a target lineshape','Reference deconvolution error')
            return
        else
            if strcmpi(get(hEditLbRD,'Enable'),'on')==1
                lb=str2double(get(hEditLbRD,'string'));
            end
            if strcmpi(get(hEditGwRD,'Enable'),'on')==1
                gw=str2double(get(hEditGwRD,'string'));
                %Moving to gaussian width
                %gw=FwHH=2*sqrt(log(2)))/(pi*gf)
                gw=2*sqrt(log(2))/(pi*gw);
            end
        end
        % for m=1:NmrData.ngrad
        SPECTRA=zeros(NmrData.fn/2,NmrData.arraydim);
        for m=1:NmrData.arraydim
            % create the time shifted fid
            wholespec=real(NmrData.SPECTRA(:,m));
            wholefid=ifft(flipud(fftshift(real(NmrData.SPECTRA(:,m)),1)),NmrData.fn);
            wholefid=wholefid(1:NmrData.fn/2);
            
            % create the time shifted FID of the reference peak
            speclim(2)=NmrData.RDleft;
            speclim(1)=NmrData.RDright;
            if speclim(1)<NmrData.sp
                speclim(1)=NmrData.sp;
            end
            if speclim(2)>(NmrData.sw+NmrData.sp)
                speclim(2)=(NmrData.sw+NmrData.sp);
            end
            speclim=NmrData.fn*(speclim-NmrData.sp)/NmrData.sw;
            if speclim(1)<1
                speclim(1)=1;
            end
            if speclim(2)>NmrData.fn
                speclim(2)=NmrData.fn;
            end
            speclim=round(speclim);
            %speclim(1)=speclim(1)+1;
            exprefspec=wholespec;
            
            %do a baseline correction using 1/8 of the data points on the
            %extreme of each side of the reference region
            numpoints=speclim(2)-speclim(1);
            numpoints=round(numpoints/8)  ;
            refbasefit=polyfit(NmrData.Specscale...
                ([speclim(1):(speclim(1)+numpoints) (speclim(2)-numpoints):speclim(2)])',...
                exprefspec([speclim(1):(speclim(1)+numpoints) (speclim(2)-numpoints):speclim(2)]),1);
            corrline=polyval(refbasefit,NmrData.Specscale(speclim(1):speclim(2)));
            exprefspec(speclim(1):speclim(2))=exprefspec(speclim(1):speclim(2))-corrline';
            exprefspec([1:speclim(1) speclim(2):NmrData.fn])=0;
            
            %expreffid=ifft(exprefspec);
            expreffid=ifft(flipud(fftshift(exprefspec,1)),NmrData.fn);
            expreffid=expreffid(1:NmrData.fn/2);
            
            % Create a perfect reference peak
            omega= 0.5*NmrData.sw.*NmrData.sfrq-(NmrData.RDcentre-NmrData.sp).*NmrData.sfrq;
            
            peak_height=1;
            delta=NmrData.RDleft-NmrData.RDright;
            switch NmrData.shiftunits
                case 'ppm';
                    delta=delta*NmrData.sfrq;
                case 'Hz'
                    %correct delta
                otherwise
                    error('illegal choice')
            end
            
            
            
            %add sattelites if appropriate
            switch  get(hBGroupPeak,'SelectedObject')
                %The decaplets at +/- 59 Hz coudl be used with J of 3.1 Hz.
                %I'll code that in later
                case hRadio1Peak1 %normal singlet
                    
                    if delta>120 %include satellites
                        omega(2)=omega(1)+59.25-0.00155*NmrData.sfrq;
                        omega(3)=omega(1)-59.25-0.00155*NmrData.sfrq;
                        peak_height(2)=0.00555;
                        peak_height(3)=0.00555;
                    else
                        %do nothing
                    end
                case hRadio2Peak2 %TSP
                    if delta>120 %include satellites
                        omega(2)=omega(1)+59.25-0.00155*NmrData.sfrq;
                        omega(3)=omega(1)-59.25-0.00155*NmrData.sfrq;
                        peak_height(2)=0.00555;
                        peak_height(3)=0.00555;
                    end
                    omega(4)=omega(1)+3.31-0.00013*NmrData.sfrq;
                    omega(5)=omega(1)-3.31-0.00013*NmrData.sfrq;
                    omega(6)=omega(1)+1.37-0.0002*NmrData.sfrq;
                    omega(7)=omega(1)-1.37-0.0002*NmrData.sfrq;
                    omega(8)=omega(1)+1.16-0.0002*NmrData.sfrq;
                    omega(9)=omega(1)-1.16-0.0002*NmrData.sfrq;
                    omega(10)=omega(1)+0.95-0.0002*NmrData.sfrq;
                    omega(11)=omega(1)-0.95-0.0002*NmrData.sfrq;
                    omega(12)=omega(1)+0.74-0.0002*NmrData.sfrq;
                    omega(13)=omega(1)-0.74-0.0002*NmrData.sfrq;
                    
                    peak_height(4)=0.0247;
                    peak_height(5)=0.0247;
                    peak_height(6)=0.0016*2/3;
                    peak_height(7)=0.0016*2/3;
                    peak_height(8)=0.0047*2/3;
                    peak_height(9)=0.0047*2/3;
                    peak_height(10)=0.0047*2/3;
                    peak_height(11)=0.0047*2/3;
                    peak_height(12)=0.0016*2/3;
                    peak_height(13)=0.0016*2/3;
                    
                    
                case hRadio2Peak3 %TMS
                    if delta>120 %include satellites
                        omega(2)=omega(1)+59.25-0.00155*NmrData.sfrq;
                        omega(3)=omega(1)-59.25-0.00155*NmrData.sfrq;
                        peak_height(2)=0.00555;
                        peak_height(3)=0.00555;
                    end
                    omega(4)=omega(1)+3.31-0.00013*NmrData.sfrq;
                    omega(5)=omega(1)-3.31-0.00013*NmrData.sfrq;
                    omega(6)=omega(1)+1.37-0.0002*NmrData.sfrq;
                    omega(7)=omega(1)-1.37-0.0002*NmrData.sfrq;
                    omega(8)=omega(1)+1.16-0.0002*NmrData.sfrq;
                    omega(9)=omega(1)-1.16-0.0002*NmrData.sfrq;
                    omega(10)=omega(1)+0.95-0.0002*NmrData.sfrq;
                    omega(11)=omega(1)-0.95-0.0002*NmrData.sfrq;
                    omega(12)=omega(1)+0.74-0.0002*NmrData.sfrq;
                    omega(13)=omega(1)-0.74-0.0002*NmrData.sfrq;
                    
                    peak_height(4)=0.0247;
                    peak_height(5)=0.0247;
                    peak_height(6)=0.0016;
                    peak_height(7)=0.0016;
                    peak_height(8)=0.0047;
                    peak_height(9)=0.0047;
                    peak_height(10)=0.0047;
                    peak_height(11)=0.0047;
                    peak_height(12)=0.0016;
                    peak_height(13)=0.0016;
                    
                otherwise
                    disp('unknown satellite shape - using pure singlet');
            end
            t=linspace(0,0.5*(NmrData.fn/NmrData.np)*NmrData.at,NmrData.fn/2);
            reffid=zeros(1,NmrData.fn/2);
            for n=1:length(omega)
                reffid=reffid+peak_height(n)*exp(1i*2*pi*omega(n)*t);
            end
            reffid=reffid.*exp(-t*pi*lb -(t/gw).^2);
            reffid=reffid(:);
            % Create the correction fid
            corrfid=expreffid./reffid;
            corrfid=corrfid/corrfid(1);
            endfid=wholefid./corrfid;
            endfid(1,:)=endfid(1,:)*NmrData.fpmult;
            SPECTRA(:,m)=endfid;
        end
        
        NmrData.SPECTRA=flipud((fftshift(fft(SPECTRA,NmrData.fn),1)));
        guidata(hMainFigure,NmrData);
        PlotSpectrum();
    end
    function RDshowCheck_Callback( eventdata, handles)
        NmrData=guidata(hMainFigure);
        if get(hRDshowCheck,'Value')
            line(NmrData.RDcentrexdata,NmrData.RDcentreydata,...
                'color','black','linewidth', 1.0,...
                'tag','RDcentre');
        else
            hRDcentre=findobj(hAxes,'tag','RDcentre');
            delete(hRDcentre)
            set(hAxes,'ButtonDownFcn','')
        end
        guidata(hMainFigure,NmrData);
    end
    function RDshowLRCheck_Callback( eventdata, handles)
        NmrData=guidata(hMainFigure);
        if get(hRDshowLRCheck,'Value')
            line(NmrData.RDleftxdata,NmrData.RDleftydata,...
                'color','red','linewidth', 1.0,...
                'tag','RDleft');
            line(NmrData.RDrightxdata,NmrData.RDrightydata,...
                'color','green','linewidth', 1.0,...
                'tag','RDright');
        else
            hRDright=findobj(hAxes,'tag','RDright');
            hRDleft=findobj(hAxes,'tag','RDleft');
            delete(hRDleft)
            delete(hRDright)
            set(hAxes,'ButtonDownFcn','')
        end
        guidata(hMainFigure,NmrData);
    end
    function RDButtonDelta_Callback( eventdata, handles)
        %get the delta the spectrum
        if NmrData.plottype==1
            NmrData.xlim_spec=xlim();
            NmrData.ylim_spec=ylim();
        end
        guidata(hMainFigure,NmrData);
        NmrData=guidata(hMainFigure);
        delta=NmrData.RDleft-NmrData.RDright;
        centre=NmrData.RDright+delta/2;
        switch NmrData.shiftunits
            case 'ppm'
               deltaorg=[delta NmrData.sfrq*delta];
               deltaorg=round(deltaorg*10000)/10000;
               delta=inputdlg({'set delta (ppm)','set delta (Hz)'},'Delta',1,{num2str(delta),num2str(NmrData.sfrq*delta)});
               delta=str2double(delta);
               delta=round(delta*10000)/10000;
            
                if deltaorg(1)~=delta(1) && deltaorg(2)~=delta(2)
                    warndlg('Only change the ppr OR Hz value')
                    uiwait(gcf)
                    delta=deltaorg(1);
                elseif deltaorg(1)~=delta(1)
                    delta=delta(1);
                elseif deltaorg(2)~=delta(2)
                    delta=delta(2)/NmrData.sfrq;
                else
                    delta=deltaorg(1);
                end
             
                               
            case 'Hz'
                deltaorg=[delta/NmrData.sfrq delta];
                deltaorg=round(deltaorg*10000)/10000;
                delta=inputdlg({'set delta (ppm)','set delta (Hz)'},'Delta',1,{num2str(delta/NmrData.sfrq),num2str(delta)});
                delta=str2double(delta);
               delta=round(delta*10000)/10000;
                if deltaorg(1)~=delta(1) && deltaorg(2)~=delta(2)
                    warndlg('Only change the ppr OR Hz value')
                    uiwait(gcf)
                    delta=deltaorg(2);
                elseif deltaorg(1)~=delta(1)
                    delta=delta(1)*NmrData.sfrq;
                elseif deltaorg(2)~=delta(2)
                    delta=delta(2);
                else
                    delta=deltaorg(1);
                end
                
                
            otherwise
                error('illegal choice')
        end
        
        
       % delta=str2double(delta);
        if isempty(delta) || isnan(delta)
            %do nothing
        else
            NmrData.RDleft=centre+delta/2;
            NmrData.RDright=centre-delta/2;
            NmrData.RDleftxdata=[NmrData.RDleft NmrData.RDleft];
            NmrData.RDrightxdata=[NmrData.RDright NmrData.RDright];
            NmrData.RDleftydata=get(hAxes,'ylim');
            NmrData.RDrightydata=get(hAxes,'ylim');
            guidata(hMainFigure,NmrData);
            PlotSpectrum();
        end
    end
% %---------End of Standard Processing
% Callbacks-----------------------------
%% ---------Advanced Processing Callbacks---------------------------
%Common features
    function ThresholdButton_Callback( eventdata, handles)
        zoom off
        pan off
        set(hMainFigure,'WindowButtonDownFcn','')
        button_state = get(hThresholdButton,'Value');
        if button_state == get(hThresholdButton,'Max')
            % Toggle button is pressed-take approperiate action
            set(hAxes,'ButtonDownFcn',@Threshold_function)
            %   set(hMainFigure,'WindowButtonDownFcn',@Threshold_function)
        elseif button_state == get(hThresholdButton,'Min')
            % Toggle button is not pressed-take appropriate action
            set(hAxes,'ButtonDownFcn','')
            hThresh=findobj(hAxes,'tag','threshold');
            delete(hThresh)
        end
        guidata(hMainFigure,NmrData);
    end
    function ReplotButton_Callback( eventdata, handles)
    end
    function ExcludeShow_Callback( eventdata, handles)
        zoom off
        pan off
        button_state = get(hExcludeShow,'Value');
        if button_state == 1
            Excludeline_function();
            
        elseif button_state == 0
            hExcludeline=findobj(hAxes,'tag','excludeline');
            delete(hExcludeline)
        end
        
    end
    function SetExcludeButton_Callback( eventdata, handles)
        zoom off
        pan off
        set(hMainFigure,'WindowButtonDownFcn','');
        guidata(hMainFigure,NmrData);
        set(hMainFigure,'WindowButtonDownFcn',@Excludeline_function);
        guidata(hMainFigure,NmrData);
        %get the delta the spectrum
        if NmrData.plottype==1
            NmrData.xlim_spec=xlim();
            NmrData.ylim_spec=ylim();
        end
        guidata(hMainFigure,NmrData);
        %set(hAxes,'ButtonDownFcn',@Excludeline_function)
        set(hExcludeShow,'Value',1)
        guidata(hMainFigure,NmrData);
        PlotSpectrum();
        %DrawExcludeline();
    end
    function ClearExcludeButton_Callback( eventdata, handles)
        zoom off
        pan off
        NmrData=guidata(hMainFigure);
        NmrData.ExcludePoints=[];
        NmrData.excludelinepoints=[];
        NmrData.exclude=ones(1,NmrData.fn);
        %set(hAxes,'ButtonDownFcn',@Excludeline_function)
        set(hMainFigure,'WindowButtonDownFcn',@Excludeline_function);
        hExcludeline=findobj(hAxes,'tag','excludeline');
        delete(hExcludeline);
        guidata(hMainFigure,NmrData);
        PlotSpectrum();
        %DrawExcludeline();
    end
    function ExportButton_Callback(source,eventdata)
        %Check if dosy data exist - othewise complain
        NmrData=guidata(hMainFigure);
        hExport=figure(...
            'NumberTitle','Off',...
            'MenuBar','none',...
            'Units','Normalized',...
            ...'DeleteFcn',@hSettings_DeleteFcn,...
            'Toolbar','none',...
            ...'ResizeFcn' , @hSettingsResizeFcn,...
            'Name','Export Data');
        hButtonPureshiftConvert=uicontrol(...
            'Parent',hExport,...
            'Style','PushButton',...
            'Units','Normalized',...
            'Visible','on',...
            'TooltipString','Export selected data formats',...
            'FontWeight','bold',...
            'Position',[0.725 0.075 0.2 0.1 ],...
            'String','Export',...
            'CallBack', {@Export_Data});
        
        hExportPanel=uipanel(...
            'Parent',hExport,...
            'Title','Select data',...
            'FontWeight','bold',...
            'TitlePosition','centertop',...
            'ForegroundColor','Blue',...
            'Units','Normalized',...
            'Position',[0. 0.3 1.0 0.65]);
        hCheckRawFID=uicontrol(...
            'Parent',hExportPanel,...
            'Style','checkbox',...
            'Units','Normalized',...
            'String','Raw FID data',...
            'Value',0,...
            'TooltipString','Export raw FID data',...
            'Position',[0.05 0.80 0.3 0.1 ],...
            'CallBack', {@CheckRawFID_Callback} );
        hCheckSpectra=uicontrol(...
            'Parent',hExportPanel,...
            'Style','checkbox',...
            'Units','Normalized',...
            'String','Processed spectra',...
            'Value',0,...
            'TooltipString','Export processed spectra',...
            'Position',[0.05 0.70 0.3 0.1 ],...
            'CallBack', {@CheckSpectra_Callback} );
        hCheckSCOREResiduals=uicontrol(...
            'Parent',hExportPanel,...
            'Style','checkbox',...
            'Units','Normalized',...
            'String','SCORE Residuals',...
            'Enable','Off',...
            'Value',0,...
            'TooltipString','Export SCORE residuals',...
            'Position',[0.55 0.60 0.2 0.1 ],...
            'CallBack', {@CheckSCOREResiduals_Callback} );
        hCheckDOSY=uicontrol(...
            'Parent',hExportPanel,...
            'Style','checkbox',...
            'Units','Normalized',...
            'String','DOSY plot',...
            'Value',0,...
            'Enable','Off',...
            'TooltipString','Export DOSY plot',...
            'Position',[0.55 0.80 0.3 0.1 ],...
            'CallBack', {@CheckDOSY_Callback} );
        hCheckSCOREComponents=uicontrol(...
            'Parent',hExportPanel,...
            'Style','checkbox',...
            'Units','Normalized',...
            'String','SCORE components',...
            'Value',0,...
            'Enable','Off',...
            'TooltipString','Export fitted SCORE components',...
            'Position',[0.55 0.70 0.3 0.1 ],...
            'CallBack', {@CheckSCOREComponents_Callback} );
        
        if ~isempty(NmrData.dosydata)
            set(hCheckDOSY,'Enable','On')
            set(hCheckDOSY,'Value',0)
        end
        if ~isempty(NmrData.scoredata)
            set(hCheckSCOREComponents,'Enable','On')
            set(hCheckSCOREComponents,'Value',0)
            set(hCheckSCOREResiduals,'Enable','On')
            set(hCheckSCOREResiduals,'Value',0)
        end
        
        function Export_Data(eventdata, handles)
            
            [filename, pathname] = uiputfile('*.*','Export selected data');
            if get(hCheckRawFID,'Value')
                filepath=[pathname filename '_RAW'];
                statfil=fopen(filepath, 'wt');
                ExportDOSYToolboxFormat(statfil, 1, 1, filename, pathname);
            end
            if get(hCheckSpectra,'Value')
                filepath=[pathname filename '_PROCESSED'];
                statfil=fopen(filepath, 'wt');
                ExportDOSYToolboxFormat(statfil, 2, 1, filename, pathname);
            end
            if get(hCheckSCOREResiduals,'Value')
                filepath=[pathname filename '_SCORE_RESIDUALS'];
                statfil=fopen(filepath, 'wt');
                ExportDOSYToolboxFormat(statfil, 5, 1, filename, pathname);
            end
            if get(hCheckSCOREComponents,'Value')
                filepath=[pathname filename '_SCORE_COMPONENTS'];
                statfil=fopen(filepath, 'wt');
                ExportDOSYToolboxFormat(statfil, 6, 1, filename, pathname);
            end
            if get(hCheckDOSY,'Value')
                filepath=[pathname filename '_DOSY'];
                statfil=fopen(filepath, 'wt');
                ExportDOSYToolboxFormat(statfil, 4, 1, filename, pathname);
            end
            
            
        end
        function CheckRawFID_Callback(eventdata, handles)
        end
        function CheckSpectra_Callback(eventdata, handles)
        end
        function CheckSCOREResiduals_Callback(eventdata, handles)
        end
        function CheckDOSY_Callback(eventdata, handles)
        end
        function CheckSCOREComponents_Callback(eventdata, handles)
        end
    end
%---DOSY---
    function EditMultexp_Callback(eventdata, handles)
        
        %add some safety here
    end
    function EditTries_Callback(eventdata, handles)
        %add some safety here
    end
    function CheckDmax_Callback(eventdata, handles)
        if get(hCheckDmax,'Value')
            set(hEditDmax,'Enable','Off')
        else
            set(hEditDmax,'Enable','On')
        end 
    end
    function FitType_Callback(eventdata, handles)      
     if get(hBGroupDOSYOpt3,'SelectedObject')==hRadio1DOSYOpt3
         %monoexponetial fit
         set(hEditMultexp,'Enable','Off')
         set(hEditMultexp,'string',num2str(1))
         set(hEditTries,'Enable','Off')
         set(hEditTries,'string',num2str(100))         
     else
         %multiexponential
         set(hEditMultexp,'Enable','On')
         set(hEditTries,'Enable','On')
     end         
    end
    function EditDmax_Callback(eventdata, handles)
        %add some safety here
    end
    function EditDmin_Callback(eventdata, handles)
        %add some safety here
    end
    function EditDres_Callback(eventdata, handles)
        %add some safety here
    end
    function EditNcomp_Callback(eventdata, handles)
        %add some safety here
    end
    function EditNgrad_Callback(eventdata, handles)
        NmrData=guidata(hMainFigure);
        NmrData.prune=...
            round(str2num(get(hEditNgrad,'string')));
        guidata(hMainFigure,NmrData);
    end
    function EditArray2_Callback(eventdata, handles)
        NmrData=guidata(hMainFigure);
        NmrData.pruneArray2=...
            round(str2num(get(hEditArray2,'string')));
        guidata(hMainFigure,NmrData);
    end
    function NgradUse_Callback(eventdata, handles)
        %add some safety here
    end
    function DOSYButton_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        APVisibleOff();
        set(hDOSYButton,'ForegroundColor',[1 0 1])
        set(hDOSYButton,'Fontweight','bold')
        set(hProcessButton,'Visible','On')
        set(hReplotButton,'Visible','On')
        set(hExportButton,'Visible','On')
        %set(hEditNcomp,'Visible','On')
        %set(hTextNcomp,'Visible','On')
        set(hBGroupDOSYOpt1,'Visible','On')
        set(hBGroupDOSYOpt2,'Visible','On')
        set(hBGroupDOSYOpt3,'Visible','On')
        set(hBMultiexpPanel,'Visible','On')
        set(hBPlotPanel,'Visible','On')
        if get(hCheckDmax,'Value')
            set(hEditDmax,'Enable','Off')
        else
            set(hEditDmax,'Enable','On')
        end        
        set(hThresholdButton,'Visible','On')
        set(hTextProcess,'Visible','On')
        set(hTextExclude,'Visible','On')
        set(hExcludeShow,'Visible','On')
        set(hClearExcludeButton,'Visible','On')
        set(hSetExcludeButton,'Visible','On')
        set(hEditNgrad,'Visible','On')
        set(hTextNgrad,'Visible','On')
        set(hNgradUse,'Visible','On')
        NmrData.pfgnmrdata=PreparePfgnmrdata();
        set(hProcessButton,'Callback',@dodosy)
        set(hReplotButton,'Callback',@plotdosy)
        %set(hExportButton,'Callback',@ExportDOSYplot)
        guidata(hMainFigure,NmrData);
    end
    function dodosy(source,eventdata)
        NmrData=guidata(hMainFigure);
        NmrData.pfgnmrdata=PreparePfgnmrdata();
        switch get(hBGroupDOSYOpt1,'SelectedObject')
            case hRadio1DOSYOpt1
                NmrData.DOSYopts(1)=0;
            case hRadio2DOSYOpt1
                NmrData.DOSYopts(1)=1;
            otherwise
                error('illegal choice')
        end
        switch get(hBGroupDOSYOpt2,'SelectedObject')
            case hRadio1DOSYOpt2
                NmrData.DOSYopts(2)=0;
            case hRadio2DOSYOpt2
                NmrData.DOSYopts(2)=1;
            otherwise
                error('illegal choice')
        end
        NmrData.DOSYopts(3)=str2double(get(hEditMultexp,'String'));
        NmrData.DOSYopts(4)=str2double(get(hEditTries,'String'));
        NmrData.DOSYopts(5)=NmrData.FitType;
        NmrData.DOSYdiffrange(1)=str2double(get(hEditDmin,'String'));
        if get(hCheckDmax,'Value')
            
            NmrData.DOSYdiffrange(2)=0;
        else
            NmrData.DOSYdiffrange(2)=str2double(get(hEditDmax,'String'));
        end
        
                
        NmrData.DOSYdiffrange(3)=str2double(get(hEditDres,'String'));
        speclim=xlim();
        if speclim(1)<NmrData.sp
            speclim(1)=NmrData.sp;
        end
        if speclim(2)>(NmrData.sw+NmrData.sp)
            speclim(2)=(NmrData.sw+NmrData.sp);
        end
        
        %         if NmrData.th<=0
        %             NmrData.th=10;
        %         end
        NmrData.pfgnmrdata.flipnr=NmrData.flipnr; % For running DOSY in 3D datasets
        NmrData.dosydata=dosy_mn(NmrData.pfgnmrdata,NmrData.th,speclim,NmrData.DOSYdiffrange,NmrData.DOSYopts,NmrData.nug);
        
        %print out statistics to file
        DTpath=which('DOSYToolbox');
        DTpath=DTpath(1:(end-13));
        statfil=fopen([DTpath 'dosystats.txt'], 'wt');
        fprintf(statfil,'%-s  \n','Fitting statistics for a 2D DOSY experiment');
        if NmrData.dosydata.Options(2)==0
            fprintf(statfil,'%-s  \n','Pure exponential fitting (Stejskal-Tanner equation)');
        elseif NmrData.dosydata.Options(2)==1
            fprintf(statfil,'\n');
            fprintf(statfil,'%-s  \n','Fitting using compensation for non-uniform field gradients (NUG). ');
        else
            fprintf(statfil,'%-s  \n','Unknown function');
        end
        
        if NmrData.dosydata.Options(3)==1
            fprintf(statfil,'%-s  \n','Monoexpoential fitting');
        elseif NmrData.dosydata.Options(3)>1
            fprintf(statfil,'%-s  \n','Multiexpoential fitting');
            fprintf(statfil,'%-s %i \n','Max number of component per peak: ',NmrData.dosydata.Options(3));
        else
            fprintf(statfil,'%-s  \n','error in the number of exponentials (Options(3) in dosy_mn.m)');
        end
        fitsize=size(NmrData.dosydata.FITSTATS);
        fprintf(statfil,'\n');
        fprintf(statfil,'\n%s%s%s \n','*******Fit Summary*******');
        fprintf(statfil,'\n');        
        fprintf(statfil,'%-10s  ','Frequency');        
        for m=1:fitsize(2)/4
            % fprintf(statfil,'%-9s%-1.1i  %-10s  %-9s%-1.1i  %-10s  ','Amplitude',m,'error','Diff coef',m,'error');
            if m==1
            fprintf(statfil,'%-10s  %-9s%-1.1i  %-10s  %-9s%-1.1i  %-10s  ','Exp. Ampl','Fit. Ampl',m,'error','Diff coef',m,'error');
            else
                fprintf(statfil,'%-9s%-1.1i  %-10s  %-9s%-1.1i  %-10s  ','Fit. Ampl',m,'error','Diff coef',m,'error');
            end
        end
        fprintf(statfil,'\n');
        for k=1:fitsize(1)
            fprintf(statfil,'%-10.5f  ',NmrData.dosydata.freqs(k));
            fprintf(statfil,'%-10.5f  ',NmrData.dosydata.ORIGINAL(k,1));
            for m=1:fitsize(2)
                fprintf(statfil,'%-10.5f  ',NmrData.dosydata.FITSTATS(k,m));
            end
            fprintf(statfil,'\n');
        end        
        fprintf(statfil,'\n%s%s%s \n','Gradient amplitudes [', num2str(numel(NmrData.dosydata.Gzlvl)), ']  (T m^-2)');
        for g=1:numel(NmrData.dosydata.Gzlvl)
            fprintf(statfil,'%-10.5e  \n',NmrData.dosydata.Gzlvl(g));
        end
        fprintf(statfil,'\n%s%s%s \n','*******Residuals*******');
        fprintf(statfil,'\n');    
        for k=1:fitsize(1)
            fprintf(statfil,'%-10s %-10.0f %-10s %-10.5f \n','Peak Nr: ', k, 'Frequency (ppm): ',NmrData.dosydata.freqs(k));
            fprintf(statfil,'%-10s   %-10s   %-10s  \n','Exp. Ampl','Fit. Ampl','Diff');
            for m=1:numel(NmrData.dosydata.Gzlvl)
                fprintf(statfil,'%-10.5e  %-10.5e  %-10.5e  \n',NmrData.dosydata.ORIGINAL(k,m),NmrData.dosydata.FITTED(k,m),NmrData.dosydata.RESIDUAL(k,m));
            end
            fprintf(statfil,'\n');
        end        
        fprintf(statfil,'\n%s%s%s \n','*******Fit Summary*******');
        fprintf(statfil,'\n');        
        fprintf(statfil,'%-10s  ','Frequency');        
        for m=1:fitsize(2)/4
            if m==1
            fprintf(statfil,'%-10s  %-9s%-1.1i  %-10s  %-9s%-1.1i  %-10s  ','Exp. Ampl','Fit. Ampl',m,'error','Diff coef',m,'error');
            else
                fprintf(statfil,'%-9s%-1.1i  %-10s  %-9s%-1.1i  %-10s  ','Fit. Ampl',m,'error','Diff coef',m,'error');
            end
        end
        fprintf(statfil,'\n');
        for k=1:fitsize(1)
            fprintf(statfil,'%-10.5f  ',NmrData.dosydata.freqs(k));
            fprintf(statfil,'%-10.5f  ',NmrData.dosydata.ORIGINAL(k,1));
            for m=1:fitsize(2)
                fprintf(statfil,'%-10.5f  ',NmrData.dosydata.FITSTATS(k,m));
            end
            fprintf(statfil,'\n');
        end     
        fprintf(statfil,'\n%s\n%s\n','This information can be found in:',[DTpath 'dosystats.txt']);
        fclose(statfil);
        type([DTpath 'dosystats.txt']);
        guidata(hMainFigure,NmrData);
    end
    function plotdosy(source,eventdata)
        dosyplot_gui(NmrData.dosydata);
    end
%----DECRA-------
    function DECRAButton_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        APVisibleOff();
        set(hDECRAButton,'ForegroundColor',[1 0 1])
        set(hDECRAButton,'Fontweight','bold')
        set(hProcessButton,'Visible','On')
        set(hReplotButton,'Visible','On')
        set(hEditNcomp,'Visible','On')
        set(hTextNcomp,'Visible','On')
        set(hTextProcess,'Visible','On')
        set(hTextExclude,'Visible','On')
        set(hExcludeShow,'Visible','On')
        set(hClearExcludeButton,'Visible','On')
        set(hSetExcludeButton,'Visible','On')
        set(hEditNgrad,'Visible','On')
        set(hTextNgrad,'Visible','On')
        set(hNgradUse,'Visible','On')
        NmrData.pfgnmrdata=PreparePfgnmrdata();
        set(hProcessButton,'Callback',@dodecra)
        set(hReplotButton,'Callback',@plotdecra)
        guidata(hMainFigure,NmrData);
    end
    function dodecra(source,eventdata)
        
        NmrData=guidata(hMainFigure);
        NmrData.pfgnmrdata=PreparePfgnmrdata();
        NmrData.ncomp=str2double(get(hEditNcomp,'String'));
        speclim=xlim();
        if speclim(1)<NmrData.sp
            speclim(1)=NmrData.sp;
        end
        if speclim(2)>(NmrData.sw+NmrData.sp)
            speclim(2)=(NmrData.sw+NmrData.sp);
        end
        NmrData.decradata=decra_mn(NmrData.pfgnmrdata,NmrData.ncomp,speclim);
        guidata(hMainFigure,NmrData);
    end
    function plotdecra(source,eventdata)
        NmrData=guidata(hMainFigure);
        decraplot(NmrData.decradata);
    end
%---MCR---
    function MCRButton_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        APVisibleOff();
        set(hMCRButton,'ForegroundColor',[1 0 1])
        set(hMCRButton,'Fontweight','bold')
        set(hProcessButton,'Visible','On')
        set(hReplotButton,'Visible','On')
        set(hEditNcomp,'Visible','On')
        set(hTextNcomp,'Visible','On')
        set(hBGroupMCROpt1,'Visible','On')
        set(hBGroupMCROpt2,'Visible','On')
        set(hBGroupMCROpt3,'Visible','On')
        set(hBGroupMCROpt4,'Visible','On')
        set(hBGroupMCROpt5,'Visible','On')
        set(hTextProcess,'Visible','On')
        set(hTextExclude,'Visible','On')
        set(hExcludeShow,'Visible','On')
        set(hClearExcludeButton,'Visible','On')
        set(hSetExcludeButton,'Visible','On')
        set(hEditNgrad,'Visible','On')
        set(hTextNgrad,'Visible','On')
        set(hNgradUse,'Visible','On')
        NmrData.pfgnmrdata=PreparePfgnmrdata();
        set(hProcessButton,'Callback',@domcr)
        set(hReplotButton,'Callback',@plotmcr)
        guidata(hMainFigure,NmrData);
    end
    function domcr(source,eventdata)
        NmrData=guidata(hMainFigure);
        NmrData.pfgnmrdata=PreparePfgnmrdata();
        switch get(hBGroupMCROpt1,'SelectedObject')
            case hRadio1MCROpt1
                NmrData.MCRopts(1)=0;
            case hRadio2MCROpt1
                NmrData.MCRopts(1)=1;
            otherwise
                error('illegal choice')
        end
        switch get(hBGroupMCROpt2,'SelectedObject')
            case hRadio1MCROpt2
                NmrData.MCRopts(2)=0;
            case hRadio2MCROpt2
                NmrData.MCRopts(2)=1;
            otherwise
                error('illegal choice')
        end
        switch get(hBGroupMCROpt3,'SelectedObject')
            case hRadio1MCROpt3
                NmrData.MCRopts(3)=0;
            case hRadio2MCROpt3
                NmrData.MCRopts(3)=1;
            case hRadio3MCROpt3
                NmrData.MCRopts(3)=2;
            otherwise
                error('illegal choice')
        end
        switch get(hBGroupMCROpt4,'SelectedObject')
            case hRadio1MCROpt4
                NmrData.MCRopts(4)=0;
            case hRadio2MCROpt4
                NmrData.MCRopts(4)=1;
            case hRadio3MCROpt4
                NmrData.MCRopts(4)=2;
            otherwise
                error('illegal choice')
        end
        switch get(hBGroupMCROpt5,'SelectedObject')
            case hRadio1MCROpt5
                NmrData.MCRopts(5)=0;
            case hRadio2MCROpt5
                NmrData.MCRopts(5)=1;
            case hRadio3MCROpt5
                NmrData.MCRopts(5)=2;
            otherwise
                error('illegal choice')
        end
        speclim=xlim();
        if speclim(1)<NmrData.sp
            speclim(1)=NmrData.sp;
        end
        if speclim(2)>(NmrData.sw+NmrData.sp)
            speclim(2)=(NmrData.sw+NmrData.sp);
        end
        NmrData.ncomp=str2double(get(hEditNcomp,'String'));
        NmrData.mcrdata=mcr_mn(NmrData.pfgnmrdata,NmrData.ncomp,speclim,NmrData.MCRopts,NmrData.nug);
        guidata(hMainFigure,NmrData);
    end
    function plotmcr(source,eventdata)
        NmrData=guidata(hMainFigure);
        mcrplot(NmrData.mcrdata);
    end
%----SCORE----
    function SCOREButton_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        APVisibleOff();
        set(hExportButton,'Visible','On')
        set(hSCOREButton,'ForegroundColor',[1 0 1])
        set(hSCOREButton,'Fontweight','Bold')
        set(hProcessButton,'Visible','On')
        set(hReplotButton,'Visible','On')
        set(hPubplotButton,'Visible','On')
        set(hEditNcomp,'Visible','On')
        set(hTextNcomp,'Visible','On')
        set(hBGroupSCOREOpt1,'Visible','On')
          set(hRadio1SCOREOpt1,'String','Exp')
        set(hRadio2SCOREOpt1,'String','NUG')
        set(hBGroupSCOREOpt2,'Visible','On')
        set(hBGroupSCOREOpt2,'Title','D guess')
        set(hBGroupSCOREOpt3,'Visible','On')
        set(hTextProcess,'Visible','On')
        set(hTextExclude,'Visible','On')
        set(hExcludeShow,'Visible','On')
        set(hClearExcludeButton,'Visible','On')
        set(hSetExcludeButton,'Visible','On')
        set(hEditNgrad,'Visible','On')
        set(hTextNgrad,'Visible','On')
        set(hNgradUse,'Visible','On')
        set(hTableFixPeaks,'Visible','Off')  %AC
        set(hBigplotButton,'Visible','On')  %AC
        set(hTextnfix,'Visible','Off')  %AC
        set(hEditnfix,'Visible','Off')  %AC
        set(hUseSynthDsButton,'Visible','Off')  %AC
        set(hTextXtalk,'Visible','Off') %AC
        set(hXtalkShow,'Visible','Off') %AC
        set(hBGroupSCOREOpt6,'Visible','On') %AC
        NmrData.pfgnmrdata=PreparePfgnmrdata();
        set(hProcessButton,'Callback',@doscore)
        set(hReplotButton,'Callback',@plotscore)
        set(hPubplotButton,'Callback',@pubplotscore)
        guidata(hMainFigure,NmrData);
    end
    function doscore(source,eventdata)
        NmrData=guidata(hMainFigure);
        NmrData.pfgnmrdata=PreparePfgnmrdata();
        NmrData.SCOREopts=[0 0 0 0 0 0];
        switch get(hBGroupSCOREOpt1,'SelectedObject')
            case hRadio1SCOREOpt1
                NmrData.SCOREopts(3)=0;
            case hRadio2SCOREOpt1
                NmrData.SCOREopts(3)=1;
            otherwise
                error('illegal choice')
        end
        switch get(hBGroupSCOREOpt2,'SelectedObject')
            case hRadio1SCOREOpt2
                NmrData.SCOREopts(1)=0;
            case hRadio2SCOREOpt2
                NmrData.SCOREopts(1)=1;
                %             case hRadio3COREOpt2
                %                 NmrData.COREopts(1)=2;
            otherwise
                error('illegal choice')
        end
        switch get(hBGroupSCOREOpt3,'SelectedObject')
            case hRadio1SCOREOpt3
                NmrData.SCOREopts(2)=0;
            case hRadio2SCOREOpt3
                NmrData.SCOREopts(2)=1;
                %             case hRadio3SCOREOpt3
                %                 NmrData.SCOREopts(2)=2;
            case hRadio4SCOREOpt3
                NmrData.SCOREopts(2)=3;    
            otherwise
                error('illegal choice')
        end
        switch get(hBGroupSCOREOpt6,'SelectedObject')
            case hRadio1SCOREOpt6
                NmrData.SCOREopts(6)=0;
            case hRadio2SCOREOpt6
                NmrData.SCOREopts(6)=1;
            otherwise
                error('illegal choice')
        end
        switch get(hXtalkShow,'value')
            case 0
                NmrData.SCOREopts(4)=1;
            case 1
                NmrData.SCOREopts(4)=2;
        end       
        
        speclim=xlim();
        if speclim(1)<NmrData.sp
            speclim(1)=NmrData.sp;
        end
        if speclim(2)>(NmrData.sw+NmrData.sp)
            speclim(2)=(NmrData.sw+NmrData.sp);
        end
        speclim(3)=str2double(get(hEditDmax,'string'));
        NmrData.ncomp=str2double(get(hEditNcomp,'String'));
        
        % AC
        FixedTableData=get(hTableFixPeaks,'Data');
        nfix=0;
        num0s=0;
        for c=1:10
            if FixedTableData{c,2}==true
               nfix=nfix+1;
               fixed(nfix)=FixedTableData{c,1}; %#ok<AGROW>
            else
               num0s=num0s+1;
            end
        end
        if num0s==10
            fixed=[];
        end
        set(hEditnfix,'string',num2str(nfix))
        
        % AC
        NmrData.scoredata=score_mn(NmrData.pfgnmrdata,NmrData.ncomp,speclim,NmrData.SCOREopts,NmrData.nug,fixed);
        

        guidata(hMainFigure,NmrData);
    end
    function plotscore(source,eventdata)
        NmrData=guidata(hMainFigure);
        scoreplot(NmrData.scoredata);
    end
    function pubplotscore(source,eventdata)
        NmrData=guidata(hMainFigure);
        scoreplotpub(NmrData.scoredata);
    end
    function BigplotButton_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        [rows , ~]=size(NmrData.scoredata.COMPONENTS);
        for k=1:rows
            figure('units','normalized','position',[0.05 0.5 0.9 0.4]);
            h=plot(NmrData.scoredata.Ppmscale,NmrData.scoredata.COMPONENTS(k,:),'LineWidth',1);
            set(gca,'Xdir','reverse');
            axis('tight')
            max1=max(NmrData.scoredata.COMPONENTS(k,:));
            ymax=max1*1.2;
            ymin=0-(max1*0.2);
            ylim([ymin ymax]);
            title('\fontname{ariel} \bf SCORE Component')
            xlabel('\fontname{ariel} \bf Chemical shift (PPM)');
        end
    end
    function UseSynthDsButton_Callback(source,eventdata)
            NmrData=guidata(hMainFigure);
            SynthTableData=get(hTableSynthPeaks,'Data');
            SynthFixDs=SynthTableData(:,2);
            npeaks=str2num(get(hEditnpeaks,'string'));
            FixedSCORE=cell(npeaks,2);
            for k=1:length(SynthFixDs)
                FixedSCORE{k,1}=SynthFixDs(k);
                FixedSCORE{k,2}=true;
            end
            for j=length(SynthFixDs)+1:10
                FixedSCORE{j,1}=0;
                FixedSCORE{j,2}=false; 
            end
            
            set(hTableFixPeaks,'Data',FixedSCORE)    
    end
%----locodosy----
    function LRDOSYButton_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        APVisibleOff();
        set(hLRDOSYButton,'ForegroundColor',[1 0 1])
        set(hLRDOSYButton,'Fontweight','Bold')
        set(hProcessButton,'Visible','On')
        set(hReplotButton,'Visible','On')
        set(hBGrouplocodosyOpt1,'Visible','On')
        set(hTextProcess,'Visible','On')
        set(hEditNgrad,'Visible','On')
        set(hTextNgrad,'Visible','On')
        set(hNgradUse,'Visible','On')
        set(hTextSelect,'Visible','On')
        set(hLRInclude,'Visible','On')
        set(hLRClear,'Visible','On')
        set(hTextSelect,'Visible','On')
        set(hTextsderrmultiplier,'Visible','On')
        set(hEditsderrmultiplier,'Visible','On')
        set(hLRViewComponent,'Visible','On')
        set(hDoSVDButton,'Visible','On')
        set(hTextDlimit,'Visible','On')
        set(hEditDlimit,'Visible','On')
        set(hTextVlimit,'Visible','On')
        set(hEditVlimit,'Visible','On')
        set(hTextSVDcutoff,'Visible','On')
        set(hEditSVDcutoff,'Visible','On')
        set(hBGrouplocodosyalg,'Visible','On')
        set(hRadio1locodosyalg,'Visible','On')
        set(hRadio2locodosyalg,'Visible','On')
        set(hLRWindowsShow,'Visible','On')
        set(hRegionsTable,'Visible','On')
        set(hRegionsTable,'Data',NmrData.LRRegionData)
        set(hProcessButton,'Callback',@LRRun_Callback)
        set(hReplotButton,'Callback',@plotlocodosy)
        set(hAutoInclude,'Visible','On')
        set(hThresholdButton,'Visible','On')
        set(hTextmethodplots,'Visible','On')
        set(hLRmethodplots,'Visible','On')
        set(hSVDplotsShow,'Visible','On')
        set(hBGroupRunType,'Visible','On')
        set(hTextDiffRes,'Visible','On')
        set(hEditDiffRes,'Visible','On')
        set(hExcludeShow,'Value',0)
        set(hUseClustering,'Visible','On')
        set(hTextUseClustering,'Visible','On')
        setappdata(0,'NmrData',NmrData)
    end
    function LRInclude_Callback( eventdata, handles)
        zoom off
        pan off
        set(hLRWindowsShow,'Value',1)
        set(hMainFigure,'WindowButtonDownFcn','')
        set(hAxes,'ButtonDownFcn',@Includeline_function);
        DrawIncludeline();
    end
    function LRClear_Callback( eventdata, handles)
        zoom off
        pan off
        NmrData=guidata(hMainFigure);
        NmrData.includelinepoints=[];
        NmrData.IncludePoints=[];
        for k=1:NmrData.fn
            NmrData.include(k)=NaN;
        end
        set(hMainFigure,'WindowButtonDownFcn','')
        set(hAxes,'ButtonDownFcn',@Includeline_function)
        hIncludeline=findobj(hAxes,'tag','includeline');
        delete(hIncludeline);
        hPeakclustline=findobj(hAxes,'tag','peakclustline');
        delete(hPeakclustline);
        NmrData.startORend=0;
        NmrData.numcomp=[];
        NmrData.winstart=[];
        NmrData.winend=[];
        NmrData.nwin=[];
        NmrData.LRRegionData=ones(length(NmrData.winstart));
        set(hRegionsTable,'Data', NmrData.LRRegionData)
        guidata(hMainFigure,NmrData);
    end
    function LRViewComponent_Callback(eventdata,handles)
        if isempty(NmrData.locodosydata)
            errordlg('No LOCODOSY components available')
        else
            %ask the user which component spectrum they want to see and plots it in
            %a separate window.
            calcRMSnoise()
            componentcell=inputdlg('View Component Spectrum','Component:',1,{'1'});
            component=str2num(componentcell{1}); %#ok<*ST2NM>
            figure('units','normalized','position',[0.05 0.5 0.9 0.4]);
            axes=subplot('position',[0.05 0.1 0.9 0.83]);
            h=plot(NmrData.locodosydata.Ppmscale,NmrData.locodosydata.cc1dspectra...
                (component,:),'LineWidth',1);
            set(gca,'Xdir','reverse');
            axis('tight')
            ylim('auto');
            title('\fontname{ariel} \bf locodosy Component')
            xlabel('\fontname{ariel} \bf Chemical shift (PPM)');
            zeroline=0*NmrData.locodosydata.zerolines(component+1,:);
            hCompZeroline=line(NmrData.locodosydata.Ppmscale,zeroline,...
                'color','r','linewidth', 2.0,...
                'tag','zeroline');
        end
    end
    function LRDoSVDButton_Callback( eventdata,handles)
        if isempty(NmrData.winstart)
            errordlg('Please select some windows to do SVD on.')
        else
            NmrData=guidata(hMainFigure);
            GetSVDcutoff()
            NmrData.pfgnmrdata=PreparePfgnmrdata();
            switch get(hSVDplotsShow,'Value');
                case 1
                    SVDoptions=1;
                case 0
                    SVDoptions=0;
            end
            NmrData.numcomp=locodosySVD(NmrData.pfgnmrdata,NmrData.winstart,NmrData.winend,...
                NmrData.nwin,NmrData.fn,SVDoptions,NmrData.SVDcutoff);
            for k=1:length(NmrData.numcomp)
                if NmrData.numcomp(k)>3
                    NmrData.numcomp(k)=3;
                end
            end
            NmrData.LRRegionData=NmrData.numcomp';
            set(hRegionsTable,'Data', NmrData.LRRegionData)
            guidata(hMainFigure,NmrData);
            
        end
    end
    function LRAutorun( eventdata, handles)
        if isempty(NmrData.winstart)
            errordlg('Please select some windows to do LOCODOSY on')
        else
            NmrData=guidata(hMainFigure);
            NmrData.pfgnmrdata=PreparePfgnmrdata();
            SVDoptions=0;
            NmrData.numcomp=locodosySVD(NmrData.pfgnmrdata,NmrData.winstart,NmrData.winend,...
                NmrData.nwin,NmrData.fn,SVDoptions,NmrData.SVDcutoff);
            for k=1:length(NmrData.numcomp)
                if NmrData.numcomp(k)>3
                    NmrData.numcomp(k)=3;
                end
            end
            NmrData.LRRegionData=NmrData.numcomp';
            set(hRegionsTable,'Data', NmrData.LRRegionData)
            NmrData.locodosyopts(4)=1;
            guidata(hMainFigure,NmrData);
            GetDlimit()
            Getminpercent()
            dolocodosy()
            NmrData.locodosyopts(4)=0;
            guidata(hMainFigure,NmrData);
        end
    end
    function LRRun_Callback( eventdata, handles)
        switch get(hBGroupRunType,'selectedobject')
            case hRadio1RunType
                % Process with current parameters
                NmrData.locodosyopts(5)=0;
                guidata(hMainFigure,NmrData);
                dolocodosy();
            case hRadio2RunType
                % Auto SVD, Reduce and Process
                NmrData.locodosyopts(5)=1;
                guidata(hMainFigure,NmrData);
                LRAutorun()
        end
    end
    function LRRegionsTable_Callback( eventdata, handles)
        NmrData.LRRegionData=get(hRegionsTable,'Data');
        NmrData.numcomp=NmrData.LRRegionData';
        guidata(hMainFigure,NmrData);
    end
    function LRAlgorithmChange_Callback( eventdata, handles)
        switch get(hBGrouplocodosyalg,'SelectedObject')
            case hRadio1locodosyalg
                set(hRadio2locodosyOpt1,'Enable','On')
                set(hRadio2RunType,'Enable','On')
            case hRadio2locodosyalg
                set(hRadio2RunType,'Enable','On')
                set(hBGrouplocodosyOpt1, 'SelectedObject',hRadio1locodosyOpt1)
                set(hRadio2locodosyOpt1,'Enable','Off')
            case hRadio3locodosyalg
                set(hRadio2locodosyOpt1,'Enable','On')
                set(hBGroupRunType, 'SelectedObject',hRadio1RunType)
                set(hRadio2RunType,'Enable','Off')
        end
    end
    function LRWindowsShow_Callback( eventdata, handles)
        zoom off
        pan off
        button_state = get(hLRWindowsShow,'Value');
        if button_state == 1
            hPeakclustline=findobj(hAxes,'tag','peakclustline');
            set(hPeakclustline,'Visible','On')
            hIncludeline=findobj(hAxes,'tag','includeline');
            set(hIncludeline,'Visible','On')
        elseif button_state == 0
            hPeakclustline=findobj(hAxes,'tag','peakclustline');
            set(hPeakclustline,'Visible','Off')
            hIncludeline=findobj(hAxes,'tag','includeline');
            set(hIncludeline,'Visible','Off')
        end
        %PlotSpectrum();
    end
    function Getsderrmultiplier(source,eventdata)
        NmrData=guidata(hMainFigure);
        %retrieves the diffusion value error margin from the toolbox gui.
        NmrData.sderrmultiplier=...
            str2num(get(hEditsderrmultiplier,'string'));
        guidata(hMainFigure,NmrData);
    end
    function GetSVDcutoff(source,eventdata)
        NmrData=guidata(hMainFigure);
        %retrieves the diffusion value error margin from the toolbox gui.
        NmrData.SVDcutoff=...
            str2num(get(hEditSVDcutoff,'string'));
        guidata(hMainFigure,NmrData);
    end
    function GetDlimit(source,eventdata)
        NmrData=guidata(hMainFigure);
        % retrieves the upper limit on diffusion coefficient for judging wether a
        % component is to be discarded or not.
        NmrData.Dlimit=...
            str2num(get(hEditDlimit,'string'));
        guidata(hMainFigure,NmrData);
    end
    function Getminpercent(source,eventdata)
        NmrData=guidata(hMainFigure);
        % retrieves the upper limit on diffusion coefficient for judging wether a
        % component is to be discarded or not.
        NmrData.minpercent=...
            str2num(get(hEditVlimit,'string'));
        guidata(hMainFigure,NmrData);
    end
    function GetDiffRes(source,eventdata)
        NmrData=guidata(hMainFigure);
        % retrieves the upper limit on diffusion coefficient for judging wether a
        % component is to be discarded or not.
        NmrData.DiffRes=...
            str2num(get(hEditDiffRes,'string'));
        guidata(hMainFigure,NmrData);
    end
    function dolocodosy(source,eventdata)
        
        % retrieve diffusion error margin before loading NmrData structure so as to
        % prevent problems with overwriting.
        Getsderrmultiplier()
        GetDlimit()
        Getminpercent()
        GetDiffRes()
        NmrData=guidata(hMainFigure);
        NmrData.pfgnmrdata=PreparePfgnmrdata();
        if isempty(NmrData.nwin)
            errordlg('The spectrum needs segmenting')
        else
            % see if NUG are being used
            switch get(hBGrouplocodosyOpt1,'SelectedObject')
                case hRadio1locodosyOpt1
                    NmrData.locodosyopts(1)=0;
                case hRadio2locodosyOpt1
                    NmrData.locodosyopts(1)=1;
                otherwise
                    error('illegal choice')
            end
            % DECRA / SCORE / PARAFAC
            switch get(hBGrouplocodosyalg,'SelectedObject')
                case hRadio1locodosyalg
                    NmrData.locodosyopts(3)=0;
                    guidata(hMainFigure,NmrData);
                    NmrData.pfgnmrdata=PreparePfgnmrdata(); %AC
                case hRadio2locodosyalg
                    NmrData.locodosyopts(3)=1;
                    guidata(hMainFigure,NmrData);
                    NmrData.pfgnmrdata=PreparePfgnmrdata(); %AC
                case hRadio3locodosyalg
                    NmrData.locodosyopts(3)=2;
                    guidata(hMainFigure,NmrData);
                    NmrData.pfgnmrdata=PreparePfgnmr3Ddata(); %AC
                otherwise
                    error('illegal choice')
            end
            % Individual plots?
            switch get(hLRmethodplots,'value')
                case 1
                    NmrData.locodosyopts(4)=1;
                case 0
                    NmrData.locodosyopts(4)=0;
            end
            % find the dimensions of the spectrum
            speclim=xlim();
            if speclim(1)<NmrData.sp
                speclim(1)=NmrData.sp;
            end
            if speclim(2)>(NmrData.sw+NmrData.sp)
                speclim(2)=(NmrData.sw+NmrData.sp);
            end
            NmrData.LRRegionData=get(hRegionsTable,'Data');
            NmrData.numcomp=NmrData.LRRegionData';
            NmrData.xlim(1)=speclim(1);
            NmrData.xlim(2)=speclim(2);
            %call the locodosy_mn m-file to perform LRSCORE on each window selected
            NmrData.locodosydata=locodosy(NmrData.pfgnmrdata,NmrData.numcomp,...
                NmrData.nwin,speclim,NmrData.locodosyopts,NmrData.th,NmrData.nug,...
                NmrData.winstart,NmrData.winend,NmrData.Dlimit,NmrData.minpercent,...
                NmrData.DiffRes);
            NmrData.LRRegionData=NmrData.locodosydata.newnumcomp;
            set(hRegionsTable,'Data', NmrData.LRRegionData)
            % call the combine1dscore m-file to find similarly diffusing species between
            % windows and build component spectra
            UseClustering=get(hUseClustering,'value');
            if UseClustering==1
                NmrData.locodosydata=combine1dlocodosy(NmrData.locodosydata...
                    .components,NmrData.nwin,NmrData.fn,NmrData.locodosydata...
                    ,NmrData.winstart,NmrData.winend,NmrData.locodosydata.sderrcell...
                    ,NmrData.sderrmultiplier);
                % call the locodosyplot m-file to plot these 1D spectra in one figure and a
                % pseudo 2d plot in another figure. This returns data on which windows are
                % used in which spectrum for the highlighting of where a synthetic 0
                % baseline has been added to component spectra.
                NmrData.locodosydata.zerolines=locodosyplot(NmrData.locodosydata,NmrData.fn);
                guidata(hMainFigure,NmrData);
            else
                %don't use clustering
            end
        end
        
    end
    function plotlocodosy(source,eventdata)
        NmrData=guidata(hMainFigure);
        dosyplot_gui(NmrData.locodosydata);
    end
%----PARAFAC-------
    function PARAFACButton_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        APVisibleOff();
        set(hPARAFACButton,'ForegroundColor',[1 0 1])
        set(hPARAFACButton,'Fontweight','bold')
        set(hProcessButton,'Visible','On')
        %set(hReplotButton,'Visible','On')
        set(hEditNcomp,'Visible','On')
        set(hTextNcomp,'Visible','On')
        set(hTextProcess,'Visible','On')
        set(hTextExclude,'Visible','On')
        set(hExcludeShow,'Visible','On')
        set(hClearExcludeButton,'Visible','On')
        set(hSetExcludeButton,'Visible','On')
        set(hEditNgrad,'Visible','On')
        %set(hTextNgrad,'Visible','On')
        set(hNgradUse,'Visible','On')
        set(hThresholdButton,'Visible','On')
        set(hPanelPARAFACConstrain,'Visible','On')
        
        set(hEditArray2,'Visible','On')
        set(hTextArray2,'Visible','On')
        set(hArray2Use,'Visible','On')
        set(hTextPrune2,'Visible','On')
        set(hTextGrad,'Visible','On')
        set(hSepPlotUse,'Visible','On')
        set(hAutoPlotUse,'Visible','On')
        
        %         NmrData.pfgnmrdata=PreparePfgnmr3Ddata();
        set(hProcessButton,'Callback',@doPARAFAC)
        %set(hReplotButton,'Callback',@plotdecra)
        guidata(hMainFigure,NmrData);
    end
    function doPARAFAC(source,eventdata)
         NmrData=guidata(hMainFigure);
        NmrData.pfgnmrdata=PreparePfgnmr3Ddata();
        Options=[1e-6 1 1 0 0 0];
              
        if get(hAutoPlotUse,'Value')
%             Options=[1e-6 1 1 0 0 0];
                   % figure
        else
            Options=[1e-6 1 0 0 0 0];
        end
        
        const=[0 0 0];
        OldLoad=[];
        FixMode=[];
        Weights=[] ;
        NmrData.ncomp=str2double(get(hEditNcomp,'String'));
        guidata(hMainFigure,NmrData);
        pfgnmrdata=NmrData.pfgnmrdata;
                      
        %set spectral limits
        speclim=xlim();
        if speclim(1)<NmrData.sp
            speclim(1)=NmrData.sp;
        end
        if speclim(2)>(NmrData.sw+NmrData.sp)
            speclim(2)=(NmrData.sw+NmrData.sp);
        end
        Specrange=speclim;
        if length(Specrange)~=2
            error('SCORE: Specrange should have excatly 2 elements')
        end
        if Specrange(1)<pfgnmrdata.sp
            disp('SCORE: Specrange(1) is too low. The minumum will be used')
            Specrange(1)=pfgnmrdata.sp;
        end
        if Specrange(2)>(pfgnmrdata.wp+pfgnmrdata.sp)
            disp('SCORE: Specrange(2) is too high. The maximum will be used')
            Specrange(2)=pfgnmrdata.wp+pfgnmrdata.sp;
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
        
        % Set constraints               
        switch get(hGroupMode1,'SelectedObject')            
            case hRadioConst1none
                const(1)=0;                
            case hRadioConst1ortho
                const(1)=1;                
            case hRadioConst1nneg
                const(1)=2;                
            case hRadioConst1unimod
                const(1)=3;                
            otherwise
                disp('unknown constraint in mode 1 - defaulting to no constraint')
        end
        switch get(hGroupMode2,'SelectedObject')
            
            case hRadioConst2none
                const(2)=0;
                
            case hRadioConst2ortho
                const(2)=1;
                
            case hRadioConst2nneg
                const(2)=2;
                
            case hRadioConst2unimod
                const(2)=3;
                
            otherwise
                disp('unknown constraint in mode 2 - defaulting to no constraint')
        end
        switch get(hGroupMode3,'SelectedObject')
            
            case hRadioConst3none
                const(3)=0;
                
            case hRadioConst3ortho
                const(3)=1;
                
            case hRadioConst3nneg
                const(3)=2;
                
            case hRadioConst3unimod
                const(3)=3;
                
            otherwise
                disp('unknown constraint in mode 3 - defaulting to no constraint')
        end
        
        %make a new stucture
        pfgnmrdata.sp=pfgnmrdata.Ppmscale(begin);
        pfgnmrdata.wp=pfgnmrdata.Ppmscale(endrange)-pfgnmrdata.Ppmscale(begin);
        pfgnmrdata.Ppmscale=pfgnmrdata.Ppmscale(begin:endrange);
        pfgnmrdata.SPECTRA=pfgnmrdata.SPECTRA(begin:endrange,:,:);
        pfgnmrdata.np=length(pfgnmrdata.Ppmscale) ;
              
        figure
       [NmrData.parafacFac]= parafac(pfgnmrdata.SPECTRA,NmrData.ncomp,Options,const,OldLoad,FixMode,Weights);
     

       %Make separate plots
       if get(hSepPlotUse,'Value')
           %Mode 1
           figure('Color',[0.9 0.9 0.9],...
               'NumberTitle','Off',...
               'Name','Mode 1');
           mode1=NmrData.parafacFac{1};
           h=plot(pfgnmrdata.Ppmscale,mode1);
           set(gca,'xdir','reverse'); 
           axis('tight')
           set(h,'LineWidth',1)
           set(gca,'LineWidth',1)
           ylim([(min(min(mode1))-0.1*max(max(mode1))) max(max(mode1))*1.1])
           title('Spectrum mode','FontSize',12, 'FontWeight','bold') %TMB 10-03-16
           xlabel('Chemical shift (ppm)','FontSize',12, 'FontWeight','bold') %TMB 10-03-16
           ylabel('Intensity','FontSize',12, 'FontWeight','bold') %TMB 10-03-16
           
           
           figure('Color',[0.9 0.9 0.9],...
               'NumberTitle','Off',...
               'Name','Mode 1 - separate');
           
           for k=1:NmrData.ncomp
               ax(k)=subplot(NmrData.ncomp,1,k);
               h=plot(pfgnmrdata.Ppmscale,mode1(:,k));
               set(gca,'xdir','reverse'); %TMB 10-03-16
           title('Spectrum mode','FontSize',12, 'FontWeight','bold') %TMB 10-03-16
           xlabel('Chemical shift (ppm)','FontSize',12, 'FontWeight','bold') %TMB 10-03-16
           ylabel('Intensity','FontSize',12, 'FontWeight','bold') %TMB 10-03-16
           end
            linkaxes(ax,'x');
           
            %Mode2
                figure('Color',[0.9 0.9 0.9],...
               'NumberTitle','Off',...
               'Name','Mode 1');
           mode2=NmrData.parafacFac{2};
           h=plot(mode2, '-*');
           axis('tight')
           set(h,'LineWidth',1)
           set(gca,'LineWidth',1)
           ylim([(min(min(mode2))-0.1*max(max(mode2))) max(max(mode2))*1.1])
           title('Diffussion mode','FontSize',12, 'FontWeight','bold') %TMB 10-03-16
           xlabel('Gradient amplitude squared','FontSize',12, 'FontWeight','bold') %TMB 10-03-16
           ylabel('Intensity','FontSize',12, 'FontWeight','bold') %TMB 10-03-16
           
           
           figure('Color',[0.9 0.9 0.9],...
               'NumberTitle','Off',...
               'Name','Mode 2 - separate');
           
           for k=1:NmrData.ncomp
               ax(k)=subplot(NmrData.ncomp,1,k);
               h=plot(mode2(:,k), '-*'); %TMB 10-03-16
           title('Diffussion mode','FontSize',12, 'FontWeight','bold') %TMB 10-03-16
           xlabel('Gradient amplitude squared','FontSize',12, 'FontWeight','bold') %TMB 10-03-16
           ylabel('Intensity','FontSize',12, 'FontWeight','bold') %TMB 10-03-16
           end
            linkaxes(ax,'x');
            
            %Mode 3
            
                 figure('Color',[0.9 0.9 0.9],...
               'NumberTitle','Off',...
               'Name','Mode 3');
           mode3=NmrData.parafacFac{3};
           h=plot(mode3, '-*'); %TMB 10-03-16
           %set(gca,'xdir','reverse'); %TMB 10-03-16
           axis('tight')
           set(h,'LineWidth',1)
           set(gca,'LineWidth',1)
           ylim([(min(min(mode3))-0.1*max(max(mode3))) max(max(mode3))*1.1])
           title('Time mode','FontSize',12, 'FontWeight','bold') %TMB 10-03-16
           xlabel('Time','FontSize',12, 'FontWeight','bold') %TMB 10-03-16
           ylabel('Concentration','FontSize',12, 'FontWeight','bold') %TMB 10-03-16
           
           
           figure('Color',[0.9 0.9 0.9],...
               'NumberTitle','Off',...
               'Name','Mode 3 - separate');
           
           for k=1:NmrData.ncomp
               ax(k)=subplot(NmrData.ncomp,1,k);
               h=plot(mode3(:,k), '-*'); %TMB 10-03-16
           title('Time mode','FontSize',12, 'FontWeight','bold') %TMB 10-03-16
           xlabel('Time','FontSize',12, 'FontWeight','bold') %TMB 10-03-16
           ylabel('Concentration','FontSize',12, 'FontWeight','bold') %TMB 10-03-16
           end
            linkaxes(ax,'x');
       end
        guidata(hMainFigure,NmrData);
    end
%----BIN-------
    function BINButton_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        APVisibleOff();
        set(hBINButton,'ForegroundColor',[1 0 1])
        set(hBINButton,'Fontweight','bold')
        %set(hProcessButton,'Visible','On')
        %set(hReplotButton,'Visible','On')
        %set(hEditNcomp,'Visible','On')
        %set(hTextNcomp,'Visible','On')
        set(hTextProcess,'Visible','On')
        set(hTextExclude,'Visible','On')
        set(hExcludeShow,'Visible','On')
        set(hClearExcludeButton,'Visible','On')
        set(hSetExcludeButton,'Visible','On')
        set(hEditNgrad,'Visible','On')
        set(hTextNgrad,'Visible','On')
        set(hNgradUse,'Visible','On')
        %set(hThresholdButton,'Visible','On')
        %NmrData.pfgnmrdata=PreparePfgnmr3Ddata();
        %set(hProcessButton,'Callback',@doPARAFAC)
        %set(hReplotButton,'Callback',@plotdecra)
        set(hPlotSpecButton,'Visible','On')
        set(hPlotBinnedButton,'Visible','On')
        set(hEditBin,'Visible','On')
        set(hTextBin,'Visible','On')
        
        guidata(hMainFigure,NmrData);
    end
    function PlotSpecButton_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        if NmrData.plottype==0
            ButtonSpec_Callback();
        end
        NmrData.xlim_spec=xlim();
        NmrData.ylim_spec=ylim();
        switch NmrData.shiftunits
            case 'ppm'
                NmrData.Specscale=...
                    linspace(NmrData.sp,(NmrData.sw+NmrData.sp),NmrData.fn);
            case 'Hz'
                NmrData.Specscale=...
                    linspace(NmrData.sp.*NmrData.sfrq,(NmrData.sw+NmrData.sp).*NmrData.sfrq,NmrData.fn);
            otherwise
                error('illegal choice')
        end
        figure('Color',[0.9 0.9 0.9],...
            'NumberTitle','Off',...
            'Name','Current spectrum');
        plot(NmrData.Specscale,real(NmrData.SPECTRA(:,NmrData.flipnr)));
        xlabel('\bf Chemical shift ');
        xlim(NmrData.xlim_spec)
        ylim(NmrData.ylim_spec)
        set(gca,'Xdir','Reverse');
        guidata(hMainFigure,NmrData);
    end
    function PlotBinnedButton_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        if NmrData.plottype==0
            ButtonSpec_Callback();
        end
        ExportBinned(0)
        guidata(hMainFigure,NmrData);
    end
%----ICOSHIFT-------
    function icoshiftButton_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        APVisibleOff();       
        set(hicoshiftButton,'ForegroundColor',[1 0 1])
        set(hicoshiftButton,'Fontweight','bold')
        set(hButtonICOAlign,'Visible','On')
       % set(hTextiCOSHIFT,'Visible','On')
        set(hBGroupIcoshiftMode,'Visible','On')
        set(hBGroupIcoshiftTarget,'Visible','On')
        set(hEditIntervals,'Visible','On')
        set(hTextIntervals,'Visible','On')
        guidata(hMainFigure,NmrData);
    end
    function ButtonICOAlign_Callback( eventdata, handles)
        NmrData=guidata(hMainFigure);
        
        %defaults
        target='average';
        mode='whole';
        fit='b';
        options=0;        
        
        switch get(hBGroupIcoshiftTarget,'SelectedObject')
            case hRadio1IcoshiftTarget
                target='average';
            case hRadio2IcoshiftTarget
                target='median';
            case hRadio3IcoshiftTarget
                target='max';
            case hRadio4IcoshiftTarget
                target='average2';
            otherwise
                error('illegal choice')
        end
        
        switch get(hBGroupIcoshiftMode,'SelectedObject')
            case hRadio1IcoshiftMode
                %Interactive
                nPoint=numel(NmrData.baselinepoints);
                if mod(nPoint,2)
                    disp('odd')
                    Nreg=ceil(nPoint/2); %number of spectral regions to process
                else
                    disp('even')
                    Nreg=round(nPoint/2); %number of spectral regions to process
                    %number of processed regions
                end
                Nproc=0;
                m=1;
                while Nreg > Nproc
                    region=ones(1,NmrData.fn)*NaN;
                    while  isnan(NmrData.region(m)) %go to first region
                        m=m+1;
                        if m >= NmrData.fn
                            disp('WARNING. region goes beyond spectra width')
                            break;
                        end
                    end
                    while  ~isnan(NmrData.region(m))
                        region(m)=NmrData.region(m);
                        m=m+1;
                        if m >= NmrData.fn
                            disp('WARNING. region goes beyond spectra width')
                            break;
                        end
                    end
                    rawspec=real(NmrData.SPECTRA(~isnan(region),:));
                    %Now I need to convert to complex and replace that spectral
                    [corrspec] = icoshift (target, rawspec', 'whole', fit, options);
                    corrspec=corrspec';
                    np=length(corrspec(:,1));
                    aspec=fft(corrspec);
                    bspec=aspec(1:(round(np/2)),:);
                    bspec(1,:)=bspec(1,:)*0.5; %remove baseline error
                    cspec=ifft(bspec,np)/0.5; %scale to match original;
                    NmrData.SPECTRA(~isnan(region),:)=cspec;
                    Nproc=Nproc+1;
                end
            case hRadio2IcoshiftMode
                % intervals
                %get intervals
                intervals=round(str2double(get(hEditIntervals,'string')));
                rawspec=real(NmrData.SPECTRA);
                %Now I need to convert to complex and replace that spectral
                
                [corrspec] = icoshift (target, rawspec', intervals, fit, options);
                corrspec=corrspec';
                np=length(corrspec(:,1));
                aspec=fft(corrspec);
                bspec=aspec(1:(round(np/2)),:);
                bspec(1,:)=bspec(1,:)*0.5; %remove baseline error
                cspec=ifft(bspec,np)/0.5; %scale to match original;
                NmrData.SPECTRA=cspec;
                
            case hRadio3IcoshiftMode
                %whole
                
                rawspec=real(NmrData.SPECTRA);
                %Now I need to convert to complex and replace that spectral
                [corrspec] = icoshift (target, rawspec', 'whole', fit, options);
                corrspec=corrspec';
                np=length(corrspec(:,1));
                aspec=fft(corrspec);
                bspec=aspec(1:(round(np/2)),:);
                bspec(1,:)=bspec(1,:)*0.5; %remove baseline error
                cspec=ifft(bspec,np)/0.5; %scale to match original;
                NmrData.SPECTRA=cspec;
                
            otherwise
                error('illegal choice')
        end
        
        guidata(hMainFigure,NmrData);
        PlotSpectrum();
    end
    function GroupIcoshiftMode_Callback( eventdata, handles)
        zoom off
        pan off
        switch get(hBGroupIcoshiftMode,'SelectedObject')
            case hRadio1IcoshiftMode
                set(hEditIntervals,'Enable','Off')                
            case hRadio2IcoshiftMode
                set(hEditIntervals,'Enable','On')
            case hRadio3IcoshiftMode
                set(hEditIntervals,'Enable','Off')
            otherwise
                error('illegal choice')
        end        
        guidata(hMainFigure,NmrData);        
    end
    function GroupIcoshiftTarget_Callback( eventdata, handles)
    end
%----INTEGRAL-----
    function INTEGRALButton_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        APVisibleOff();
        set(hINTEGRALButton,'ForegroundColor',[1 0 1])
        set(hINTEGRALButton,'Fontweight','bold')
        set(hTextIntegrals,'Visible','On')
        set(hIntegralsShow,'Visible','On')
        set(hIntegralsScale,'Visible','On')
        set(hClearIntegralsButton,'Visible','On')
        set(hSetIntegralButton,'Visible','On')
        set(hTextNormalise,'Visible','On')
        set(hBGroupNormalise,'Visible','On')
        set(hRadio1Normalise,'Visible','On')
        set(hRadio2Normalise,'Visible','On')
        set(hEditNorm,'Visible','On')
        set(hTextNorm,'Visible','On')
        set(hEditNormPeak,'Visible','On')
        set(hTextNormPeak,'Visible','On')
        set(hExportIntegralButton,'Visible','On')
        set(hExportIntegralSetsButton,'Visible','On')
        set(hTextIntegralsExport,'Visible','On')
        set(hImportIntegralSetsButton,'Visible','On')
        set(hTextIntegralsImport,'Visible','On')
        guidata(hMainFigure,NmrData);
    end
    function IntegralsShow_Callback( eventdata, handles)
        zoom off
        pan off
        button_state = get(hIntegralsShow,'Value');
        if button_state == 1
            IntLine_function();
        elseif button_state == 0
            hIntLine=findobj(hAxes,'tag','IntLine');
            delete(hIntLine);
            set(hIntegralsScale,'Value',0)
        end
        PlotSpectrum();
        guidata(hMainFigure,NmrData);
    end
    function IntegralsScale_Callback( eventdata, handles)
        zoom off
        pan off
        button_state = get(hIntegralsScale,'Value');
        if button_state == 1
            set(hIntegralsShow,'Value',1)
            IntLine_function();
        elseif button_state == 0
        end
        PlotSpectrum();
        guidata(hMainFigure,NmrData);
    end
    function SetIntegralsButton_Callback( eventdata, handles)
        zoom off
        pan off
        %get the delta the spectrum
        if NmrData.plottype==1
            NmrData.xlim_spec=xlim();
            NmrData.ylim_spec=ylim();
        end
        IntLine_function();
        guidata(hMainFigure,NmrData);
        PlotSpectrum();
        set(hMainFigure,'WindowButtonDownFcn',@IntLine_function)
        set(hIntegralsShow,'Value',1)
        %DrawIntLine();
    end
    function ClearIntegralsButton_Callback( eventdata, handles)
        zoom off
        pan off
        NmrData=guidata(hMainFigure);
        NmrData.IntPoint=[];
        % NmrData.IntPoint=[NmrData.sp];
        %NmrData.IntPoint=[NmrData.sp+NmrData.sw];
        NmrData.IntPointSort=[];
        NmrData.IntPointIndex=[];
        NmrData.Integral=ones(1, NmrData.fn);
        set(hMainFigure,'WindowButtonDownFcn','')
        hIntLine=findobj(hAxes,'tag','IntLine');
        delete(hIntLine);
        guidata(hMainFigure,NmrData);
        PlotSpectrum();
        %DrawIntLine();
    end
    function EditNorm_Callback( eventdata, handles)
        zoom off
        pan off
        tmp=round(str2double(get(hEditNorm,'string')));
        if isnan(tmp)
            disp('Norm must be a number; defaulting to 100')
            set(hEditNorm,'String',num2str(100))
        end
        
        guidata(hMainFigure,NmrData);
        set(hIntegralsShow,'Value',1)
        PlotSpectrum();
        %DrawIntLine();
    end
    function EditNormPeak_Callback( eventdata, handles)
        zoom off
        pan off
        tmp=round(str2double(get(hEditNormPeak,'string')));
        if isnan(tmp)
            disp('Norm must be a number defaulting to 1')
            set(hEditNormPeak,'String',num2str(1))
        end
        guidata(hMainFigure,NmrData);
        set(hIntegralsShow,'Value',1)
        PlotSpectrum();
        %DrawIntLine();
    end
    function GroupNormalise_Callback( eventdata, handles)
        zoom off
        pan off
        switch get(hBGroupNormalise,'SelectedObject')
            case hRadio1Normalise
                set(hEditNormPeak,'Enable','On')
                set(hEditNorm,'Enable','On')
            case hRadio2Normalise
                set(hEditNormPeak,'Enable','Off')
                set(hEditNorm,'Enable','On')
            case hRadio3Normalise
                set(hEditNormPeak,'Enable','Off')
                set(hEditNorm,'Enable','Off')
            otherwise
                error('illegal choice')
        end
        
        guidata(hMainFigure,NmrData);
        
        PlotSpectrum();
        set(hIntegralsShow,'Value',1)
        %DrawIntLine();
    end
    function ExportIntegralButton_Callback( eventdata, handles)
        %export the integral data
        [filename, pathname] = uiputfile('*.txt','Export Integrals');
        filepath=[pathname filename];
        statfil=fopen(filepath, 'wt');
        %print out FID data to file
        if isunix()==1
            slashindex=find(NmrData.filename=='/');
        else
            slashindex=find(NmrData.filename=='\');
        end
        
        %print mandatory fields
        fprintf(statfil,'%-s  \n','## DOSY Toolbox data file');
        fprintf(statfil,'%-s\t\t\t\t\t\t %-s \n','#Title (string) ' , NmrData.filename(slashindex(end)+1:end) );
        fprintf(statfil,'%-s\t\t\t\t\t\t\t %-s \n','#Date (string) ' , datestr(now) );
        fprintf(statfil,'%-s\t\t\t\t\t %-s  \n','#DOSY Toolbox version (string) ', NmrData.version);
        fprintf(statfil,'%-s\t\t\t\t %-s  \n','#DOSY Toolbox format version (double) ', '0.1');
        fprintf(statfil,'%-s\t\t\t\t\t\t %-s  \n','#Data Type (string) ', 'Integrals');
        fprintf(statfil,'%-s\t\t\t\t\t\t %-s  \n','#Data Origin (string) ', 'DOSY Toolbox');
        fprintf(statfil,'%-s\t\t\t\t %-s  \n','#Spectrometer/Data System (string)', NmrData.type);
        fprintf(statfil,'%-s\t\t\t\t\t\t %-s  \n','#Data Class (string) ', 'Integrals');
        fprintf(statfil,'%-s\t\t\t\t\t %-s  \n','#Observe Nucleus (string) ', '1-H');
        fprintf(statfil,'%-s\t\t\t\t %-f  \n','#Observe frequency (double ; MHz) ', NmrData.sfrq);
        fprintf(statfil,'%-s\t\t\t\t \n','#Y axis definition (null) ');
        fprintf(statfil,'%-s\t\t\t\t \n','#Binary file name (null) ');
        fprintf(statfil,'%-s\t\t\t\t\t\t %-s  \n','#Complex Data (string)', 'No');
        %print peak regions
        fprintf(statfil,'%-s %-d %-s \n','#Integral Regions [',floor(length(NmrData.IntPointSort)/2),'] (string)');
        for k=1:length(NmrData.IntPointSort)/2
            fprintf(statfil,'%-s %-d %-s %-f %-f \n','Peak ',k, ': (double ; ppm)', NmrData.IntPointSort(2*k-1),NmrData.IntPointSort(2*k));
        end
        %print peak data
        intnorm=str2double(get(hEditNorm,'String'));
        intpeak=round(str2double(get(hEditNormPeak,'String')));
        switch get(hBGroupNormalise,'SelectedObject')
            case hRadio1Normalise
                fprintf(statfil,'%-s\t\t\t\t\t %-d \n','# Normalised to Peak: (integer)',intpeak);
            case hRadio2Normalise
                fprintf(statfil,'%-s\t\t\t\t %-f \n','# Total area normalised to (double) ',intnorm);
            case hRadio3Normalise
                fprintf(statfil,'%-s \n','# No normalisation (null)');
            otherwise
                fprintf(statfil,'%-s \n','# Unknown normalisation (null)');
        end
        tmpflip= NmrData.flipnr;
        for n=1:NmrData.arraydim
            NmrData.flipnr=n;
            guidata(hMainFigure,NmrData);
            PlotSpectrum();
            fprintf(statfil,'%-s\t\t\t\t %-d \n','# Integrals for spectrum (integer)',NmrData.flipnr);
            intcum=0;
            for p=1:length(NmrData.IntPointSort)/2
                hh=real(NmrData.SPECTRA(:,NmrData.flipnr));
                ss=sum(hh(NmrData.IntPointIndex(2*p-1):NmrData.IntPointIndex(2*p)));
                intcum=intcum+ss;
                if p==intpeak
                    intpeaksize=ss;
                end
            end
            for m=1:length(NmrData.IntPointSort)/2
                switch get(hBGroupNormalise,'SelectedObject')
                    case hRadio1Normalise
                        if  ~isempty(m) &&  m>=intpeak
                            for k=1:length(NmrData.IntPointSort)/2
                                hh=real(NmrData.SPECTRA(:,NmrData.flipnr));
                                ss=sum(hh(NmrData.IntPointIndex(2*m-1):NmrData.IntPointIndex(2*m)));
                                area=intnorm*ss/intpeaksize;
                            end
                        else
                            for k=1:length(NmrData.IntPointSort)/2
                                area=NaN;
                            end
                        end
                    case hRadio2Normalise
                        for k=1:length(NmrData.IntPointSort)/2
                            hh=real(NmrData.SPECTRA(:,NmrData.flipnr));
                            ss=sum(hh(NmrData.IntPointIndex(2*m-1):NmrData.IntPointIndex(2*m)));
                            area=intnorm*ss/intcum;
                        end
                    case hRadio3Normalise
                        %normalise to intnorm in the first spectrum
                        intcum_1=0;
                        for p=1:length(NmrData.IntPointSort)/2
                            hh_1=real(NmrData.SPECTRA(:,1));
                            ss_1=sum(hh_1(NmrData.IntPointIndex(2*k-1):NmrData.IntPointIndex(2*k)));
                            intcum_1=intcum_1+ss_1;
                        end
                        for k=1:length(NmrData.IntPointSort)/2
                            hh=real(NmrData.SPECTRA(:,NmrData.flipnr));
                            ss=sum(hh(NmrData.IntPointIndex(2*m-1):NmrData.IntPointIndex(2*m)));
                            area=intnorm*ss/intcum_1;
                            
                        end
                    otherwise
                        error('illegal choice')
                end
                fprintf(statfil,'%-s %-d %-s %-f \n','Peak ',m, ': (double)', area);
            end
        end
        NmrData.flipnr=tmpflip;
        guidata(hMainFigure,NmrData);
        set(hMainFigure,'WindowButtonDownFcn','')
        IntLine_function();
        PlotSpectrum();
        fclose(statfil);
        type(filepath);
        
    end
    function ExportIntegralSetButton_Callback( eventdata, handles)
        %export the integral regions
        [filename, pathname] = uiputfile('*.txt','Export Integral Regions');
        filepath=[pathname filename];
        statfil=fopen(filepath, 'wt');
        if isunix()==1
            slashindex=find(NmrData.filename=='/');
        else
            slashindex=find(NmrData.filename=='\');
        end
        
        %print mandatory fields
        fprintf(statfil,'%-s  \n','## DOSY Toolbox data file');
        fprintf(statfil,'%-s\t\t\t\t\t\t %-s \n','#Title (string) ' , NmrData.filename(slashindex(end)+1:end) );
        fprintf(statfil,'%-s\t\t\t\t\t\t\t %-s \n','#Date (string) ' , datestr(now) );
        fprintf(statfil,'%-s\t\t\t\t\t %-s  \n','#DOSY Toolbox version (string) ', NmrData.version);
        fprintf(statfil,'%-s\t\t\t\t %-s  \n','#DOSY Toolbox format version (double) ', '0.1');
        fprintf(statfil,'%-s\t\t\t\t\t\t %-s  \n','#Data Type (string) ', 'Integrals Settings');
        fprintf(statfil,'%-s\t\t\t\t\t\t %-s  \n','#Data Origin (string) ', 'DOSY Toolbox');
        fprintf(statfil,'%-s\t\t\t\t %-s  \n','#Spectrometer/Data System (string)', NmrData.type);
        fprintf(statfil,'%-s\t\t\t\t\t\t %-s  \n','#Data Class (string) ', 'Integrals');
        fprintf(statfil,'%-s\t\t\t\t\t %-s  \n','#Observe Nucleus (string) ', '1-H');
        fprintf(statfil,'%-s\t\t\t\t %-f  \n','#Observe frequency (double ; MHz) ', NmrData.sfrq);
        fprintf(statfil,'%-s\t\t\t\t \n','#Y axis definition (null) ');
        fprintf(statfil,'%-s\t\t\t\t \n','#Binary file name (null) ');
        fprintf(statfil,'%-s\t\t\t\t\t\t %-s  \n','#Complex Data (string)', 'No');
        %print peak regions
        fprintf(statfil,'%-s %-d %-s \n','#Integral Regions [',floor(length(NmrData.IntPointSort)/2),'] (string)');
        for k=1:length(NmrData.IntPointSort)/2
            fprintf(statfil,'%-s %-d %-s %-f %-f \n','Peak ',k, ': (double;ppm)', NmrData.IntPointSort(2*k-1),NmrData.IntPointSort(2*k));
        end
        
        fclose(statfil);
        type(filepath);
        
    end
    function ImportIntegralSetButton_Callback( eventdata, handles)
        %export the integral regions
        [filename, pathname] = uigetfile('*.*','Import Integral Regions');
        filepath=[pathname filename];
        statfil=fopen(filepath, 'rt');
        
        [ImportData]=ImportDOSYToolboxFormat(statfil);
        %type(filepath);
        %
        if isfield(ImportData,'DataType')
            disp(['File of type ' ImportData.DataType.Value])
        else
            disp(['Unknown file type ' ImportData.DataType])
        end
        if isfield(ImportData,'IntegralRegions')
            disp('Importing integral regions')
            NmrData.IntPoint=[];
            for k=1:length(ImportData.IntegralRegions.Value);
                ParmIndexTwo=strfind(ImportData.IntegralRegions.Value{k},')');
                StrTmp=ImportData.IntegralRegions.Value{k}(ParmIndexTwo+1:end);
                NmrData.IntPoint=[NmrData.IntPoint ; sscanf(StrTmp,'%f %f')];
            end
        else
            error('DOSY Toolbox: File import. integral regions does not exists (or import failed)')
        end
        NmrData.IntPoint= NmrData.IntPoint' ;
        set(hIntegralsShow,'Value',1);
        
        guidata(hMainFigure,NmrData);
        set(hMainFigure,'WindowButtonDownFcn','')
        IntLine_function();
        PlotSpectrum();
        
    end
%----Baseline Correction-----
    function BaselineButton_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        APVisibleOff();
        set(hBaselineButton,'ForegroundColor',[1 0 1]);
        set(hBaselineButton,'Fontweight','bold');
        set(hXiRockePanel,'Visible','On');
        
        guidata(hMainFigure,NmrData);
    end
    function Auto1BaselineButton_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        %
        % Baseline flattening according to Y. Xi & D.M. Rocke, BMC Bioinformatics
        % vol 9, 234 (2008).
        % Adjust parameters A & B in Part 2.
        %
        % Part 1: set up for LOWESS auto noise estimate:
        
        
        
        binsize = 32;   % points per bin
        
        aStar    = 1e-8 ;  % determined empirically reasonable
        noiseStdFact = 1.25;
        
         binsize=round(str2double(get(hEditBaselineBin,'string')));
         aStar=str2double(get(hEditBaselineStar,'string'));
         noiseStdFact=str2double(get(hEditBaselineStd,'string'))   ;     
         Plot= get(hCheckPhase,'Value');
        
        
        
        
        
       
        hp=waitbar(0,'Automatic baseline correction');
        for Nspec=1:NmrData.arraydim
            waitbar(Nspec/NmrData.arraydim);
            a=real(NmrData.SPECTRA(:,Nspec));
            %scale spectra
            SpecMax=max(a);
            Scale=(1/SpecMax)*1e14; %empirically this seems good.
            a=a/(Scale);
            
            x=NmrData.Specscale';
            s     =real(a);
            npt   = length(s);
 
            
            % Determine binned mean and variance as approximation of full spectrum
            kbin = round(npt / binsize);
            smean = zeros(kbin,1);
            svar  = zeros(kbin,1);
            for k = 1:kbin
              
                smean(k) = mean(s(1+(k-1)*binsize:k*binsize));
                svar(k)  = var(s(1+(k-1)*binsize:k*binsize));
            
            end
            %
            % LOWESS fit to estimate noise variance; taken from W.L. Marinez & A.R.
            % Martinez, Computational Statistics Handbook 2nd Edition 2008.
            alpha  = 0.5;
            lambda = 2;
            [sortmean,idx] = sort(smean);
            
            % Focus on lower portion of sortmean:
            jdx = find(sortmean < 20);
            x0  = linspace(min(sortmean(jdx)), max(sortmean(jdx)), 50);
            
            % Robust LOESS
            %figure
            loess_fit_r = csloessr(sortmean(jdx),svar(idx(jdx)),x0,alpha,lambda);
            %plot(sortmean(jdx),svar(idx(jdx)),'bo',x0,loess_fit_r,'k-');
            % Estimate noise variance
            kdx = x0 > -0.5 & x0 < 0; % Empirically chosen limits for mean
            noiseVar = mean(loess_fit_r(kdx));
            %
            %%
            % Part 2: vary parameters for baseline correction.
            % There is some interplay between noiseVar and aStar; adjust here for given
            % data set.
            %
            %aStar    = 1e-5 ;  % determined empirically reasonable
            noiseStd = sqrt(noiseVar);
            B     =noiseStdFact/ noiseStd;
            C     = npt^4;
            A     = C * aStar / noiseStd;
            bEst  = baseline(s,A,B,noiseStd);
            sFit  = s - bEst;
            %
            % Calculated baseline bEst can be too low at ends; therefore
            % consider residuals at one end where there are no peaks.
            % Compare resid and baseline curvature trade-off by varying aStar and
            % noiseVar...
            ix    = find(x(:) <= -0.17 & x(:) >= -1.6);
            resid = sum((s(ix) - bEst(ix)).^2);
            % figure;
            %             figure
            %             plot(x,[s bEst sFit]);
            %             set(gca,'XDir','reverse',...
            %                 'FontSize',11,'FontWeight','demi');
            %             xlabel('ppm','FontSize',11,'FontWeight','demi');
            %             guidata(hMainFigure,NmrData);
            
            corrspec=sFit*Scale;
            np=length(corrspec(:,1));
            aspec=fft(corrspec);
            bspec=aspec(1:(round(np/2)),:);
            bspec(1,:)=bspec(1,:)*0.5; %remove baseline error
            cspec=ifft(bspec,np)/0.5; %scale to match original;
            NmrData.SPECTRA(:,Nspec)=cspec;
            
            
            
            
        end
        close(hp)
        
        guidata(hMainFigure,NmrData);
        %set(gca,hAxes)
        PlotSpectrum()
    end
%----Analyze-----
    function AnalyzeButton_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        APVisibleOff();
        set(hAnalyzeButton,'ForegroundColor',[1 0 1])
        set(hAnalyzeButton,'Fontweight','bold')
        set(hTextAnalyze,'Visible','Off')
        set(hAnalyzeFreqButton,'Visible','On')
        set(hAnalyzeResButton,'Visible','On')
        set(hAnalyzeAmpButton,'Visible','On')
        set(hAnalyzeTempButton,'Visible','On')
        set(hAnalyzePhaseButton,'Visible','On')
        set(hAnalyzeIntButton,'Visible','On')
        set(hDSSButton,'Visible','On')
        set(hTextStart,'Visible','On')
        set(hEditStart,'Visible','On')
        set(hTextStop,'Visible','On')
        set(hEditStop,'Visible','On')
        set(hTextStep,'Visible','On')
        set(hEditStep,'Visible','On')
        set(hTextChartWidth,'Visible','On')
        set(hEditChartWidth,'Visible','On')        
        set(hTextStopChart,'Visible','On')
        set(hEditStopChart,'Visible','On') 
        set(hTextHorizontalOffset,'Visible','On')
        set(hEditHorizontalOffset,'Visible','On')
        set(hTextVerticalOffset,'Visible','On')
        set(hEditVerticalOffset,'Visible','On')
        
        set(hThresholdButton,'Visible','On')
        set(hEditStop,'String',NmrData.arraydim)
          
          
        guidata(hMainFigure,NmrData);
    end
    function AnalyzeFreqButton_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        analyzedata=PrepareAnalyzeData();        
        
        freq=zeros(1,analyzedata.arraydim);   
        for narray=1:analyzedata.arraydim   
            th=100*NmrData.thresydata(1)/max(real(analyzedata.SPECTRA(:,analyzedata.increments(narray))));
           [peaks]=peakpick_mn(real(analyzedata.SPECTRA(:,analyzedata.increments(narray))),th);
            if isempty(peaks)
                freq(narray)=0;                
            else
            %[peaks]=peakpick_mn(analyzedata.SPECTRA(:,analyzedata.increments(narray)),NmrData.th)  ;
            amp=analyzedata.SPECTRA(peaks(1).max,analyzedata.increments(narray));
            ampmax=1;
            for k=1:length(peaks)
                testamp=analyzedata.SPECTRA(peaks(k).max,analyzedata.increments(narray));
                if testamp>amp
                    ampmax=k;
                end
            end
            freq(narray)=analyzedata.Ppmscale(peaks(ampmax).max);
            end
        end
               
        analyze.type='Frequency';
        analyze.title='Analyze Frequency';
        analyze.data=freq;
        analyze.xscale=analyzedata.increments;
        analyze.xlabel='Increment Number';
        switch NmrData.shiftunits
            case 'ppm'
                %we want Hz for this
               analyze.data= analyze.data.*NmrData.sfrq;
            case 'Hz'                
%all fine
                
            otherwise
                error('illegal choice')
        end
        
        analyze.ylabel=['Frequency /' 'Hz'];
        clear analyzedata
     
        PlotAnalyze(analyze);
        guidata(hMainFigure,NmrData);
    end
    function AnalyzeAmpButton_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        analyzedata=PrepareAnalyzeData();        
        
        freq=zeros(1,analyzedata.arraydim);
        amparray=zeros(1,analyzedata.arraydim);
        for narray=1:analyzedata.arraydim
           th=100*NmrData.thresydata(1)/max(real(analyzedata.SPECTRA(:,analyzedata.increments(narray))));
           [peaks]=peakpick_mn(real(analyzedata.SPECTRA(:,analyzedata.increments(narray))),th);
            %[peaks]=peakpick_mn(real(analyzedata.SPECTRA(:,analyzedata.increments(narray))),NmrData.th);
            if isempty(peaks)
                freq(narray)=0;
                amparray(narray)=0;
            else
                amp=analyzedata.SPECTRA(peaks(1).max,analyzedata.increments(narray));
                ampmax=1;
                
                for k=1:length(peaks)
                    testamp=analyzedata.SPECTRA(peaks(k).max,analyzedata.increments(narray));
                    if testamp>amp
                        ampmax=k;
                    end
                end
                freq(narray)=analyzedata.Ppmscale(peaks(ampmax).max);
                amparray(narray)=real(analyzedata.SPECTRA(peaks(ampmax).max,analyzedata.increments(narray)));
            end
        end
     
        analyze.type='Apmlitude';
        analyze.title='Analyze Amplitude';
        analyze.data=amparray;
        analyze.xscale=analyzedata.increments;
        analyze.xlabel='Increment Number';
        analyze.ylabel='Peak Amplitude';
        clear analyzedata
        NmrData.analyze=analyze;
        PlotAnalyze(analyze);
        guidata(hMainFigure,NmrData);
    end    
    function AnalyzeTempButton_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
       analyzedata=PrepareAnalyzeData();        
        
        freq=zeros(1,analyzedata.arraydim);   
        Temp=zeros(1,analyzedata.arraydim); 
        for narray=1:analyzedata.arraydim    
            
            [peaks]=peakpick_mn(analyzedata.SPECTRA(:,analyzedata.increments(narray)),NmrData.th)  ;
            amp=analyzedata.SPECTRA(peaks(1).max,analyzedata.increments(narray));
            ampmax=1;
            for k=1:length(peaks)
                testamp=analyzedata.SPECTRA(peaks(k).max,analyzedata.increments(narray));
                if testamp>amp
                    ampmax=k;
                end
            end
            freq(narray)=analyzedata.Ppmscale(peaks(ampmax).max);
            if narray==1
                temp1=freq(narray)/(4.7*NmrData.sfrq/500);
            end
            Temp(narray)=freq(narray)/(4.7*NmrData.sfrq/500) - temp1;
        end
               
        analyze.type='Temperature';
        analyze.title='Analyze Temperaure';
        analyze.data=Temp;
        analyze.xscale=analyzedata.increments;
        analyze.xlabel='Increment Number';
        analyze.ylabel='Temperature /Kelvin';
        clear analyzedata
     
        PlotAnalyze(analyze);
        guidata(hMainFigure,NmrData);
    end
    function AnalyzeResButton_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        analyzedata=PrepareAnalyzeData();
        
        freq=zeros(1,analyzedata.arraydim);
        freqnr=zeros(1,analyzedata.arraydim);
        for narray=1:analyzedata.arraydim
            [peaks]=peakpick_mn(analyzedata.SPECTRA(:,analyzedata.increments(narray)),NmrData.th);
            amp=analyzedata.SPECTRA(peaks(1).max,analyzedata.increments(narray));
            ampmax=1;
            for k=1:length(peaks);
                testamp=analyzedata.SPECTRA(peaks(k).max,analyzedata.increments(narray));
                if testamp>amp
                    ampmax=k;
                end
            end
            freq(narray)=analyzedata.Ppmscale(peaks(ampmax).max);
            freqnr(narray)=peaks(ampmax).max;
        end
        PeakWidth=zeros(1,analyzedata.arraydim);
        for narray=1:analyzedata.arraydim
            PeakWidth(narray)=EstimatePeakshape(analyzedata.SPECTRA(:,analyzedata.increments(narray)),0);
        end
        
        
        analyze.type='Resolution';
        analyze.title='Analyze Peakshape';
        analyze.data=PeakWidth;
        analyze.xscale=analyzedata.increments;
        analyze.xlabel='Increment Number';
        analyze.ylabel='Peak width at half height /Hz';
        clear analyzedata
        
        PlotAnalyze(analyze);
        guidata(hMainFigure,NmrData);
    end
    function AnalyzePhaseButton_Callback(source,eventdata)
        %The sum of the positive and negative peaks of a pure Lorentzian close to dispersion mode 
        %divided by the difference is approximately equal to the phase deviation from pure dispersion 
        %in radians. (Recipe from Ad Bax).
        
        NmrData=guidata(hMainFigure);
        set(hEditPh0,'string',num2str(NmrData.rp+90,4))
        EditPh0_Callback();
        analyzedata=PrepareAnalyzeData();
        freq=zeros(1,analyzedata.arraydim);
        amparray1=zeros(1,analyzedata.arraydim);
        for narray=1:analyzedata.arraydim
            [peaks]=peakpick_mn(analyzedata.SPECTRA(:,analyzedata.increments(narray)),NmrData.th)  ;
            amp=analyzedata.SPECTRA(peaks(1).max,analyzedata.increments(narray));
            ampmax=1;
            for k=1:length(peaks)
                testamp=analyzedata.SPECTRA(peaks(k).max,analyzedata.increments(narray));
                if testamp>amp
                    ampmax=k;
                end
            end
            freq(narray)=analyzedata.Ppmscale(peaks(ampmax).max);
            amparray1(narray)=real(analyzedata.SPECTRA(peaks(ampmax).max,analyzedata.increments(narray)));
        end
        
    %    pause(2)
        set(hEditPh0,'string',num2str(NmrData.rp-180,4))
        EditPh0_Callback();
        analyzedata=PrepareAnalyzeData();
        amparray2=zeros(1,analyzedata.arraydim);
        for narray=1:analyzedata.arraydim
            [peaks]=peakpick_mn(analyzedata.SPECTRA(:,analyzedata.increments(narray)),NmrData.th)  ;
            amp=analyzedata.SPECTRA(peaks(1).max,analyzedata.increments(narray));
            ampmax=1;
            for k=1:length(peaks)
                testamp=analyzedata.SPECTRA(peaks(k).max,analyzedata.increments(narray));
                if testamp>amp
                    ampmax=k;
                    testamp=amp;
                end
            end
            amparray2(narray)=real(analyzedata.SPECTRA(peaks(ampmax).max,analyzedata.increments(narray)));
        end
        

        tmp1= (amparray2+(-amparray1));
        tmp2=(amparray2-(-amparray1));
       
        phasearray=tmp1./tmp2;
        phasearray=phasearray*180/pi;
        
       % phasearray=90-(90*(phasearray./(phasearray(1))));
        
        
      %  pause(2)
        set(hEditPh0,'string',num2str(NmrData.rp+90,4))
        EditPh0_Callback()
        
        analyze.type='Phase';
        analyze.title='Analyze Phase';
        analyze.data=phasearray;
        analyze.xscale=analyzedata.increments;
        analyze.xlabel='Increment Number';
        analyze.ylabel='Phase change /Degrees';
        clear analyzedata
        
        PlotAnalyze(analyze);
        
        guidata(hMainFigure,NmrData)
    end
    function AnalyzeIntButton_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        analyzedata=PrepareAnalyzeData();   
    
        if length(NmrData.IntPointIndex)>2 ||  length(NmrData.IntPointIndex)<2
            errordlg('Set one integral region only (using the INTEGRATE controls)'); 
            return;
        end
        
         firstspec=real(NmrData.SPECTRA(:,analyzedata.increments(1)));
         firstint=sum(firstspec(NmrData.IntPointIndex(1):NmrData.IntPointIndex(2)));
         intarray=zeros(1,analyzedata.arraydim);   
         for narray=1:analyzedata.arraydim
             spec=real(NmrData.SPECTRA(:,analyzedata.increments(narray)));             
             intarray(narray)=100*sum(spec(NmrData.IntPointIndex(1):NmrData.IntPointIndex(2)))/firstint;
         end
         
         
        analyze.type='Integral';
        analyze.title='Analyze Integral';
        analyze.data=intarray;
        analyze.xscale=analyzedata.increments;
        analyze.xlabel='Increment Number';
        analyze.ylabel='Integral';
        clear analyzedata
     
        PlotAnalyze(analyze);
        guidata(hMainFigure,NmrData);
    end
    function DSSButton_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        analyzedata=PrepareAnalyzeData();
     
        VertOff=str2num(get(hEditVerticalOffset,'String'));
        HorizOff=str2num(get(hEditHorizontalOffset,'String'));        
        Horiz=round(HorizOff*analyzedata.np/100);
        
        plotspec=nan(analyzedata.np+abs(Horiz)*analyzedata.arraydim,analyzedata.arraydim);
        ylimit=ylim();  
        for k=1:analyzedata.arraydim
               analyzedata.SPECTRA(analyzedata.SPECTRA(:,k)>ylimit(2),k)=nan;
               analyzedata.SPECTRA(analyzedata.SPECTRA(:,k)<ylimit(1),k)=nan;
        end
        if Horiz<0
            for k=1:analyzedata.arraydim
               % plotspec((k-1)*abs(Horiz)+1:analyzedata.np+(k-1)*abs(Horiz),analyzedata.arraydim-k+1)=real(analyzedata.SPECTRA(:,analyzedata.increments(analyzedata.arraydim-k+1)));
               plotspec((k-1)*abs(Horiz)+1:analyzedata.np+(k-1)*abs(Horiz),k)=real(analyzedata.SPECTRA(:,analyzedata.increments(k)));
            end
        else
            for k=1:analyzedata.arraydim
               % plotspec((k-1)*Horiz+1:analyzedata.np+(k-1)*Horiz,k)=real(analyzedata.SPECTRA(:,analyzedata.increments(k)));  
               plotspec((k-1)*abs(Horiz)+1:analyzedata.np+(k-1)*abs(Horiz),analyzedata.arraydim-k+1)=real(analyzedata.SPECTRA(:,analyzedata.increments(analyzedata.arraydim-k+1)));
            end
        end
        VertIncr=VertOff*max(max(plotspec))/100;
        for k=1:analyzedata.arraydim
            %plotspec((k-1)*Horiz+1:analyzedata.np+(k-1)*Horiz,k)=plotspec(:,k)+(k-1)*VertIncr;
            plotspec(:,k)=plotspec(:,k)+(k-1)*VertIncr;
        end
        
         text(analyzedata.arraydim,min(min(real(analyzedata.SPECTRA(:,analyzedata.increments(k))))),num2str(analyzedata.increments(k)));
        
        hFigDSS=figure;
        hPlotDSS= plot(plotspec,'Color','black');
       
        hold on
         if Horiz<0
            for k=1:analyzedata.arraydim
               text(1-k*Horiz,min(min(plotspec(:,k))),num2str(analyzedata.increments(k)),'Color','Blue');
                
            end
        else
            for k=1:analyzedata.arraydim
                text(analyzedata.arraydim*Horiz-k*Horiz,min(min(plotspec(:,k))),num2str(analyzedata.increments(k)),'Color','Blue');
            end
        end
        hold off
          set(gca,'Xdir','reverse');
        guidata(hMainFigure,NmrData);
    end
    function EditStart_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
       
        guidata(hMainFigure,NmrData);
    end
    function EditStop_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
       
        guidata(hMainFigure,NmrData);
    end
    function EditStep_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
       
        guidata(hMainFigure,NmrData);
    end
    function EditChartWidth_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
       
        guidata(hMainFigure,NmrData);
    end
    function EditStopChart_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
       
        guidata(hMainFigure,NmrData);
    end
    function EditHorizontalOffset_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
       
        guidata(hMainFigure,NmrData);
    end
    function EditVerticalOffset_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
       
        guidata(hMainFigure,NmrData);
    end
    function PlotAnalyze(analyzedata)
        hAnalyzeFig=figure;
        hPlotAnalyze= plot(analyzedata.xscale,analyzedata.data,'-+','Color','black','MarkerEdgeColor','r');
        xlabel(analyzedata.xlabel)
        ylabel(analyzedata.ylabel)
        title(analyzedata.title) 
        axis(gca,'tight')
         tmp=ylim();
         tmpdiff=tmp(2) -tmp(1);
        tmp(1)=tmp(1)-0.2*tmpdiff;
        tmp(2)=tmp(2)+0.2*tmpdiff;
       ylim(tmp)
        
    end
    function analyzedata=PrepareAnalyzeData()
        NmrData=guidata(hMainFigure);
        analyzedata=NmrData;
        analyzedata.wp=NmrData.sw;
        analyzedata.Ppmscale=NmrData.Specscale;
        analyzedata.SPECTRA=NmrData.SPECTRA;
        
        switch NmrData.shiftunits
            case 'ppm'
                %all fine
                
            case 'Hz'                
                analyzedata.sp=NmrData.sp.*NmrData.sfrq;
                analyzedata.wp=NmrData.sw.*NmrData.sfrq;
                
            otherwise
                error('illegal choice')
        end
        
        Specrange=xlim();
        if Specrange(1)<analyzedata.sp
            disp('Analyze: Specrange(1) is too low. The minumum will be used')
            Specrange(1)=analyzedata.sp;
        end
        if Specrange(2)>(analyzedata.wp+analyzedata.sp)
            disp('Analyze: Specrange(2) is too high. The maximum will be used')
            Specrange(2)=analyzedata.wp+analyzedata.sp;
        end
        for k=1:length(analyzedata.Ppmscale)
            if (analyzedata.Ppmscale(k)>Specrange(1))
                begin=k-1;
                k1=begin;
                break;
            end
        end
        
        for k=begin:length(analyzedata.Ppmscale)
            if (analyzedata.Ppmscale(k)>=Specrange(2))
                endrange=k;
                break;
            end
        end
        %make a new stucture
        analyzedata.sp=analyzedata.Ppmscale(k1);
        analyzedata.wp=analyzedata.Ppmscale(endrange)-analyzedata.Ppmscale(k1);
        analyzedata.Ppmscale=analyzedata.Ppmscale(k1:endrange);               
        analyzedata.SPECTRA=analyzedata.SPECTRA(k1:endrange,:);
        analyzedata.np=length(analyzedata.Ppmscale);
        analyzedata.increments=1:NmrData.arraydim;

 
        k=str2num(get(hEditStart,'String'));
        step=str2num(get(hEditStep,'String'));
        stop=str2num(get(hEditStop,'String'));
        incrit=1;

        while k<=NmrData.arraydim && k<=stop          
         
           incr(incrit)=analyzedata.increments(k); %#ok<AGROW>
            k=k+step;
            incrit=incrit+1;
        end
       
        analyzedata.increments=incr;     
        analyzedata.arraydim=length(analyzedata.increments); 
        
        guidata(hMainFigure,NmrData);        
    end
%----T1/T2-----
    function T1Button_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        APVisibleOff();
        set(hT1Button,'ForegroundColor',[1 0 1])
        set(hT1Button,'Fontweight','bold')
        set(hProcessButton,'Visible','On')
        set(hReplotButton,'Visible','On')
        set(hBGroupT1Opt2,'Visible','On')
        set(hPanelT1plotting,'Visible','On')
        set(hTextExclude,'Visible','On')
        set(hExcludeShow,'Visible','On')
        set(hClearExcludeButton,'Visible','On')
        set(hSetExcludeButton,'Visible','On')
        set(hThresholdButton,'Visible','On')
        set(hProcessButton,'Callback',@doT1)
        set(hReplotButton,'Callback',@plotT1)
        
        guidata(hMainFigure,NmrData);
    end
    function doT1(source,eventdata)
        NmrData=guidata(hMainFigure);
        NmrData.pfgnmrdata=PreparePfgnmrdata();
        speclim=xlim();
        if speclim(1)<NmrData.sp
            speclim(1)=NmrData.sp;
        end
        if speclim(2)>(NmrData.sw+NmrData.sp)
            speclim(2)=(NmrData.sw+NmrData.sp);
        end
        NmrData.pfgnmrdata.flipnr=NmrData.flipnr;
        button_state = get(hCheckT1limits,'Value');
        T1range=[0 10 256];
        T1range(3)=str2double(get(hEditT1res,'String'));
        if button_state == 1
            %disp('on')
            T1range(1)=0;
            T1range(2)=0;
        elseif button_state == 0
            %disp('off')
            T1range(1)=str2double(get(hEditT1min,'String'));
            T1range(2)=str2double(get(hEditT1max,'String'));
        end
        
             
        switch get(hBGroupT1Opt2,'SelectedObject')
            
            case hRadio1T1Opt2
                %T1
                disp('T1 (3 parameter fit)')
                FitType=1;
                
            case hRadio2T1Opt2
                %T2
                disp('T2 (2 parametes fit)')                
                FitType=2;
          
            otherwise
                disp('unknown selection of relaxation fitting')
        end
        
        NmrData.t1data=t1_mn(NmrData.pfgnmrdata,NmrData.th,speclim,T1range,FitType);
        dosyplot_gui(NmrData.t1data);
         
        %print out statistics to file
        DTpath=which('DOSYToolbox');
        DTpath=DTpath(1:(end-13));
        if FitType==1
            %statfil=fopen([DTpath 't1stats.txt'], 'wt');
            relaxfil=[DTpath 't1stats.txt'];
        elseif FitType==2
            % statfil=fopen([DTpath 't2stats.txt'], 'wt');
            relaxfil=[DTpath 't2stats.txt'];
        else
            error('unknown FitType')
        end
       statfil=fopen(relaxfil,'wt');
    
        fprintf(statfil,'%-s  \n','********************************************************'); 
        fprintf(statfil,'%-s  \n','Fitting statistics for a T1/T2 experiment');    
        if FitType==1
             fprintf(statfil,'%-s  \n','T1 exponential fitting M(t) =(M(0) - M0)*exp(-t/T1) + M0;');
        elseif FitType==2
            fprintf(statfil,'%-s  \n','T2 exponential fitting M(t) =(M(0) - M(inf))*exp(-t/T1) + M(inf);');

        else
            error('unknown FitType')
        end
        fitsize=size(NmrData.t1data.FITSTATS);
        fprintf(statfil,'\n');
        fprintf(statfil,'\n%s%s%s \n','*******Fit Summary*******');
        fprintf(statfil,'\n');        
        fprintf(statfil,'%-13s  ','Frequency');        
        fprintf(statfil,'%-13s  %-13s  %-13s  %-13s  %-13s %-13s %-13s ','Exp. M(0)','Fit. M(0)','error','Fit. M0/M(inf)','error','T1/T2','error');
        fprintf(statfil,'\n');
        for k=1:fitsize(1)
            fprintf(statfil,'%-13.5f  ',NmrData.t1data.freqs(k));
            fprintf(statfil,'%-13.5f  ',NmrData.t1data.ORIGINAL(k,1));
            for m=1:fitsize(2)
                fprintf(statfil,'%-13.5f  ',NmrData.t1data.FITSTATS(k,m));
            end
            fprintf(statfil,'\n');
        end        
        fprintf(statfil,'\n%s%s%s \n','Tau values [', num2str(numel(NmrData.t1data.d2)), ']  (s)');
        for g=1:numel(NmrData.t1data.d2)
            fprintf(statfil,'%-10.5f  \n',NmrData.t1data.d2(g));
        end
        fprintf(statfil,'\n%s%s%s \n','*******Residuals*******');
        fprintf(statfil,'\n');    
        for k=1:fitsize(1)
            fprintf(statfil,'%-10s %-10.0f %-10s %-10.5f \n','Peak Nr: ', k, 'Frequency (ppm): ',NmrData.t1data.freqs(k));
            fprintf(statfil,'%-10s   %-10s   %-10s  \n','Exp. Ampl','Fit. Ampl','Diff');
            for m=1:numel(NmrData.t1data.d2)                
                fprintf(statfil,'%-10.5e  %-10.5e  %-10.5e  \n',NmrData.t1data.ORIGINAL(k,m),NmrData.t1data.FITTED(k,m),NmrData.t1data.RESIDUAL(k,m));
            end
            fprintf(statfil,'\n');
        end        
        fprintf(statfil,'\n%s%s%s \n','*******Fit Summary*******');
        fprintf(statfil,'\n');        
        fprintf(statfil,'%-13s  ','Frequency');        
        fprintf(statfil,'%-13s  %-13s  %-13s  %-13s  %-13s %-13s %-13s ','Exp. M(0)','Fit. M(0)','error','Fit. M0/M(inf)','error','T1/T2','error');
        fprintf(statfil,'\n');
        for k=1:fitsize(1)
            fprintf(statfil,'%-13.5f  ',NmrData.t1data.freqs(k));
            fprintf(statfil,'%-13.5f  ',NmrData.t1data.ORIGINAL(k,1));
            for m=1:fitsize(2)
                fprintf(statfil,'%-13.5f  ',NmrData.t1data.FITSTATS(k,m));
            end
            fprintf(statfil,'\n');
        end 
        fprintf(statfil,'\n%s\n%s\n','This information can be found in:',relaxfil);
        fclose(statfil);
        type(relaxfil);
        guidata(hMainFigure,NmrData);
    end
    function plotT1(source,eventdata)
        dosyplot_gui(NmrData.t1data);
    end
    function CheckT1limits_Callback( eventdata, handles)
        zoom off
        pan off
        button_state = get(hCheckT1limits,'Value');
        if button_state == 1
            %disp('on')
            set(hEditT1max,'Enable','Off')
            set(hEditT1min,'Enable','Off')
        elseif button_state == 0
            %disp('off')
            set(hEditT1max,'Enable','On')
            set(hEditT1min,'Enable','On')
        end
    end
%----FDMRRT-----
 function EditCres_Callback(eventdata, handles)
        set(hEditCres,'String', num2str(...
            max(1,str2num(get(hEditCres,'String')))));
    end
    function FDMRRTN1_Callback(eventdata, handles)
        set(hEditN1,'String', num2str(...
            min(max(2,str2num(get(hEditN1,'String'))),...
            NmrData.pfgnmrdata.np)));
    end
    function FDMRRTN2_Callback(eventdata, handles)
        set(hEditN2,'String', num2str(...
            min(max(2,str2num(get(hEditN2,'String'))),...
            NmrData.pfgnmrdata.ngrad)));
    end
    function FDMRRTBasis_Callback(eventdata, handles)
        set(hEditBasis,'String', num2str(...
            min(max(2,str2num(get(hEditBasis,'String'))), 500)));
    end
    function FDMRRTButton_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        APVisibleOff();
        set(hFDMRRTButton,'ForegroundColor',[1 0 1])
        set(hFDMRRTButton,'Fontweight','bold')
        set(hProcessButton,'Visible','On')
        set(hReplotButton,'Visible','On')
        set(hExportButton,'Visible','On')
        set(hTextN1,'Visible','On')
        set(hEditN1,'Visible','On')
        set(hTextN2,'Visible','On')
        set(hEditN2,'Visible','On')
        set(hTextBasis,'Visible','On')
        set(hEditBasis,'Visible','On')
        set(hEditS,'Visible','On')
        set(hTextS,'Visible','On')
        set(hBGroupFDMRRTOpt1,'Visible','On')
        set(hBGroupFDMRRTOpt2,'Visible','On')
        set(hBGroupFDMRRTOpt3,'Visible','On')
        set(hEditQ,'Visible','On')
        set(hEditS,'Visible','On')
        set(hTextQ,'Visible','On')
        set(hTextS,'Visible','On')
        set(hEditCres,'Visible','On')
        set(hTextCres,'Visible','On')
        set(hEditDmin,'Visible','On')
        set(hTextDmin,'Visible','On')
        set(hEditDmax,'Visible','On')
        set(hEditDmax,'Enable','On')        
        set(hTextDmax,'Visible','On')
        set(hEditDres,'Visible','On')
        set(hTextDres,'Visible','On')
        set(hThresholdButton,'Visible','On')
        set(hUseClustering,'Visible','Off')
        set(hTextUseClustering,'Visible','Off')
        NmrData.pfgnmrdata=PreparePfgnmrdata();
        set(hEditN1,'String', num2str(min(NmrData.pfgnmrdata.np,4096)));
        set(hEditN2,'String', num2str(NmrData.pfgnmrdata.ngrad));
        set(hEditBasis,'String', '50');
        set(hEditQ,'String', '10.00');
        set(hEditS,'String', '0.2');
        set(hEditCres,'String', '1024');
        set(hProcessButton,'Callback',@DoFDMRRT)
        set(hReplotButton,'Callback',@plotfdmrrt)
        %set(hExportButton,'Callback',@ExportFDMRRTplot)
        guidata(hMainFigure,NmrData);
        return;
        theta = -pi/18; %#ok<UNRCH>
        mfactor = 0.75;
        nfactor = 0.95;
        sigma0 = 5;
        ngauss = 3*sigma0;
        gauss = normpdf(-ngauss:ngauss,0,sigma0)';
        fid00 = circshift(NmrData.FID(:,1),-NmrData.lrfid) * exp(-i * theta);
        fid00(end-NmrData.lrfid+1:end,:) = 0.0;
        n00 = size(fid00,1);
        for kk=1:4
            mfactork = mfactor^(kk-1);
            n0 = floor(n00 * mfactork);
            fid0 = fid00(1:n0);
            spec0 = fft(fid0.* cos(pi/2*(1:n0)'/n0));
            for kkk=1:100
                nfactork = nfactor^kkk;
                n1 = floor(n0*nfactork);
                fid1 = zeros(size(fid0));
                fid1(1:n1) = fid0(1:n1);
                spec1 = fft(fid1 .* cos(pi/2*(1:n0)'/n1));
                err(kkk,:)=[nfactork, sum(abs(spec0 - spec1))^2/sum(abs(spec0))];
                %				figure();
                %				plot(real([spec0 - spec1, spec0]))
            end
            err
            figure();
            plot(err(1:end-1,1)*n0,diff(err(:,2),1))
        end
    end
    function DoFDMRRT(source,eventdata)
        %Prepare the data for DOSY analysis
        NmrData.dosyplot=0;
        guidata(hMainFigure,NmrData)
        NmrData=guidata(hMainFigure);
        
        
        switch get(hBGroupFDMRRTOpt1,'SelectedObject')
            case hRadio1FDMRRTOpt1
                NmrData.FDMRRTopts(1)=0;
            case hRadio2FDMRRTOpt1
                NmrData.FDMRRTopts(1)=1;
            otherwise
                error('illegal choice')
        end
        switch get(hBGroupFDMRRTOpt2,'SelectedObject')
            case hRadio1FDMRRTOpt2
                NmrData.FDMRRTopts(2)=0;
            case hRadio2FDMRRTOpt2
                NmrData.FDMRRTopts(2)=1;
            otherwise
                error('illegal choice')
        end
        switch get(hBGroupFDMRRTOpt3,'SelectedObject')
            case hRadio1FDMRRTOpt3
                NmrData.FDMRRTopts(3)=0;
            case hRadio2FDMRRTOpt3
                NmrData.FDMRRTopts(3)=1;
            otherwise
                error('illegal choice')
        end
        NmrData.FDMRRTopts(4) = str2num(get(hEditN1,'String'));
        NmrData.FDMRRTopts(5) = str2num(get(hEditN2,'String'));
        NmrData.FDMRRTopts(6) = str2num(get(hEditBasis,'String'));
        NmrData.FDMRRTopts(7) = str2num(get(hEditQ,'String'));
        NmrData.FDMRRTopts(8) = str2num(get(hEditS,'String')) * 10^(-10);
        NmrData.FDMRRTopts(9) = str2num(get(hEditDmin,'String'));
        NmrData.FDMRRTopts(10) = str2num(get(hEditDmax,'String'));
        NmrData.FDMRRTopts(11) = str2num(get(hEditDres,'String'));
        NmrData.FDMRRTopts(12) = str2num(get(hEditCres,'String'));
        NmrData.FDMRRTopts(20) = strcmp(NmrData.type,'Bruker') * NmrData.lrfid;
        
        Specrange=xlim();
        if Specrange(1)<NmrData.sp
            Specrange(1)=NmrData.sp;
        end
        if Specrange(2)>(NmrData.sw+NmrData.sp)
            Specrange(2)=(NmrData.sw+NmrData.sp);
        end
        
        NmrData.xlim_spec=Specrange;
        guidata(hMainFigure,NmrData)
        NmrData.pfgnmrdata=PreparePfgnmrdata();
        pfgnmrdata=NmrData.pfgnmrdata;

        for k=1:length(pfgnmrdata.Ppmscale)
            if (pfgnmrdata.Ppmscale(k)>Specrange(1))
                begin=k-1;
                k1=begin;
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
        pfgnmrdata.sp=pfgnmrdata.Ppmscale(k1);
        pfgnmrdata.wp=pfgnmrdata.Ppmscale(endrange)-pfgnmrdata.Ppmscale(k1);
        pfgnmrdata.Ppmscale=pfgnmrdata.Ppmscale(k1:endrange);
        pfgnmrdata.SPECTRA=pfgnmrdata.SPECTRA(k1:endrange,:);
        pfgnmrdata.np=length(pfgnmrdata.Ppmscale);
    
        NmrData.pfgnmrdata.XSPEC= pfgnmrdata.SPECTRA;
        
        
        guidata(hMainFigure,NmrData)
        
        
        
        NmrData.dosydata = fdmrrt_mn(NmrData);
        guidata(hMainFigure,NmrData)
        
        
        guidata(hMainFigure,NmrData)
    end
    function plotfdmrrt(source,eventdata)
        dosyplot_gui(NmrData.dosydata)
    end
%----ILT-----
    function ILTButton_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        APVisibleOff();
        set(hILTButton,'ForegroundColor',[1 0 1])
        set(hILTButton,'Fontweight','bold')
        set(hProcessButton,'Visible','On')
        set(hReplotButton,'Visible','On')
        set(hExportButton,'Visible','On')
        set(hEditDmin,'Visible','On')
        set(hTextDmin,'Visible','On')
        set(hEditDmax,'Visible','On')
        set(hEditDmax,'Enable','On')        
        set(hTextDmax,'Visible','On')
        set(hEditDres,'Visible','On')
        set(hTextDres,'Visible','On')
        set(hThresholdButton,'Visible','On')
        set(hBGroupDOSYOpt1,'Visible','On')
        set(hBGroupDOSYOpt2,'Visible','On')
        set(hBGroupDOSYOpt3,'Visible','On')
        set(hBMultiexpPanel,'Visible','On')
        set(hBPlotPanel,'Visible','On')
        set(hBGroupILTRegMet,'Visible','On')
        set(hBGroupILTOptimLambda,'Visible','On')
        set(hBGroupILTSmooth,'Visible','On')
        set(hBGroupILTConstrain,'Visible','On')
        set(hEditLamda,'Visible','On')
        set(hTextLamda,'Visible','On')
        set(hProcessButton,'Callback',@DoILT)
        
    end
    function DoILT(source,eventdata)
        %Prepare the data for ILT analysis
        
        NmrData=guidata(hMainFigure);
        
        %         RegularisationMethod=1; %0=none, 1=Tikhonov
        %         Smooth= 0 %0=none, 1=1st derivative, 2=2nd derivative
        %         Constraint =1 %0=none, 1=Non-negativity standard
        %         OptimLambda=1 %0=manual, 1=l-curve, 2=gcv
        
        RegLambda=1;
        ILTOpts=[0 0 0 0];
        RegLambda = str2num(get(hEditLamda,'String'));
        switch get(hBGroupILTRegMet,'SelectedObject')
            case hRadio1ILTRegMet
                RegularisationMethod=0;
            case hRadio2ILTRegMet
                RegularisationMethod=1;
            otherwise
                error('illegal choice')
        end
        
        switch get(hBGroupILTOptimLambda,'SelectedObject')
            case hRadio1ILTILTOptimLambd
                OptimLambda=0; %manual
            case hRadio2ILTILTOptimLambd
                OptimLambda=1; %l-curve
            case hRadio3ILTILTOptimLambd
                OptimLambda=2; %gcv
            otherwise
                error('illegal choice')
        end
        
        
        switch get(hBGroupILTSmooth,'SelectedObject')
            case hRadio1ILTILTSmooth
                Smooth=0; %No smoothing
            case hRadio2ILTILTOptiSmooth
                Smooth=1; %first derivative
            case hRadio3ILTILTOptimSmooth
                Smooth=2; %second derivative
            otherwise
                error('illegal choice')
        end
        
        
        
        switch get(hBGroupILTConstrain,'SelectedObject')
            case hRadio1ILTConstrain
                Constraint=0; %No constraint
            case hRadio2ILTConstrain
                Constraint=1; %Non-negativity
            otherwise
                error('illegal choice')
        end
        ILTOpts=[RegularisationMethod OptimLambda Smooth Constraint RegLambda];
        diffrange=[0 20 256];
        diffrange(1)=str2double(get(hEditDmin,'String'));
        diffrange(2)=str2double(get(hEditDmax,'String'));
        diffrange(3)=str2double(get(hEditDres,'String'));
        
        speclim=xlim();
        if speclim(1)<NmrData.sp
            speclim(1)=NmrData.sp;
        end
        if speclim(2)>(NmrData.sw+NmrData.sp)
            speclim(2)=(NmrData.sw+NmrData.sp);
        end
        
        switch get(hBGroupDOSYOpt1,'SelectedObject')
            case hRadio1DOSYOpt1
                PeakPick=0; %all data points
            case hRadio2DOSYOpt1
                PeakPick=1; %peak picking
            otherwise
                error('illegal choice')
        end
        switch get(hBGroupDOSYOpt2,'SelectedObject')
            case hRadio1DOSYOpt2
                nugflag=0;
            case hRadio2DOSYOpt2
                nugflag=1;
            otherwise
                error('illegal choice')
        end
        
        NmrData.pfgnmrdata=PreparePfgnmrdata();
        NmrData.ILTdata=ILT_mn(NmrData.pfgnmrdata,PeakPick,NmrData.th,speclim,diffrange,ILTOpts,nugflag,NmrData.nug);
        
        
        %print out statistics to file
        DTpath=which('DOSYToolbox');
        DTpath=DTpath(1:(end-13));
        statfil=fopen([DTpath 'dosystats.txt'], 'wt');
        fprintf(statfil,'%-s  \n','Fitting statistics for a 2D DOSY ILT experiment');
        if nugflag==0
            fprintf(statfil,'%-s  \n','Pure exponential fitting (Stejskal-Tanner equation)');
        elseif nugflag==1
            fprintf(statfil,'\n');
            fprintf(statfil,'%-s  \n','Fitting using compensation for non-uniform field gradients (NUG). ');
        else
            fprintf(statfil,'%-s  \n','Unknown function');
        end
        
        switch RegularisationMethod
            case 0
                fprintf(statfil,'%-s  \n','Not regularised');
            case 1
                fprintf(statfil,'%-s  \n','Tikhonov regularisation');
            otherwise
                fprintf(statfil,'%-s  \n','Unknown regularisation');
        end
        
        switch OptimLambda
            case 0
                fprintf(statfil,'%-s  \n','manual lambda'); %manual
            case 1
                fprintf(statfil,'%-s  \n','lambda estimated by l-curve'); %manual %l-curve
            case 2
                fprintf(statfil,'%-s  \n','lambda estimated by gcv'); %manual; %gcv
            otherwise
                fprintf(statfil,'%-s  \n','Unknown lambda estimation'); %second derivative
        end
        
        
        switch Smooth
            case 0
                fprintf(statfil,'%-s  \n','No smoothing');
                %No smoothing
            case 1
                fprintf(statfil,'%-s  \n','First derivative smoothing'); %first derivative
            case 2
                fprintf(statfil,'%-s  \n','Second derivative smoothing'); %second derivative
            otherwise
                fprintf(statfil,'%-s  \n','Unknown smoothing'); %second derivative
        end
        
        
        
        switch Constraint
            case 0
                fprintf(statfil,'%-s  \n','No constraint');  %No constraint
            case 1
                fprintf(statfil,'%-s  \n','Non-negativity constraint') ; %Non-negativity
            otherwise
                fprintf(statfil,'%-s  \n','Unknown constraint') ; %Non-negativity
        end
        
        
        fitsize=size(NmrData.ILTdata.FITSTATS);
        fprintf(statfil,'\n');
        fprintf(statfil,'\n%s%s%s \n','*******Fit Summary*******');
        fprintf(statfil,'\n');
        fprintf(statfil,'%-10s  ','Frequency');
        fprintf(statfil,'%-10s  %-9s%-1.1i  %-10s  %-9s%-1.1i  %-10s  ','Exp. Ampl','Fit. Ampl');
        fprintf(statfil,'\n');
        for k=1:fitsize(1)
            fprintf(statfil,'%-10.5f  ',NmrData.ILTdata.freqs(k));
            fprintf(statfil,'%-10.5f  ',NmrData.ILTdata.ORIGINAL(k,1));
            fprintf(statfil,'%-10.5f  ',NmrData.ILTdata.FITTED(k,1));
            fprintf(statfil,'\n');
        end
        fprintf(statfil,'\n%s%s%s \n','Gradient amplitudes [', num2str(numel(NmrData.ILTdata.Gzlvl)), ']  (T m^-2)');
        for g=1:numel(NmrData.ILTdata.Gzlvl)
            fprintf(statfil,'%-10.5e  \n',NmrData.ILTdata.Gzlvl(g));
        end
        fprintf(statfil,'\n%s%s%s \n','*******Residuals*******');
        fprintf(statfil,'\n');
        for k=1:fitsize(1)
            fprintf(statfil,'%-10s %-10.0f %-10s %-10.5f \n','Peak Nr: ', k, 'Frequency (ppm): ',NmrData.ILTdata.freqs(k));
            fprintf(statfil,'%-10s   %-10s   %-10s  \n','Exp. Ampl','Fit. Ampl','Diff');
            for m=1:numel(NmrData.ILTdata.Gzlvl)
                fprintf(statfil,'%-10.5e  %-10.5e  %-10.5e  \n',NmrData.ILTdata.ORIGINAL(k,m),NmrData.ILTdata.FITTED(k,m),NmrData.ILTdata.RESIDUAL(k,m));
            end
            fprintf(statfil,'\n');
        end
        fprintf(statfil,'\n%s%s%s \n','*******Fit Summary*******');
        fprintf(statfil,'\n');
        fprintf(statfil,'%-10s  ','Frequency');
        fprintf(statfil,'\n');
        fprintf(statfil,'%-10s  ','Frequency');
        fprintf(statfil,'%-10s  %-9s%-1.1i  %-10s  %-9s%-1.1i  %-10s  ','Exp. Ampl','Fit. Ampl');
        fprintf(statfil,'\n');
        for k=1:fitsize(1)
            fprintf(statfil,'%-10.5f  ',NmrData.ILTdata.freqs(k));
            fprintf(statfil,'%-10.5f  ',NmrData.ILTdata.ORIGINAL(k,1));
            fprintf(statfil,'%-10.5f  ',NmrData.ILTdata.FITTED(k,1));
            fprintf(statfil,'\n');
        end
        fprintf(statfil,'\n%s\n%s\n','This information can be found in:',[DTpath 'dosystats.txt']);
        fclose(statfil);
        
        guidata(hMainFigure,NmrData)
    end
%----ICA-------
    function ICAButton_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        APVisibleOff();
        set(hICAButton,'ForegroundColor',[1 0 1])
        set(hICAButton,'Fontweight','bold')
        set(hProcessButton,'Visible','On')
        %set(hReplotButton,'Visible','On')
        set(hEditNcomp,'Visible','On')
        set(hTextNcomp,'Visible','On')
        set(hTextProcess,'Visible','On')
        set(hTextExclude,'Visible','On')
        set(hExcludeShow,'Visible','On')
        set(hClearExcludeButton,'Visible','On')
        set(hSetExcludeButton,'Visible','On')
        set(hEditNgrad,'Visible','On')
        set(hTextNgrad,'Visible','On')
        set(hNgradUse,'Visible','On')
        set(hThresholdButton,'Visible','On')
        set(hProcessButton,'Callback',@doICA)
        %set(hReplotButton,'Callback',@plotdecra)
        guidata(hMainFigure,NmrData);
    end
    function doICA(source,eventdata)
        NmrData=guidata(hMainFigure);
        NmrData.pfgnmrdata=PreparePfgnmr3Ddata();
        
        NmrData.ncomp=str2double(get(hEditNcomp,'String'));
        guidata(hMainFigure,NmrData);
        pfgnmrdata=NmrData.pfgnmrdata;
        speclim=xlim();
        if speclim(1)<NmrData.sp
            speclim(1)=NmrData.sp;
        end
        if speclim(2)>(NmrData.sw+NmrData.sp)
            speclim(2)=(NmrData.sw+NmrData.sp);
        end
        Specrange=speclim;
        if length(Specrange)~=2
            error('SCORE: Specrange should have excatly 2 elements')
        end
        if Specrange(1)<pfgnmrdata.sp
            disp('SCORE: Specrange(1) is too low. The minumum will be used')
            Specrange(1)=pfgnmrdata.sp;
        end
        if Specrange(2)>(pfgnmrdata.wp+pfgnmrdata.sp)
            disp('SCORE: Specrange(2) is too high. The maximum will be used')
            Specrange(2)=pfgnmrdata.wp+pfgnmrdata.sp;
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
        pfgnmrdata.SPECTRA=pfgnmrdata.SPECTRA(begin:endrange,:,:);
        pfgnmrdata.np=length(pfgnmrdata.Ppmscale) ;

        NMRData.icadata=ica_mn(pfgnmrdata,NmrData.ncomp);

        guidata(hMainFigure,NmrData);
    end
%----More-----
    function MoreButton_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        APVisibleOff();
        if strcmpi(get(hDOSYButton,'Visible'),'on')
            % Toggle button is pressed-take approperiate action
            set(hDOSYButton,'Visible','Off')
            set(hDECRAButton,'Visible','Off')
            set(hMCRButton,'Visible','Off')
            set(hSCOREButton,'Visible','Off')
            set(hFDMRRTButton,'Visible','Off')
            set(hLRDOSYButton,'Visible','Off')
            set(hPARAFACButton,'Visible','Off')
            set(hILTButton,'Visible','Off')
            set(hICAButton,'Visible','Off')
            set(hBINButton,'Visible','On')
            set(hicoshiftButton,'Visible','On')
            set(hINTEGRALButton,'Visible','On')
            set(hAnalyzeButton,'Visible','On')
            set(hPSButton,'Visible','On')
            set(hPSButton,'Enable','On')
            set(hSynthesiseButton,'Visible','On') %AC
            set(hTestingButton,'Visible','Off')
            set(hROLSYButton,'Visible','Off')
            set(hRSCOREButton,'Visible','Off')
            set(hT1Button,'Visible','On')
            set(hAlignButton,'Visible','On')
            if strcmp(NmrData.local,'yes')
                set(hBaselineButton,'Visible','On')                  
            end
        elseif strcmpi(get(hAnalyzeButton,'Visible'),'on')
            % Toggle button is not pressed-take appropriate action
           
            set(hBINButton,'Visible','Off')
            set(hicoshiftButton,'Visible','Off')
            set(hINTEGRALButton,'Visible','Off')
            set(hBaselineButton,'Visible','Off')
            set(hAnalyzeButton,'Visible','Off')
            set(hT1Button,'Visible','Off')
            set(hPSButton,'Visible','Off')
            set(hPSButton,'Enable','Off')
            set(hPSButton,'ForegroundColor',[1 0 1])
            set(hPSButton,'Fontweight','bold')
            set(hSynthesiseButton,'Visible','Off') %AC
            set(hAlignButton,'Visible','Off')
            if strcmp(NmrData.local,'yes')
                set(hROLSYButton,'Visible','On')
                set(hRSCOREButton,'Visible','On')
                set(hTestingButton,'Visible','On')
            end
        else
            set(hDOSYButton,'Visible','On')
            set(hDECRAButton,'Visible','On')
            set(hMCRButton,'Visible','On')
            set(hSCOREButton,'Visible','On')
            set(hLRDOSYButton,'Visible','On')
            set(hPARAFACButton,'Visible','On')            
            set(hILTButton,'Visible','On')
              set(hFDMRRTButton,'Visible','On')
            if strcmp(NmrData.local,'yes')
                set(hICAButton,'Visible','On')                
            end
            set(hTestingButton,'Visible','Off')
            set(hROLSYButton,'Visible','Off')
            set(hRSCOREButton,'Visible','Off')
         end
        guidata(hMainFigure,NmrData);
    end
%----Pure shift-----------------------
    function PSButton_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        APVisibleOff();
        
        set(hButtonPureshiftConvert,'Visible','On')
        set(hEditnfid,'Visible','On')
        set(hTextnfid,'Visible','On')
        set(hEditnpoints,'Visible','On')
        set(hTextnpoint,'Visible','On')
        set(hEditnfirstfidpoints,'Visible','On')
        set(hTextnfirstfidpoints,'Visible','On')
        set(hEditDropPoints,'Visible','On')
        set(hTextDropPoints,'Visible','On')
        set(hButtonUnConvertPK,'Visible','On')
        set(hButtonPureshiftConvertPK,'Visible','On')
        set(hPSButton,'ForegroundColor',[1 0 1])
        set(hPSButton,'Fontweight','bold')
        if isfield(NmrData,'droppts')
            droppts=NmrData.droppts;
        else
            droppts=0;
        end
        if isfield(NmrData,'nchunk')
            sw1=NmrData.sw*2/NmrData.nchunk;
        else
            sw1=NmrData.sw1;
            %sw1=str2double(psdata.acqu2s.SW)*NmrData.sfrq;
        end
        sw=NmrData.sw*NmrData.sfrq;
        sw1=sw1*NmrData.sfrq;
        npoint=round(sw/sw1);
        %firstfidpoint=round(npoint/2);
        firstfidpoint=npoint;
        nfid=NmrData.arraydim/NmrData.ngrad;
        set(hEditnfid,'string',num2str(nfid));
        set(hEditnpoints,'string',num2str(npoint));
        set(hEditnfirstfidpoints,'string',num2str(firstfidpoint));
        set(hEditDropPoints,'string',num2str(droppts));
        guidata(hMainFigure,NmrData);
    end
    function PureshiftConvertZS_Callback( eventdata, handles)
        psdata=guidata(hMainFigure);
        tmp=NmrData;
        nfid= str2double(get(hEditnfid,'string'));
        npoint= str2double(get(hEditnpoints,'string'));
        firstfidpoint=str2double(get(hEditnfirstfidpoints,'string'));
        droppts=str2double(get(hEditDropPoints,'string'));
        
        if ~isempty(psdata)
            Initiate_NmrData();
            NmrData.type=psdata.type;
            NmrData.lrfid=psdata.lrfid;
            NmrData.sfrq=psdata.sfrq;
            NmrData.FID=psdata.FID;
            NmrData.filename=psdata.filename;
            NmrData.dosyconstant=psdata.dosyconstant;
            NmrData.Gzlvl=psdata.Gzlvl;
            NmrData.ngrad=psdata.ngrad;
            if (isfield(psdata,'acqus'))
                NmrData.acqus=psdata.acqus;
            end
            if (isfield(psdata,'acqus2'))
                NmrData.acqus=psdata.acqus2;
            end
            if (isfield(psdata,'procpar'))
                NmrData.procpar=psdata.procpar;
            end
            NmrData.np=psdata.np;
            NmrData.fn=NmrData.np;
            NmrData.sw=psdata.sw;
            NmrData.at=psdata.at;
            NmrData.sp=psdata.sp;
            NmrData.lp=0;
            NmrData.rp=0;
            NmrData.gamma=psdata.gamma;
            NmrData.DELTA=psdata.DELTA;
            NmrData.delta=psdata.delta;
            if (isfield(psdata,'arraydim'))
                NmrData.arraydim=psdata.arraydim;
            else
                NmrData.arraydim=NmrData.ngrad;
            end
            
            % droppts
            %leftshift the fid
            if NmrData.lrfid>0
                %left shift the fid
                for k=1:NmrData.arraydim
                    NmrData.FID(:,k)= circshift(NmrData.FID(:,k),-NmrData.lrfid);
                end
                NmrData.lrfid=0;
            end
            
            % firstfidpoint
            FID=zeros(NmrData.ncomp,npoint*nfid-firstfidpoint);
            size(FID)
            size(NmrData.FID)
            for ngzlv=1:NmrData.ngrad
                FID(ngzlv,1:firstfidpoint)=NmrData.FID(droppts+1:firstfidpoint+droppts,ngzlv);
                for k=2:nfid;
                    %Tva=(ngzlv-1)*NmrData.ngrad + ngzlv +k
                    FID(ngzlv,firstfidpoint+(k-2)*npoint+1:firstfidpoint+(k-1)*npoint)=NmrData.FID(droppts+1:npoint+droppts,ngzlv + NmrData.ngrad*(k-1));
                end
            end
            NmrData.FID=complex(imag(FID),real(FID))';
            NmrData.arraydim=NmrData.ngrad;
            NmrData.np=length(NmrData.FID);
            NmrData.rp=0;
            NmrData.lp=0;
            clear psdata;
            guidata(hMainFigure,NmrData);
            figure(hMainFigure)
            Setup_NmrData();
        else
            %do nothing
        end
        NmrData.orig=tmp;
        guidata(hMainFigure,NmrData);
    end
    function UnConvertPK_Callback( eventdata, handles)
        NmrData=NmrData.orig;
        guidata(hMainFigure,NmrData);
        Setup_NmrData();
    end
    function PureshiftConvertPK_Callback( eventdata, handles)
        psdata=guidata(hMainFigure);
        nfid= str2double(get(hEditnfid,'string'));
        npoint= str2double(get(hEditnpoints,'string'));
        firstfidpoint=str2double(get(hEditnfirstfidpoints,'string'));
        droppts=str2double(get(hEditDropPoints,'string'));
        if nfid>(NmrData.arraydim/NmrData.ngrad)/2
            string=['For PK processing nFID should probably be less than ' num2str((NmrData.arraydim/NmrData.ngrad)/2)];
            choice=questdlg(string,...
                'tmp',...
                'Continue','Cancel','Cancel');
            switch choice
                case 'Continue'
                    %do Nothing just carry on
                case 'Cancel'
                    return
            end
        end
        
        if ~isempty(psdata)
            
            % save original data
            tmp=NmrData;
            guidata(hMainFigure,NmrData);
            Initiate_NmrData();
            NmrData.type=psdata.type;
            NmrData.lrfid=psdata.lrfid;
            NmrData.sfrq=psdata.sfrq;
            NmrData.FID=psdata.FID;
            NmrData.filename=psdata.filename;
            NmrData.dosyconstant=psdata.dosyconstant;
            NmrData.Gzlvl=psdata.Gzlvl;
            NmrData.ngrad=psdata.ngrad;
            if (isfield(psdata,'acqus'))
                NmrData.acqus=psdata.acqus;
            end
            if (isfield(psdata,'acqus2'))
                NmrData.acqus=psdata.acqus2;
            end
            if (isfield(psdata,'procpar'))
                NmrData.procpar=psdata.procpar;
            end
            NmrData.np=psdata.np;
            NmrData.fn=NmrData.np;
            NmrData.sw=psdata.sw;
            NmrData.at=psdata.at;
            NmrData.sp=psdata.sp;
            NmrData.lp=0;
            NmrData.rp=0;
            NmrData.gamma=psdata.gamma;
            NmrData.DELTA=psdata.DELTA;
            NmrData.delta=psdata.delta;
            if (isfield(psdata,'arraydim'))
                NmrData.arraydim=psdata.arraydim;
            else
                NmrData.arraydim=NmrData.ngrad;
            end
            
            % droppts
            %leftshift the fid
            if NmrData.lrfid>0
                %left shift the fid
                for k=1:NmrData.arraydim
                    NmrData.FID(:,k)= circshift(NmrData.FID(:,k),-NmrData.lrfid);
                end
                NmrData.lrfid=0;
            end
            % firstfidpoint
            FID=zeros(NmrData.ncomp,npoint*nfid-firstfidpoint);
            
            
            
            %alternating FIDs starting with 2
            for ngzlv=1:NmrData.ngrad
                for k=1:nfid;
                    
                    % FID(1,firstfidpoint+(k-2)*npoint+1:firstfidpoint+(k-1)*npoint)=NmrData.FID(firstfidpoint+(k-2)*npoint+1:firstfidpoint+(k-1)*npoint,2*k);
                    %                                 FID(ngzlv,firstfidpoint+(k-2)*npoint+1:firstfidpoint+(k-1)*npoint)=...
                    %                                     NmrData.FID(firstfidpoint+(k-2)*npoin
                    %                                     t+1:firstfidpoint+(k-1)*npoint,ngzlv)
                    %                                     ;
                    
                    
                    % FID(ngzlv,firstfidpoint+(k-2)*npoint+1:firstfidpoint+(k-1)*npoint)=...
                    %     NmrData.FID(firstfidpoint+(k-2)*npoint+1:firstfidpoint+(k-1)*npoint,(NmrData.arraydim/NmrData.ngrad)*(ngzlv-1) + 2*k);
                    
                    
                    FID(ngzlv,firstfidpoint+(k-2)*npoint+1:firstfidpoint+(k-1)*npoint)=...
                        NmrData.FID(firstfidpoint+(k-2)*npoint+1:firstfidpoint+(k-1)*npoint,NmrData.ngrad+1 +NmrData.ngrad*2*(k-1) +ngzlv-1);
                end
            end
            
            
            
            
            
            
            
            NmrData.FID=complex(imag(FID),real(FID))';
            NmrData.arraydim=NmrData.ngrad;
            NmrData.np=length(FID);
            NmrData.rp=0;
            NmrData.lp=0;
            clear psdata;
            NmrData.orig=tmp;
            guidata(hMainFigure,NmrData);
            figure(hMainFigure)
            Setup_NmrData();
        else
            %do nothing
        end
        guidata(hMainFigure,NmrData);
    end
    function Editnfid_Callback( eventdata, handles)
        NmrData=guidata(hMainFigure);
        nfid=round(str2double(get(hEditnfid,'string')));
        set(hEditnfid,'string',num2str(nfid));
        guidata(hMainFigure,NmrData);
    end
    function Editnpoints_Callback( eventdata, handles)
        NmrData=guidata(hMainFigure);
        npoint=round(str2double(get(hEditnpoints,'string')));
        set(hEditnpoints,'string',num2str(npoint));
        guidata(hMainFigure,NmrData);
    end
    function Editfirstfidpoints_Callback( eventdata, handles)
        NmrData=guidata(hMainFigure);
        firstfidpoint=round(str2double(get(hEditnfirstfidpoints,'string')));
        set(hEditnfirstfidpoints,'string',num2str(firstfidpoint));
        guidata(hMainFigure,NmrData);
    end
    function EditDropPoints_Callback( eventdata, handles)
        NmrData=guidata(hMainFigure);
        droppts=round(str2double(get(hEditDropPoints,'string')));
        set(hEditDropPoints,'string',num2str(droppts));
        guidata(hMainFigure,NmrData);
    end
%----Synthesise DOSY------------------
    function SynthesiseButton_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        APVisibleOff();
        set(hSynthesiseButton,'ForegroundColor',[1 0 1])
        set(hSynthesiseButton,'Fontweight','bold')
        set(hRandomDOSYButton,'Visible','On')
        set(hTextsw,'Visible','On')
        set(hEditsw,'Visible','On')
        set(hTextnp,'Visible','On')
        set(hEditnp,'Visible','On')
        set(hTextmingrad,'Visible','On')
        set(hEditmingrad,'Visible','On')
        set(hTextmaxgrad,'Visible','On')
        set(hEditmaxgrad,'Visible','On')
        set(hTextni,'Visible','On')
        set(hEditni,'Visible','On')
        set(hTextSynthParam,'Visible','On')
        set(hTextSynthGenDOSY,'Visible','On')
        set(hUpdateSynthButton,'Visible','On')
        set(hTextnpeaks,'Visible','On')
        set(hEditnpeaks,'Visible','On')
        set(hTextnoise,'Visible','On')
        set(hEditnoise,'Visible','On')
        set(hTableSynthPeaks,'Visible','On')
        set(hText3Dplot,'Visible','On')
        set(hCheck3Dplot,'Visible','On')
        set(hTextUseNUG,'Visible','On')
        set(hCheckUseNUG,'Visible','On')
        set(hUpdateTableButton,'Visible','On')
        
    end
    function RandomDOSYButton_Callback(source,eventdata)
    NmrData=guidata(hMainFigure);
    
        % read parameters
        SynthData.sw=str2num(get(hEditsw,'string'));
        SynthData.np=str2num(get(hEditnp,'string'));
        SynthData.mingrad=str2num(get(hEditmingrad,'string'));
        SynthData.maxgrad=str2num(get(hEditmaxgrad,'string'));
        SynthData.ni=str2num(get(hEditni,'string'));
        SynthData.npeaks=str2num(get(hEditnpeaks,'string'));
        SynthData.noise=str2num(get(hEditnoise,'string'));
        SynthData.meshplot=get(hCheck3Dplot,'Value');
        SynthData.multiplicity=ones(1,SynthData.npeaks);
        SynthData.lw=ones(1,SynthData.npeaks);
        SynthData.Amps=ones(1,SynthData.npeaks);
        if get(hCheckUseNUG,'value')==1
            SynthData.NUGs=NmrData.nug;
        else
            SynthData.NUGs=0;
        end
        RandSynthData=SyntheticDOSY(SynthData);
        
        NmrData.RandSynthData=RandSynthData;
        
        set(0,'CurrentFigure',hMainFigure)
        % Clear the current data structure
        Initiate_NmrData();
        
        % Copy in the relevant synthesised bits
        NmrData.FID=RandSynthData.FIDs;
        NmrData.sw=RandSynthData.sw;
        NmrData.np=RandSynthData.np;
        NmrData.fn=RandSynthData.np;
        NmrData.ngrad=RandSynthData.ngrad;
        NmrData.arraydim=RandSynthData.ngrad;
        NmrData.at=RandSynthData.at;
        NmrData.gamma=RandSynthData.gamma;
        NmrData.DELTA=RandSynthData.DELTA;
        NmrData.delta=RandSynthData.delta;
        NmrData.Gzlvl=RandSynthData.gradlvl;
        NmrData.dosyconstant=RandSynthData.dosyconstant;
        NmrData.issynthetic=1;
        NmrData.filename='SyntheticDOSY';
        NmrData.sp=-0.5*RandSynthData.sw;
        NmrData.lp=0;
        NmrData.rp=0;
        NmrData.sfrq=RandSynthData.sfrq;
        
        % Generate data structure and update table
        TableData(:,1)=RandSynthData.Freqs;
        TableData(:,2)=RandSynthData.Dvals*1e10;
        TableData(:,3)=RandSynthData.Amps;
        TableData(:,4)=SynthData.lw;
        TableData(:,5)=SynthData.multiplicity;
                        
        set(hTableSynthPeaks,'Data',TableData)
        
    guidata(hMainFigure,NmrData);
    figure(hMainFigure)
    Setup_NmrData()
    % calcRMSnoise(NmrData.SPECTRA,NmrData.Specscale)

    PlotSpectrum()
    end
    function UpdateSynthButton_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        % read parameters
        SynthData.sw=str2num(get(hEditsw,'string'));
        SynthData.np=str2num(get(hEditnp,'string'));
        SynthData.mingrad=str2num(get(hEditmingrad,'string'));
        SynthData.maxgrad=str2num(get(hEditmaxgrad,'string'));
        SynthData.ni=str2num(get(hEditni,'string'));
        SynthData.npeaks=str2num(get(hEditnpeaks,'string'));
        SynthData.noise=str2num(get(hEditnoise,'string'));
        SynthData.meshplot=get(hCheck3Dplot,'Value');
        if get(hCheckUseNUG,'value')==true
            SynthData.NUGs=NmrData.nug;
            SynthData.probename=NmrData.probename;
            SynthData.nugcal=NmrData.gcal;
        else
            SynthData.NUGs=0;
            SynthData.probename='';
            SynthData.nugcal=0;
        end
        
        % Get table data
        SynthTableData=get(hTableSynthPeaks,'Data');
        SynthData.Freqs=SynthTableData(:,1);
        SynthData.Dvals=SynthTableData(:,2);
        SynthData.Amps=SynthTableData(:,3);
        SynthData.lw=SynthTableData(:,4);
        SynthData.multiplicity=SynthTableData(:,5);
        
        RandSynthData=SyntheticDOSY(SynthData);
        
        NmrData.RandSynthData=RandSynthData;
        
        set(0,'CurrentFigure',hMainFigure)
        
        % Clear the current data structure
        Initiate_NmrData();
        
        % Copy in the relevant synthesised bits
        % NmrData.SPECTRA=RandSynthData.SPECTRA;
        NmrData.FID=RandSynthData.FIDs;
        NmrData.sw=RandSynthData.sw;
        NmrData.np=RandSynthData.np;
        NmrData.fn=RandSynthData.np;
        NmrData.ngrad=RandSynthData.ngrad;
        NmrData.arraydim=RandSynthData.ngrad;
        NmrData.at=RandSynthData.at;
        NmrData.gamma=RandSynthData.gamma;
        NmrData.DELTA=RandSynthData.DELTA;
        NmrData.delta=RandSynthData.delta;
        NmrData.Gzlvl=RandSynthData.gradlvl;
        NmrData.dosyconstant=RandSynthData.dosyconstant;
        NmrData.issynthetic=1;
        NmrData.filename='SyntheticDOSY';
        NmrData.sp=-0.5*RandSynthData.sw;
        NmrData.lp=0;
        NmrData.rp=0;
        NmrData.sfrq=RandSynthData.sfrq;
        NmrData.nug= SynthData.NUGs;
        NmrData.probename=SynthData.probename;
        NmrData.gcal=SynthData.nugcal;
        
        % Generate data structure and update table
        TableData(:,1)=RandSynthData.Freqs;
        TableData(:,2)=RandSynthData.Dvals*1e10;
        TableData(:,3)=RandSynthData.Amps;
        TableData(:,4)=SynthData.lw;
        TableData(:,5)=SynthData.multiplicity;
        
        set(hTableSynthPeaks,'Data',TableData)
        
        guidata(hMainFigure,NmrData);
        
        Setup_NmrData()
        
        % plot
        PlotSpectrum()
    end
    function UpdateTableButton_Callback(source,eventdata)
        SynthTableData=get(hTableSynthPeaks,'Data');
        if str2num(get(hEditnpeaks,'string')) > length(SynthTableData(:,1))
            diff=str2num(get(hEditnpeaks,'string'))-length(SynthTableData(:,1));
            SynthTableData(end+1:end+diff,1:5)=repmat([0 1 1 1 1]',1,diff)';
        elseif  str2num(get(hEditnpeaks,'string')) < length(SynthTableData(:,1))
            diff=abs(str2num(get(hEditnpeaks,'string'))-length(SynthTableData(:,1)));
            SynthTableData=SynthTableData(1:end-diff,:);
        else
            %the table is the right size
        end
        set(hTableSynthPeaks,'Data',SynthTableData)
    end
%----Align spectra ------------------
    function AlignButton_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        APVisibleOff();
        set(hAlignButton,'ForegroundColor',[1 0 1])
        set(hAlignButton,'Fontweight','bold')
        set(hAlignPanel,'Visible','On')
        set(hThresholdButton,'Visible','On') 
        if isempty(NmrData.fshift)
        else
            set(hEditShift,'String',num2str(NmrData.fshift(NmrData.flipnr)));
        end
        
        
     end
    function AutoAlignButton_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        analyzedata=PrepareAnalyzeData();
%         analyzedata.Ppmscale(1)
%         analyzedata.Ppmscale(end)
        FS=1;
         hp=waitbar(0,'Finding frequencies');
        for p=NmrData.flipnr:(NmrData.arraydim-NmrData.flipnr)
            waitbar(p/(NmrData.arraydim-NmrData.flipnr+1));
            th=100*NmrData.thresydata(1)/max(real(analyzedata.SPECTRA(:,p)));
            [peaks]=peakpick_mn(real(analyzedata.SPECTRA(:,p)),th);
            
            if isempty(peaks)
                %do nothing                
            else
                amp=real(analyzedata.SPECTRA(peaks(1).max,p));
                ampmax=1;
                for k=1:length(peaks)
                    testamp=analyzedata.SPECTRA(peaks(k).max,p);
                    if testamp>amp
                        ampmax=k;
                    end
                end
                %size(analyzedata.Ppmscale)
                switch NmrData.shiftunits
                    case 'ppm'                    
                        NmrData.fshift(p)=analyzedata.Ppmscale(peaks(ampmax).max)*NmrData.sfrq;
                    case 'Hz'                        
                        NmrData.fshift(p)=analyzedata.Ppmscale(peaks(ampmax).max);
                    otherwise
                        error('illegal choice')
                end
                if FS==1
                    FirstSPec=NmrData.fshift(p);
                    FS=0;
                end
                NmrData.fshift(p)=NmrData.fshift(p)-FirstSPec;
            end
        end
        
       % NmrData.fshift=NmrData.fshift/2;
       
        close(hp)
        
        guidata(hMainFigure,NmrData);
    end
    function ZeroAlignButton_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        NmrData.fshift=zeros(1,NmrData.arraydim);
        set(hSliderShift,'value',NmrData.fshift(NmrData.flipnr));
        guidata(hMainFigure,NmrData);
        set(hEditShift,'String',num2str(NmrData.fshift(NmrData.flipnr)));
         msgbox('Align shifts cleared')
    end
%     function ApplyAlignButton_Callback(source,eventdata)
%         FTButton_Callback();
%     end

    function EditLinear_Callback(source,eventdata)
        
        
    end

%     function LinearAlignButton_Callback(source,eventdata)
%         NmrData=guidata(hMainFigure);
%         get(hEditLinear,'String')
%         linStep=str2double(get(hEditLinear,'String'));
%         linarray=linspace(0,linStep*(NmrData.arraydim-1),NmrData.arraydim);      
%         NmrData.fshift=NmrData.fshift+linarray;
%         guidata(hMainFigure,NmrData);        
%         set(hSliderShift,'value',NmrData.fshift(NmrData.flipnr));
%         set(hEditShift,'String',num2str(NmrData.fshift(NmrData.flipnr)));      
%     end

    function EditShift_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        NmrData.fshift(NmrData.flipnr)=str2double(get(hEditShift,'String'));
        set(hSliderShift,'value',NmrData.fshift(NmrData.flipnr));
        guidata(hMainFigure,NmrData);
        if get(hCheckAutoApply,'Value')
            if get(hCheckApplyFT,'Value')                
                FTButton_Callback();
            else
                set(hCheckApplyFT,'Value',1)
                FTButton_Callback();
                set(hCheckApplyFT,'Value',0)
                
            end
        end
    end

    function ButtonPlusShift_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        NmrData.fshift(NmrData.flipnr)= NmrData.fshift(NmrData.flipnr)+0.1;
        set(hEditShift,'String',num2str(NmrData.fshift(NmrData.flipnr)));
        guidata(hMainFigure,NmrData);
        set(hSliderShift,'value',NmrData.fshift(NmrData.flipnr));
        if get(hCheckAutoApply,'Value')
            FTButton_Callback();
        end
    end

    function ButtonMinusShift_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        NmrData.fshift(NmrData.flipnr)= NmrData.fshift(NmrData.flipnr)-0.1;
        set(hEditShift,'String',num2str(NmrData.fshift(NmrData.flipnr)));
        guidata(hMainFigure,NmrData);
        set(hSliderShift,'value',NmrData.fshift(NmrData.flipnr));
        if get(hCheckAutoApply,'Value')
            FTButton_Callback();
        end
    end
    function SliderShift_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        NmrData.fshift(NmrData.flipnr)=get(hSliderShift,'value');
        guidata(hMainFigure,NmrData);
        set(hEditShift,'String',num2str(NmrData.fshift(NmrData.flipnr)));
        if get(hCheckAutoApply,'Value')
            FTButton_Callback();
        end
        
    end
    function ButtonPlusShift2_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        NmrData.fshift(NmrData.flipnr)= NmrData.fshift(NmrData.flipnr)+0.01;
        set(hEditShift,'String',num2str(NmrData.fshift(NmrData.flipnr)));
        guidata(hMainFigure,NmrData);
        set(hSliderShift,'value',NmrData.fshift(NmrData.flipnr));
        if get(hCheckAutoApply,'Value')
            FTButton_Callback();
        end
        
    end
    function ButtonMinusShift2_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        NmrData.fshift(NmrData.flipnr)= NmrData.fshift(NmrData.flipnr)-0.01;
        set(hEditShift,'String',num2str(NmrData.fshift(NmrData.flipnr)));
        guidata(hMainFigure,NmrData);
        set(hSliderShift,'value',NmrData.fshift(NmrData.flipnr));
        if get(hCheckAutoApply,'Value')
            FTButton_Callback();
        end
    end
    function CheckAutoApply_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        
        guidata(hMainFigure,NmrData);
    end



%----RSCORE ------------------
    function RSCOREButton_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        APVisibleOff();
         set(hRSCOREButton,'ForegroundColor',[1 0 1])
        set(hRSCOREButton,'Fontweight','bold')
        set(hProcessButton,'Visible','On')
        set(hReplotButton,'Visible','On')
        set(hPubplotButton,'Visible','On')
        set(hReplotButton,'Callback',@plotrscore)
        set(hPubplotButton,'Callback',@pubplotrscore)
         set(hEditNcomp,'Visible','On')
        set(hTextNcomp,'Visible','On')
        set(hBGroupSCOREOpt1,'Visible','On')
        set(hRadio1SCOREOpt1,'String','T2 (2 params)')
        set(hRadio2SCOREOpt1,'String','T1 (3 params)')
         set(hTextExclude,'Visible','On')
        set(hExcludeShow,'Visible','On')
        set(hBGroupSCOREOpt2,'Visible','On')
        set(hBGroupSCOREOpt2,'Title','T guess')
        set(hBGroupSCOREOpt3,'Visible','On')
           set(hClearExcludeButton,'Visible','On')
        set(hSetExcludeButton,'Visible','On')
        set(hEditNgrad,'Visible','On')
        set(hTextNgrad,'Visible','On')
        set(hNgradUse,'Visible','On')
        set(hBGroupSCOREOpt6,'Visible','On') 
        set(hProcessButton,'Callback',@doRSCORE)
        
    end
    function doRSCORE(source,eventdata)
        NmrData=guidata(hMainFigure);
        NmrData.pfgnmrdata=PreparePfgnmrdata();
        NmrData.RSCOREopts=[0 0 0 0 0 0];
        switch get(hBGroupSCOREOpt1,'SelectedObject')
            case hRadio1SCOREOpt1
                NmrData.RSCOREopts(3)=0;
            case hRadio2SCOREOpt1
                NmrData.RSCOREopts(3)=1;
            otherwise
                error('illegal choice')
        end
        switch get(hBGroupSCOREOpt2,'SelectedObject')
            case hRadio1SCOREOpt2
                NmrData.RSCOREopts(1)=0;
            case hRadio2SCOREOpt2
                NmrData.RSCOREopts(1)=1;
            otherwise
                error('illegal choice')
        end
        switch get(hBGroupSCOREOpt3,'SelectedObject')
            case hRadio1SCOREOpt3
                NmrData.RSCOREopts(2)=0;
            case hRadio2SCOREOpt3
                NmrData.RSCOREopts(2)=1;
            case hRadio4SCOREOpt3
                NmrData.RSCOREopts(2)=3;
            otherwise
                error('illegal choice')
        end
        switch get(hBGroupSCOREOpt6,'SelectedObject')
            case hRadio1SCOREOpt6
                NmrData.RSCOREopts(6)=0;
            case hRadio2SCOREOpt6
                NmrData.RSCOREopts(6)=1;
            otherwise
                error('illegal choice')
        end
        
        speclim=xlim();
        if speclim(1)<NmrData.sp
            speclim(1)=NmrData.sp;
        end
        if speclim(2)>(NmrData.sw+NmrData.sp)
            speclim(2)=(NmrData.sw+NmrData.sp);
        end
        
        NmrData.ncomp=str2double(get(hEditNcomp,'String'));
        
        [rscoredata]=rscore_mn(NmrData.pfgnmrdata, NmrData.ncomp, speclim,NmrData.RSCOREopts);
        guidata(hMainFigure,NmrData);
    end












%----ROLSY ------------------
    function ROLSYButton_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        APVisibleOff();
        set(hROLSYButton,'ForegroundColor',[1 0 1])
        set(hROLSYButton,'Fontweight','bold')
        set(hProcessButton,'Visible','On')
        set(hThresholdButton,'Visible','On')
        
        
        set(hProcessButton,'Callback',@doROLSY)
        
    end
    function doROLSY(source,eventdata)
        NmrData=guidata(hMainFigure);
        NmrData.pfgnmrdata=PreparePfgnmrdata();
        [rolsydata]=rolsy_mn(NmrData.pfgnmrdata);
        guidata(hMainFigure,NmrData);
    end
%---Testing
    function TestingButton_Callback(source,eventdata)
        NmrData=guidata(hMainFigure);
        APVisibleOff();
        set(hTestingButton,'ForegroundColor',[1 0 1])
        set(hTestingButton,'Fontweight','bold')
        set(hProcessButton,'Visible','On')
        set(hProcessButton,'Callback',@DoTesting)
        
    end
    function DoTesting(source,eventdata)
        %Prepare the data for Testing analysis
        
        NmrData=guidata(hMainFigure);
        
        NmrData.pfgnmrdata=PreparePfgnmr3Ddata();
        
        %Do your analysis in a separate m-file
        
        guidata(hMainFigure,NmrData)
    end
%% Utility functions
    function PeakWidth=EstimatePeakshape(Spec,MaxPoint)
        
        if MaxPoint==0
            [~, MaxPoint]=max(Spec);
        end        
        IntFac=16;
        SearchPoints=16;
        if MaxPoint<SearchPoints
            SearchPoints=MaxPoint-1;
        elseif length(Spec)-MaxPoint<SearchPoints
            SearchPoints=length(Spec)-MaxPoint-1;
        else
            SearchPoints=16;
        end
        IntSpec=interpft(Spec,IntFac*length(Spec)+2);
        [MaxPointIntAmp, MaxPointInt]=max(IntSpec(IntFac*(MaxPoint-SearchPoints):IntFac*(MaxPoint+SearchPoints)));
        MaxPointInt=IntFac*(MaxPoint-SearchPoints) + MaxPointInt -1;
        
        for k=1:length(IntSpec(MaxPointInt:end))
            IntSpec(MaxPointInt+k);
            if IntSpec(MaxPointInt+k)<MaxPointIntAmp/2
                break
            end
            
        end
        RightPoint=k;
        
        for k=1:length(IntSpec(1:MaxPointInt))
            IntSpec(MaxPointInt-k);
            if IntSpec(MaxPointInt-k)<MaxPointIntAmp/2
                break
            end
        end
        LeftPoint=k;
        PeakWidth=(((RightPoint+LeftPoint)/NmrData.fn)*(NmrData.sw*NmrData.sfrq))/IntFac;
    end
    function Baseline_function(source,eventdata)
        NmrData=guidata(hMainFigure);
        if isempty(get(hMainFigure,'WindowButtonDownFcn'))
            %we only update the parameters
        else
            switch get(gcbf, 'SelectionType')
                case 'normal'
                    %leftclick
                    %add a new point
                    pt=get(gca,'currentpoint');
                    xpos=pt(1,1);
                    ypos=pt(2,2);
                    xl=xlim();
                    yl=ylim();
                    if xpos>xl(2) || xpos<xl(1) || ypos>yl(2) || ypos<yl(1)
                        %outside axis
                    else
                        NmrData.BasePoints=[NmrData.BasePoints xpos];
                    end
                    
                case 'alt'
                    %disp('rightclick')
                    %remove last point
                    if ~isempty(NmrData.BasePoints>0)
                        NmrData.BasePoints(end)=[];
                    end
                case 'extend'
                    %middleclick
                    %Stop taking new points
                    set(hMainFigure,'WindowButtonDownFcn','')
                case 'open'
                    %doubleclick
                    %do nothing
                    
                otherwise
                    error('illegal choice')
            end
        end
        
        
        NmrData.baselinepoints=NmrData.BasePoints;
        NmrData.baselinepoints=unique(NmrData.baselinepoints);
        NmrData.baselinepoints=sort(NmrData.baselinepoints);
        %disp(num2str(NmrData.baselinepoints))
        NmrData.region=ones(1,NmrData.fn);
        bpoints=[1 NmrData.fn];
        for k=1:length(NmrData.baselinepoints)
            bpoints=[bpoints round(NmrData.fn*...
                (NmrData.baselinepoints(k)-NmrData.sp)/NmrData.sw)]; %#ok<AGROW>
        end
        bpoints=unique(bpoints);
        bpoints=sort(bpoints);
        bpoints1=bpoints(1:2:end);
        bpoints2=bpoints(2:2:end);
        for k=1:(length(bpoints1))
            if k<=length(bpoints2)
                NmrData.region(bpoints1(k):bpoints2(k))=NaN;
            end
        end
        if NmrData.plottype==0
            NmrData.xlim_fid=xlim();
            NmrData.ylim_fid=ylim();
        elseif NmrData.plottype==1
            NmrData.xlim_spec=xlim();
            NmrData.ylim_spec=ylim();
        else
            error('Illegal plot type')
        end
        guidata(hMainFigure,NmrData);
        PlotSpectrum();
        %set(hAxes,'ButtonDownFcn',@Baseline_function);
    end
    function Auto_Baseline_function(source,eventdata)
        NmrData=guidata(hMainFigure);
        disp('hi')
        guidata(hMainFigure,NmrData);
        %PlotSpectrum();
    end
    function Excludeline_function(source,eventdata)
        NmrData=guidata(hMainFigure);
        switch get(gcbf, 'SelectionType')
            case 'normal'
                %leftclick
                %add a new point
                pt=get(gca,'currentpoint');
                xpos=pt(1,1);
                ypos=pt(2,2);
                xl=xlim();
                yl=ylim();
                if xpos>xl(2) || xpos<xl(1) || ypos>yl(2) || ypos<yl(1)
                    %  disp('hi')
                    %outside axis
                else
                    NmrData.ExcludePoints=[NmrData.ExcludePoints xpos];
                end
                
            case 'alt'
                %disp('rightclick')
                %remove last point
                if ~isempty(NmrData.ExcludePoints>0)
                    NmrData.ExcludePoints(end)=[];
                end
            case 'extend'
                %middleclick
                %Stop taking new points
                set(hMainFigure,'WindowButtonDownFcn','')
            case 'open'
                %doubleclick
                %do nothing
                
            otherwise
                error('illegal choice')
        end
        NmrData.excludelinepoints=unique(NmrData.ExcludePoints);
        NmrData.excludelinepoints=sort(NmrData.excludelinepoints);
        %disp(num2str(NmrData.baselinepoints))
        NmrData.exclude=ones(1,NmrData.fn);
        expoints=[1 NmrData.fn];
        for k=1:length(NmrData.excludelinepoints)
            expoints=[expoints round(NmrData.fn*...
                (NmrData.excludelinepoints(k)-NmrData.sp)/NmrData.sw)]; %#ok<AGROW>
        end
        expoints=unique(expoints);
        expoints=sort(expoints);
        expoints1=expoints(1:2:end);
        expoints2=expoints(2:2:end);
        for k=1:(length(expoints1))
            if k<=length(expoints2)
                NmrData.exclude(expoints1(k):expoints2(k))=NaN;
            end
        end
        hExcludeline=findobj(hAxes,'tag','excludeline');
        delete(hExcludeline)
        guidata(hMainFigure,NmrData);
        PlotSpectrum();
        %DrawExcludeline();
        %set(hAxes,'ButtonDownFcn',@Excludeline_function);
        %set(hMainFigure,'WindowButtonDownFcn',@Excludeline_function);
    end
    function IntLine_function(source,eventdata)
        if isempty(get(hMainFigure,'WindowButtonDownFcn'))
            %we only update the parameters
        else
            switch get(gcbf, 'SelectionType')
                case 'normal'
                    %leftclick
                    %add a new point
                    pt=get(gca,'currentpoint');
                    xpos=pt(1,1);
                    ypos=pt(2,2);
                    xl=xlim();
                    yl=ylim();
                    if xpos>xl(2) || xpos<xl(1) || ypos>yl(2) || ypos<yl(1)
                        %  disp('hi')
                        %outside axis
                    else
                        NmrData.IntPoint=[NmrData.IntPoint xpos];
                    end
                    
                case 'alt'
                    %disp('rightclick')
                    %remove last point
                    if ~isempty(NmrData.IntPoint>0)
                        NmrData.IntPoint(end)=[];
                    end
                case 'extend'
                    %middleclick
                    %Stop taking new points
                    set(hMainFigure,'WindowButtonDownFcn','')
                case 'open'
                    %doubleclick
                    %do nothing
                otherwise
                    error('illegal choice')
            end
        end
        NmrData.IntPointSort=unique(NmrData.IntPoint);
        NmrData.IntPointSort=sort(NmrData.IntPointSort);
        IntPointIndex=[];
        for k=1:length(NmrData.IntPointSort)
            IntPointIndex=[IntPointIndex round(NmrData.fn*...
                (NmrData.IntPointSort(k)-NmrData.sp)/NmrData.sw)]; %#ok<AGROW>
        end
        IntPointIndex=unique(IntPointIndex);
        IntPointIndex=sort(IntPointIndex);
        if bitand(1,length(IntPointIndex)) %odd
            IntPointIndex=[1 IntPointIndex];
            NmrData.Integral=ones(1,NmrData.fn);
            for k=1:length(IntPointIndex)/2
                NmrData.Integral(IntPointIndex(2*k-1):IntPointIndex(2*k)+1)=NaN;
            end
        else %even
            NmrData.Integral=ones(1,NmrData.fn).*NaN;
            for k=1:length(IntPointIndex)/2
                
                NmrData.Integral((IntPointIndex(2*k-1)):(IntPointIndex(2*k)))=1;
                %NmrData.Integral(IntPointIndex(kk):IntPointIndex(kk+1))=NaN;
            end
        end;
        NmrData.IntPointIndex=IntPointIndex;
        guidata(hMainFigure,NmrData);
        PlotSpectrum();
    end
    function DrawIntLine(source,eventdata)
        NmrData=guidata(hMainFigure);
        hIntLine=findobj(hAxes,'tag','IntLine');
        delete(hIntLine);
        TmpIntegral=NmrData.Integral;
        if ~isempty(NmrData.IntPoint>0)
            tmp=real(NmrData.SPECTRA(:,NmrData.flipnr)).*NmrData.Integral(:);
            t_indx=isnan(tmp);
            tmp(t_indx)=0;
            tmp2=cumsum(tmp);
            NmrData.Integral=tmp2/tmp2(end);
            NmrData.Integral(t_indx)=NaN;
        else
            tmp=real(NmrData.SPECTRA(:,NmrData.flipnr));
            NmrData.Integral=cumsum(tmp);
        end
        
        ypos=get(hAxes,'ylim');
        ydata=0.9*ypos(2)-(NmrData.Integral/max(NmrData.Integral))*ypos(2)*0.9;
        ydata=NmrData.Intscale*ydata;
        
        xlimits=get(hAxes,'xlim');
        hIntLine=line(NmrData.Specscale,ydata,...
            'color',[0 0.8 0],'linewidth', 1,...
            'tag','IntLine'); 
        set(hAxes,'xlim',xlimits);
        %plot peak numbers
        ypos=get(hAxes,'ylim');
        yp=(ypos(2)-ypos(1))/2;
        yp1=0.2*yp + ypos(1);
        yp2=0.1*yp + ypos(1);
        if ~isempty(NmrData.IntPointIndex) && NmrData.IntPointIndex(1)==1
            NmrData.IntPointIndex(  1)=[];
        end
        for k=1:length(NmrData.IntPointSort)/2
            
            text((NmrData.IntPointSort(2*k-1)+NmrData.IntPointSort(2*k))/2,yp1,num2str(k));
        end
        intnorm=str2double(get(hEditNorm,'String'));
        intpeak=round(str2double(get(hEditNormPeak,'String')));
        intcum=0;
        for k=1:length(NmrData.IntPointSort)/2
            hh=real(NmrData.SPECTRA(:,NmrData.flipnr));
            ss=sum(hh(NmrData.IntPointIndex(2*k-1):NmrData.IntPointIndex(2*k)));
            intcum=intcum+ss;
            if k==intpeak
                intpeaksize=ss;
            end
        end
        switch get(hBGroupNormalise,'SelectedObject')
            case hRadio1Normalise
                if  ~isempty(k) &&  k>=intpeak
                    for k=1:length(NmrData.IntPointSort)/2
                        hh=real(NmrData.SPECTRA(:,NmrData.flipnr));
                        ss=sum(hh(NmrData.IntPointIndex(2*k-1):NmrData.IntPointIndex(2*k)));
                        text((NmrData.IntPointSort(2*k-1)+NmrData.IntPointSort(2*k))/2,yp2,num2str(intnorm*ss/intpeaksize));
                    end
                else
                    for k=1:length(NmrData.IntPointSort)/2
                        text((NmrData.IntPointSort(2*k-1)+NmrData.IntPointSort(2*k))/2,yp2,'N/A');
                    end
                end
            case hRadio2Normalise
                for k=1:length(NmrData.IntPointSort)/2
                    hh=real(NmrData.SPECTRA(:,NmrData.flipnr));
                    ss=sum(hh(NmrData.IntPointIndex(2*k-1):NmrData.IntPointIndex(2*k)));
                    text((NmrData.IntPointSort(2*k-1)+NmrData.IntPointSort(2*k))/2,yp2,num2str(intnorm*ss/intcum));
                end
            case hRadio3Normalise
                for k=1:length(NmrData.IntPointSort)/2
                    %normalise to intnorm in the first spectrum
                    intcum_1=0;
                    for m=1:length(NmrData.IntPointSort)/2
                        hh_1=real(NmrData.SPECTRA(:,1));
                        ss_1=sum(hh_1(NmrData.IntPointIndex(2*k-1):NmrData.IntPointIndex(2*k)));
                        intcum_1=intcum_1+ss_1;
                    end
                    hh=real(NmrData.SPECTRA(:,NmrData.flipnr));
                    ss=sum(hh(NmrData.IntPointIndex(2*k-1):NmrData.IntPointIndex(2*k)));
                    %text((NmrData.IntPointSort(2*k-1)+NmrData.IntPointSort(2*k))/2,yp2,num2str(ss/intcum));
                    text((NmrData.IntPointSort(2*k-1)+NmrData.IntPointSort(2*k))/2,yp2,num2str(intnorm*ss/intcum_1));
                end
            otherwise
                error('illegal choice')
        end
        
        NmrData.Integral=TmpIntegral;
        guidata(hMainFigure,NmrData);
    end
    function DrawBaseline(source,eventdata)
        NmrData=guidata(hMainFigure);
        hBaseline=findobj(hAxes,'tag','baseline');
        delete(hBaseline)
        ypos=get(hAxes,'ylim');
        ypos=(ypos(2)-ypos(1))/2;
        ydata=ypos.*NmrData.region;
        xlimits=get(hAxes,'xlim');
        line(NmrData.Specscale,ydata,...
            'color','g','linewidth', 1.0,...
            'tag','baseline');
        set(hAxes,'xlim',xlimits);
        guidata(hMainFigure,NmrData);
    end
    function Threshold_function(source,eventdata)
        %set a threshold
        NmrData=guidata(hMainFigure);
        set(hMainFigure,'WindowButtonDownFcn','')
        guidata(hMainFigure,NmrData);
        hThresh=findobj(hAxes,'tag','threshold');
        delete(hThresh);  %(works even if hthresh==[])
        pt=get(gca,'currentpoint');
        ypos=pt(1,2);      
         switch NmrData.shiftunits
            case 'ppm'
                startunit='ppm';
            case 'Hz'
                NmrData.shiftunits='ppm';
                NmrData.xlim_spec=NmrData.xlim_spec./NmrData.sfrq;                
                startunit='Hz';
            otherwise
                error('illegal choice')
        end
       
        speclim=NmrData.xlim_spec;
        speclim=NmrData.fn*(speclim-NmrData.sp)/NmrData.sw;
        if speclim(1)<1
            speclim(1)=1;
        end
        if speclim(2)>NmrData.fn
            speclim(2)=NmrData.fn;
        end
        speclim=round(speclim); 
        NmrData.th=100*ypos/max(real(NmrData.SPECTRA(speclim(1):speclim(2),NmrData.flipnr)));
        
        %NmrData.th=100*ypos/max(real(NmrData.SPECTRA(NmrData.xlim_spec(1):NmrData.xlim_spec(2),NmrData.flipnr)));
        
         switch startunit
            case 'ppm'
                %all fine
            case 'Hz'
                NmrData.shiftunits='Hz';
                NmrData.xlim_spec=NmrData.xlim_spec.*NmrData.sfrq;
                NmrData.reference=NmrData.reference.*NmrData.sfrq;
            otherwise
                error('illegal choice')
        end
        NmrData.thresydata=[ypos ypos];
        %b=NmrData.thresydata
        NmrData.thresxdata=get(hAxes,'xlim');
        line(NmrData.thresxdata,NmrData.thresydata,...
            'color',[1 0 1],'linewidth', 1.0,...
            'tag','threshold');
        drawnow    
        guidata(hMainFigure,NmrData);
        %set(hAxes,'ButtonDownFcn',@Axes_ButtonDownFcn)
    end
    function DrawExcludeline(source,eventdata)
        NmrData=guidata(hMainFigure);
        hExcludeline=findobj(hAxes,'tag','excludeline');
        delete(hExcludeline)
        ypos=get(hAxes,'ylim');
        ypos=(ypos(2)-ypos(1))/3;
        ydata=ypos.*NmrData.exclude;
        xlimits=get(hAxes,'xlim');
        hExcludeline=line(NmrData.Specscale,ydata,...
            'color','r','linewidth', 1.0,...
            'tag','excludeline'); 
        set(hAxes,'xlim',xlimits);
        
        guidata(hMainFigure,NmrData);
    end
    function Pivot_function(source,eventdata)
        NmrData=guidata(hMainFigure);
        hPivot=findobj(hAxes,'tag','Pivot');
        delete(hPivot);
        pt=get(gca,'currentpoint');
        xpos=pt(1,1);
        NmrData.pivotxdata=[xpos xpos];
        NmrData.pivotydata=get(hAxes,'ylim');
        NmrData.pivot=xpos;
        line(NmrData.pivotxdata,NmrData.pivotydata,...
            'color',[0 1 1],'linewidth', 1.0,...
            'tag','Pivot');
        drawnow
        guidata(hMainFigure,NmrData);
    end
    function APVisibleOff()
        %turning of most gui elements in the advanced processing panel
        if NmrData.plottype==0
            NmrData.xlim_fid=xlim();
            NmrData.ylim_fid=ylim();
        elseif NmrData.plottype==1
            NmrData.xlim_spec=xlim();
            NmrData.ylim_spec=ylim();
        else
            error('Illegal plot type')
        end
        guidata(hMainFigure,NmrData);
        set(hDOSYButton,'ForegroundColor',[0 0 0])
        set(hDOSYButton,'Fontweight','normal')
        set(hDECRAButton,'ForegroundColor',[0 0 0])
        set(hDECRAButton,'Fontweight','normal')
        set(hMCRButton,'ForegroundColor',[0 0 0])
        set(hMCRButton,'Fontweight','normal')
        set(hSCOREButton,'ForegroundColor',[0 0 0])
        set(hSCOREButton,'Fontweight','normal')
        set(hLRDOSYButton,'ForegroundColor',[0 0 0])    %AC
        set(hLRDOSYButton,'Fontweight','normal')        %AC
        set(hSynthesiseButton,'ForegroundColor',[0 0 0])    %AC
        set(hSynthesiseButton,'Fontweight','normal')        %AC
        set(hPARAFACButton,'ForegroundColor',[0 0 0])
        set(hPARAFACButton,'Fontweight','normal')
        set(hBINButton,'ForegroundColor',[0 0 0])
        set(hBINButton,'Fontweight','normal')
        set(hicoshiftButton,'ForegroundColor',[0 0 0])
        set(hicoshiftButton,'Fontweight','normal')
        set(hINTEGRALButton,'ForegroundColor',[0 0 0])
        set(hINTEGRALButton,'Fontweight','normal')
        set(hBaselineButton,'ForegroundColor',[0 0 0])
        set(hBaselineButton,'Fontweight','normal')
        set(hFDMRRTButton,'ForegroundColor',[0 0 0])
        set(hFDMRRTButton,'Fontweight','normal')
        set(hILTButton,'ForegroundColor',[0 0 0])
        set(hILTButton,'Fontweight','normal')
        set(hICAButton,'ForegroundColor',[0 0 0])
        set(hICAButton,'Fontweight','normal')
        set(hTestingButton,'ForegroundColor',[0 0 0])
        set(hTestingButton,'Fontweight','normal')
        set(hBGroupILTRegMet,'Visible','Off')
        set(hBGroupILTOptimLambda,'Visible','Off')
        set(hBGroupILTSmooth,'Visible','Off')
        set(hBGroupILTConstrain,'Visible','Off')
        set(hTextLamda,'Visible','Off')
        set(hTextS,'Visible','Off')
        set(hTextN1,'Visible','Off')
        set(hEditN1,'Visible','Off')
        set(hTextN2,'Visible','Off')
        set(hEditN2,'Visible','Off')
        set(hTextBasis,'Visible','Off')
        set(hEditBasis,'Visible','Off')
        set(hEditQ,'Visible','Off')
        set(hEditS,'Visible','Off')
        set(hTextQ,'Visible','Off')
        set(hEditCres,'Visible','Off')
        set(hTextCres,'Visible','Off')
        set(hBGroupFDMRRTOpt1,'Visible','Off')
        set(hBGroupFDMRRTOpt2,'Visible','Off')
        set(hBGroupFDMRRTOpt3,'Visible','Off')
        %set(hFilterButton,'ForegroundColor',[0 0 0])
        % set(hFilterButton,'Fontweight','normal')
        set(hPSButton,'ForegroundColor',[0 0 0])
        set(hPSButton,'Fontweight','normal')
        set(hAnalyzeButton,'ForegroundColor',[0 0 0])
        set(hAnalyzeButton,'Fontweight','normal')
        set(hAlignButton,'ForegroundColor',[0 0 0])
        set(hAlignButton,'Fontweight','normal')
        set(hT1Button,'ForegroundColor',[0 0 0])
        set(hT1Button,'Fontweight','normal')
        set(hBGroupT1Opt2,'Visible','Off')
        set(hPanelT1plotting,'Visible','Off')
        set(hProcessButton,'Visible','Off')
        set(hReplotButton,'Visible','Off')
        set(hPubplotButton,'Visible','Off')
        set(hExportButton,'Visible','Off')
        set(hEditNcomp,'Visible','Off')
        set(hTextNcomp,'Visible','Off')
        set(hEditNgrad,'Visible','Off')
        set(hTextNgrad,'Visible','Off')
        
        set(hNgradUse,'Visible','Off')
        set(hBGroupMCROpt1,'Visible','Off')
        set(hBGroupMCROpt2,'Visible','Off')
        set(hBGroupMCROpt3,'Visible','Off')
        set(hBGroupMCROpt4,'Visible','Off')
        set(hBGroupMCROpt5,'Visible','Off')
        set(hThresholdButton,'Visible','Off')
        set(hBGroupDOSYOpt1,'Visible','Off')
        set(hBGroupDOSYOpt2,'Visible','Off')
        set(hBGroupDOSYOpt3,'Visible','Off')
        set(hBMultiexpPanel,'Visible','Off')
        set(hBPlotPanel,'Visible','Off')
        set(hBGroupSCOREOpt1,'Visible','Off')
        set(hBGroupSCOREOpt2,'Visible','Off')
        set(hBGroupSCOREOpt3,'Visible','Off')
        set(hBGrouplocodosyOpt1,'Visible','Off')
        set(hTextProcess,'Visible','Off')
        set(hTextExclude,'Visible','Off')
        set(hExcludeShow,'Visible','Off')
        set(hClearExcludeButton,'Visible','Off')
        set(hSetExcludeButton,'Visible','Off')
        set(hPlotSpecButton,'Visible','Off')
        set(hPlotBinnedButton,'Visible','Off')
        set(hButtonICOAlign,'Visible','Off')
        %set(hTextiCOSHIFT,'Visible','Off')
        set(hBGroupIcoshiftMode,'Visible','Off')
        set(hBGroupIcoshiftTarget,'Visible','Off')
        set(hEditIntervals,'Visible','Off')
        set(hTextIntervals,'Visible','Off')
        set(hEditBin,'Visible','Off')
        set(hTextBin,'Visible','Off')
        set(hTextIntegrals,'Visible','Off')
        set(hIntegralsShow,'Visible','Off')
        set(hClearIntegralsButton,'Visible','Off')
        set(hSetIntegralButton,'Visible','Off')
        set(hTextNormalise,'Visible','Off')
        set(hBGroupNormalise,'Visible','Off')
        set(hRadio1Normalise,'Visible','Off')
        set(hRadio2Normalise,'Visible','Off')
        set(hEditNorm,'Visible','Off')
        set(hTextNorm,'Visible','Off')
        set(hEditNormPeak,'Visible','Off')
        set(hTextNormPeak,'Visible','Off')
        set(hExportIntegralButton,'Visible','Off')
        set(hExportIntegralSetsButton,'Visible','Off')
        set(hTextIntegralsExport,'Visible','Off')
        set(hImportIntegralSetsButton,'Visible','Off')
        set(hTextIntegralsImport,'Visible','Off')
        set(hTextAnalyze,'Visible','Off')
        set(hAnalyzeFreqButton,'Visible','Off')
        set(hAnalyzeResButton,'Visible','Off')
        set(hAnalyzeAmpButton,'Visible','Off')
        set(hAnalyzeTempButton,'Visible','Off')
        set(hAnalyzePhaseButton,'Visible','Off')
        set(hAnalyzeIntButton,'Visible','Off')
        set(hDSSButton,'Visible','Off')
        set(hTextStart,'Visible','Off')
        set(hEditStart,'Visible','Off')
        set(hTextStop,'Visible','Off')
        set(hEditStop,'Visible','Off')
        set(hTextStep,'Visible','Off')
        set(hEditStep,'Visible','Off')
        set(hTextChartWidth,'Visible','Off')
        set(hEditChartWidth,'Visible','Off')        
        set(hTextStopChart,'Visible','Off')
        set(hEditStopChart,'Visible','Off') 
        set(hTextHorizontalOffset,'Visible','Off')
        set(hEditHorizontalOffset,'Visible','Off')
        set(hTextVerticalOffset,'Visible','Off')
        set(hEditVerticalOffset,'Visible','Off')
        set(hPanelPARAFACConstrain,'Visible','Off')
        set(hBGroupRunType,'Visible','Off')
        set(hTextDiffRes,'Visible','Off')
        set(hEditDiffRes,'Visible','Off')
        set(hUseClustering,'Visible','Off')
        set(hTextUseClustering,'Visible','Off')
        set(hIntegralsScale,'Visible','Off')
        set(hButtonPureshiftConvert,'Visible','Off')
        set(hEditnfid,'Visible','Off')
        set(hTextnfid,'Visible','Off')
        set(hEditnpoints,'Visible','Off')
        set(hTextnpoint,'Visible','Off')
        set(hEditnfirstfidpoints,'Visible','Off')
        set(hTextnfirstfidpoints,'Visible','Off')
        set(hEditDropPoints,'Visible','Off')
        set(hTextDropPoints,'Visible','Off')
        set(hButtonUnConvertPK,'Visible','Off')    
        set(hEditLamda,'Visible','Off')
        set(hTextLamda,'Visible','Off')
%AC
        set(hTextnfix,'Visible','Off')
        set(hEditnfix,'Visible','Off') 
        set(hUseSynthDsButton,'Visible','Off')
        set(hTableFixPeaks,'Visible','Off')
        set(hBigplotButton,'Visible','Off')
        set(hTextXtalk,'Visible','Off')
        set(hXtalkShow,'Visible','Off')
        set(hBGroupSCOREOpt6,'Visible','Off')
% LOCO %AC
        set(hLRInclude,'Visible','Off')
        set(hLRClear,'Visible','Off')
        set(hTextsderrmultiplier,'Visible','Off')
        set(hEditsderrmultiplier,'Visible','Off')
        set(hTextSelect,'Visible','Off')
        set(hLRViewComponent,'Visible','Off')
        set(hDoSVDButton,'Visible','Off')
        set(hTextDlimit,'Visible','Off')
        set(hEditDlimit,'Visible','Off')
        set(hBGrouplocodosyalg,'Visible','Off')
        set(hRadio1locodosyalg,'Visible','Off')
        set(hRadio2locodosyalg,'Visible','Off')
        set(hRegionsTable,'Visible','Off')
        set(hLRWindowsShow,'Visible','Off')
        set(hAutoInclude,'Visible','Off')
        set(hTextVlimit,'Visible','Off')
        set(hEditVlimit,'Visible','Off')
        set(hTextSVDcutoff,'Visible','Off')
        set(hEditSVDcutoff,'Visible','Off')
        set(hTextmethodplots,'Visible','Off')
        set(hLRmethodplots,'Visible','Off')
        set(hSVDplotsShow,'Visible','Off')
% Synthesise DOSY %AC
        set(hRandomDOSYButton,'Visible','Off')
        set(hTextsw,'Visible','Off')
        set(hEditsw,'Visible','Off')
        set(hTextnp,'Visible','Off')
        set(hEditnp,'Visible','Off')
        set(hTextmingrad,'Visible','Off')
        set(hEditmingrad,'Visible','Off')
        set(hTextmaxgrad,'Visible','Off')
        set(hEditmaxgrad,'Visible','Off')
        set(hTextni,'Visible','Off')
        set(hEditni,'Visible','Off')
        set(hTextSynthParam,'Visible','Off')
        set(hTextSynthGenDOSY,'Visible','Off')
        set(hUpdateSynthButton,'Visible','Off')
        set(hTextnpeaks,'Visible','Off')
        set(hEditnpeaks,'Visible','Off')
        set(hTextnoise,'Visible','Off')
        set(hEditnoise,'Visible','Off')
        set(hTableSynthPeaks,'Visible','Off')
        set(hText3Dplot,'Visible','Off')
        set(hCheck3Dplot,'Visible','Off')
        set(hTextUseNUG,'Visible','Off')
        set(hCheckUseNUG,'Visible','Off')
        set(hUpdateTableButton,'Visible','Off')
        set(hXiRockePanel,'Visible','Off');
        set(hAlignPanel,'Visible','Off')
        
        set(hEditArray2,'Visible','Off')
        set(hTextArray2,'Visible','Off')
        set(hArray2Use,'Visible','Off')
        set(hTextPrune2,'Visible','Off')
        set(hTextGrad,'Visible','Off')
        set(hSepPlotUse,'Visible','Off')
        set(hAutoPlotUse,'Visible','Off')
        
        
        
        
        if strcmp(NmrData.local,'yes')
            set(hButtonPureshiftConvertPK,'Visible','Off')
        end
        
        
        
        
    end
    function pfgnmrdata=PreparePfgnmrdata()
        %Prepare the data for advanced processing
        zoom off
        pan off
        set(hMainFigure,'WindowButtonDownFcn','')
        %get the delta the spectrum
        if NmrData.plottype==1
            %disp('hi')
            NmrData.xlim_spec=xlim();
            NmrData.ylim_spec=ylim();
        end
        guidata(hMainFigure,NmrData);
        % Excludeline_function()
        NmrData=guidata(hMainFigure);
        pfgnmrdata.filename=NmrData.filename;
        pfgnmrdata.type=NmrData.type;
        pfgnmrdata.np=NmrData.np;
        pfgnmrdata.wp=NmrData.sw;
        pfgnmrdata.sp=NmrData.sp;
        pfgnmrdata.dosyconstant=NmrData.dosyconstant;
        pfgnmrdata.Gzlvl=NmrData.Gzlvl;
        pfgnmrdata.ngrad=NmrData.ngrad;
        pfgnmrdata.arraydim=NmrData.arraydim;
        pfgnmrdata.Ppmscale=NmrData.Specscale;
        if (isfield(NmrData,'d2'))
                pfgnmrdata.d2=NmrData.d2;
        end        
        if (isfield(NmrData,'bt'))
                pfgnmrdata.bt=NmrData.bt;
        end         
        if (isfield(NmrData,'bigtau'))
                pfgnmrdata.bigtau=NmrData.bigtau;
        end        
       
        switch NmrData.disptype
            case 0
                pfgnmrdata.SPECTRA=abs(NmrData.SPECTRA);
            case 1
                pfgnmrdata.SPECTRA=real(NmrData.SPECTRA);
            otherwise
                disp('Unknown display type. Using phase sensitive mode')
                pfgnmrdata.SPECTRA=real(NmrData.SPECTRA);
        end
        pfgnmrdata.SPECTRA=pfgnmrdata.SPECTRA/max(max(pfgnmrdata.SPECTRA));
        if isfield(NmrData,'exclude')
            if get(hExcludeShow,'Value')
                for k=1:NmrData.ngrad
                    pfgnmrdata.SPECTRA(:,k)=...
                        pfgnmrdata.SPECTRA(:,k).*isnan(NmrData.exclude');
                end
            end
        end
        % Prune gradient levels if opted
        if get(hNgradUse,'Value')
            %check the validity of the prune array
            if length(NmrData.prune)>=length(NmrData.Gzlvl)
                errstring=...
                    {'Too many gradient levels in prune',...
                    'No pruning will be done'};
                hErr=errordlg...
                    (errstring,'Prune error');
                uiwait(hErr)
            elseif NmrData.prune <1
                errstring=...
                    {'Prune numbers cannot be zero or negative',...
                    'No pruning will be done'};
                hErr=errordlg...
                    (errstring,'Prune error');
                uiwait(hErr)
            elseif NmrData.prune>NmrData.ngrad
                errstring=...
                    {'Prune numbers cannot exceed number of gradient levels',...
                    'No pruning will be done'};
                hErr=errordlg...
                    (errstring,'Prune error');
                uiwait(hErr)
            elseif length(unique(NmrData.prune))~=length(NmrData.prune)
                errstring=...
                    {'Duplicates in prune vector',...
                    'No pruning will be done'};
                hErr=errordlg...
                    (errstring,'Prune error');
                uiwait(hErr)
            else
                %do the pruning
                pfgnmrdata.SPECTRA(:,NmrData.prune)=[];
                pfgnmrdata.Gzlvl(NmrData.prune)=[];
                pfgnmrdata.ngrad=pfgnmrdata.ngrad-length(NmrData.prune);
            end
        end
        %MN 10Nov09 Add flipnr for score and locodosy
        pfgnmrdata.flipnr=NmrData.flipnr; % For running SCORE in 3D datasets
        
        guidata(hMainFigure,NmrData);
    end
    function pfgnmrdata=PreparePfgnmr3Ddata()
        %Prepare the data for advanced processing
        NmrData=guidata(hMainFigure);
        pfgnmrdata.filename=NmrData.filename;
        pfgnmrdata.np=NmrData.np;
        pfgnmrdata.wp=NmrData.sw;
        pfgnmrdata.sp=NmrData.sp;
        pfgnmrdata.dosyconstant=NmrData.dosyconstant;
        pfgnmrdata.Gzlvl=NmrData.Gzlvl;
        pfgnmrdata.ngrad=NmrData.ngrad;
        pfgnmrdata.narray2=NmrData.narray2;
        pfgnmrdata.Ppmscale=NmrData.Specscale;
        pfgnmrdata.SPECTRA=real(NmrData.SPECTRA);
        pfgnmrdata.SPECTRA=pfgnmrdata.SPECTRA/max(max(pfgnmrdata.SPECTRA));
        if isfield(NmrData,'exclude')
            if get(hExcludeShow,'Value')
                for k=1:NmrData.arraydim
                    pfgnmrdata.SPECTRA(:,k)=...
                        pfgnmrdata.SPECTRA(:,k).*isnan(NmrData.exclude');
                end
            end
        end
        pfgnmrdata.SPECTRA=reshape(pfgnmrdata.SPECTRA,NmrData.fn,NmrData.ngrad,NmrData.narray2);
        % Prune gradient levels if opted
        if get(hNgradUse,'Value')
            %check the validity of the prune array
            if length(NmrData.prune)>=length(NmrData.Gzlvl)
                errstring=...
                    {'Too many gradient levels in prune',...
                    'No pruning will be done'};
                hErr=errordlg...
                    (errstring,'Prune error');
                uiwait(hErr)
            elseif NmrData.prune <1
                errstring=...
                    {'Prune numbers cannot be zero or negative',...
                    'No pruning will be done'};
                hErr=errordlg...
                    (errstring,'Prune error');
                uiwait(hErr)
            elseif NmrData.prune>NmrData.ngrad
                errstring=...
                    {'Prune numbers cannot exceed number of gradient levels',...
                    'No pruning will be done'};
                hErr=errordlg...
                    (errstring,'Prune error');
                uiwait(hErr)
            elseif length(unique(NmrData.prune))~=length(NmrData.prune)
                errstring=...
                    {'Duplicates in prune vector',...
                    'No pruning will be done'};
                hErr=errordlg...
                    (errstring,'Prune error');
                uiwait(hErr)
            else
                %do the pruning
                pfgnmrdata.SPECTRA(:,NmrData.prune,:)=[];
                pfgnmrdata.Gzlvl(NmrData.prune)=[];
                pfgnmrdata.ngrad=pfgnmrdata.ngrad-length(NmrData.prune);
            end
        end
        
              % Prune array 2 levels if opted
        if get(hArray2Use,'Value')
            %check the validity of the prune array
            if length(NmrData.pruneArray2)>=NmrData.narray2;
                errstring=...
                    {'Too many array levels in prune',...
                    'No pruning will be done'};
                hErr=errordlg...
                    (errstring,'Prune error');
                uiwait(hErr)
            elseif NmrData.pruneArray2 <1
                errstring=...
                    {'Prune numbers cannot be zero or negative',...
                    'No pruning will be done'};
                hErr=errordlg...
                    (errstring,'Prune error');
                uiwait(hErr)
            elseif length(unique(NmrData.pruneArray2))~=length(NmrData.pruneArray2)
                errstring=...
                    {'Duplicates in prune vector',...
                    'No pruning will be done'};
                hErr=errordlg...
                    (errstring,'Prune error');
                uiwait(hErr)
            else
                %do the pruning
                pfgnmrdata.SPECTRA(:,:,NmrData.pruneArray2)=[];
                pfgnmrdata.narray2=pfgnmrdata.narray2-length(NmrData.pruneArray2);
            end
        end
        
        
        guidata(hMainFigure,NmrData);
    end
    function PlotSpectrum()
        NmrData=guidata(hMainFigure);
        set(gcf,'CurrentAxes',hAxes)
        if NmrData.plotsep==1
            figure('Color',[0.9 0.9 0.9],...
                'NumberTitle','Off',...
                'Name','Current');
        end
        if NmrData.plottype==0
            %FID
            set(hBaselineShow,'Value',0)
            set(hExcludeShow,'Value',0)
            set(hThresholdButton,'Value',get(hThresholdButton,'Min'))
            set(hPivotCheck,'Value',0)
            Timescale=GetTimescale();
            Winfunc=GetWinfunc('PlotSpectrum');
            orgfid = NmrData.FID;
            
            %leftshift the fid
            if NmrData.lrfid>0
                %left shift the fid
                for k=1:NmrData.arraydim
                    NmrData.FID(:,k)= circshift(NmrData.FID(:,k),-NmrData.lrfid);
                end
            end
            %phase or abs
            if NmrData.disptype==0
                plotfid=abs(NmrData.FID(:,NmrData.flipnr));
            else
                plotfid=real(NmrData.FID(:,NmrData.flipnr));
            end
            
            if NmrData.plotsep==1
                %determine what to plot
                if  get(hPlotFID,'Value') && get(hPlotWinfunc,'Value') && get(hPlotFIDWinfunc,'Value')
                    %FID + new FID + winfunc
                    hPlot= plot(Timescale,plotfid, Timescale,...
                        plotfid.*Winfunc/(max(Winfunc)),'red',...
                        Timescale,0.9*max(NmrData.ylim_fid)*Winfunc/(max(Winfunc)),'green','Linewidth',2);
                    
                elseif get(hPlotFID,'Value') && get(hPlotWinfunc,'Value')
                    %FID + winfunc
                    hPlot= plot(Timescale,plotfid,...
                        Timescale,0.9*max(NmrData.ylim_fid)*Winfunc/(max(Winfunc)),'green','Linewidth',2);
                    
                elseif  get(hPlotFID,'Value') && get(hPlotFIDWinfunc,'Value')
                    %FID + new FID
                    hPlot= plot(Timescale,plotfid, Timescale,...
                        plotfid.*Winfunc/(max(Winfunc)),'red');
                    
                elseif get(hPlotWinfunc,'Value') && get(hPlotFIDWinfunc,'Value')
                    %new FID + winfunc
                    hPlot= plot(Timescale,...
                        plotfid.*Winfunc/(max(Winfunc)),'red',...
                        Timescale,0.9*max(NmrData.ylim_fid)*Winfunc/(max(Winfunc)),'green','Linewidth',2);
                    
                elseif get(hPlotFID,'Value')
                    %FID
                    hPlot= plot(Timescale,plotfid);
                    
                elseif get(hPlotFIDWinfunc,'Value')
                    % new FID
                    hPlot= plot(Timescale,...
                        plotfid.*Winfunc/(max(Winfunc)),'red');
                    
                elseif get(hPlotWinfunc,'Value')
                    % winfunc
                    hPlot= plot(Timescale,0.9*max(NmrData.ylim_fid)*Winfunc/(max(Winfunc)),'green','Linewidth',2);
                else
                    % unknown
                    disp('unknown plot combination')
                end
                
                xlabel('\bf Time (s)');
                ylim(NmrData.ylim_fid);
                xlim(NmrData.xlim_fid);
            else
                %determine what to plot
                if  get(hPlotFID,'Value') && get(hPlotWinfunc,'Value') && get(hPlotFIDWinfunc,'Value')
                    %FID + new FID + winfunc
                    %disp('One')
                    hPlot= plot(Timescale,plotfid, Timescale,...
                        plotfid.*Winfunc/(max(Winfunc)),'red',...
                        Timescale,0.9*max(ylim())*Winfunc/(max(Winfunc)),'green','Linewidth',2);
                    
                elseif get(hPlotFID,'Value') && get(hPlotWinfunc,'Value')
                    %FID + winfunc
                    hPlot= plot(Timescale,plotfid,...
                        Timescale,0.9*max(ylim())*Winfunc/(max(Winfunc)),'green','Linewidth',2);
                    
                elseif  get(hPlotFID,'Value') && get(hPlotFIDWinfunc,'Value')
                    %FID + new FID
                    hPlot= plot(Timescale,plotfid, Timescale,...
                        plotfid.*Winfunc/(max(Winfunc)),'red');
                    
                elseif get(hPlotWinfunc,'Value') && get(hPlotFIDWinfunc,'Value')
                    %new FID + winfunc
                    hPlot= plot(Timescale,...
                        plotfid.*Winfunc/(max(Winfunc)),'red',...
                        Timescale,0.9*max(ylim())*Winfunc/(max(Winfunc)),'green','Linewidth',2);
                    
                elseif get(hPlotFID,'Value')
                    %FID
                    hPlot= plot(Timescale,plotfid);
                    
                elseif get(hPlotFIDWinfunc,'Value')
                    % new FID
                    hPlot= plot(Timescale,...
                        plotfid.*Winfunc/(max(Winfunc)),'red');
                    
                elseif get(hPlotWinfunc,'Value')
                    % winfunc
                    hPlot= plot(Timescale,0.9*max(ylim())*Winfunc/(max(Winfunc)),'green','Linewidth',2);
                else
                    % unknown
                    disp('unknown plot combination')
                end
                xlabel(hAxes,'\bf Time (s)');
                xlim(NmrData.xlim_fid);
                ylim(NmrData.ylim_fid);
            end
            NmrData.FID = orgfid;
        elseif NmrData.plottype==1
            %Spectrum
            switch NmrData.shiftunits
                case 'ppm'
                    NmrData.Specscale=...
                        linspace(NmrData.sp,(NmrData.sw+NmrData.sp),NmrData.fn);
                case 'Hz'
                    NmrData.Specscale=...
                        linspace(NmrData.sp.*NmrData.sfrq,(NmrData.sw+NmrData.sp).*NmrData.sfrq,NmrData.fn);
                otherwise
                    error('illegal choice')
            end
            if NmrData.plotsep==1
                
                test_marker=0;
                test_spec=1;
                if NmrData.disptype==0
                    if test_spec==1
                        hPlot=plot(NmrData.Specscale,abs(NmrData.SPECTRA(:,NmrData.flipnr)));
                    end
                    if test_marker==1
                        hold on
                        hPlot=plot(NmrData.Specscale,abs(NmrData.SPECTRA(:,NmrData.flipnr)),'+','MarkerSize',12,'LineWidth',2,'Color','red');
                        hold off
                    end
                else
                    if test_spec==1
                        hPlot=plot(NmrData.Specscale,real(NmrData.SPECTRA(:,NmrData.flipnr)));
                    end
                    if test_marker==1
                        hold on
                        hPlot=plot(NmrData.Specscale,real(NmrData.SPECTRA(:,NmrData.flipnr)),'+','MarkerSize',12,'LineWidth',2,'Color','red');
                        hold off
                    end
                end
               
                
                xlabel('\bf Chemical shift ');
                xlim(NmrData.xlim_spec)
                ylim(NmrData.ylim_spec)
                set(gca,'Xdir','Reverse')
                
            else
                if NmrData.disptype==0
                    hPlot=plot(hAxes,NmrData.Specscale,abs(NmrData.SPECTRA(:,NmrData.flipnr)));
                    xlabel(hAxes,'\bf Chemical shift ');
                else
                    hPlot=plot(hAxes,NmrData.Specscale,real(NmrData.SPECTRA(:,NmrData.flipnr)));
                    xlabel(hAxes,'\bf Chemical shift ');
                end
            end
            xlim(NmrData.xlim_spec)
            ylim(NmrData.ylim_spec)
            set(hAxes,'Xdir','Reverse');
            if get(hReferenceCheck,'Value')
                line(NmrData.referencexdata,NmrData.referenceydata,...
                    'color','magenta','linewidth', 1.0,...
                    'tag','Reference');
                drawnow
            else
                hReference=findobj(hAxes,'tag','Reference');
                delete(hReference)
            end
            if get(hRDshowCheck,'Value')
                NmrData.RDrcentreydata=get(hAxes,'ylim');
                NmrData.RDcentrexdata=[NmrData.RDcentre NmrData.RDcentre];
                line(NmrData.RDcentrexdata,NmrData.RDcentreydata,...
                    'color','black','linewidth', 1.0,...
                    'tag','RDcentre');
            else
                hRDcentre=findobj(hAxes,'tag','RDcentre');
                delete(hRDcentre)
            end
            if get(hRDshowLRCheck,'Value')
                NmrData.RDleftydata=get(hAxes,'ylim');
                NmrData.RDrightydata=get(hAxes,'ylim');
                NmrData.RDleftxdata=[NmrData.RDleft NmrData.RDleft];
                NmrData.RDrightxdata=[NmrData.RDright NmrData.RDright];
                line(NmrData.RDleftxdata,NmrData.RDleftydata,...
                    'color','red','linewidth', 1.0,...
                    'tag','RDleft');
                line(NmrData.RDrightxdata,NmrData.RDrightydata,...
                    'color','green','linewidth', 1.0,...
                    'tag','RDright');
            else
                hRDright=findobj(hAxes,'tag','RDright');
                hRDleft=findobj(hAxes,'tag','RDleft');
                delete(hRDleft)
                delete(hRDright)
            end
            if get(hIntegralsShow,'Value')
                DrawIntLine();
            end
            if get(hExcludeShow,'Value')
                DrawExcludeline();
            end
            if get(hBaselineShow,'Value')
                DrawBaseline();
            end
            if get(hLRWindowsShow,'Value')
                DrawIncludeline();
            end
            if get(hPivotCheck,'Value')
                %Pivot_function();
            end
            if get(hPivotCheck,'Value')
                line(NmrData.pivotxdata,NmrData.pivotydata,...
                    'color',[0 1 1],'linewidth', 1.0,...
                    'tag','Pivot');
                drawnow
            else
                hPivot=findobj(hAxes,'tag','Pivot');
                delete(hPivot)
            end
            xlim(NmrData.xlim_spec)
            ylim(NmrData.ylim_spec)
            guidata(hMainFigure,NmrData);
        else
            error('Undefined plot type')
        end
        set(hPlot,'HitTest','off')
        set(hThresholdButton,'Value',get(hThresholdButton,'Min'))
        %NmrData.th=0;
        hThresh=findobj(hAxes,'tag','threshold');
        delete(hThresh)
        NmrData.plotsep=0;
        guidata(hMainFigure,NmrData);
        
    end
    function PhaseSpectrum(lpChange,rpChange,AbsPhase)
        %phase the spectrum depending on the change in lp and rp; a change
        %in lp also makes a change in rp depending on the pivot position
        NmrData=guidata(hMainFigure);
        if NmrData.plottype==1
            NmrData.xlim_spec=xlim();
            NmrData.ylim_spec=ylim();
        end
        if isnan(lpChange)
            lpChange=0;
        end
        if isnan(rpChange)
            rpChange=0;
        end
        Rc=1i*(pi/180);
        
        switch get(hScopeGroup,'SelectedObject')
            case hRadioScopeGlobal
                %                 a=NmrData.fn
                %                 lpChange
                lpCorr= linspace(0,1,NmrData.fn)*lpChange;
                if AbsPhase==1
                    %Apply absolute values - no change (after FT or loading in a
                    %new experiment)
                elseif AbsPhase==20
                    %This means phasing individual spectra from GroupScope_Callback
                    %function. Workaround to speed it up (hard to keep
                    %elegant code when bolting on)
                    PhaseCorrTot=zeros(NmrData.fn,NmrData.arraydim);
                    for k=1:NmrData.arraydim
                        lpCorr= linspace(0,1,NmrData.fn)*(NmrData.lp-NmrData.lpInd(k));
                        PhaseCorrTot(:,k)=(exp(Rc*((NmrData.rp-NmrData.rpInd(k)) + lpCorr)))';
                    end
                    NmrData.SPECTRA=NmrData.SPECTRA.*PhaseCorrTot;
                else
                    if AbsPhase==2 %autophase or manual edit
                        %nover mind the pivot
                    else
                        rpCorrlp=- lpCorr(round(NmrData.fn*...
                            (NmrData.pivot-NmrData.sp)/NmrData.sw));
                        rpChange=rpChange+rpCorrlp;
                    end
                    NmrData.lp=NmrData.lp+lpChange;
                    NmrData.rp=NmrData.rp+rpChange;
                end
                % disp('phase')
                %size(NmrData.SPECTRA)
                %a=NmrData.arraydim
                phaseCorr=...
                    (exp(Rc*(rpChange + lpCorr)))';
                %phasing all spectra
                NmrData.SPECTRA=NmrData.SPECTRA.*repmat...
                    (phaseCorr,1,(NmrData.arraydim));
                set(hEditPh1,'string',num2str(NmrData.lp,4))
                set(hEditPh0,'string',num2str(NmrData.rp,4))
                set(hSliderPh0,'value',NmrData.rp);
                set(hSliderPh1,'value',NmrData.lp);
            case hRadioScopeIndividual
                lpCorr= linspace(0,1,NmrData.fn)*lpChange;
                if AbsPhase==1
                    %Apply absolute values - no change (after FT or loading in a
                    %new experiment)
                else
                    if AbsPhase==2 %autophase or manual edit
                        %nover mind the pivot
                    elseif AbsPhase==20
                        %This means phasing individual spectra from GroupScope_Callback
                        %function. Workaround to speed it up (hard to keep
                        %elegant code when bolting on)
                        PhaseCorrTot=zeros(NmrData.fn,NmrData.arraydim);
                        for k=1:NmrData.arraydim
                            lpCorr= linspace(0,1,NmrData.fn)*(NmrData.lpInd(k)-NmrData.lp);
                            PhaseCorrTot(:,k)=(exp(Rc*((NmrData.rpInd(k)-NmrData.rp) + lpCorr)))';
                        end
                        NmrData.SPECTRA=NmrData.SPECTRA.*PhaseCorrTot;
                        
                        
                    elseif AbsPhase==10
                        %This means phasing individual spectra from FT
                        %function. Workaround to speed it up (hard to keep
                        %elegant code when bolting on)
                        PhaseCorrTot=zeros(NmrData.fn,NmrData.arraydim);
                        for k=1:NmrData.arraydim
                            lpCorr= linspace(0,1,NmrData.fn)*NmrData.lpInd(k);
                            PhaseCorrTot(:,k)=(exp(Rc*(NmrData.rpInd(k) + lpCorr)))';
                        end
                        NmrData.SPECTRA=NmrData.SPECTRA.*PhaseCorrTot;
                    else
                        rpCorrlp= - lpCorr(round(NmrData.fn*...
                            (NmrData.pivot-NmrData.sp)/NmrData.sw));
                        rpChange=rpChange+rpCorrlp;
                    end
                    NmrData.lpInd(NmrData.flipnr)=...
                        NmrData.lpInd(NmrData.flipnr)+lpChange;
                    NmrData.rpInd(NmrData.flipnr)=...
                        NmrData.rpInd(NmrData.flipnr)+rpChange;
                end
                phaseCorr=...
                    (exp(Rc*(rpChange + lpCorr)))';
                %phasing just the displayed spectrum
                if AbsPhase==10
                    %don't phase current spectrum twice
                else
                NmrData.SPECTRA(:,NmrData.flipnr)=...
                    NmrData.SPECTRA(:,NmrData.flipnr).*phaseCorr;
                end
                set(hEditPh1,'string',num2str(NmrData.lpInd(NmrData.flipnr),4))
                set(hEditPh0,'string',num2str(NmrData.rpInd(NmrData.flipnr),4))
                set(hSliderPh0,'value',NmrData.rpInd(NmrData.flipnr));
                set(hSliderPh1,'value',NmrData.lpInd(NmrData.flipnr));
            otherwise
                error('illegal choice')
        end
        guidata(hMainFigure,NmrData);
    end
    function Timescale=GetTimescale()
        NmrData=guidata(hMainFigure);
        %Timescale=linspace(0,NmrData.at*(NmrData.fn/NmrData.np),NmrData.fn);
        Timescale=linspace(0,NmrData.at,NmrData.np);
        guidata(hMainFigure,NmrData);
    end
    function Winfunc=GetWinfunc(Caller)
        NmrData=guidata(hMainFigure);
        if  strcmp(Caller,'FTButton_Callback')
            Timescale=linspace(0,NmrData.at*(NmrData.fn/NmrData.np),NmrData.fn);
        else        
             Timescale=GetTimescale();
        end
        if get(hCheckLb,'Value')
            Lbfunc=exp(-Timescale'*pi*NmrData.lb);
        else
            Lbfunc=Timescale'*0+1;
        end
        if get(hCheckGw,'Value')
            gf=2*sqrt(log(2))/(pi*NmrData.gw);
            Gwfunc=exp(-(Timescale'/gf).^2);
        else
            Gwfunc=Timescale'*0+1;
        end
        if  strcmp(Caller,'FTButton_Callback')
            Winfunc=Gwfunc.*Lbfunc;
        elseif    strcmp(Caller,'PlotSpectrum')
            Winfunc=0.9*Gwfunc.*Lbfunc.*max(real(NmrData.FID(:,NmrData.flipnr)))/max(Gwfunc.*Lbfunc);
        else
            error('unknown caller for Winfunc');
        end
        guidata(hMainFigure,NmrData);
    end
    function Initiate_NmrData()
        NmrData=guidata(hMainFigure);
        tmp=NmrData.version;
        tmp2=NmrData.local;
        clear NmrData
        NmrData.at=[];
        NmrData.arraydim=[];
        NmrData.array2nr=[];
        NmrData.baselinecorr=[];
        NmrData.baselinepoints=[];
        NmrData.BasePoints=[];
        NmrData.d2=[];
        NmrData.dc=0;
        NmrData.dcspec=1;
        NmrData.decradata=[];
        NmrData.DELTA=[];
        NmrData.DELTAOriginal=[];
        NmrData.DELTAprime=[];
        NmrData.delta=[];
        NmrData.deltaOriginal=[];
        NmrData.disptype=1; %Determines if phase sensitive or absolute value plotting is used
        NmrData.DOSYdiffrange=[];
        NmrData.dosyconstant=[];
        NmrData.dosyconstantOriginal=[];
        NmrData.dosydata=[];
        NmrData.DOSYopts=[];
        NmrData.exclude=[];
        NmrData.excludelinepoints=[];
        NmrData.ExcludePoints=[];
        NmrData.FID=[];
        NmrData.FitType=0;
        NmrData.filename='';
        NmrData.flipnr=[];
        NmrData.fn=0;
        NmrData.fpmult=0.5;
        NmrData.fshift=[];
        NmrData.gamma=[];
        NmrData.gammaOriginal=[];
        NmrData.gcal=[];
        NmrData.gcal_orig=[];
        NmrData.gf=0;
        NmrData.gradnr=[];
        NmrData.gw=0;
        NmrData.Gzlvl=[];
        NmrData.Integral=[];
        NmrData.IntPoint=[];
        NmrData.IntPointIndex=[];
        NmrData.IntPointSort=[];
        NmrData.Intscale=1;
        NmrData.lb=[];
        NmrData.local=tmp2;
        NmrData.lp=[];
        NmrData.lpInd=[];
        NmrData.locodosydata=[];
        NmrData.locodosyopts=[];
        NmrData.lrfid=0;
        NmrData.lsspec=0;
        NmrData.linshift=1;
        NmrData.mcrdata=[];
        NmrData.MCRopts=[];
        NmrData.narray2=[];
        NmrData.ncomp=[];
        %NmrData.nfid=[];
        NmrData.ngrad=[];
        NmrData.np=[];
        NmrData.nug=[1 0 0 0]; %default as pure exponential
        NmrData.nwin=[];
        NmrData.order=[];
        NmrData.panelpos=[0 0];
        NmrData.pfgnmrdata=[];
        NmrData.pivot=[];
        NmrData.pivotxdata=[];
        NmrData.pivotydata=[];
        NmrData.plottype=1;
        NmrData.plotsep=0;
        NmrData.probename='undefined';
        NmrData.prune=[];
        NmrData.pruneArray2=[];
        NmrData.RDcentrexdata=[0 0];
        NmrData.RDcentreydata=[0 0];
        NmrData.RDcentre=0;
        NmrData.RDleftxdata=0;
        NmrData.RDleftydata=0;
        NmrData.RDleft=0;
        NmrData.RDrightxdata=[0 0];
        NmrData.RDrightydata=[0 0];
        NmrData.RDright=0;
        NmrData.reference=[];
        NmrData.referencexdata=[];
        NmrData.referenceydata=[];
        NmrData.RRTopts=[];
        %NmrData.procpar=[];
        NmrData.region=[];
        NmrData.rp=[];
        NmrData.rpInd=[];
        NmrData.scoredata=[];
        NmrData.SCOREopts=[];
        NmrData.sfrq=[];
        NmrData.shiftunits='ppm';
        NmrData.sp=[];
        NmrData.Specscale=[];
        NmrData.SPECTRA=[];
        NmrData.sw=[];
        NmrData.sw1=[];
        NmrData.tau=0;
        NmrData.tauOriginal=[];
        NmrData.th=0.0;
        NmrData.thresxdata=0;
        NmrData.thresydata=0;
        NmrData.Timescale=[];
        NmrData.type='';
        NmrData.version=tmp;
        NmrData.xlim=[];
        NmrData.xlim_fid=[];
        NmrData.ylim=[];
        NmrData.ylim_fid=[];
        NmrData.flipnr=str2num(get(hEditFlip,'String'));
        NmrData.fn=NmrData.np;
        NmrData.gw=str2num(get(hEditGw,'String'));
        NmrData.lb=str2num(get(hEditLb,'String'));
        %AC
        NmrData.include=[];
        NmrData.includelinepoints=[];
        NmrData.IncludePoints=[];
        NmrData.startORend=0;
        NmrData.winstart=[];
        NmrData.winend=[];
        NmrData.numcomp=[];
        NmrData.concat1dspectra=[];
        NmrData.sderrmultiplier=[];
        NmrData.LRRegionData=[];
        NmrData.issynthetic=0;
        %AC
        %nD specific
        NmrData.xlim_1D=[];
        NmrData.ylim_1D=[];
        NmrData.xlim_2D=[];
        NmrData.ylim_2D=[];
        
        
        guidata(hMainFigure,NmrData);
    end
    function Setup_NmrData()
        NmrData=guidata(hMainFigure);
        set(gcf,'CurrentAxes',hAxes)
        
        if NmrData.issynthetic==1       %AC
            slashindex=1;
        elseif isunix()==1
            slashindex=find(NmrData.filename=='/'); 
        else
            slashindex=find(NmrData.filename=='\');
        end
        
       % slashindex
        set(hMainFigure,'Name',...
            [NmrData.version ' ...' NmrData.filename(slashindex(end):end)])
        set(hScopeGroup,'SelectedObject',hRadioScopeGlobal)
        set(hEditOrder,'string',2);
        NmrData.order=round(str2double(get(hEditOrder,'string')));
        NmrData.plottype=1;
        NmrData.flipnr=1;
        NmrData.dc=0;
        NmrData.fpmult=0.5;        
        % NmrData.nfid=NmrData.arraydim;
        NmrData.fn=NmrData.np;
        NmrData.thresydata=0;
        NmrData.thresxdata=0;
        NmrData.Timescale=linspace...
            (0,NmrData.at*(NmrData.fn/NmrData.np),NmrData.fn);
        NmrData.exclude=ones(1,NmrData.fn);
        NmrData.ExcludePoints=[];
        NmrData.excludelinepoints=[];
        NmrData.IntPoint=[];
        NmrData.Integral=ones(1,NmrData.fn);
        NmrData.region=ones(1,NmrData.fn);
        NmrData.baselinepoints=[];
        NmrData.BasePoints=[];
        % NmrData.bpoints=[1 NmrData.fn];
        %NmrData.baselinecorr=zeros(NmrData.fn,NmrData.ngrad);
        NmrData.baselinecorr=zeros(NmrData.fn,NmrData.arraydim);
        NmrData.xlim_fid=[0 NmrData.at];
        NmrData.ylim_fid=...
            [min(real(NmrData.FID(:,1))) max(real(NmrData.FID(:,1)))];
        set(hEditFn,'string',num2str(NmrData.fn));
        set(hEditNp,'string',num2str(NmrData.np));
        set(hExcludeShow,'Value',0)
        NmrData.Specscale=...
            linspace(NmrData.sp,(NmrData.sw+NmrData.sp),NmrData.fn);
        NmrData.Specscale=...
            linspace(NmrData.sp,(NmrData.sw+NmrData.sp),NmrData.fn);
        NmrData.pivot=NmrData.Specscale(round(NmrData.np/2));
        set(hSliderPh0,'value',NmrData.rp);
        set(hEditPh0,'string',num2str(NmrData.rp,4));
        set(hSliderPh1,'value',NmrData.lp);
        set(hEditPh0,'string',num2str(NmrData.lp,4));       
        NmrData.SPECTRA=flipud((fftshift(fft(NmrData.FID,NmrData.fn),1)));
        guidata(hMainFigure,NmrData);        
        PhaseSpectrum(NmrData.lp,NmrData.rp,1);
        %NmrData.lpInd=ones(1,NmrData.ngrad).*NmrData.lp;
        %NmrData.rpInd=ones(1,NmrData.ngrad).*NmrData.rp;
        if isfield(NmrData,'lpInd')
            if length(NmrData.lpInd)==NmrData.arraydim
                %accept values
            else                
                NmrData.lpInd=ones(1,NmrData.arraydim).*NmrData.lp;               
            end
        else
            NmrData.lpInd=ones(1,NmrData.arraydim).*NmrData.lp;
                    
        end
        if isfield(NmrData,'rpInd')
            if length(NmrData.rpInd)==NmrData.arraydim
                %accept values
            else
                 NmrData.rpInd=ones(1,NmrData.arraydim).*NmrData.rp;
            end
        else
            NmrData.rpInd=ones(1,NmrData.arraydim).*NmrData.rp;
        end
        NmrData.th=0.0;
        hPlot=plot(hAxes,NmrData.Specscale,...
            real(NmrData.SPECTRA(:,NmrData.flipnr)));
        set(hPlot,'HitTest','off')
        xlabel(hAxes,'\bf Chemical shift');
        set(hAxes,'Xdir','Reverse');
        axis('tight')
        NmrData.xlim_spec=xlim();
        NmrData.ylim_spec=ylim();
        NmrData.pivotxdata=[NmrData.pivot NmrData.pivot];
        NmrData.pivotydata=get(hAxes,'ylim');
        NmrData.dosyconstantOriginal=NmrData.dosyconstant;
        NmrData.DELTAOriginal=NmrData.DELTA;
        NmrData.deltaOriginal=NmrData.delta;
        NmrData.tauOriginal=NmrData.tau;
        NmrData.gammaOriginal=NmrData.gamma;
        NmrData.array2nr=1;
        NmrData.narray2=NmrData.arraydim/NmrData.ngrad;
        NmrData.gradnr=1;
        NmrData.fshift=zeros(1,NmrData.arraydim);
        set(hEditShift,'string',num2str(0));
        set(hEditLinear,'string',num2str(0));
        NmrData.fshift=zeros(1,NmrData.arraydim);
        %AC
        NmrData.include=ones(1,NmrData.fn);
        NmrData.includelinepoints=[];
        NmrData.incpoints=[1 NmrData.fn];
        NmrData.LRRegionData=ones(100,1);
        NmrData.SVDcutoff=0.999;
        NmrData.locodosyopts=[0 0 0 0 0];
        NmrData.pfIterations=2500;
        set(hEditsderrmultiplier,'string',num2str(4));
        set(hEditDlimit,'string',num2str(25));
        set(hEditVlimit,'string',num2str(5));
        set(hEditSVDcutoff,'string',num2str(0.99));
        set(hLRWindowsShow,'Value',0)
        %AC
        
        set(hEditFlip,'string',num2str(NmrData.gradnr));
        set(hEditFlip2,'string',num2str(NmrData.array2nr));
        set(hEditFlipSpec,'string',num2str(NmrData.flipnr));
        set(hTextFlip,'string',['/' num2str(NmrData.ngrad)]);
        set(hTextFlip2,'string',['/' num2str(NmrData.narray2)]);
        set(hTextFlipSpec,'string',['/' num2str(NmrData.arraydim)]);
        set(hButtonFid,'value',0);
        set(hButtonSpec,'value',1);
        %Sanity check of dosy parameters - if they shoudl exist

        if ~strcmp(NmrData.delta,'non existing')
            if (NmrData.delta<=0) || (NmrData.delta==Inf) || (isnan(NmrData.delta))
                disp('WARNING. Diffusion encoding pulse width is not sensible.')
                disp('Setting it to a default value of 0.001.')
                disp('You should probably change it under "Edit -> parameters"')
                NmrData.delta=0.001;
            end
        end
        if ~strcmp(NmrData.DELTA,'non existing')
            if length(NmrData.DELTA)==1 %If an array is read, it is assumed the values are correct
                if (NmrData.DELTA<=0) || (NmrData.DELTA==Inf) || (isnan(NmrData.DELTA))
                    disp('WARNING. Diffusion time is not sensible.')
                    disp('Setting it to a default value of 0.1.')
                    disp('You should probably change it under "Edit -> parameters"')
                    NmrData.DELTA=0.1;
                end
            end
        end
        
        NmrData.DELTAprime=...
            NmrData.dosyconstant./(NmrData.gamma.^2.*NmrData.delta.^2);
        guidata(hMainFigure,NmrData);
        ButtonAutoscale_Callback();
        FTButton_Callback();
        guidata(hMainFigure,NmrData);
    end
    function Reference_function(source,eventdata)
        NmrData=guidata(hMainFigure);
        hReference=findobj(hAxes,'tag','Reference');
        delete(hReference);
        pt=get(gca,'currentpoint');
        xpos=pt(1,1);
        NmrData.referencexdata=[xpos xpos];
        NmrData.referenceydata=get(hAxes,'ylim');
        NmrData.reference=xpos;
        line(NmrData.referencexdata,NmrData.referenceydata,...
            'color','magenta','linewidth', 1.0,...
            'tag','Reference');
        drawnow
        %num2str(NmrData.reference,'%1.3f')
        set(hChangeEdit,'string',num2str(NmrData.reference,'%1.3f'));
        guidata(hMainFigure,NmrData);
    end
    function RDLeft_function(source,eventdata)
        NmrData=guidata(hMainFigure);
        hRDleft=findobj(hAxes,'tag','RDleft');
        delete(hRDleft);
        pt=get(gca,'currentpoint');
        xpos=pt(1,1);
        NmrData.RDleftxdata=[xpos xpos];
        NmrData.RDleftydata=get(hAxes,'ylim');
        NmrData.RDleft=xpos;
        line(NmrData.RDleftxdata,NmrData.RDleftydata,...
            'color','red','linewidth', 1.0,...
            'tag','RDleft');
        drawnow
        set(hRDshowLRCheck,'Value',1);
        guidata(hMainFigure,NmrData);
    end
    function RDRight_function(source,eventdata)
        NmrData=guidata(hMainFigure);
        hRDright=findobj(hAxes,'tag','RDright');
        delete(hRDright);
        pt=get(gca,'currentpoint');
        xpos=pt(1,1);
        NmrData.RDrightxdata=[xpos xpos];
        NmrData.RDrightydata=get(hAxes,'ylim');
        NmrData.RDright=xpos;
        line(NmrData.RDrightxdata,NmrData.RDrightydata,...
            'color','green','linewidth', 1.0,...
            'tag','RDright');
        drawnow
        set(hRDshowLRCheck,'Value',1);
        guidata(hMainFigure,NmrData);
    end
    function RDCentre_function(source,eventdata)
        NmrData=guidata(hMainFigure);
        hRDcentre=findobj(hAxes,'tag','RDcentre');
        delete(hRDcentre);
        pt=get(gca,'currentpoint');
        xpos=pt(1,1);
        NmrData.RDcentrexdata=[xpos xpos];
        NmrData.RDcentreydata=get(hAxes,'ylim');
        NmrData.RDcentre=xpos;
        line(NmrData.RDcentrexdata,NmrData.RDcentreydata,...
            'color','black','linewidth', 1.0,...
            'tag','RDcentre');
        drawnow
        set(hRDshowCheck,'Value',1);
        guidata(hMainFigure,NmrData);
    end
    function [ImportData]= ImportDOSYToolboxFormat(FileIdentifier)
        statfil=FileIdentifier;
        ImportData=[];
        k=1;
        while k
            ParmLine=fgetl(statfil);
            if ParmLine==-1;  break;  end;
            StrName=[]; 
            StringOne=[]; 
            ParmName=[]; 
            ParmForm=[]; 
            ParmUnit=[];
            ParmComment=[];
            if strcmp(ParmLine(1:2),'##')
                %Only for Human eyes
                continue
            elseif strcmp(ParmLine(1),'#');
                %parse stings
                StringOne=ParmLine(2:end);
                %parse mandatory parethesis
                if isempty(strfind(StringOne,')')) || isempty(strfind(StringOne,'('))
                    error('DOSY Toolbox: File import. Mandatory parenthesis (e.g. (double)) missing')
                else
                    ParmIndexOne=strfind(StringOne,'(');
                    ParmIndexTwo=strfind(StringOne,')');
                    ParmName=StringOne(ParmIndexOne+1:ParmIndexTwo-1);
                    SemiIdx=strfind(';',ParmName);
                    switch length(SemiIdx)
                        case 0
                            ParmForm=ParmName;
                            ParmForm(isspace(ParmForm))=[];
                            
                        case 1
                            ParmForm=ParmName(1: SemiIdx(1)-1)   ;
                            ParmForm(isspace(ParmForm))=[];
                            ParmUnit=ParmName(SemiIdx(1)+1:end );
                            ParmUnit(isspace(ParmUnit))=[];
                            
                        case 2
                            ParmForm=ParmName(1: SemiIdx(1)-1)  ;
                            ParmForm(isspace(ParmForm))=[];
                            ParmUnit=ParmName(SemiIdx(1)+1:SemiIdx(2)-1 );
                            ParmUnit(isspace(ParmUnit))=[];
                            ParmComment=ParmName(SemiIdx(2)+1:end );
                            
                        otherwise
                            error('DOSY Toolbox: File import. Illegal format withing parenthesis')
                    end
                end
                if strfind(StringOne,'[')
                    %Check for array
                    sq_idx1=strfind(StringOne,'[');
                    if strfind(StringOne,']')
                        sq_idx2=strfind(StringOne,']');
                    end
                    arrayval=str2num(StringOne(sq_idx1:sq_idx2)); 
                    if isempty(arrayval)
                        %Not intended as an array?)
                        error('DOSY Toolbox: File import. No value in array brackets - aborting import')
                    else
                        %read in array in cell array
                        StrName=StringOne(1:sq_idx1-1);
                        StrName(~isletter(StrName))=[];
                        
                        
                        if strcmp(StrName,'DataPoints') && isfield(ImportData,'ComplexData')
                            %These are the actual data points
                            ImportData.(StrName).Value=zeros(1,arrayval);
                            if strcmpi(ImportData.ComplexData.Value,'Yes')
                                disp('complex data')
                                for m=1:arrayval
                                    ParmLine=fgetl(statfil);
                                    if ParmLine==-1;  break;  end;
                                    TmpPoint=sscanf(ParmLine,'%e %e');
                                    ImportData.(StrName).Value(m)=complex(TmpPoint(1),TmpPoint(2));
                                end
                            else
                                for m=1:arrayval
                                    ParmLine=fgetl(statfil);
                                    if ParmLine==-1;  break;  end;
                                    ImportData.(StrName).Value(m)= sscanf(ParmLine,'%e');
                                end
                            end
                        else
                            ImportData.(StrName).Value=cell(1,arrayval);
                            for m=1:arrayval
                                ParmLine=fgetl(statfil);
                                if ParmLine==-1;  break;  end;
                                ImportData.(StrName).Value{1,m}=ParmLine;
                            end
                        end
                    end
                else
                    %parse non-arrayed data
                    StrName=StringOne(1:ParmIndexOne-1);
                    StrName(~isletter(StrName))=[];
                    ParmVal=StringOne(ParmIndexTwo+1:end);
                    %remove trailing white spaces
                    while  ~isempty(ParmVal) && isspace(ParmVal(1))
                        ParmVal(1)=[];
                    end
                    while ~isempty(ParmVal) && isspace(ParmVal(end))
                        ParmVal(end)=[];
                    end
                    %remove double quotes
                    while  ~isempty(ParmVal) && strcmp('"',ParmVal(1))
                        ParmVal(1)=[];
                    end
                    while ~isempty(ParmVal) && strcmp('"',ParmVal(end))
                        ParmVal(end)=[];
                    end
                    ImportData.(StrName).Value=[];
                    while ~isempty(ParmVal) && isspace(ParmVal(1))
                        ParmVal(1)=[];
                    end
                    if strcmp(ParmForm,'string')
                        ImportData.(StrName).Value=ParmVal;
                    elseif strcmp(ParmForm,'null')
                        ImportData.(StrName).Value='';
                    elseif isempty(ParmForm)
                        ImportData.(StrName).Value=ParmVal;
                        disp(['Warning: ' 'DOSY Toolbox: File import' 'missing data format. Importing as string'])
                    else
                        ImportData.(StrName).Value=str2num(ParmVal); 
                    end
                    
                end
                ImportData.(StrName).ParmForm=ParmForm;
                ImportData.(StrName).ParmUnit=ParmUnit;
                ImportData.(StrName).ParmComment=ParmComment;
%                 %ImportData.(StrName)
                % ImportData
            end
        end
        fclose(statfil);
        %ImportData.BinaryFileName
        
    end
    function ExportDOSYToolboxFormat(FileIdentifier, ExportType,DataFormat,FileName, PathName)
        statfil=FileIdentifier;
        %print out FID data to file
        if isunix()==1
            slashindex=find(NmrData.filename=='/');
        elseif NmrData.issynthetic==1      %AC
            slashindex=1;           
        else
            slashindex=find(NmrData.filename=='\');
        end
        fprintf(statfil,'%-s  \n','## DOSY Toolbox data file');
        
        fprintf(statfil,'%-s  \n','## ************ File and Data Information **********************');
        if DataFormat==1 %ASCII
            fprintf(statfil,'%-s\t\t\t\t\t\t  \n','#Binary File Name (null)');
        elseif DataFormat==2 %binary
            fprintf(statfil,'%-s\t\t\t\t\t\t  \n','#Binary File Name (string)','*.bin');
        else
            error('Unknown DataFormat')
        end
        switch ExportType
            case 1
                %complex FID
                fprintf(statfil,'%-s\t\t\t\t\t\t %-s  \n','#Data Class (string) ', '"FID"');
                fprintf(statfil,'%-s\t\t\t\t\t\t %-s  \n','#Complex Data (string)', '"Yes"');
            case 2
                %complex spectra
                fprintf(statfil,'%-s\t\t\t\t\t\t %-s  \n','#Data Class (string) ', '"Spectra"');
                fprintf(statfil,'%-s\t\t\t\t\t\t %-s  \n','#Complex Data (string)', '"Yes"');
            case 3
                %real spectra
                fprintf(statfil,'%-s\t\t\t\t\t\t %-s  \n','#Data Class (string) ', '"Spectra"');
                fprintf(statfil,'%-s\t\t\t\t\t\t %-s  \n','#Complex Data (string)', '"No"');
            case 4
                % DOSY display
                fprintf(statfil,'%-s\t\t\t\t\t\t %-s  \n','#Data Class (string) ', '"DOSY"');
                fprintf(statfil,'%-s\t\t\t\t\t\t %-s  \n','#Complex Data (string)', '"No"');
            case 5
                % SCORE residuals
                fprintf(statfil,'%-s\t\t\t\t\t\t %-s  \n','#Data Class (string) ', '"Spectra"');
                fprintf(statfil,'%-s\t\t\t\t\t\t %-s  \n','#Complex Data (string)', '"No"');
            case 6
                % SCORE components
                fprintf(statfil,'%-s\t\t\t\t\t\t %-s  \n','#Data Class (string) ', '"Spectra"');
                fprintf(statfil,'%-s\t\t\t\t\t\t %-s  \n','#Complex Data (string)', '"No"');
            otherwise
        end
        fprintf(statfil,'%-s\t\t\t\t\t\t %-s  \n','#Data Origin (string) ', '"DOSY Toolbox"');
        if  ExportType==1 || ExportType==2 ||ExportType==3
            %complex FID or complex spec or real spec
            fprintf(statfil,'%-s\t\t\t\t\t\t %-s  \n','#Data Type (string) ', '"DOSY data"');
        elseif  ExportType==4
            % DOSY display
            fprintf(statfil,'%-s\t\t\t\t\t\t %-s  \n','#Data Type (string) ', '"DOSY plot"');
        elseif  ExportType==5
            % SCORE residuals
            fprintf(statfil,'%-s\t\t\t\t\t\t %-s  \n','#Data Type (string) ', '"SCORE residuals"');
        elseif  ExportType==6
            % SCORE components
            fprintf(statfil,'%-s\t\t\t\t\t\t %-s  \n','#Data Type (string) ', '"SCORE components"');
        else
            error('File export: Unknown Data Class')
        end
        
        fprintf(statfil,'%-s\t\t\t\t\t\t\t %-s \n','#Date (string) ' ,['"' datestr(now) '"'] );
        fprintf(statfil,'%-s\t\t\t\t %-s  \n','#DOSY Toolbox Format Version (string) ', '0.1');
        fprintf(statfil,'%-s\t\t\t\t\t %-s  \n','#DOSY Toolbox Version (string) ', ['"' NmrData.version '"']);
        if  ExportType==1 || ExportType==2 ||ExportType==3
            %complex FID, complex spex or real spec
            if NmrData.arraydim==1
                fprintf(statfil,'%-s\t\t\t\t\t %-d  \n','#Number Of Arrays (integer)', 0);
            elseif  NmrData.arraydim==NmrData.ngrad
                fprintf(statfil,'%-s\t\t\t\t\t %-d  \n','#Number Of Arrays (integer)', 1);
            else
                fprintf(statfil,'%-s\t\t\t\t\t %-d  \n','#Number Of Arrays (integer)', 2);
            end
        elseif  ExportType==4 || ExportType==5 ||  ExportType==6
            % DOSY display,  SCORE residuals, SCORE components
            fprintf(statfil,'%-s\t\t\t\t\t %-d  \n','#Number Of Arrays (integer)', 1);
        else
            error('File export: Unknown Data Class')
        end
        
        fprintf(statfil,'%-s\t\t\t\t %-s  \n','#Spectrometer/Data System (string)', ['"' NmrData.type '"']);
        fprintf(statfil,'%-s\t\t\t\t\t\t %-s \n','#Title (string) ' , ['"' NmrData.filename(slashindex(end)+1:end) '"'] );
        
        fprintf(statfil,'%-s  \n','## ************ Matrix Format **********************************');
        switch ExportType
            case 1
                %complex FID
                fprintf(statfil,'%-s\t\t\t\t\t\t %-s  \n','#Complex Data (string)', '"Yes"');
                fprintf(statfil,'%-s\t\t\t\t\t %-d  \n','#Number Of Rows (integer) ', NmrData.arraydim);
                fprintf(statfil,'%-s\t\t\t\t\t %-d  \n','#Points Per Row (integer) ', NmrData.np);
                
            case 2
                %complex spectra
                fprintf(statfil,'%-s\t\t\t\t\t\t %-s  \n','#Complex Data (string)', '"Yes"');
                fprintf(statfil,'%-s\t\t\t\t\t %-d  \n','#Number Of Rows (integer) ', NmrData.arraydim);
                fprintf(statfil,'%-s\t\t\t\t\t %-d  \n','#Points Per Row (integer) ', NmrData.fn);
                
            case 3
                %real spectra
                fprintf(statfil,'%-s\t\t\t\t\t\t %-s  \n','#Complex Data (string)', '"No"');
                fprintf(statfil,'%-s\t\t\t\t\t %-d  \n','#Number Of Rows (integer) ', NmrData.arraydim);
                fprintf(statfil,'%-s\t\t\t\t\t %-d  \n','#Points Per Row (integer) ', NmrData.fn);
                
            case 4
                % DOSY display
                fprintf(statfil,'%-s\t\t\t\t\t\t %-s  \n','#Complex Data (string)', '"No"');
                fprintf(statfil,'%-s\t\t\t\t\t %-d  \n','#Number Of Rows (integer) ', length(NmrData.dosydata.Dscale));
                fprintf(statfil,'%-s\t\t\t\t\t %-d  \n','#Points Per Row (integer) ', length(NmrData.dosydata.Spectrum));
            case 5
                % SCORE residuals
                fprintf(statfil,'%-s\t\t\t\t\t\t %-s  \n','#Complex Data (string)', '"No"');
                fprintf(statfil,'%-s\t\t\t\t\t %-d  \n','#Number Of Rows (integer) ', NmrData.scoredata.ngrad);
                fprintf(statfil,'%-s\t\t\t\t\t %-d  \n','#Points Per Row (integer) ', NmrData.scoredata.np);
            case 6
                % SCORE components
                fprintf(statfil,'%-s\t\t\t\t\t\t %-s  \n','#Complex Data (string)', '"No"');
                fprintf(statfil,'%-s\t\t\t\t\t %-d  \n','#Number Of Rows (integer) ', NmrData.scoredata.ncomp);
                fprintf(statfil,'%-s\t\t\t\t\t %-d  \n','#Points Per Row (integer) ', NmrData.scoredata.np);
            otherwise
                
        end
        if  ExportType==1 || ExportType==2 ||ExportType==3 || ExportType==5 || ExportType== 6
            %complex FID or complex spec or real spec, SCORE residuals,
            %SCORE components
            fprintf(statfil,'%-s\t\t\t\t\t %-s  \n','#Y Axis Definition (string)', '"Gradient Amplitude"');
            fprintf(statfil,'%-s\t\t\t\t\t\t %-s  \n','#Y Label (null)', '');
        elseif  ExportType==4
            % DOSY display
            fprintf(statfil,'%-s\t\t\t\t\t %-s  \n','#Y Axis Definition (string)', '"Diffusion Scale"');
            fprintf(statfil,'%-s\t\t\t\t\t\t %-s  \n','#Y Label (string)', '"Diffusion coefficient m^{2} s^{-1} \times 10^{-10}"');
        else
            error('File export: Unknown Data Class')
        end
        
        fprintf(statfil,'%-s  \n','## ************ Acquisition Parameters *************************');
        fprintf(statfil,'%-s\t\t\t\t\t %-e  \n','#Acquisition Time (double; s) ', NmrData.at);
        fprintf(statfil,'%-s\t\t\t\t %-d  \n','#Complex Points Acquired (integer) ', NmrData.np);
        if  ExportType==1 || ExportType==2 ||ExportType==3
            %complex FID, complex spex or real spec
            fprintf(statfil,'%-s\t\t\t\t %-e  \n','#Lowest Frequency (double ; ppm)', NmrData.sp);
            fprintf(statfil,'%-s\t\t\t\t %-e  \n','#Observe Frequency (double ; MHz) ', NmrData.sfrq);
            fprintf(statfil,'%-s\t\t\t\t\t %-s  \n','#Observe Nucleus (string) ', '"1-H"');
            fprintf(statfil,'%-s\t\t\t\t\t %-e  \n','#Spectral Width (double ; ppm) ', NmrData.sw);
            fprintf(statfil,'%-s\t\t\t\t\t %-s  \n','#Pulse Sequence Name (string) ', '"Unknown"');
            if ExportType==1
            fprintf(statfil,'%-s\t\t\t\t\t\t %-e  \n','#Left Rotation (double)', NmrData.lrfid);
            end
        elseif  ExportType==4
            % DOSY display
            fprintf(statfil,'%-s\t\t\t\t %-f  \n','#Lowest Frequency (double ; ppm)', NmrData.dosydata.sp);
            fprintf(statfil,'%-s\t\t\t\t %-e  \n','#Observe Frequency (double ; MHz) ', NmrData.sfrq);
            fprintf(statfil,'%-s\t\t\t\t\t %-s  \n','#Observe Nucleus (string) ', '"1-H"');
            fprintf(statfil,'%-s\t\t\t\t\t %-f  \n','#Spectral Width (double ; ppm) ', NmrData.dosydata.wp);
            fprintf(statfil,'%-s\t\t\t\t\t %-s  \n','#Pulse Sequence Name (string) ', '"Unknown"');
        elseif  ExportType==5 || ExportType==6
            % DOSY display
            fprintf(statfil,'%-s\t\t\t\t %-f  \n','#Lowest Frequency (double ; ppm)', NmrData.scoredata.sp);
            fprintf(statfil,'%-s\t\t\t\t %-e  \n','#Observe Frequency (double ; MHz) ', NmrData.sfrq);
            fprintf(statfil,'%-s\t\t\t\t\t %-s  \n','#Observe Nucleus (string) ', '"1-H"');
            fprintf(statfil,'%-s\t\t\t\t\t %-f  \n','#Spectral Width (double ; ppm) ', NmrData.scoredata.wp);
            fprintf(statfil,'%-s\t\t\t\t\t %-s  \n','#Pulse Sequence Name (string) ', '"Unknown"');
        else
            error('File export: Unknown Data Class')
        end
        
        fprintf(statfil,'%-s  \n','## ************ Processing parameters ***************************');
        
        if  ExportType==1 ||  ExportType==2 ||  ExportType==3 ||  ExportType==4
            fprintf(statfil,'%-s\t\t\t\t\t %-d  \n','#Fourier Number (integer) ', NmrData.fn);
        elseif  ExportType==5 || ExportType==6
            fprintf(statfil,'%-s\t\t\t\t\t %-d  \n','#Fourier Number (integer) ', NmrData.scoredata.np);
        else
            error('File export: Unknown Fourier Number')
        end
        if  ExportType==1
            %complex FID, complex spec or real spec
            fprintf(statfil,'%-s\t\t\t %-e  \n','#Left Phase (double; degree; First order) ', NmrData.lp);
            fprintf(statfil,'%-s\t\t\t %-e  \n','#Right Phase (double; degree; Zeroth order) ', NmrData.rp);
            fprintf(statfil,'%-s%-d%-s\t\t\t \n','#Left Phase Array [', NmrData.arraydim ,'] (double data 1 ; T m^-1)');
            for k=1:NmrData.arraydim
                fprintf(statfil,'%-e  \n', NmrData.lpInd(k));
            end
            fprintf(statfil,'%-s%-d%-s\t\t\t \n','#Right Phase Array [', NmrData.arraydim ,'] (double data 1 ; T m^-1)');
            for k=1:NmrData.arraydim
                fprintf(statfil,'%-e  \n', NmrData.rpInd(k));
            end
        elseif  ExportType==2 ||ExportType==3 || ExportType==5 ||ExportType==6
            fprintf(statfil,'%-s\t\t\t %-e  \n','#Left Phase (double; degree; First order) ', 0);
            fprintf(statfil,'%-s\t\t\t %-e  \n','#Right Phase (double; degree; Zeroth order) ', 0);
        elseif  ExportType==4
            %phase parameters not relevant
        else
            error('File export: Unknown Data Class')
        end
        
        fprintf(statfil,'%-s  \n','## ************ Diffusion Parameters ****************************');
        if  ExportType==1 || ExportType==2 ||ExportType==3 || ExportType==5 ||ExportType==6
            %complex FID or complex spec or real spec
            fprintf(statfil,'%-s\t\t\t\t %-e  \n','#Diffusion Delay (double ; s ; DELTA) ', NmrData.DELTA);
            fprintf(statfil,'%-s\t\t\t %-e  \n','#Diffusion Encoding Time (double ; s ; delta) ', NmrData.delta);
            fprintf(statfil,'%-s\t\t\t\t\t\t %-e  \n','#Dosygamma (double) ', NmrData.gamma);
            fprintf(statfil,'%-s\t\t\t\t\t %-e  \n','#Dosytimecubed (double) ', NmrData.dosyconstant/NmrData.gamma.^2);
            fprintf(statfil,'%-s\t\t\t\t\t %-s  \n','#Gradient Shape (string) ', '"Square"');
            fprintf(statfil,'%-s\t\t\t\t\t %-s  \n','#Pulse Sequence Type (string)', '"Other"');
            fprintf(statfil,'%-s\t\t\t\t\t   \n','#Tau (null)');
        elseif  ExportType==4
            % DOSY display
        else
            error('File export: Unknown Data Class')
        end
        fprintf(statfil,'%-s  \n','## ************ Arrays *****************************************');
        if  ExportType==1 || ExportType==2 ||ExportType==3
            %complex FID or complex spec or real spec
            fprintf(statfil,'%-s%-d%-s\t\t\t \n','#Gradient Amplitude [', NmrData.ngrad ,'] (double data 1 ; T m^-1)');
            for k=1:NmrData.ngrad
                fprintf(statfil,'%-e  \n', NmrData.Gzlvl(k));
            end
            
        elseif  ExportType==4
            % DOSY display
            fprintf(statfil,'%-s%-d%-s\t\t\t \n','#Diffusion Scale [', length(NmrData.dosydata.Dscale) ,'] (double data 1 ; m^2 s^-1 * 10^-10)');
            for k=1:length(NmrData.dosydata.Dscale)
                fprintf(statfil,'%-f  \n', NmrData.dosydata.Dscale(k));
            end
        elseif  ExportType==5
            %SCORE Residuals
            fprintf(statfil,'%-s%-d%-s\t\t\t \n','#Gradient Amplitude [', NmrData.scoredata.ngrad ,'] (double data 1 ; T m^-1)');
            for k=1:NmrData.scoredata.ngrad
                fprintf(statfil,'%-e  \n', NmrData.scoredata.Gzlvl(k));
            end
        elseif  ExportType==6
            % SCORE components
            fprintf(statfil,'%-s%-d%-s\t\t\t \n','#Component Number [', NmrData.scoredata.ncomp ,'] (double data 1 ; m^2 s^-1 * 10^-10)');
            for k=1:NmrData.scoredata.ncomp
                fprintf(statfil,'%-f  \n', k);
            end
        else
            error('File export: Unknown Data Class')
        end
        if NmrData.issynthetic==1
            fprintf(statfil,'%-s  \n','## ************ Synthetic Parameters *************************');
            fprintf(statfil,'%-s\t\t\t\t %-d  \n','#Number of Synthetic Peaks (integer) ', str2num(get(hEditnpeaks,'string')));
            fprintf(statfil,'%-s\t\t\t %-e  \n','#Lowest Gradient Strength (double ; T m-1) ', str2num(get(hEditmingrad,'string')));
            fprintf(statfil,'%-s\t\t\t %-e  \n','#Highest Gradient Strength (double ; T m-1) ', str2num(get(hEditmaxgrad,'string')));
            fprintf(statfil,'%-s\t\t\t\t %-d  \n','#Number of DOSY Increments (integer) ', str2num(get(hEditni,'string')));
            fprintf(statfil,'%-s\t\t\t\t %-d  \n','#Signal to Noise Ratio (integer) 1/ ', str2num(get(hEditnoise,'string')));

            SynthTableData=get(hTableSynthPeaks,'Data');
            SynthData.Freqs=SynthTableData(:,1);
            SynthData.Dvals=SynthTableData(:,2);
            SynthData.Amps=SynthTableData(:,3);
            SynthData.lw=SynthTableData(:,4);
            SynthData.gw=SynthTableData(:,5);
        
            fprintf(statfil,'%-s\t\t\t \n','#Peak Frequencies (double data ; Hz)');
            for k=1:length(SynthData.Freqs)
                fprintf(statfil,'%-e  \n', SynthData.Freqs(k));
            end
            
            fprintf(statfil,'%-s\t\t\t \n','#Diffusion Coefficients (double data ; m^2 s^-1 * 10^-10)');
            for k=1:length(SynthData.Dvals)
                fprintf(statfil,'%-e  \n', SynthData.Dvals(k));
            end
            
            fprintf(statfil,'%-s\t\t\t \n','#Peak Amplitudes (double data;)');
            for k=1:length(SynthData.Amps)
                fprintf(statfil,'%-e  \n', SynthData.Amps(k));
            end
            
            fprintf(statfil,'%-s\t\t\t \n','#Line Widths Lorentzian (double data ; Hz)');
            for k=1:length(SynthData.lw)
                fprintf(statfil,'%-e  \n', SynthData.lw(k));
            end
            
            fprintf(statfil,'%-s\t\t\t \n','#Line Widths Gaussian (double data ; Hz)');
            for k=1:length(SynthData.gw)
                fprintf(statfil,'%-e  \n', SynthData.gw(k));
            end
        end

        fprintf(statfil,'%-s  \n','## ************ Actual Data Points *****************************');
        
        switch ExportType
            case 1
                %complex FID
                fprintf(statfil,'%-s%-d%-s\t\t\t\t \n','#Data Points [', NmrData.np*NmrData.arraydim ,'] (double)');
                
                
            case 2
                %complex spectra
                fprintf(statfil,'%-s%-d%-s\t\t\t\t \n','#Data Points [', NmrData.fn*NmrData.arraydim ,'] (double)');
                
            case 3
                %real spectra
                fprintf(statfil,'%-s%-d%-s\t\t\t\t \n','#Data Points [', NmrData.fn*NmrData.arraydim ,'] (double)');
                
                
            case 4
                % DOSY display
                fprintf(statfil,'%-s%-d%-s\t\t\t\t \n','#Data Points [', length(NmrData.dosydata.Dscale).*length(NmrData.dosydata.Spectrum),'] (double)');
                
            case 5
                % SCORE residuals
                fprintf(statfil,'%-s%-d%-s\t\t\t\t \n','#Data Points [', NmrData.scoredata.np*NmrData.scoredata.ngrad,'] (double)');
                
            case 6
                % SCORE components
                fprintf(statfil,'%-s%-d%-s\t\t\t\t \n','#Data Points [', NmrData.scoredata.ncomp*NmrData.scoredata.np ,'] (double)');
                
            otherwise
                
        end
        
        
        if DataFormat==1 %ASCII
            
            switch ExportType
                case 1
                    %complex FID
                    hp=waitbar(0,'Exporting DOSY data (FID)');                
                   
                    for k=1:NmrData.arraydim
                        waitbar(k/NmrData.arraydim);
                        for m=1:NmrData.np
                            fprintf(statfil,'%-e %e  \n', real(NmrData.FID(m,k)), imag(NmrData.FID(m,k)) );
                        end
                    end
                   
                    close(hp)
                    
                case 2
                    %complex spectra
                    hp=waitbar(0,'Exporting DOSY data (complex spectra)');
                    NmrData.SPECTRA=flipud(NmrData.SPECTRA);
                    for k=1:NmrData.ngrad
                        waitbar(k/NmrData.ngrad);
                        for m=1:NmrData.fn
                            fprintf(statfil,'%-e %e  \n', real(NmrData.SPECTRA(m,k)), imag(NmrData.SPECTRA(m,k)) );
                        end
                    end
                    close(hp)
                case 3
                    %real spectra
                    hp=waitbar(0,'Exporting DOSY data (real spectra)');
                    NmrData.SPECTRA=flipud(NmrData.SPECTRA);
                    for k=1:NmrData.ngrad
                        waitbar(k/NmrData.ngrad);
                        for m=1:NmrData.fn
                            fprintf(statfil,'%-e \n', real(NmrData.SPECTRA(m,k)) );
                        end
                    end
                    close(hp)
                    
                case 4
                    % DOSY display
                    hp=waitbar(0,'Exporting DOSY plot');
                    NmrData.dosydata.DOSY=rot90(NmrData.dosydata.DOSY,2);
                    for k=1:length(NmrData.dosydata.Dscale)
                        waitbar(k/length(NmrData.dosydata.Dscale));
                        for m=1:length(NmrData.dosydata.Spectrum)
                            fprintf(statfil,'%-e  \n', NmrData.dosydata.DOSY(m,k));
                        end
                    end
                    close(hp)
                case 5
                    % SCORE residuals
                    hp=waitbar(0,'Exporting SCORE residuals');
                    %size(NmrData.scoredata.RESIDUALS)
                    for k=1:NmrData.scoredata.ngrad
                        waitbar(k/NmrData.scoredata.ngrad);
                        for m=1:NmrData.scoredata.np
                            fprintf(statfil,'%-e \n', NmrData.scoredata.RESIDUALS(m,k) );
                        end
                    end
                    close(hp)
                case 6
                    % SCORE components
                    hp=waitbar(0,'Exporting SCORE components');
                    %Normalise components?
                    %size(NmrData.scoredata.COMPONENTS)
                    for k=1:NmrData.scoredata.ncomp
                        waitbar(k/NmrData.ngrad);
                        for m=1: NmrData.scoredata.np
                            fprintf(statfil,'%-e \n', NmrData.scoredata.COMPONENTS(k,m) );
                        end
                    end
                    close(hp)
                otherwise
            end
            fclose(statfil);
            
        elseif DataFormat==2 %binary
            fclose(statfil);
            filepath=[PathName FileName];
            filepath=[PathName FileName];
            filepath=filepath(1:(end-4));
            filepath=[filepath '.bin'];
            binfile=fopen(filepath, 'w','b');
            switch ExportType
                case 1
                    %complex FID
                    hp=waitbar(0,'Exporting DOSY data (FID)');
                    fwrite(binfile,real(NmrData.FID),'int64',0,'b');
                    fwrite(binfile,imag(NmrData.FID),'int64',0,'b');
                    close(hp)
                    
                case 2
                    %complex spectra
                    hp=waitbar(0,'Exporting DOSY data (complex spectra)');
                    NmrData.SPECTRA=flipud(NmrData.SPECTRA);
                    fwrite(binfile,real(NmrData.SPECTRA),'int64',0,'b');
                    fwrite(binfile,imag(NmrData.SPECTRA),'int64',0,'b');
                    close(hp)
                case 3
                    %real spectra
                    hp=waitbar(0,'Exporting DOSY data (real spectra)');
                    NmrData.SPECTRA=flipud(NmrData.SPECTRA);
                    fwrite(binfile,real(NmrData.SPECTRA),'int64',0,'b');
                    close(hp)
                    
                case 4
                    % DOSY display
                    hp=waitbar(0,'Exporting DOSY plot');
                    NmrData.dosydata.DOSY=rot90(NmrData.dosydata.DOSY,2);
                    for k=1:length(NmrData.dosydata.Dscale)
                        waitbar(k/length(NmrData.dosydata.Dscale));
                        for m=1:length(NmrData.dosydata.Spectrum)
                            fprintf(statfil,'%-e  \n', NmrData.dosydata.DOSY(m,k));
                        end
                    end
                    close(hp)
                case 5
                    % SCORE residuals
                    hp=waitbar(0,'Exporting SCORE residuals');
                    %size(NmrData.scoredata.RESIDUALS)
                    for k=1:NmrData.scoredata.ngrad
                        waitbar(k/NmrData.scoredata.ngrad);
                        for m=1:NmrData.scoredata.np
                            fprintf(statfil,'%-e \n', NmrData.scoredata.RESIDUALS(m,k) );
                        end
                    end
                    close(hp)
                case 6
                    % SCORE components
                    hp=waitbar(0,'Exporting SCORE components');
                    %Normalise components?
                    %size(NmrData.scoredata.COMPONENTS)
                    for k=1:NmrData.scoredata.ncomp
                        waitbar(k/NmrData.ngrad);
                        for m=1: NmrData.scoredata.np
                            fprintf(statfil,'%-e \n', NmrData.scoredata.COMPONENTS(k,m) );
                        end
                    end
                    close(hp)
                otherwise
            end
            fclose(binfile);
        else
            fclose(statfil);
            error('unknown DataFormat')
        end
    end
    function fpeakclusters(handles, eventdata)
        if NmrData.th==0
            errordlg('Please set a threshold before auto-segmenting.')
        else
            % Take the average y value for the spectrum and set the threshhold for peakfind
            % clustering as that, making sure this is above the noise.
            %   OR use a user defined threshold (current system).
            NmrData=guidata(hMainFigure);
            set(hLRWindowsShow,'Value',1)
            hIncludeline=findobj(hAxes,'tag','includeline');
            set(hIncludeline,'Visible','Off')
            hThresh=findobj(hAxes,'tag','threshold');
            delete(hThresh);  %(works even if hthresh==[])
            threshold=NmrData.thresydata(1,1);
            %     value=sum(sum(real(NmrData.SPECTRA)));
            %     threshold=(value/(NmrData.fn*NmrData.ngrad));
            %     RMSnoise=calcRMSnoise(NmrData.SPECTRA,NmrData.Specscale);
            %     if threshold<(RMSnoise*10)
            %         threshold=RMSnoise*10;
            %     end
            firstspect=real(NmrData.SPECTRA(:,1));
            sw=(max(abs(NmrData.Specscale))+min(abs(NmrData.Specscale)));
            leeway=round(25*(NmrData.fn/(sw*NmrData.sfrq)));
            currentpoint=0;
            numwin=0;
            rows3=0;
            finished=0;
            winstartind=0;
            winendin=0;
            while finished==0
                numwin=numwin+1;
                [rows2]=find((firstspect(currentpoint+1:end,1)>(threshold)),1);
                rows2=rows2+currentpoint+1;
                currentpoint=rows2;
                if rows2
                    [rows3]=find((firstspect(rows2+1:end,1)<(threshold)),1);
                    currentpoint=currentpoint+rows3;
                    winstartind(numwin)=rows2; %#ok<AGROW>
                    winendind(numwin)=currentpoint; %#ok<AGROW>
                else
                    finished=1;
                end
            end
            numwin=numwin-1; %test is past numwin+1
            
            count=0;
            peakline=ones(1,length(NmrData.Specscale));
            % code for ignoring very thin peaks and grouping close, narrow peaks
            
            % for m=1:length(winstartind)
            %     if (winendind(m)-winstartind(m))>(leeway/4)
            %         count=count+1;
            %         starttmp(count)=winstartind(m);
            %         endtmp(count)=winendind(m);
            %     end
            % end
            % winstartind=starttmp;
            % winendind=endtmp;
            for k=1:length(winstartind)
                winstartind(k)=winstartind(k)-leeway; %#ok<AGROW>
                winendind(k)=winendind(k)+leeway;
                peakline(winstartind(k):winendind(k))=NaN;
            end
            columns=peakline==1;
            peakline=ones(1,length(NmrData.include));
            peakline(1,columns)=NaN;
            hPeakclustline=line(NmrData.Specscale,peakline*threshold,...
                'color',[0 0 0],'linewidth', 1.0,...
                'tag','peakclustline');
            NmrData.nwin=length(winstartind);
            NmrData.winstart=NmrData.Specscale(winstartind);
            NmrData.winend=NmrData.Specscale(winendind);
            NmrData.LRRegionData=ones(length(NmrData.winstart),1);
            set(hRegionsTable,'Data', NmrData.LRRegionData)
            guidata(hMainFigure,NmrData);
        end
    end
    function DrawIncludeline(source,eventdata)
        NmrData=guidata(hMainFigure);
        ypos=get(hAxes,'ylim');
        ypos=(ypos(2)-ypos(1))/2;
        hIncludeline=findobj(hAxes,'tag','includeline');
        delete(hIncludeline)
        ydata=ypos.*NmrData.include;
        xlimits=get(hAxes,'xlim');
        hIncludeline=line(NmrData.Specscale,ydata,...
            'color',[0 0 0],'linewidth', 1.0,...
            'tag','includeline'); 
        set(hAxes,'xlim',xlimits);
        guidata(hMainFigure,NmrData);
    end
    function Includeline_function(source,eventdata)
        NmrData=guidata(hMainFigure);
        NmrData.xlim_spec=xlim();
        NmrData.ylim_spec=ylim();
        switch get(gcbf, 'SelectionType')
            case 'normal'
                %leftclick
                %add a new point
                pt=get(gca,'currentpoint');
                xpos=pt(1,1);
                ypos=pt(2,2);
                xl=xlim();
                yl=ylim();
                if xpos>xl(2) || xpos<xl(1) || ypos>yl(2) || ypos<yl(1)
                    %  disp('hi')
                    %outside axis
                else
                    NmrData.IncludePoints=[NmrData.IncludePoints xpos];
                end
                
            case 'alt'
                %disp('rightclick')
                %remove last point
                if ~isempty(NmrData.IncludePoints>0)
                    NmrData.IncludePoints(end)=[];
                end
            case 'extend'
                %middleclick
                %Stop taking new points
                set(hMainFigure,'WindowButtonDownFcn','')
            case 'open'
                %doubleclick
                %do nothing
                
            otherwise
                error('illegal choice')
        end
        NmrData.includelinepoints=unique(NmrData.IncludePoints);
        NmrData.includelinepoints=sort(NmrData.includelinepoints);
        %disp(num2str(NmrData.includelinepoints))
        NmrData.include=ones(1,NmrData.fn);
        inpoints=[1 NmrData.fn];
        for k=1:length(NmrData.includelinepoints)
            inpoints=[inpoints round(NmrData.fn*...
                (NmrData.includelinepoints(k)-NmrData.sp)/NmrData.sw)]; %#ok<AGROW>
        end
        inpoints=unique(inpoints);
        inpoints=sort(inpoints);
        inpoints1=inpoints(1:2:end);
        inpoints2=inpoints(2:2:end);
        for k=1:(length(inpoints1))
            if k<=length(inpoints2)
                NmrData.include(inpoints1(k):inpoints2(k))=NaN;
            end
        end

        % retrieving the number of components in the window.

        NmrData.winstart=NmrData.IncludePoints(1:2:end);
        NmrData.winend=NmrData.IncludePoints(2:2:end);
        
%         % retrieving the number of components in the window.
%         if NmrData.startORend==0
%             NmrData.winstart=[NmrData.winstart,xpos];
%         elseif NmrData.startORend==1
%             NmrData.winend=[NmrData.winend,xpos];
%         end
%         
%         % making sure you're on the right end of a window
%         if NmrData.startORend==0
%             NmrData.startORend=1;
%         elseif NmrData.startORend==1
%             NmrData.startORend=0;
%         end
        
        NmrData.nwin=length(NmrData.winstart);
        NmrData.LRRegionData=ones(length(NmrData.winstart),1);
        set(hRegionsTable,'Data', NmrData.LRRegionData)
        
        guidata(hMainFigure,NmrData);
        PlotSpectrum();
        set(hAxes,'ButtonDownFcn',@Includeline_function);
        %set(hMainFigure,'WindowButtonDownFcn',@Includeline_function);
    end
%if strcmp(NmrData.local,'yes') %only if local
end
