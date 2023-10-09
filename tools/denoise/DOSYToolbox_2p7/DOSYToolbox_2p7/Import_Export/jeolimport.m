function [jeoldata]=jeolimport()
%   [jeoldata]=jeolimport()
%   Imports PFG-NMR data in Jeol delta format
%   Useage: Point to the *.jdf file that contains the raw data. The
%           imported data will be returned in the structure jeoldata
%           containing the following members:
%               procpar: structure containing the information in the *.hdr
%                        file (process and acqusition parameters)
%               ngrad: number of gradient levels
%               sw: spectral width (in ppm)
%               sp: start of spectrum (in ppm)
%               filename: original file name and path
%               np: number of complex data points per gradient level
%               sfrq: spectrometer frequency (im MHz)
%               at: acquisition time (in seconds)%
%               gamma: magnetogyric ratio of the nucleus
%               Gzlvl: gradient strengths
%               DELTA: diffusion time
%               delta: diffusion encoding time
%               dosyconstant: gamma.^2*delts^2*DELTAprime
%               FID: Free induction decays

%   Example:
%   See also: DOSYToolbox, dosy_mn, score_mn, decra_mn, mcr_mn, varianimport,
%             brukerimport, jeolimport, peakpick_mn, dosyplot_mn,
%             dosyresidual, dosyplot_gui, scoreplot_mn, decraplot_mn,
%             mcrplot_mn
%
%   This is a part of the DOSYToolbox
%   Copyright 2007-2008  <Mathias Nilsson>

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
[file path]=uigetfile('*.jdf','Choose the JEOL file (*.jdf)')
clc
byte_format='b'; %always Big Endian for Header, History and List
fileid=fopen([path file],'r',byte_format);
    jeoldata.filename=[path file];

%% read in Header
File_Identifier=fread(fileid,8,'char=>char')'; %#ok<*NASGU> % JEOL.NMR otherwise incorrect data
Endian=fread(fileid,1,'uint8');  % 0 fopr Big an 1 for Little
Major_Version=fread(fileid,1,'uint8'); %must be 1
Minor_Version=fread(fileid,2,'uint8') ;%must be 1
Data_Dimension_Number=fread(fileid,1,'uint8') ; %1-8 (8 is max dimensionality)
Data_Dimension_Exist=fread(fileid,1,'uint8') ;% see manual
Data_Type=fread(fileid,1,'ubit2')
Data_Format=fread(fileid,1,'bit6')
Instrument=fread(fileid,1,'uint8'); % see manual
Translate=fread(fileid,8,'uint8') ;% should always be 1,2,3,4,5,6,7,8 otherwise indicated processed data
Data_Axis_Type=fread(fileid,8,'uint8') % (1= real, 3=complex) for more see manual
%Data_Units=fread(fileid,16,'uint8') %  see manual
for k=1:8
    Data_Units(k).Power=fread(fileid,1,'ubit4');
    Data_Units(k).SIprefix=fread(fileid,1,'ubit4');
    Data_Units(k).Base=fread(fileid,1,'int8');
