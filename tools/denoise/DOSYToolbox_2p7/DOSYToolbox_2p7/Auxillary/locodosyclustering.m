%%




%% Homebrew Kmeans 
%function[] = lrankclustering(sorteddvals)
% dvalarray=sorteddvals(:,3);
% dvalarray=dvalarray';
% numpoints=length(dvalarray);
% SSE=zeros(1,numpoints);
% 
% centroids=0;
% centroids(1)=dvalarray(1);
% centroids(2)=dvalarray(numpoints);
% dvalmatrix=dvalarray;
% dvalmatrix(2,1)=1;
% 
% for i=1:numpoints
%     if i==2
%         SSE=sum(minvals.^2);
%     end
%     for j=1:length(centroids)      
%         for k=1:numpoints   
%             distmatrix(j,k)=((dvalarray(k)-centroids(j))^2); %#ok
%         end
%     end
%     [minvals, index]=min(distmatrix,[],2);
%     for m=1:numpoints
%        clusters{index(m),1}=[clusters{index(m),1} dvalarray(m)]; 
%     end

% UNFINISHED

% end
% figure
% plot(num,SSE);
% end
%% Inbuilt Kmeans
% function[] = lrankclustering(sorteddvals)
% dvalarray=sorteddvals(:,3);
% dvalarray=dvalarray';
% for k=1:length(dvalarray)
% [IDX,C,sumd]=kmeans(dvalarray,k,...
%                     'distance','sqEuclidean',...
%                     'replicates',5);
% sumdmat(k,1)=sum(sumd);    %#ok        
% end
% figure
% plot(sumdmat)
% end
%% Inbuilt Fuzzy Clustering
% function[] = lrankclustering(sorteddvals)
% dvalarray=sorteddvals(:,3);
% for k=2:length(dvalarray)
%     n_clusters=k;
%     [centre,U,obj_fcn] = fcm(dvalarray, n_clusters);
% sumdmat(k,1)=min(obj_fcn);            
% end
% figure
% plot(sumdmat(2:k,1))
% end
%% Hybrid Subtractive Clustering (uses the st. err. values for each peak)
function[centroids,clusterlimits] = locodosyclustering(sorteddvals,sderrmultiplier)
dvalarray=sorteddvals(:,3);
dosyspec=findobj(gcf,'Position',[0.1 0.34 0.7 0.5]); % will break down if dosy spec moved
axlim=axis(dosyspec);
axheight=diff(axlim(3:4));
diffsderr=abs(sorteddvals(:,4) ./ axheight);
diffsderr=diffsderr .* sderrmultiplier; % sd err adjustment
% call the clustering function
[centroids,clusterlimits]=sclust(dvalarray,diffsderr);
% lines where the centroids fall
x=[axlim(1) axlim(2)];
for k=1:length(centroids)
    y=[centroids(k) centroids(k)];
    line(x,y,'color','g','linewidth',1,'parent',dosyspec);
end
end
function[centroids,clusterlimits] = sclust(dvals,diffsderr)
[numpoints,numdims] = size(dvals);

removefactor = 1.25; % compensates upon the discovery of a centroid for its influence
includeratio = 0.5; % how much lower the potential for being a centroid is compared
excluderatio = 0.15; % to the potential of the first centroid.

sderrmults = 1.0 ./ diffsderr;
subtpotvect = 1.0 ./ (removefactor * diffsderr);

mindval = min(dvals);
maxdval = max(dvals);
index = find(maxdval == mindval);
mindval(index) = mindval(index) - 0.0001*(1 + abs(mindval(index)));
maxdval(index) = maxdval(index) + 0.0001*(1 + abs(maxdval(index)));
dvals(:,1) = (dvals(:,1) - mindval) / (maxdval - mindval); % normalization
dvals = min(max(dvals,0),1);

centroidpots = zeros(1,numpoints); 

for i=1:numpoints, 
    startpt= dvals(i,1);
    startpt= startpt(ones(1,numpoints),1);
	overlapmat = (startpt - dvals) .* sderrmults;
    centroidpots(i) = sum(exp(-4*overlapmat.^2)); % how good a centroid each point would make.
end 

% the centroid with the maximum overlap is used as the starting point and
% as a reference for further centroid suitability.
[startcentd,bestcentdind] = max(centroidpots);

% begin finding centroids using the best starting centroid as a beginning
bestcentdpot = startcentd;

centroids = [];
numcentroids = 0;
keeplooking = 1;

while keeplooking & bestcentdpot %#ok
	keeplooking = 0;
	bestcentdval = dvals(bestcentdind,:);
	bestcentdratio = bestcentdpot/startcentd;

	if bestcentdratio > includeratio
		keeplooking = 1; % worthy of being a centroid
	elseif bestcentdratio > excluderatio % consider distance from other centroids + potential
		minsqerr = -1;
		for i=1:numcentroids
            overlapmat = (bestcentdval - centroids(i,:)) .* sderrmults;
			overlapmat2 = overlapmat * overlapmat';

			if minsqerr < 0 | overlapmat2 < minsqerr %#ok
				minsqerr = overlapmat2; 
			end
		end	

		minerr = sqrt(minsqerr);
		if (bestcentdratio + minerr) >= 1 %
			keeplooking = 1;	% add as a centroid
		else
			keeplooking = 2;	% do not add and remove
		end
	end	
	if keeplooking == 1
		centroids = [centroids ; bestcentdval]; %#ok, new centroid added
		numcentroids = numcentroids + 1;

        tempvect = bestcentdval(ones(1,numpoints), :);
		overlapmat = (tempvect - dvals) .* subtpotvect;
    	remove = bestcentdpot*exp(-4*overlapmat.^2);
		centroidpots = centroidpots - remove'; % reset nearby potentials
		centroidpots(centroidpots<0) = 0; 

		[bestcentdpot,bestcentdind] = max(centroidpots); % look for the next best

	elseif keeplooking == 2
		centroidpots(bestcentdind) = 0;
		[bestcentdpot,bestcentdind] = max(centroidpots);
	end 
end
% reverse normalisation
centroids(:,1) = (centroids(:,1) * (maxdval(1) - mindval(1))) + mindval(1);
% reverse normalise the limits
clusterlimits = (diffsderr .* (maxdval - mindval));
end
