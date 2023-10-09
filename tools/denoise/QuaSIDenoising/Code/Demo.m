close all;
clear all;

%% Important:
% run: mex nth_element.cpp 

%% Parameter
% K: Number of frames
% mu: Weight for the TV prior   
% lambda: Weight for the QuaSI prior
% alpha: Weight for the aux. variable of the QuaSI prior
% beta: Weight for the aux. variable of the TV prior
% tol: Termination tolerance
% maxOuterIter: Number of Outer Iterations
% maxInnerIter: Number of Inner Iterations
% p: Patchsize of the QuaSI prior
% quantile=0.5 is the median filter


%% standard parameter
K = 5;              
mu =  0.075*K;     
lambda = 5*K;       
alpha = 100*K;      
beta = 1.5*K;       
tol = 0.01;
maxOuterIter = 20; 
maxInnerIter = 2;   
p = 3;      
quantile = 0.5;    
%% input data from: https://www5.cs.fau.de/en/research/software/idaa/
% Dataset: pigeyeRegistered.zip
path = 'E:\Qingjia_work\NewMatlabCode\matlabcode\CSI_simulate\CSI_simulate\PHIP_Dynamic_image\denoise\QuaSIDenoising\Code\images\';
for k = 1:K
    g(:,:,k) = im2double(imread([path sprintf('9_%d.tif',k)]));
end

%% Optimization
result = admm(g,mu,lambda,alpha,beta,tol,maxOuterIter,maxInnerIter,p,quantile);
figure;imshow(result)