end
Title=fread(fileid,124,'char=>char')'; % ;
Data_Axis_Ranged=fread(fileid,8,'ubit4')'; %  see manual
Data_Points=fread(fileid,8,'int32')' %  see manual
Data_Offset_Start=fread(fileid,8,'int32')' %  see manual
Data_Offset_Stop=fread(fileid,8,'int32')' %  see manual
Data_Axis_Start=fread(fileid,8,'double')'; %  see manual
Data_Axis_Stop=fread(fileid,8,'double')'; %  see manual
Creation_Time=fread(fileid,8,'ubit4');%  see manual
Revision_Time=fread(fileid,8,'ubit4'); %  see manual
Node_Name=fread(fileid,16,'char=>char')';
Site=fread(fileid,128,'char=>char')';
Author=fread(fileid,128,'char=>char')';
Comment=fread(fileid,128,'char=>char')';
Data_Axis_Titles=fread(fileid,256,'char=>char')';
Base_Freq=fread(fileid,8,'double')';
Zero_Point=fread(fileid,8,'float64')';
Reversed=fread(fileid,8,'ubit1')';
fread(fileid, 11);
%RESERVED=fread(fileid,3,'ubit1')'
%Annotation_OK=fread(fileid,8,'ubit1')'
History_Used=fread(fileid,1,'int32')';
History_Length=fread(fileid,1,'int32')';
Param_Start=fread(fileid,1,'int32')';
Param_Length=fread(fileid,1,'int32')';
List_Start=fread(fileid,8,'int32')'; %  see manual
List_Length=fread(fileid,8,'int32')'; %  see manual
Data_Start=fread(fileid,1,'int32')'
Data_Length=fread(fileid,1,'int64')';
Context_Start=fread(fileid,1,'int64')';
Context_Length=fread(fileid,1,'int32')';
Annote_Start=fread(fileid,1,'int64')';
Annote_Length=fread(fileid,1,'int32')';
Total_Size=fread(fileid,1,'int64')';
Unit_Location=fread(fileid,8,'int8')'; %  see manual
Compound_Units=fread(fileid,2,'bit12')'; %  see manual

%% read in History
fclose(fileid)
byte_format='b'; %always Big Endian for Header, History and List
fileid=fopen([path file],'r',byte_format);
fread(fileid,1360);
History=fread(fileid,History_Length,'char=>char')';

%% read in Parameters

if Endian==0
    byte_format='b'; % Big Endian
else
    byte_format='l'; % Little Endian
end

fileid=fopen([path file],'r',byte_format);
fread(fileid,Param_Start);
% read parameter section header
Parameter_Size=fread(fileid,1,'int32')';
Low_Index=fread(fileid,1,'int32')';
High_Index=fread(fileid,1,'int32')';
Total_Size=fread(fileid,1,'int32')';

nparams=High_Index+1;

%nparams=10;
for k=1:nparams
    fread(fileid,4); %jumpin the undocumented Class Structure
    Unit_Scaler=fread(fileid,1,'int16')'; %multiplication factor for unit if not 0
    %Units=fread(fileid,10,'int8')' %  see manual
    for k=1:5
        Units(k).Power=fread(fileid,1,'ubit4'); %#ok<*AGROW>
        Units(k).SIprefix=fread(fileid,1,'ubit4');
        Units(k).Base=fread(fileid,1,'int8');
    end
    fread(fileid,16);
    Value_Type=fread(fileid,1,'int32')';
    fseek(fileid,-20,'cof');
    
    switch Value_Type
        case 0 %string
            Value=fread(fileid,16,'char=>char')';
            fread(fileid,4);
            
        case 1 %integer
            Value=fread(fileid,1,'int32')';
            fread(fileid,16);
            
        case 2 %float
            Value=fread(fileid,1,'float64')';
            fread(fileid,12);
            
        case 3 %Complex
            rl=fread(fileid,1,'float64')';
            im=fread(fileid,1,'float64')';
            Value=complex(rl,im);
            fread(fileid,4);
            
        case 4 %Infinity
            disp('Infinity - not sure how to handle this')
            Value=fread(fileid,1,'int32')';
            fread(fileid,16);
            
        otherwise
            disp('Unknkown Value_Type')
            fread(fileid,20);
    end    
    Name=fread(fileid,28,'char=>char')';
    Name(isspace(Name))=[] ;
    procpar.(Name).Value=Value;
    procpar.(Name).Units=Units;
    procpar.(Name).Unit_Scaler=Unit_Scaler;
    procpar.(Name).Value_Type=Value_Type;
end

%% read in Data

    fseek(fileid,Data_Start,'bof');
    
%Data_Format=1
switch Data_Format
    
    case 1 %1D
        disp('1D')
        if Data_Type==0 %64-bit
             jeoldata.arraydim=1
            jeoldata.ngrad=1
            
            fseek(fileid,Data_Offset_Start(1),'cof');   
            readpoints= Data_Offset_Stop(1)-Data_Offset_Start(1)+1;
            REAL=fread(fileid,readpoints,'float64'); 
            fseek(fileid,Data_Offset_Start(1),'cof');            
            IMAG=fread(fileid,readpoints,'float64');     
            
            figure
            plot(REAL)
