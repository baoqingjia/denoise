%% Multi-scale Low Rank Matrix Decomposition on Hanning Matrices
%
% (c) Frank Ong 2015
%
clc
clear
% close all
% setPath


load original_noiseData.mat;
SpecAll=PhaseDataAfterphc;


%% Set Parameters
N =size(SpecAll); % Matrix length
L = log2(min(N(:)));  % Number of levels
FOV = [N(1),N(2)]; % Matrix Size
sigma = 0.1;
nIter = 50; % Number of iterations
rho = 10; % ADMM parameter


%% Generate Multiscale block Sizes
% block_sizesRow = [1  4  4 4  4 8   8  16 18 18 ];
% block_sizesCol = [1 4  4 8  8 20 20 30  30  30];
block_sizesRow = [16  32  64  128 256 512];
block_sizesCol = [16  32  64  128 256 512];


max_L = length(block_sizesCol);

% Generate block sizes


block_sizes=cat(1,block_sizesCol,block_sizesRow);
block_sizes=block_sizes';
block_sizes = [block_sizes; N(1)*N(2), 1];
disp('Block sizes:');
disp(block_sizes)

levels = size(block_sizes,1);

ms = block_sizes(:,1);

ns = block_sizes(:,2);

bs = prod( repmat(FOV, [levels,1]) ./ block_sizes, 2 );

ms = [ms; N(1)*N(1)];
ns = [ns; 1];
bs = [bs; 1];

% Penalties
lambdas = sqrt(ms) + sqrt(ns) + sqrt( log2( bs .* min( ms, ns ) ) );


%% Generate Hanning Blocks

% rng(5)
% nblocks = [10, 6, 4, 1, 1];

% [X, X_decom] = gen_hanning( FOV, block_sizes, nblocks, sigma );

X=abs(SpecAll)/max(abs(SpecAll(:)));


figure,imshow(abs(X),[])
titlef('Original');

% figure,imshow3(abs(X_decom),[],[1,levels]),
% titlef('Actual Decomposition');
% drawnow

%% Initialize Operator
FOVl = [FOV,levels];
level_dim = length(FOV) + 1;


% Get summation operator
A = @(x) sum( x, level_dim ); % Summation Operator
AT = @(x) repmat( x, [ones(1,level_dim-1), levels] ); % Adjoint Operator


%% Iterations
X_it = zeros(FOVl);
Z_it = zeros(FOVl);
U_it = zeros(FOVl);

for it = 1:nIter
    
    % Data consistency
    X_it = 1 / levels * AT( X - A( Z_it - U_it ) ) + Z_it - U_it;
    
    % Level-wise block threshold
    for l = 1:levels
        Z_it(:,:,l) = blockSVT( X_it(:,:,l) + U_it(:,:,l), block_sizes(l,:), lambdas(l) / rho);     
    end
    
    % Update dual
    U_it = U_it - Z_it + X_it;
    
    % Plot
    figure(24),
    imshow3(abs(X_it),[],[1,levels]),
    title(sprintf('Iteration %d',it),'FontSize',14);
    drawnow
    
end

%% Show Result
figure,imshow3(abs(X_it),[],[1,levels]),title('Multi-scale Low Rank Decomposition','FontSize',14);

XRec=sum(X_it (:,:,1:end-1),3);
DenoiseSpecAll=XRec;

figure;stackedplot(abs(DenoiseSpecAll(1:end,1:18)),1,1);  
figure;stackedplot(abs(SpecAll(1:end,:)),1,1);    
figure;subplot(1,2,1);plot(abs(sum(DenoiseSpecAll,2)));subplot(1,2,2);plot((abs(sum(SpecAll,2))))

ImagShowNum=18;
figure('Name','all Spec'); 
ha = tight_subplot(2,ImagShowNum,0.001);
for iSilce=1:ImagShowNum
    axes(ha(iSilce)); %#ok<LAXES>
    plot((abs((SpecAll(:,iSilce)))));ylim([0,3*10^6])
    axes(ha(iSilce+ImagShowNum)); %#ok<LAXES>
    plot((abs((DenoiseSpecAll(:,iSilce)))));ylim([0,1])
end

