% A comparison for various image denoising algorithms on the famous "lena"
% image. One example call for each denoising algorithm is included, the
% resulting images are stored. This code may serve as an example on how to
% use the various algorithms.
%
% Author: Markus Mayer, Pattern Recognition Lab, University
% of Erlangen-Nuremberg, markus.mayer@informatik.uni-erlangen.de

% Load image, store noisy version as well as original

img = double(imread('lena.jpg'));

img=img(:,:,1);

img = img./ 255;

imgNoise = img + randn(size(img)) .* 0.2;
imgNoise(imgNoise < 0) = 0;
imgNoise(imgNoise > 1) = 1;

% imwrite(img, 'lenaOrig.jpg', 'Quality', 100);
% imwrite(imgNoise, 'lenaNoise.jpg', 'Quality', 100);



% Apply the denoising algorithms and store the results

imgWaveletHard = waveletHardThreshold(imgNoise, 'mu', 0.15, 'lmax', 5, 'basis', 'dddtcwt');
figure;;subplot(1,3,1);imagesc(img)
subplot(1,3,2);;imagesc(imgNoise)
subplot(1,3,3);;imagesc(imgWaveletHard)
% imwrite(imgWaveletHard, 'lenaWaveletHard.jpg', 'Quality', 100);

imgWaveletSoft = waveletSoftThreshold(imgNoise, 'mu', 0.15, 'lmax', 5, 'basis', 'dddtcwt');
figure;;subplot(1,3,1);imagesc(img)
subplot(1,3,2);;imagesc(imgNoise)
subplot(1,3,3);;imagesc(imgWaveletSoft)

imgComplex = diffusionPeronaMalik(imgNoise, 'function', 'complex', 'sigma', 0.02, 'time', 10 , 'maxIter', 300);
figure;;subplot(1,3,1);imagesc(img)
subplot(1,3,2);;imagesc(imgNoise)
subplot(1,3,3);;imagesc(abs(imgComplex))

imgAnisotropic = diffusionAnisotropic(imgNoise, 'function', 'tuckey', 'sigma', 0.005, 'time', 2 , 'maxIter', 300);
% imwrite(imgAnisotropic, 'lenaAnisotropic.jpg', 'Quality', 100);
figure;;subplot(1,3,1);imagesc(img)
subplot(1,3,2);;imagesc(imgNoise)
subplot(1,3,3);;imagesc(abs(imgAnisotropic))

imgBayes = bayesEstimateDenoise(imgNoise, 'sigmaSpatial', 3, 'windowSize', 3, 'sigmaFactor', 2);
 figure;;subplot(1,3,1);imagesc(img)
subplot(1,3,2);;imagesc(imgNoise)
subplot(1,3,3);;imagesc(abs(imgBayes))

% A special section for the multiframe method:

imgNoiseVol = zeros(size(img, 1), size(img, 2), 4);

for i = 1:4
    imgNoise = img + randn(size(img)) .* 0.2;
    imgNoise(imgNoise < 0) = 0;
    imgNoise(imgNoise > 1) = 1;

    imgNoiseVol(:,:,i) = imgNoise;
end

imgWaveletMultiframe = waveletMultiFrame(imgNoiseVol, 'k', 6, 'p', 4, 'maxLevel', 5, 'weightMode', 4, 'basis', 'dualTree');
% imwrite(imgWaveletMultiframe, 'lenaMultiframe.jpg', 'Quality', 100);

 figure;;subplot(1,3,1);imagesc(img)
subplot(1,3,2);;imagesc(sum(imgNoiseVol,3))
subplot(1,3,3);;imagesc(abs(imgWaveletMultiframe))

sigma=20;
z=(sum(imgNoiseVol,3));
z=z/max(z(:))*256;
[NA, y_est] = BM3D(1, z, sigma);
 figure;;subplot(2,2,1);imagesc(img)
subplot(2,2,2);;imagesc(sum(imgNoiseVol,3));colormap gray;
subplot(2,2,3);;imagesc(abs(y_est))
subplot(2,2,4);;imagesc(abs(imgWaveletMultiframe))

ImDenoise=bm4d(imgNoiseVol);
figure;imagesc(abs(sum(ImDenoise(:,:,:),3)));colormap gray;

 figure;;subplot(2,2,1);imagesc(img)
subplot(2,2,2);;imagesc(sum(imgNoiseVol,3));colormap gray;
subplot(2,2,3);;imagesc(abs(y_est))
subplot(2,2,4);;imagesc(abs(sum(ImDenoise(:,:,:),3)));colormap gray;

%%

%% Set Parameters
N = size(imgNoise,1); % Matrix length
L = log2(N);  % Number of levels
FOV = [N,N]; % Matrix Size
sigma = 0.1;

nIter = 1000; % Number of iterations

rho = 10; % ADMM parameter


%% Generate Multiscale block Sizes
max_L = L;

% Generate block sizes
block_sizes = [2.^(0:2:max_L)', 2.^(0:2:max_L)'];
block_sizes = [block_sizes; N^2, 1];
disp('Block sizes:');
disp(block_sizes)

levels = size(block_sizes,1);

ms = block_sizes(:,1);

ns = block_sizes(:,2);

bs = prod( repmat(FOV, [levels,1]) ./ block_sizes, 2 );

ms = [ms; N*N];
ns = [ns; 1];
bs = [bs; 1];

% Penalties
lambdas = sqrt(ms) + sqrt(ns) + sqrt( log2( bs .* min( ms, ns ) ) );


%% Generate Hanning Blocks


% nblocks = [10, 6, 4, 1, 1];

% [X, X_decom] = gen_hanning( FOV, block_sizes, nblocks, sigma );
X=50*abs(imgNoise)/max(abs(imgNoise(:)));

figure,imshow(abs(X),[])
titlef('Original');
% 
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
%     figure(24),
%     imshow3(abs(X_it),[],[1,levels]),
%     title(sprintf('Iteration %d',it),'FontSize',14);
%     drawnow
    
end

%% Show Result

figure,imshow3(abs(X_it),[],[1,levels]),title('Multi-scale Low Rank Decomposition','FontSize',14);


XRec=sum(X_it(:,:,end-3:end),3);
figure;subplot(1,2,1);imagesc(X);colormap gray;
subplot(1,2,2);imagesc(XRec);colormap gray;


