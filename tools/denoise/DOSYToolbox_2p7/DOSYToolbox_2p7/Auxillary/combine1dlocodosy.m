function[lrankdata]=combine1dlocodosy(components,nwin,fn,lrankdata,winstart,winend,sderrcell,sderrmultiplier)

% combine1dlrank: Organising the data produced by lrank_mn and export for
% clustering followed by assembling for presentation. 
%
% see also 'core_mn, decra_mn, dosy_mn, score_mn, and mcr_mn'
%
%-------------------------------INPUT--------------------------------------
% components      A cell array of the matrices returned from SCORE
%                 processing, containing the results from each window.
%                                                                      
% fn              The Fourier number of the recorded data.
%
% lrankdata       The data structure containing all the data and
%                 information from the lrank_mn processing.
%                 
% nwin            Number of windows that the spectrum (full or defined by
%                 Specrange)will be divied into.
%
% winstart/winend An array of the start/end points of the spectral windows
%                 (PPM).
%
% sderrcell       A cell array containing the standard errors of each 
%                 calculated diffusion coefficient.            
% 
% sderrmultiplier The value by which the standard error is multiplied for 
%                 the purpose of clustering.      
%
%--------------------------------------OUTPUT------------------------------
%   lrankdata          Structure containg the concatenated 1D suggested
%                      component spectra, and clustering errors per
%                      component.
% 
%     combine1dlrank   of NMR data
%     Copyright (C) <2010>  <Mathias Nilsson>
%
%     This program is free software; you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation; either version 2 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License along
%     with this program; if not, write to the Free Software Foundation, Inc.,
%     51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
%
%     Dr. Mathias Nilsson 
%     School of Chemistry, University of Manchester,
%     Oxford Road, Manchester M13 9PL, UK 
%     Telephone: +44 (0) 161 275 4668 
%     Fax: +44 (0)161 275 4598
%     mathias.nilsson@manchester.ac.uk

getdvals=[100,3];
tncomps=1; % total number of components

for m=1:nwin
    dimensions=size(components{m,1}); % find out num comps in the window
    numwincomp=dimensions(1,1);
    dvalmatrix=components{m,2}; % retrieves the dval matrix for this window
    sderrarray=sderrcell{m,1}; % retrieves the standard errors for these dvals
    for k=1:numwincomp
        getdvals((tncomps),1)=m; % saves the window number at the bottom of the first column
        getdvals((tncomps),2)=k; % saves the row in the window matrix at the bottom of the second column
        dvalscalar=dvalmatrix(1,k); % retrieves the correct dval from that matrix 
        getdvals((tncomps),3)=dvalscalar; % saves the dval at the bottom of the third column
        getdvals((tncomps),4)=(sderrarray(k)); % Saves the error on this dval       
    tncomps=tncomps+1;
    end
end

sorteddvals=sortrows(getdvals,3); % sorts by dval, maintaining which spectra each dval relates to.
sorteddvals(:,3)=sorteddvals(:,3)*100000;
sorteddvals(:,3)=round(sorteddvals(:,3));
sorteddvals(:,3)=sorteddvals(:,3)/100000;

% call the clustering algorithm.
[centroids,clusterlimits]=locodosyclustering(sorteddvals, sderrmultiplier);
centroids=sortrows(centroids,1);
centroids=centroids*100000;
centroids=round(centroids);
centroids=centroids/100000;

overallncomps=length(centroids); % No. of concatenated spectra to be produced
for j=1:length(centroids)
    [rows1]=find(sorteddvals(:,3)==centroids(j));
    [rows2]=find((sorteddvals(:,3)<(centroids(j,1)+ (sorteddvals(rows1(1),4)*sderrmultiplier*10)))...
                & sorteddvals(:,3)>(centroids(j,1)-(sorteddvals(rows1(1),4)*sderrmultiplier*10)));
% the problem here is that the clustering algorithm uses fuzzy clustering
% and so does not specifically assign a dval to a particular cluster, each
% centroid has 'influence' over every dval. as a result the application of
% the SD err multiplier here to produce suggested components is too small
% and a factor of 10 is included also.
    dvalrange{j,1}=['D = ' num2str(sorteddvals(rows1,3)) ' +/- '...
        num2str(sorteddvals(rows1,4)*sderrmultiplier)]; %#ok
    for k=1:length(rows2)
% Organise the bits of spectrum from each window into adjacent matrices in a cell 
        windowmatrix=components{(sorteddvals(rows2(k))),1};
        sorted1dspectra{j,(sorteddvals(rows2(k),1))}=windowmatrix(sorteddvals(rows2(k),2),:);
    end
    
end

% Create the matrix for storing the completed spectra and convert from a
% PPM value to a point number for easy reference in the matrix.
cc1dspectra=zeros([overallncomps,fn]);
winstartpoint=zeros(1,nwin);
winendpoint=zeros(1,nwin);
for f=1:length(winstart)
    for g=1:fn
        if lrankdata.Ppmscale(g,1)<winstart(1,f)
            winstartpoint(1,f)=g;
            g=fn; %#ok
        end    
    end
    for h=1:fn
        if lrankdata.Ppmscale(h)<winend(1,f)
            winendpoint(1,f)=h;
            g=fn; %#ok
        end    
    end
end

overallncomps %#ok
% populate the matrix with the sections of spectra for each components and
% any gaps with 0's
for l=1:overallncomps
    for j=1:nwin
        if size(sorted1dspectra{l,j})>0
            for y=1:(length(sorted1dspectra{l,j}))
                compmatrix=sorted1dspectra{l,j};
                cc1dspectra(l,(winstartpoint(1,j)+y))=compmatrix(1,y);
            end
        end
    end
end
lrankdata.winendpoint=winendpoint;
lrankdata.winstartpoint=winstartpoint;
lrankdata.sorted1dspectra=sorted1dspectra;
lrankdata.cc1dspectra=cc1dspectra;
lrankdata.ccncomps=overallncomps;
lrankdata.dvalrange=dvalrange;
lrankdata.nwin=nwin;
lrankdata.sorteddvals=sorteddvals;
end
