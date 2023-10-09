function [jeoldata]=jeolimport_generic()
%   [jeoldata]=jeolimport()
%   Imports PFG-NMR data in Jeol generic format
%   Useage: Point to the *.hdr file that contains the raw data. The
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
%               Gzlvl: gradient strengths/large
%               DELTA: diffusion time
%               delta: diffusion encoding time
%               dosyconstant: gamma.^2*delta^2*DELTAprime
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
[file path]=uigetfile('*.hdr','Choose the JEOL generic header file (*.hdr)');

if path
    %get the procpar header file first
    fidpath=[path file];
    fileid_procpar=fopen(fidpath,'rt');
    
    %%read in the lot
    k=1;
    while k
        parmline=fgetl(fileid_procpar);
        if parmline==-1;  break;  end;
        parmcell=textscan(parmline,'%q %q');
        if strcmp(parmcell{1,1},'y_list')
            procpar.y_list={};
            nlist=cell2mat(parmcell{1,2});
            nlist=str2num(nlist);%#ok
            for m=1:nlist
                parmline=fgetl(fileid_procpar);
                if parmline==-1;  break;  end;
                parmcell=textscan(parmline,'%q %q');
                procpar.y_list{m}=parmcell{1,1};
                
            end
        elseif strcmp(parmcell{1,1},'z_list')
            procpar.z_list={};
            nlist=cell2mat(parmcell{1,2});
            nlist=str2num(nlist);%#ok
            for m=1:nlist
                parmline=fgetl(fileid_procpar);
                if parmline==-1;  break;  end;
                parmcell=textscan(parmline,'%q %q');
                procpar.z_list{m}=parmcell{1,1};
            end
            
        else
            procpar.(char(parmcell{1,1}))=cell2mat(parmcell{1,2});
        end
    end
    %procpar
    %procpar
    procpar=orderfields(procpar);
    jeoldata.procpar=procpar;
    jeoldata.rp=0;
    jeoldata.lp=0;
    fclose(fileid_procpar);
    
    %Get the parameters I need for now (in units I like)
    %jeoldata.ngrad=nlist;
    jeoldata.np=str2double(jeoldata.procpar.x_curr_points);
    
    %will have to make a decision on wheter this is dosy data or not.
    %jeoldata.procpar
    if isfield(jeoldata.procpar, 'z_list')
        %at least 3D data - lets assume pureshift DOSY for now
        jeoldata.ngrad=length(jeoldata.procpar.z_list);
        jeoldata.arraydim=str2double(jeoldata.procpar.y_curr_points)*jeoldata.ngrad;
        disp('Hi')
        
    elseif isfield(jeoldata.procpar, 'y_list')
        ngradtmp=length(jeoldata.procpar.y_list);
        %jeoldata.ngrad=str2double(jeoldata.procpar.y_curr_points)/ngradtmp;
        jeoldata.ngrad=ngradtmp;
        jeoldata.arraydim=str2double(jeoldata.procpar.y_curr_points);
    else
        jeoldata.ngrad=1;
        if isfield(jeoldata.procpar,'y_curr_points')
            jeoldata.arraydim=str2double(jeoldata.procpar.y_curr_points);
        else
            jeoldata.arraydim=1;
        end
        
    end
    if isfield(procpar,'y_format')
        datatype=procpar.y_format;
    else
        datatype='UNKNOWN';
    end
    if strcmpi('COMPLEX',datatype)
        jeoldata.arraydim=jeoldata.arraydim*2;
    end
    
    %Sfrq (MHz)
    tmp(1)=find(procpar.x_freq=='[');
    tmp(2)=find(procpar.x_freq==']');
    jeoldata.sfrq=str2double(procpar.x_freq(1:tmp(1)-1)); %assuming it will alays be in MHz
    unit=procpar.x_freq(tmp(1)+1:tmp(2)-1);
    switch unit
        case 'kHz'
            jeoldata.sfrq=jeoldata.sfrq*1e-3;
        case 'MHz'
            jeoldata.sfrq=jeoldata.sfrq;
        otherwise
            error('Unknown unit')
    end
    
    %sw (ppm)
    tmp(1)=find(procpar.x_sweep=='[');
    tmp(2)=find(procpar.x_sweep==']');
    jeoldata.sw=str2double(procpar.x_sweep(1:tmp(1)-1));
    unit=procpar.x_sweep(tmp(1)+1:tmp(2)-1);
    switch unit
        case 'kHz'
            jeoldata.sw=jeoldata.sw*1e3;
        case 'MHz'
            jeoldata.sw=jeoldata.sw*1e6;
        case 'Hz'
            jeoldata.sw=jeoldata.sw;
        otherwise
            error('Unknown unit')
    end
    jeoldata.sw=jeoldata.sw/jeoldata.sfrq; %now in ppm
    %sw1 (ppm)
    if isfield(procpar,'y_sweep')
        tmp(1)=find(procpar.y_sweep=='[');
        tmp(2)=find(procpar.y_sweep==']');
        jeoldata.sw1=str2double(procpar.y_sweep(1:tmp(1)-1));
        unit=procpar.y_sweep(tmp(1)+1:tmp(2)-1);
        switch unit
            case 'kHz'
                jeoldata.sw1=jeoldata.sw1*1e3;
            case 'MHz'
                jeoldata.sw1=jeoldata.sw1*1e6;
            case 'Hz'
                jeoldata.sw1=jeoldata.sw1;
            otherwise
                error('Unknown unit')
        end
        jeoldata.sw1=jeoldata.sw1/jeoldata.sfrq; %now in ppm
    end
    
    
    disp('Using the JEOL referencing has not been implemented')
    disp('The spectrum will be set to start at -1 ppm')
    jeoldata.sp=-1;
    
    % Acquisition time [at] (s)
    % a= procpar.x_start
    tmp(1)=find(procpar.x_start=='[');
    tmp(2)=find(procpar.x_start==']');
    jeoldata.at_start=str2double(procpar.x_start(1:tmp(1)-1));
    unit=procpar.x_start(tmp(1)+1:tmp(2)-1);
    switch unit
        case 's'
            jeoldata.at_start=jeoldata.at_start;
        case 'ppm'
            
            if isfield(procpar,'y_start')
                %probably 2D data - use y_start
                tmp(1)=find(procpar.y_start=='[');
                tmp(2)=find(procpar.y_start==']');
                jeoldata.at_start=str2double(procpar.y_start(1:tmp(1)-1));
            else
                %probably spectrum - not fid
                errordlg('Data appears to be as spectrum, not FID','not supported')
            end
            
        otherwise
            error('Unknown unit')
    end
    
    
    
    
    tmp(1)=find(procpar.x_stop=='[');
    tmp(2)=find(procpar.x_stop==']');
    jeoldata.at_stop=str2double(procpar.x_stop(1:tmp(1)-1));
    unit=procpar.x_stop(tmp(1)+1:tmp(2)-1);
    switch unit
        case 's'
            jeoldata.at_stop=jeoldata.at_stop;
        case 'ppm'
            %probably 2D data - use y_stop
            tmp(1)=find(procpar.y_stop=='[');
            tmp(2)=find(procpar.y_stop==']');
            jeoldata.at_stop=str2double(procpar.y_stop(1:tmp(1)-1));
        otherwise
            error('Unknown unit')
    end
    
    jeoldata.at=jeoldata.at_stop-jeoldata.at_start;
    
    jeoldata=rmfield(jeoldata,'at_stop');
    jeoldata=rmfield(jeoldata,'at_start');
    
    %gradient levels (T/m)
    if jeoldata.ngrad>1
        if isfield(jeoldata.procpar, 'z_list')
            for k=1:jeoldata.ngrad
                %gzlvl(k)=procpar.y_list{k}
                temp=cell2mat(procpar.z_list{k});
                tmp(1)=find(temp=='[');
                tmp(2)=find(temp==']');
                jeoldata.Gzlvl(k)=str2double(temp(1:tmp(1)-1));
                unit=temp(tmp(1)+1:tmp(2)-1);
                switch unit
                    case 'mT/m'
                        jeoldata.Gzlvl(k)=jeoldata.Gzlvl(k)*1e-3;
                    case 'T/km'
                        jeoldata.Gzlvl(k)=jeoldata.Gzlvl(k)*1e-3;
                    otherwise
                        error('Unknown unit')
                end
            end
            
        elseif isfield(jeoldata.procpar, 'y_list')
            for k=1:jeoldata.ngrad
                %gzlvl(k)=procpar.y_list{k}
                temp=cell2mat(procpar.y_list{k});
                tmp(1)=find(temp=='[');
                tmp(2)=find(temp==']');
                jeoldata.Gzlvl(k)=str2double(temp(1:tmp(1)-1));
                unit=temp(tmp(1)+1:tmp(2)-1);
                switch unit
                    case 'mT/m'
                        jeoldata.Gzlvl(k)=jeoldata.Gzlvl(k)*1e-3;
                    case 'T/km'
                        jeoldata.Gzlvl(k)=jeoldata.Gzlvl(k)*1e-3;
                    otherwise
                        error('Unknown unit')
                end
            end
        else
            error('No z-list or y_list - confused')
        end
        
        
        if isfield(procpar, 'delta')
            %Diffusion parameters (delta, DELTA, gamma, dosyconstant
            tmp(1)=find(procpar.delta=='[');
            tmp(2)=find(procpar.delta==']');
            jeoldata.delta=str2double(procpar.delta(1:tmp(1)-1));
            unit=procpar.delta(tmp(1)+1:tmp(2)-1);
            switch unit
                case 'ms'
                    jeoldata.delta=jeoldata.delta*1e-3;
                case 's'
                    jeoldata.delta=jeoldata.delta;
                    
                otherwise
                    error('Unknown unit')
            end
        else
            disp('WARNING! delta is missing from the parameter set')
            disp('Setting the diffusion encoding time to default value of 1 ms')
            jeoldata.delta=0.001;
        end
        
        
        if isfield(procpar, 'delta_large')
            tmp(1)=find(procpar.delta_large=='[');
            tmp(2)=find(procpar.delta_large==']');
            jeoldata.DELTA=str2double(procpar.delta_large(1:tmp(1)-1));
            unit=procpar.delta_large(tmp(1)+1:tmp(2)-1);
            switch unit
                case 'ms'
                    jeoldata.DELTA=jeoldata.DELTA*1e-3;
                case 's'
                    jeoldata.DELTA=jeoldata.DELTA;
                    
                otherwise
                    error('Unknown unit')
            end
            
            tmp(1)=find(procpar.delta_large=='[');
            tmp(2)=find(procpar.delta_large==']');
            jeoldata.DELTA=str2double(procpar.delta_large(1:tmp(1)-1));
            unit=procpar.delta_large(tmp(1)+1:tmp(2)-1);
            switch unit
                case 'ms'
                    jeoldata.DELTA=jeoldata.DELTA*1e-3;
                case 's'
                    jeoldata.DELTA=jeoldata.DELTA;
                    
                otherwise
                    error('Unknown unit')
            end
        else
            disp('WARNING! delta_large is missing from the parameter set')
            disp('Setting the diffusion time to default value of 0.1 s')
            jeoldata.DELTA=0.1;
        end
        
        
        
        switch procpar.x_domain
            case '1H'
                jeoldata.gamma=267524618.573;
            otherwise
                disp('unknown nucleus - defaulting to proton')
                jeoldata.gamma=267524618.573;
        end
        
        if isfield(procpar, 'Dtau')
            tmp(1)=find(procpar.Dtau=='[');
            tmp(2)=find(procpar.Dtau==']');
            jeoldata.tau=str2double(procpar.Dtau(1:tmp(1)-1));
            unit=procpar.Dtau(tmp(1)+1:tmp(2)-1);
            switch unit
                case 'ms'
                    jeoldata.tau=jeoldata.tau*1e-3;
                case 's'
                    jeoldata.tau=tau.tau;
                    
                otherwise
                    error('Unknown unit')
            end
        elseif isfield(procpar, 'dtau')
            tmp(1)=find(procpar.dtau=='[');
            tmp(2)=find(procpar.dtau==']');
            jeoldata.tau=str2double(procpar.dtau(1:tmp(1)-1));
            unit=procpar.dtau(tmp(1)+1:tmp(2)-1);
            switch unit
                case 'ms'
                    jeoldata.tau=jeoldata.tau*1e-3;
                case 's'
                    jeoldata.tau=jeoldata.tau;
                    
                otherwise
                    error('Unknown unit')
            end
        else
            disp('Dtau is missing from the parameter set')
            disp('Setting the tau default value of 0')
            jeoldata.tau=0;
        end
        
        if isfield(procpar, 'st_coef')
            disp('Calculating dosyconstant as st_coef*delta^2. This may not be correct in all cases as theresems to be a couple of different variants of the pulse sequence out'); 
            tmp(1)=find(procpar.st_coef=='[');
            tmp(2)=find(procpar.st_coef==']');
            jeoldata.st_coef=str2double(procpar.st_coef(1:tmp(1)-1));
            unit=procpar.st_coef(tmp(1)+1:tmp(2)-1);
            switch unit
                case 'ms'
                    jeoldata.st_coef=jeoldata.st_coef*1e-3;
                case 's'
                    jeoldata.st_coef=jeoldata.st_coef;
                    
                otherwise
                    error('Unknown unit of st_coef')
            end
            
            
            
            jeoldata.dosyconstant=jeoldata.gamma.^2*jeoldata.st_coef*jeoldata.delta.^2;            
            
        else
            disp('st_coef is missing from the parameter set')
            disp('Setting the tau default value of 0')
            if isfield(procpar, 'Dtau') || isfield(procpar, 'dtau')
                disp('Tau value present - assuming bipolar sequence')
                jeoldata.dosyconstant=jeoldata.gamma.^2.*jeoldata.delta.^2.*(eoldata.DELTA-jeoldata.delta/3-jeoldata.tau/2);
            else
                disp('assuing monopolar sequence')
                jeoldata.dosyconstant=jeoldata.gamma.^2*jeoldata.delta.^2*(jeoldata.DELTA-jeoldata.delta/3);
                jeoldata.tau=0;
            end            
        end
        
        
        
    else
        jeoldata.Gzlvl=0;
        jeoldata.dosyconstant=0;
        jeoldata.ngrad=1;
        jeoldata.gamma=267524618.573;
        jeoldata.DELTA='non existing';
        jeoldata.delta='non existing';
        jeoldata.DAC_to_G='non existing';
    end
    
    
    
    fidpath=fidpath(1:(end-4));
    jeoldata.filename=fidpath;
    hp=msgbox('Reading data - this may take a while','Data Import');
    %check for filetype to read in
    if exist([fidpath '.bin'],'file')
        %binary file
        disp('binary file')
        fidpath=[fidpath '.bin'];
        fileid_FID=fopen(fidpath,'r','b');
        FID=zeros(jeoldata.np,jeoldata.arraydim);
        
        
        pureshiftflag=0; %seems to work in the general case (for our data)
        if pureshiftflag
            secdim=(jeoldata.arraydim/jeoldata.ngrad);
            for k=1:secdim
                for m=1:jeoldata.ngrad
                    impfid=fread(fileid_FID,jeoldata.np*2,'double');
                    compfid=complex(impfid(1:2:end),impfid(2:2:end));
                    %tmp=(k-1)*jeoldata.ngrad + m
                    %tmp= k + (m-1)*secdim
                    
                    FID(:, k + (m-1)*secdim)=compfid;
                end
            end
            
        else %This is the previous code
            impfid=fread(fileid_FID,jeoldata.np*2*jeoldata.arraydim,'double');
            compfid=complex(impfid(1:2:end),impfid(2:2:end));
            for k=1:jeoldata.arraydim
                FID(:,k)=compfid((k-1)*jeoldata.np+1:k*jeoldata.np);
            end
            
        end
        jeoldata.FID=FID;
        fclose(fileid_FID);
    elseif exist([fidpath '.asc'],'file')
        %ascii file
        disp('ascii file')
        fidpath=[fidpath '.asc'];
        fileid_FID=fopen(fidpath,'rt');
        %nIncrement=round(jeoldata.ngrad.*str2double(jeoldata.procpar.y_curr_points));
        %nIncrement=round(jeoldata.ngrad.*jeoldata.arraydim);
        FID=zeros(jeoldata.np,jeoldata.arraydim);
        fgetl(fileid_FID);
        jeoldata.nchunks=jeoldata.arraydim/jeoldata.ngrad;
        for m=1:jeoldata.arraydim
            for n=1:jeoldata.np
                ParmLine=fgetl(fileid_FID);
                if ParmLine==-1;  break;  end;
                if jeoldata.arraydim==1
                    TmpPoint=sscanf(ParmLine,'%e %e %e');
                    FID(n,m)=complex(TmpPoint(2),TmpPoint(3));
                else
                    TmpPoint=sscanf(ParmLine,'%e %e %e %e');
                    FID(n,m)=complex(TmpPoint(3),TmpPoint(4));
                end
            end
        end
        jeoldata.FID=FID;
        if strcmpi('COMPLEX',datatype)
            %sort the data array as for varian data
            disp('COMPLEX 2D')
            FID=zeros(size(jeoldata.FID));
            for k=1:jeoldata.arraydim/2
                FID(:,2*k-1)=jeoldata.FID(:,k);
                FID(:,2*k)=jeoldata.FID(:,k+round(jeoldata.arraydim/2));
            end            
        end        
        
        jeoldata.FID=FID;
        fclose(fileid_FID);
    else
        %unknown
        disp('unknown file format')
    end
    %jeoldata
    close(hp)
    
    % Working out how much to rotate the FID
    if   strcmp(jeoldata.procpar.digital_filter,'FALSE')
        jeoldata.digshift=0;
    else %according to the JEOL manual
        orders=str2num(procpar.orders);       %#ok<ST2NM>
        factors=str2num(procpar.factors);        %#ok<ST2NM>
        theta=0;
        for k=1:orders(1)
            theta= theta+ 0.5*((orders(k+1) - 1)/prod(factors(k:orders(1))));
        end
        jeoldata.digshift=round(theta);
        
    end
    jeoldata.droppts=0;   
else
    jeoldata=[];
end
%jeoldata.FID=ifft(fftshift(jeoldata.FID));


%This should only be used for proper 2D data (i.e. not dosy)
%just checking for COMPLEX at the moment


%this is for a specif dataset.
%      jeoldata.digshift=31;
%      jeoldata.rp=77.46;
%      jeoldata.lp=-581.3;


end