%             figure
%             plot(IMAG)
%             
%               figure
%             plot(real(fft(REAL)))
%             figure
%             plot(real(fft(IMAG)))
%             
            DATA=complex(REAL,IMAG);
            
            ttt=REAL;
            j=0
            for k=1:readpoints
%                 k
%                 mod(k,4)
%                 rem(4,k)
                if mod(k,6)==1
                    k
                    j=j+1
                    mmm(j)=REAL(k);
                    nnn(j)=IMAG(k);
                end
            end
            
            xxx=complex(mmm,nnn);
            figure
            plot(real(xxx))
            figure
            plot(abs((fft(xxx))))
                
            
            
        elseif Data_Type==1 %32-bit
            disp('32bit data - untested import')
            
        else
            error('unknown Data_Type')
        end
        
    case 2 %2D
        disp('2D')
        
    case 12 %2D
         jeoldata.arraydim=10
         jeoldata.ngrad=10
        disp('small 2D')
        twoDsize=Data_Offset_Stop(2) - Data_Offset_Start(2)+1
         twoDsize=12
        readpoints= Data_Offset_Stop(1)-Data_Offset_Start(1)+1
        DATA=zeros(readpoints,twoDsize);
        
       
        for k=1:twoDsize
            fseek(fileid,Data_Offset_Start(1),'cof');              
            REAL=fread(fileid,readpoints,'float64'); 
            fseek(fileid,Data_Offset_Start(1),'cof');            
            IMAG=fread(fileid,readpoints,'float64'); 
            DATA(:,k)=complex(REAL,IMAG);
        end
        
     
        fseek(fileid,Data_Start,'bof');
        DATA2=fread(fileid,readpoints*twoDsize,'float64'); 
            ttt=reshape(DATA,readpoints*twoDsize,1);
            figure
            plot(real(ttt))
            
            figure
            for k=1:12
            subplot(6,2,k)
            plot(real(DATA(:,k)))
            end
        find(ttt(1:1024*8)==0)
        
            j=0;
            for k=1:readpoints/2
                if mod(k,12)==1
                    k;
                    j=j+1;
                    mmm(j)=DATA(k,1);
                    nnn(j)=DATA(k,1);
                end
            end
            
             figure
            plot(real(mmm))
            figure
            plot(abs((fft(mmm))))
        
            
            
%          xxx=complex(mmm,nnn);
%             figure
%             plot(real(xxx))
%             figure
%             plot(abs((fft(xxx))))
        
    otherwise
        error('Only 1D and 2D data supported - this looks like a higher dimensionality')
        
end



fclose(fileid);


