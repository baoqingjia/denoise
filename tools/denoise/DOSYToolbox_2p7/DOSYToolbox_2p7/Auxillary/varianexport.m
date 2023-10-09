function []=varianexport(indata)
%  []=varianexport(indata)
%   
%    Exports reconstructed fids to Vnmr format by replacing the original fid
%   by the constructed one. The original fid will be saved as fid.date and 
%   as fid.org if fid.org does not already exist and
%   
%   Useage: Point to the fid directory that contains the original raw data.
%   The argument 'indata' must contain the same numer of (complex) FIDS as 
%   in the raw data and with the same number of data points per fid 




[pathname] = uigetdir(pwd,'Original experiment');
format= 'yyyy-mm-dd-HH-MM-SS';
tid=datestr(now,format);

if isunix()==1
    copyfile([pathname,'/fid'],[pathname,'/fid.new']);
    copyfile([pathname,'/fid'],[pathname,'/fid.',tid]);
    if exist('fid.org','file')==2
        %do nothing
    else
        copyfile([pathname,'/fid'],[pathname,'/fid.org']);
    end
    fileID=fopen([pathname,'/fid.new'],'r+','b');
else
    copyfile([pathname,'\fid'],[pathname,'\fid.new']);
    copyfile([pathname,'\fid'],[pathname,'\fid.tid']);
    if exist('fid.org','file')==2
        %do nothing
    else
        copyfile([pathname,'\fid'],[pathname,'\fid.org']);
    end
    
    
    fileID=fopen([pathname,'\fid.new'],'r+','b');
end
hp=waitbar(1,'Exporting data');
nblocks=fread(fileID,1,'int32');
ntraces=fread(fileID,1,'int32'); %#ok<NASGU>
np=fread(fileID,1,'int32');
ebytes=fread(fileID,1,'int32'); %#ok<NASGU>
tbytes=fread(fileID,1,'int32'); %#ok<NASGU>
bbytes=fread(fileID,1,'int32'); %#ok<NASGU>
vers_id=fread(fileID,1,'int16'); %#ok<NASGU>
status=fread(fileID,1,'int16'); %#ok<NASGU>
nbheaders=fread(fileID,1,'int32'); %#ok<NASGU>
%disp('Importing fid data')

%complex_fid=zeros(np/2,nblocks);

for m=1:nblocks
    waitbar(m/nblocks,hp,'Exporting data');
    %read in block header
   
    scale=fread(fileID,1,'int16'); %#ok<NASGU>
    status_block=fread(fileID,1,'int16');
    bitstatus=bitget(uint16(status_block),1:16);
    index=fread(fileID,1,'int16'); %#ok<NASGU>
    mode=fread(fileID,1,'int16'); %#ok<NASGU>
    ctcount=fread(fileID,1,'int32'); %#ok<NASGU>
    lpval=fread(fileID,1,'float32'); %#ok<NASGU>
    rpval=fread(fileID,1,'float32'); %#ok<NASGU>
    lvl=fread(fileID,1,'float32'); %#ok<NASGU>
    tlt=fread(fileID,1,'float32'); %#ok<NASGU>
    
    infid= indata(:,m);
    realfid=real(infid);
    imagfid=imag(infid);
    writefid=zeros(1,np);
    writefid(1:2:np)=realfid;
    writefid(2:2:np)=imagfid;
    fseek(fileID,0,'cof');
    
    if bitstatus(4)==1
        disp('float32')
        fwrite(fileID,writefid,'float32',0,'b');
    elseif bitstatus(3)==1
        disp('int32')
        fwrite(fileID,writefid,'int32',0,'b');
    elseif bitstatus(3)==0
        disp('int16')
        
        fwrite(fileID,writefid,'int16',0,'b');
    else
        error('Illegal combination in file header status')
    end
%     %
    %
    %         complex_fid(:,m)=fid_data(1:2:np,:) + 1i*fid_data(2:2:np);
    fseek(fileID,0,'cof');
end
close(hp)
fclose(fileID);



end



% if isunix()==1
%             slashindex=find(NmrData.filename=='/');
%         elseif NmrData.issynthetic==1      %AC
%             slashindex=1;           
%         else
%             slashindex=find(NmrData.filename=='\');
% end
        
% filepath=[PathName FileName];
%             filepath=[PathName FileName];
%             filepath=filepath(1:(end-4));
%             filepath=[filepath '.bin'];
%             binfile=fopen(filepath, 'w','b');
%             switch ExportType
%                 case 1
%                     %complex FID
%                     hp=waitbar(0,'Exporting DOSY data (FID)');
%                     fwrite(binfile,real(NmrData.FID),'int64',0,'b');
%                     fwrite(binfile,imag(NmrData.FID),'int64',0,'b');
%                     close(hp)
                    