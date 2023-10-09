function[zerolines]=lrankplot(lrankdata,fn)

if nargin==0
    disp(' ')
    disp(' ')
    disp(' LRANKPLOT')
    disp('At least one input is needed')
    disp(' ')
    disp(' Type <<help mcrplot>> for more info')
    disp('  ')
    return
elseif nargin >2
    error(' Too many inputs')
end

%normalise the components
for k=1:lrankdata.ccncomps
    lrankdata.cc1dspectra(k,:)=lrankdata.cc1dspectra(k,:)/norm(lrankdata.cc1dspectra(k,:));
end

ax1=zeros(1,(lrankdata.ccncomps));
ax2=zeros(1,(lrankdata.ccncomps));

% Add the full spectrum to the first row of cc1dspectra
[a,b]=size(lrankdata.cc1dspectra);
tmp=zeros(a+1,b);
tmp(1,:)=lrankdata.Spectrum;
tmp(2:end,:)=lrankdata.cc1dspectra;
lrankdata.cc1dspectra=tmp;

% Add a blank to the first value of dvalrange
[a,b]=size(lrankdata.dvalrange);
tmp=cell(a+1,b);
tmp{1,1}='Original Spectrum';
tmp(2:end,1)=lrankdata.dvalrange;
lrankdata.dvalrange=tmp;

figure('Color',[0.9 0.9 0.9],...
    'NumberTitle','Off',...
    'Name','LRANK');

zerolines=ones(lrankdata.ccncomps,fn);
for k=1:lrankdata.ccncomps+1
% work out where there are regions of purely zeroes and actual spectra and
% then plot each concatenated spectrum with the zero regions highlighted
    if k>1
        for m=1:lrankdata.nwin
            if size(lrankdata.sorted1dspectra{k-1,m}>0)
                zerolines(k,(lrankdata.winstartpoint(1,m):lrankdata.winendpoint(1,m)))=NaN;
            end    
        end
    end
      
    ax1(k)=subplot(lrankdata.ccncomps+1,6,[(k-1)*6+1 (k-1)*6+4]);
    h=plot(lrankdata.Ppmscale,lrankdata.cc1dspectra(k,:),'Parent',ax1(k),'LineWidth',1);
    if k>1
        zeroline=0*zerolines(k,:);
        hZeroline=line(lrankdata.Ppmscale,zeroline,...
            'color','r','linewidth', 2.0,...
            'Erasemode','Normal','tag','zeroline');
    end
    set(gca,'Xdir','reverse');
    axis('tight')
    if k==1
        axis off
    end
    ylim('auto');
%ylim([(min(min(lrankdata.cc1dspectra))-0.1*max(max(lrankdata.cc1dspectra))) max(max(lrankdata.cc1dspectra))*1.1])
    set(h,'LineWidth',1)
    set(gca,'LineWidth',1)
    if k==1
        title('\fontname{ariel} \bf LRANK components')
    end
    if k==lrankdata.ccncomps+1
        xlabel('\fontname{ariel} \bf Chemical shift (PPM)');
    end
% plot a blank axes with text giving the range of diffusion coefficients
% present.
    ax2(k)=subplot(lrankdata.ccncomps+1,6,[(k-1)*6+5 (k-1)*6+6]);
    str=['\fontname{ariel} \bf' (k-1) lrankdata.dvalrange(k,1)];
    text(0.1,0.95,str);
    axis off
    
end
set(ax1,'FontName','Arial','FontWeight','bold','LineWidth',2);
set(ax2,'FontName','Arial','FontWeight','bold','LineWidth',2);
linkaxes(ax1,'x');
linkaxes(ax2,'x');
end