%% Set up the data for the DOSY Toolbox

 jeoldata.procpar=procpar;
 
 %Assuming 1D data for now

 jeoldata.lp=0;
 jeoldata.rp=0;
 
 jeoldata.np=Data_Points(1);
 
 
 % Spectrometer frequency
 if procpar.X_FREQ.Units(1).Base==13 % SI Hz
     jeoldata.sfrq=procpar.X_FREQ.Value;
 else
     error('Unknown unit for the spectrometer frequency')
 end 
 if procpar.X_FREQ.Units(1).SIprefix==0 %Hz
     jeoldata.sfrq= jeoldata.sfrq*1e-6;
 elseif  procpar.X_FREQ.Units(1).SIprefix==-1 %kHz
     jeoldata.sfrq= jeoldata.sfrq*1e-3;
 elseif  procpar.X_FREQ.Units(1).SIprefix==-2 %MHz
     jeoldata.sfrq= jeoldata.sfrq;
 else
     error('Unknown SI modifier for spectrometer frequency')
 end
 
 
 if procpar.X_SWEEP.Units(1).Base==13 % SI Hz
     jeoldata.sw=procpar.X_SWEEP.Value;
 else
     error('Unknown unit for the spectrometer frequency')
 end 
 if procpar.X_SWEEP.Units(1).SIprefix==0 %Hz
     jeoldata.sw= jeoldata.sw;
 elseif  procpar.X_SWEEP.Units(1).SIprefix==-1 %kHz
     jeoldata.sw= jeoldata.sw*1e3;
 elseif  procpar.X_SWEEP.Units(1).SIprefix==-2 %MHz
     jeoldata.sw=jeoldata.sw*1e6;
 else
     error('Unknown SI modifier for spectrometer frequency')
 end
 jeoldata.sw=jeoldata.sw/jeoldata.sfrq; %now in ppm
 
 
 if procpar.X_ACQ_DURATION.Units(1).Base==28 % SI seconds
     jeoldata.at=procpar.X_ACQ_DURATION.Value;
 else
     error('acquisition time not in seconds - only time domain data supported')
 end 
 
 if procpar.X_ACQ_DURATION.Units(1).SIprefix==0 % s
     jeoldata.at= jeoldata.at;
 elseif  procpar.X_ACQ_DURATION.Units(1).SIprefix==1 % ms
     jeoldata.at= jeoldata.at*1e-3;
 else
     error('Unknown SI modifier for acquisition time frequency')
 end
 

 
        jeoldata.Gzlvl=0;
        jeoldata.dosyconstant=0;
        jeoldata.ngrad=1;
        jeoldata.gamma=267524618.573;
        jeoldata.DELTA='non existing';
        jeoldata.delta='non existing';
        jeoldata.DAC_to_G='non existing';
 
 
 
   disp('Using the JEOL referencing has not been implemented')
    disp('The spectrum will be set to start at -1 ppm')
    jeoldata.sp=-1;
 
 jeoldata.FID=DATA;
 
 
 
 jeoldata.digshift=0;
 jeoldata



% 
% 
% Data_Format=fread(fileid,1,'uint8') % 0 = 64bit float; 1 = 32bit float
% Instrument=fread(fileid,1,'uint8') % 0 = 64bit float; 1 = 32bit float
% 

