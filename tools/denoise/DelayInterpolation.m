function [FID,Spec] = DelayInterpolation(Mat,groupDelay)

% Cut the delay in the beginning and past it in the end when interpulating
% the data. Gets a Matrix of all seperate averages and repetitions when the
% time dependent data is in the colomns and returns two matrices- FID and
% Spec each has the data of each average in the rows.


% Gets a Matrix size - NA*NR x NAcqPoints- the data of each average is in the rows.
% Returns two matrix FIS and Spec each - NA*NR x NAcqPoints - the data of
% each average is in the rows.
% Note - all matrices are in the right orientation!
      
if nargin<2    groupDelay = 67.985717773437500; end

        FID = fft(Mat,size(Mat,2),2);
        N = size(FID,2);
        x = linspace(0, 1-1/N, N);
        FID = FID.*exp(1i*2*pi*(groupDelay-0.03)*x);
        FID = ifft(FID,size(FID,2),2);
        FID = FID(:,1:size(FID,2)-ceil(groupDelay)-1);
        Spec = fftshift(fft(FID,size(FID,2),2));


end


% Old - for only one spectrum matrix-
%         groupDelay = ParamStructacqp.GRPDLY;
%         fid = fft(Mat); % only one dimention (no averages) if the spectrum is on the second dimention (row data)
%         N = numel(fid);
%         x = linspace(0, 1-1/N, N);
%         fid = fid.*exp(1i*2*pi*(groupDelay-0.03)*x);
%         fid = ifft(fid);
%         % Take off the last few points
%         FID = fid(1:end-ceil(groupDelay)-1);
%         Spec = fftshift(fft(FID)); %return one spectrum (not matrix of averages) where the data is on the second dim (raw vector)


%       
%         groupDelay = ParamStructacqp.GRPDLY;
%         FID = fft(Mat,size(Mat,2),2);
%         N = size(FID,2);
%         x = linspace(0, 1-1/N, N);
%         FID = FID.*exp(1i*2*pi*(groupDelay-0.03)*x);
%         FID = ifft(FID,size(FID,2),2);
%         FID = FID(:,1:size(FID,2)-ceil(groupDelay)-1);
%         Spec = fftshift(fft(FID,size(FID,2),2));
%         FID = fliplr(FID);
%         Spec = fliplr(Spec);