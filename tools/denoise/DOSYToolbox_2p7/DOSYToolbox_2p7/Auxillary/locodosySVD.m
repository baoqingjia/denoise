function[numcomp] = lrankSVD(pfgnmrdata,winstart,winend,nwin,fn,SVDoptions,SVDcutoff)

% Turn the ppm values into point numbers
winstartpoint=zeros(1,nwin);
winendpoint=zeros(1,nwin);
for f=1:length(winstart)
    for g=1:fn
        if pfgnmrdata.Ppmscale(g)<winstart(1,f)
            winstartpoint(1,f)=g;
            g=fn;
        end    
    end
    for h=1:fn
        if pfgnmrdata.Ppmscale(h)<winend(1,f)
            winendpoint(1,f)=h;
            g=fn;
        end    
    end
end
% Use these point numbers to extract the relevant bits of the spectral
% matrix ready for SVD analysis
cellofparts=cell([nwin,3]);
for k=1:nwin 
cellofparts{k,1} = pfgnmrdata.SPECTRA((winstartpoint(k):winendpoint(k)),:);
singularvalues=svd(cellofparts{k,1}); %perform SVD on the spectral part
cellofparts{k,2}=singularvalues;
count=1;
finished=0;
tsv=sum(singularvalues);
    while finished==0
        firstfewsv=sum(singularvalues(1:count));
        if (firstfewsv/tsv)>SVDcutoff
            finished=1;
            cellofparts{k,3}=count;
            numcomp(1,k)=count;
        end
        count=count+1;
    end
end

if SVDoptions==1
    plotSVD(cellofparts,nwin,pfgnmrdata,winstartpoint,winendpoint)
end
end

function plotSVD(cellofparts,nwin,pfgnmrdata,winstartpoint,winendpoint)

for k=1:nwin
figure('units','normalized','position',[0.05 0.5 0.9 0.4]);

% plot the window of the spectrum
spectrumaxes=subplot('position',[0.05 0.1 0.4 0.83]); 
spectrumpart=cellofparts{k,1};
h=plot(pfgnmrdata.Ppmscale(winstartpoint(k):winendpoint(k)),...
(spectrumpart(:,1)),'Parent',spectrumaxes,'LineWidth',1);
    axis('tight')
    ylim('auto');
    xlabel('\fontname{ariel} \bf Chemical shift (PPM)');
    set(gca,'Xdir','reverse');
    str1=['\fontname{ariel} \bf' 'Window No.: ' num2str(k)];
    xl=xlim;
    adjx=(xl(1)+(xl(2)-xl(1))*0.3);
    yl=ylim;
    x=(adjx);
    y=(yl(1,2)*0.9);
    text(x,y,str1,'Parent',spectrumaxes);
%plot the singular values
singvalsaxes=subplot('position',[0.55 0.1 0.4 0.83]); 
singularvalues=cellofparts{k,2};
singularvalues=singularvalues*(100/singularvalues(1));
x=[0 1 2 3 4 5 6 7 8 9];
svdnocomps=cellofparts{k,3};
j=plot(x,singularvalues(1:10),'Parent',singvalsaxes,'LineWidth',1);
    axis('tight')
    ylim('auto');
    xlabel('\fontname{ariel} \bf No. Components');
    str2=['\fontname{ariel} \bf' 'Suggested No. Comps: ' num2str(svdnocomps(1,1))];
    xl=xlim;
    yl=ylim;    
    x=(xl(1,2)*0.6);
    y=(yl(1,2)*0.9);
    text(x,y,str2,'Parent',singvalsaxes);
end
end