% if path
%     %get the procpar header file first
%     fidpath=[path file];
%     fileid_procpar=fopen(fidpath,'rt');
%     
%     %%read in the lot
%     k=1;
%     while k
%         parmline=fgetl(fileid_procpar);
%         if parmline==-1;  break;  end;
%         parmcell=textscan(parmline,'%q %q');
%         if strcmp(parmcell{1,1},'y_list')
%             procpar.y_list={};
%             nlist=cell2mat(parmcell{1,2});
%             nlist=str2num(nlist);%#ok
%             for m=1:nlist
%                 parmline=fgetl(fileid_procpar);
%                 if parmline==-1;  break;  end;
%                 parmcell=textscan(parmline,'%q %q');
%                 procpar.y_list{m}=parmcell{1,1};
%             end
%         else
%             procpar.(char(parmcell{1,1}))=cell2mat(parmcell{1,2});
%         end
%     end
%     %procpar
%     jeoldata.procpar=procpar;
%     jeoldata.rp=0;
%      jeoldata.lp=0;
%     fclose(fileid_procpar);
%     
%     %Get the parameters I need for now (in units I like)
%     %jeoldata.ngrad=nlist;
%     jeoldata.np=str2double(jeoldata.procpar.x_curr_points);
%     
%     %will have to make a decision on wheter this is dosy data or not.
%     if isfield(jeoldata.procpar, 'y_list')
%         ngradtmp=length(jeoldata.procpar.y_list);
%         %jeoldata.ngrad=str2double(jeoldata.procpar.y_curr_points)/ngradtmp;
%         jeoldata.ngrad=ngradtmp;
%         jeoldata.arraydim=str2double(jeoldata.procpar.y_curr_points);
%     else
%         jeoldata.ngrad=1;
%         if isfield(jeoldata.procpar,'y_curr_points')
%             jeoldata.arraydim=str2double(jeoldata.procpar.y_curr_points);
%         else
%             jeoldata.arraydim=1;
%         end
%         
%     end
%     if isfield(procpar,'y_format')
%         datatype=procpar.y_format;
%     else
%         datatype='UNKNOWN';
%     end
%     if strcmpi('COMPLEX',datatype)
%         jeoldata.arraydim=jeoldata.arraydim*2;
%     end
%     
%     %Sfrq (MHz)
%     tmp(1)=find(procpar.x_freq=='[');
%     tmp(2)=find(procpar.x_freq==']');
%     jeoldata.sfrq=str2double(procpar.x_freq(1:tmp(1)-1)); %assuming it will alays be in MHz
%     unit=procpar.x_freq(tmp(1)+1:tmp(2)-1);
%     switch unit
%         case 'kHz'
%             jeoldata.sfrq=jeoldata.sfrq*1e-3;
%         case 'MHz'
%             jeoldata.sfrq=jeoldata.sfrq;
%         otherwise
%             error('Unknown unit')
%     end
%     
%     %sw (ppm)
%     tmp(1)=find(procpar.x_sweep=='[');
%     tmp(2)=find(procpar.x_sweep==']');
%     jeoldata.sw=str2double(procpar.x_sweep(1:tmp(1)-1));
%     unit=procpar.x_sweep(tmp(1)+1:tmp(2)-1);
%     switch unit
%         case 'kHz'
%             jeoldata.sw=jeoldata.sw*1e3;
%         case 'MHz'
%             jeoldata.sw=jeoldata.sw*1e6;
%         case 'Hz'
%             jeoldata.sw=jeoldata.sw;
%         otherwise
%             error('Unknown unit')
%     end
%     jeoldata.sw=jeoldata.sw/jeoldata.sfrq; %now in ppm
%      %sw1 (ppm)
%      if isfield(procpar,'y_sweep')
%          tmp(1)=find(procpar.y_sweep=='[');
%          tmp(2)=find(procpar.y_sweep==']');
%          jeoldata.sw1=str2double(procpar.y_sweep(1:tmp(1)-1));
%          unit=procpar.y_sweep(tmp(1)+1:tmp(2)-1);
%          switch unit
%              case 'kHz'
%                  jeoldata.sw1=jeoldata.sw1*1e3;
%              case 'MHz'
%                  jeoldata.sw1=jeoldata.sw1*1e6;
%              case 'Hz'
%                  jeoldata.sw1=jeoldata.sw1;
%              otherwise
%                  error('Unknown unit')
%          end
%          jeoldata.sw1=jeoldata.sw1/jeoldata.sfrq; %now in ppm
%      end
%     
%     
%     disp('Using the JEOL referencing has not been implemented')
%     disp('The spectrum will be set to start at -1 ppm')
%     jeoldata.sp=-1;
%     
%     % Acquisition time [at] (s)
%   % a= procpar.x_start
%     tmp(1)=find(procpar.x_start=='[');
%     tmp(2)=find(procpar.x_start==']');
%     jeoldata.at_start=str2double(procpar.x_start(1:tmp(1)-1));
%     unit=procpar.x_start(tmp(1)+1:tmp(2)-1);
%     switch unit
%         case 's'
%             jeoldata.at_start=jeoldata.at_start;
%         case 'ppm'
%             
%             if isfield(procpar,'y_start')
%                 %probably 2D data - use y_start
%                 tmp(1)=find(procpar.y_start=='[');
%             tmp(2)=find(procpar.y_start==']');
%             jeoldata.at_start=str2double(procpar.y_start(1:tmp(1)-1));
%             else
%                 %probably spectrum - not fid
%                  errordlg('Data appears to be as spectrum, not FID','not supported')
%             end
%             
%         otherwise
%             error('Unknown unit')
%     end
%     
%     
%     
%     
%     tmp(1)=find(procpar.x_stop=='[');
%     tmp(2)=find(procpar.x_stop==']');
%     jeoldata.at_stop=str2double(procpar.x_stop(1:tmp(1)-1));
%     unit=procpar.x_stop(tmp(1)+1:tmp(2)-1);
%     switch unit
%         case 's'
%             jeoldata.at_stop=jeoldata.at_stop;
%         case 'ppm'
%             %probably 2D data - use y_stop
%             tmp(1)=find(procpar.y_stop=='[');
%             tmp(2)=find(procpar.y_stop==']');
%             jeoldata.at_stop=str2double(procpar.y_stop(1:tmp(1)-1));
%         otherwise
%             error('Unknown unit')
%     end
%     
%     jeoldata.at=jeoldata.at_stop-jeoldata.at_start;
%     
%     jeoldata=rmfield(jeoldata,'at_stop');
%     jeoldata=rmfield(jeoldata,'at_start');
%     
%     %gradient levels (T/m) 
%     if isfield(jeoldata.procpar, 'y_list')
%         for k=1:jeoldata.ngrad
%             %gzlvl(k)=procpar.y_list{k}
%             temp=cell2mat(procpar.y_list{k});
%             tmp(1)=find(temp=='[');
%             tmp(2)=find(temp==']');
%             jeoldata.Gzlvl(k)=str2double(temp(1:tmp(1)-1));
%             unit=temp(tmp(1)+1:tmp(2)-1);
%             switch unit
%                 case 'mT/m'
%                     jeoldata.Gzlvl(k)=jeoldata.Gzlvl(k)*1e-3;
%                     case 'T/km'
%                     jeoldata.Gzlvl(k)=jeoldata.Gzlvl(k)*1e-3;
%                 otherwise
%                     error('Unknown unit')
%             end
%         end
%         
%         %Diffusion parameters (delta, DELTA, gamma, dosyconstant
%         tmp(1)=find(procpar.delta=='[');
%         tmp(2)=find(procpar.delta==']');
%         jeoldata.delta=str2double(procpar.delta(1:tmp(1)-1));
%         unit=procpar.delta(tmp(1)+1:tmp(2)-1);
%         switch unit
%             case 'ms'
%                 jeoldata.delta=jeoldata.delta*1e-3;
%             case 's'
%                 jeoldata.delta=jeoldata.delta;
%                 
%             otherwise
%                 error('Unknown unit')
%         end
%         
%         tmp(1)=find(procpar.delta_large=='[');
%         tmp(2)=find(procpar.delta_large==']');
%         jeoldata.DELTA=str2double(procpar.delta_large(1:tmp(1)-1));
%         unit=procpar.delta_large(tmp(1)+1:tmp(2)-1);
%         switch unit
%             case 'ms'
%                 jeoldata.DELTA=jeoldata.DELTA*1e-3;
%             case 's'
%                 jeoldata.DELTA=jeoldata.DELTA;
%                 
%             otherwise
%                 error('Unknown unit')
%         end
%         
%         tmp(1)=find(procpar.delta_large=='[');
%         tmp(2)=find(procpar.delta_large==']');
%         jeoldata.DELTA=str2double(procpar.delta_large(1:tmp(1)-1));
%         unit=procpar.delta_large(tmp(1)+1:tmp(2)-1);
%         switch unit
%             case 'ms'
%                 jeoldata.DELTA=jeoldata.DELTA*1e-3;
%             case 's'
%                 jeoldata.DELTA=jeoldata.DELTA;
%                 
%             otherwise
%                 error('Unknown unit')
%         end
%         %Maybe little delta is each gradient not the combined
%         jeoldata.DELTA=jeoldata.DELTA*2;
%         
%         switch procpar.x_domain
%             case '1H'
%                 jeoldata.gamma=267524618.573;
%             otherwise
%                 disp('unknown nucleus - defaulting to proton')
%                 jeoldata.gamma=267524618.573;
%         end        
%         jeoldata.dosyconstant=jeoldata.gamma.^2*jeoldata.delta.^2*(jeoldata.DELTA-jeoldata.delta/3);               
%     else
%         jeoldata.Gzlvl=0;
%         jeoldata.dosyconstant=0;
%         jeoldata.ngrad=1;
%         jeoldata.gamma=267524618.573;
%         jeoldata.DELTA='non existing';
%         jeoldata.delta='non existing';
%         jeoldata.DAC_to_G='non existing';
%     end
%     
%     
%     
%     fidpath=fidpath(1:(end-4));
%     jeoldata.filename=fidpath;
%      hp=msgbox('Reading data - this may take a while','Data Import');  
%     %check for filetype to read in
%     if exist([fidpath '.bin'],'file')
%         %binary file
%         disp('binary file')
%         fidpath=[fidpath '.bin'];
%         fileid_FID=fopen(fidpath,'r','b');        
%         FID=zeros(jeoldata.np,jeoldata.ngrad);
%         impfid=fread(fileid_FID,jeoldata.np*2*jeoldata.ngrad,'double');        
%         compfid=complex(impfid(1:2:end),impfid(2:2:end));        
%         for k=1:jeoldata.arraydim
%             FID(:,k)=compfid((k-1)*jeoldata.np+1:k*jeoldata.np);
%         end
%         jeoldata.FID=FID;
%         fclose(fileid_FID);
%     elseif exist([fidpath '.asc'],'file')
%         %ascii file
%         disp('ascii file')
%         fidpath=[fidpath '.asc'];
%         fileid_FID=fopen(fidpath,'rt');        
%         %nIncrement=round(jeoldata.ngrad.*str2double(jeoldata.procpar.y_curr_points));
%         %nIncrement=round(jeoldata.ngrad.*jeoldata.arraydim);
%         FID=zeros(jeoldata.np,jeoldata.arraydim);     
%         fgetl(fileid_FID);
%         jeoldata.nchunks=jeoldata.arraydim/jeoldata.ngrad; 
%         for m=1:jeoldata.arraydim            
%             for n=1:jeoldata.np              
%                 ParmLine=fgetl(fileid_FID);
%                 if ParmLine==-1;  break;  end;
%                 if jeoldata.arraydim==1
%                     TmpPoint=sscanf(ParmLine,'%e %e %e');
%                     FID(n,m)=complex(TmpPoint(2),TmpPoint(3));
%                 else                    
%                     TmpPoint=sscanf(ParmLine,'%e %e %e %e');
%                     FID(n,m)=complex(TmpPoint(3),TmpPoint(4));
%                 end
%             end
%         end
%         jeoldata.FID=FID;
%         fclose(fileid_FID);    
%     else
%         %unknown
%         disp('unknown file format')
%     end
%     
%    close(hp)
%    
%    %should find better defaults
%    
%    %Need to figure ut how many points to rotate 
%    % but at I can't find a decent algorithm so I'll just use something
%    % terribly crude
%    if   strcmp(jeoldata.procpar.digital_filter,'FALSE')
%        jeoldata.digshift=1;
%    else       
%        %jeoldata.digshift=19;       
%        [tmp jeoldata.digshift]=max(abs(jeoldata.FID(1:50,1)));
%    end
%    jeoldata.droppts=1;
%    
%   
% else
%     jeoldata=[];
% end
% %jeoldata.FID=ifft(fftshift(jeoldata.FID));
% 
% 
% %This should only be used for proper 2D data (i.e. not dosy)
% %just checking for COMPLEX at the moment
% 
%  if strcmpi('COMPLEX',datatype)
%     %sort the data array as for varian data
%     FID=zeros(size(jeoldata.FID));
%     for k=1:jeoldata.arraydim/2
%         FID(:,2*k-1)=jeoldata.FID(:,k);
%         FID(:,2*k)=jeoldata.FID(:,k+round(jeoldata.arraydim/2));
%     end
%     jeoldata.FID=FID;
%    
% end
% jeoldata
 %this is for a specif dataset.
%      jeoldata.digshift=31;
%      jeoldata.rp=77.46;
%      jeoldata.lp=-581.3;


end
