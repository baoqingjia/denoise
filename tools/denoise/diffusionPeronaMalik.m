function [sol, resimg] = diffusionPeronaMalik(img, varargin)
% DENOISEPM Denoise an image with Perona-Malik isotropic diffusion. Many
% proposed algorithms in the literature can be formulated such that they
% fit in the Perona-Malik framework, just by switching the edgestopping
% function. We implemented some of them. 
% 
% The underlying PDE is solved by the lagged diffusivity method 
% (C. R. Vogel, 1996, see below) using red-black Gauss-Seidel iteration 
% steps.
%
% Note: In older literature, and even in our days, the diffusion algorithms
% originated from the Perona-Malik formulation are called "anisotropic
% diffusion". However, we stick to J. Weickerts definition of it, calling
% it "isotropic diffusion", as the amount of diffusion applied in all 
% direction is equal for each pixel.
% 
% Parameters:
% [SOL, RESIMG] = denoisePM(IMG, VARARGIN)
% SOL: Solution. The diffused image.
% RESIMG: Optional residual image.
% IMG: 2D image matrix
% VARARGIN: Optional parameters:
%   sigma: standard derivation value/list of the edge-stopping 
%       function 
%   time: Time parameter - amount of diffusion applied.
%   preSmooth: standart derivation of pre-gradient-computation 
%       smoothing (suggestion: something small, for example 0.5)
%   maxIter: Maximum number of iterations. (suggestion: 1000)
% EDGESTOPFCT: edge-stopping function used. Possibilities are: 'perona',
% 'tukey', 'tukeylog', 'complex', 'complexIntensitySensitiv'
%  Default: tukey
% STARTSOL: Initialisation for the solution, by default the input image
%
% Calling examples:
% 
% First Example: 0..255 scaled intensity values, tuckey edge stop.
% sol = denoisePM(img, 'function', 'tuckey', ...
%                      'sigma', 20, 'time', 3, 'maxIter', 1000);  
%
% Second example: 0..255 scaled intensity values, complex diffusion
% sol = denoisePM(img, 'function', 'complex', ...
%                 'sigma', [20 pi/1000], 'time', 3, 'maxIter', 200, ...
%                 'preSmooth', 0);  
%
% A list of cites for the different edgestopfunctions:
%
% 'perona'
% P. Perona, J. Malik:	Scale-Space and Edge Detection Using Anisotropic
% Diffusion, IEEE Trans. Pattern Anal. Mach. Intell., 
% 12(7), 1990, 629?639.
%
% 'tuckey'
% M. J. Black, G. Sapiro, D. Marimont, D. Heeger: Robust anisotropic
% diffusion, IEEE Trans. on Image Processing, 
% 7(3), 1998, 421?432.
%
% 'complex'
% G. Gilboa, N. A. Sochen, Y.Y. Zeevi, Image Enhancement and Denoising by 
% Complex Diffusion Processes, 
% IEEE Trans. Pattern Anal. Mach. Intell. 26(8), 1020?1036 (2004).
% Needs 2 sigma variables: Sigma and Theta, stored in a vector
%
% 'complexIntensitySensitiv'
% Ideas were adapted from (but not exactly reproduced, as we use a
% different solver, and not the theta->0 approximative solution of Gilboas 
% complex diffusion:
% Rui Bernardes, Cristina Maduro, Pedro Serranho, Aderito Araujo,
% Silvia Barbeiro, and Jose Cunha-Vaz: Improved adaptive complex diffusion
% despeckling filter, Optics Express, 18(23), 24048-24059, 2010
% Needs 4 sigma variables: SigmaMin, SigmaMax, Theta, GaussNeighborHood
%
% The corresponding 'log' version compute their coefficients on a 
% logarithmic version of the image.
%
% The lagged diffusitivy solution of the PDE was proposed in:
% C. R. Vogel, M. E. Oman: Iterative Methods for Total Variation Denoising,
% SIAM Journal on Scientific Computing, 17(1), 1996, 227?238.
% 
% Further discussion on the method can be found in:
% T. Chan, P. Mulet: On the convergence of the lagged diffusivity fixed
% point method in total variation image restoration,
% SIAM journal on numerical analysis, 36(2), 1999, 354?367.
%
% Implementation by Markus Mayer, Pattern Recognition Lab, 
% University of Erlangen-Nuremberg, 2008
% This version was revised and commented in August 2010, and modified again
% in December 2011
%
% You may use this code as you want. I would be grateful if you would go to
% my homepage look for articles that you find worth citing in your next
% publication:
% http://www5.informatik.uni-erlangen.de/en/our-team/mayer-markus
% Thanks, Markus

Params.edgeStopFunction = 'tukey';
Params.sigma = 20;
Params.time = 3;
Params.preSmooth = 0;
Params.maxIter = 1000;
Params.precision = 'double';
Params.startSolutionProvided = 0;

% Read Optional Parameters
if (~isempty(varargin) && iscell(varargin{1}))
    varargin = varargin{1};
end

for k = 1:2:length(varargin)
    if (strcmp(varargin{k}, 'sigma'))
        Params.sigma = varargin{k+1};
    elseif (strcmp(varargin{k}, 'sigmaMin'))
        Params.sigma(1) = varargin{k+1};
    elseif (strcmp(varargin{k}, 'sigmaMax'))
        Params.sigma(2) = varargin{k+1};
    elseif (strcmp(varargin{k}, 'sigmaGauss'))
        Params.sigma(4) = varargin{k+1};
        Params.sigma(3) = pi/1000;
    elseif (strcmp(varargin{k}, 'sigmaCurve'))
        Params.sigma(5) = varargin{k+1};
    elseif (strcmp(varargin{k}, 'time'))
        Params.time = varargin{k+1};
    elseif (strcmp(varargin{k}, 'preSmooth'))
        Params.preSmooth = varargin{k+1};
    elseif (strcmp(varargin{k}, 'maxIter'))
        Params.maxIter = varargin{k+1};
    elseif (strcmp(varargin{k}, 'precision'))
        Params.precision = varargin{k+1};
    elseif (strcmp(varargin{k}, 'function'))
        Params.edgeStopFunction = varargin{k+1};
    elseif (strcmp(varargin{k}, 'startSolution'))
        sol = varargin{k+1};
        Params.startSolutionProvided = 1;
    end
end

if strcmp(Params.edgeStopFunction, 'complex') && numel(Params.sigma) == 1
    Params.sigma = [Params.sigma pi/1000];
end

if strcmp(Params.edgeStopFunction, 'complexIntensitySensitiv') 
    if Params.sigma(1) > Params.sigma(2)
        temp = Params.sigma(2);
        Params.sigma(2) = Params.sigma(1);
        Params.sigma(1) = temp;
    end
end


% Add a 1-border to the image (mirroring, to avoid boundary problems)
img = [img(:,1), img, img(:,size(img,2))];
img = vertcat(img(1,:), img, img(size(img,1),:));

if ~Params.startSolutionProvided
    sol = img; % solution initialisation: original image
else
    sol = [sol(:,1), sol, sol(:,size(sol,2))];
    sol = vertcat(sol(1,:), sol, sol(size(sol,1),:));
end

% Variable initialisations
stencilN = zeros(size(img, 1), size(img, 2), Params.precision);
stencilS = zeros(size(img, 1), size(img, 2), Params.precision);
stencilE = zeros(size(img, 1), size(img, 2), Params.precision);
stencilW = zeros(size(img, 1), size(img, 2), Params.precision);
stencilM = zeros(size(img, 1), size(img, 2), Params.precision);

resimg = img;
resold = 1e+20; % old residual
resarr = [1e+20 1e+20 1e+20]; % array of the last 3 residual changes

% To avoid numerical problems when computing the gradients, the image might
% be smoothed with a small gaussian before the computation. Initialisation
% of the gaussian filter.
if Params.preSmooth ~= 0
    gauss1 = fspecial('gaussian', ...
        round(Params.preSmoothOn + Params.preSmoothOn + 1), ...
        Params.preSmoothOn);
end

iter = 0; % iteration counter

% Algorithm: No explicit time marching is applied, instead the linear
% equation system the diffusion process creates for one timestep is solved
% with lagged diffusivity by R/B Gauss-Seidel Iteration steps

% diffusion iteration stoping criteria
% if the sum of the last 5 residuals is negative, a completion of the
% calculation is assumed.
while (sum(resarr) > 0) && (iter < Params.maxIter);
    % Calculation of the edge-stoping function
    
    if Params.preSmooth ~= 0
        smoothsol = imfilter(sol, gauss1, 'symmetric');
        
        if strcmp(Params.edgeStopFunction,  'tukey')
            coeff = tukeyEdgeStop(smoothsol, Params.sigma);
        elseif strcmp(Params.edgeStopFunction, 'perona')
            coeff = peronaEdgeStop(smoothsol, Params.sigma);
        elseif strcmp(Params.edgeStopFunction, 'tukeylog')
            coeff = tukeyEdgeStopLog(smoothsol, Params.sigma);
        elseif strcmp(Params.edgeStopFunction, 'complex')
            coeff = complexEdgeStop(smoothsol, Params.sigma);
        elseif strcmp(Params.edgeStopFunction, 'complexIntensitySensitiv')
            gauss2 = fspecial('gaussian', ...
                round(Params.sigma(4) + Params.sigma(4) + 1), ...
                Params.sigma(4));
            washedSol = imfilter(sol, gauss2, 'symmetric');
            coeff = complexIntensitySensitiveEdgeStop(smoothsol, Params.sigma, washedSol);
        else
            error('Give a suitable edgeStopFunction argument');
        end
    else
        if strcmp(Params.edgeStopFunction,  'tukey')
            coeff = tukeyEdgeStop(sol, Params.sigma);
        elseif strcmp(Params.edgeStopFunction, 'perona')
            coeff = peronaEdgeStop(sol, Params.sigma);
        elseif strcmp(Params.edgeStopFunction, 'tukeylog')
            coeff = tukeyEdgeStopLog(sol, Params.sigma);
        elseif strcmp(Params.edgeStopFunction, 'complex')
            coeff = complexEdgeStop(sol, Params.sigma);
        elseif strcmp(Params.edgeStopFunction, 'complexIntensitySensitiv')
            gauss2 = fspecial('gaussian', ...
                round(Params.sigma(4) + Params.sigma(4) + 1), ...
                Params.sigma(4));
            washedSol = imfilter(sol, gauss2, 'symmetric');
            coeff = complexIntensitySensitiveEdgeStop(sol, Params.sigma, washedSol);
        else
            error('Give a suitable edgeStopFunction argument');
        end
    end
    
    coeff = coeff * Params.time;
    
    % Stencil computation
    stencilN(2:end-1, 2:end-1) = (coeff(2:end-1, 2:end-1) + coeff(1:end-2, 2:end-1))/2;
    stencilS(2:end-1, 2:end-1) = (coeff(2:end-1, 2:end-1) + coeff(3:end, 2:end-1))/2;
    stencilE(2:end-1, 2:end-1) = (coeff(2:end-1, 2:end-1) + coeff(2:end-1, 3:end))/2;
    stencilW(2:end-1, 2:end-1) = (coeff(2:end-1, 2:end-1) + coeff(2:end-1, 1:end-2))/2;

    stencilM = stencilN + stencilS + stencilE + stencilW + 1;

    % Solution computation: R/B Gauss Seidel
    sol(2:2:end-1, 2:2:end-1) = (img(2:2:end-1, 2:2:end-1) ...
        + (stencilN(2:2:end-1, 2:2:end-1) .* sol(1:2:end-2, 2:2:end-1) ...
        + stencilS(2:2:end-1, 2:2:end-1) .* sol(3:2:end, 2:2:end-1) ...
        + stencilE(2:2:end-1, 2:2:end-1) .* sol(2:2:end-1, 3:2:end)...
        + stencilW(2:2:end-1, 2:2:end-1) .* sol(2:2:end-1, 1:2:end-2))) ...
        ./ stencilM(2:2:end-1, 2:2:end-1);

    sol(3:2:end, 3:2:end) = (img(3:2:end, 3:2:end) ...
        + (stencilN(3:2:end, 3:2:end) .* sol(2:2:end-1, 3:2:end) ...
        + stencilS(3:2:end, 3:2:end) .* sol(4:2:end, 3:2:end) ...
        + stencilE(3:2:end, 3:2:end) .* sol(3:2:end, 4:2:end) ...
        + stencilW(3:2:end, 3:2:end) .* sol(3:2:end, 2:2:end-1))) ...
        ./ stencilM(3:2:end, 3:2:end);

    sol(2:2:end-1, 3:2:end) = (img(2:2:end-1, 3:2:end) ...
        + (stencilN(2:2:end-1, 3:2:end) .* sol(1:2:end-2, 3:2:end) ...
        + stencilS(2:2:end-1, 3:2:end) .* sol(3:2:end, 3:2:end) ...
        + stencilE(2:2:end-1, 3:2:end) .* sol(2:2:end-1, 4:2:end) ...
        + stencilW(2:2:end-1, 3:2:end) .* sol(2:2:end-1, 2:2:end-1))) ...
        ./ stencilM(2:2:end-1, 3:2:end);

    sol(3:2:end, 2:2:end-1) = (img(3:2:end, 2:2:end-1) ...
        + (stencilN(3:2:end, 2:2:end-1) .* sol(2:2:end-1, 2:2:end-1) ...
        + stencilS(3:2:end, 2:2:end-1) .* sol(4:2:end, 2:2:end-1) ...
        + stencilE(3:2:end, 2:2:end-1) .* sol(3:2:end, 3:2:end) ...
        + stencilW(3:2:end, 2:2:end-1) .* sol(3:2:end, 1:2:end-2))) ...
        ./ stencilM(3:2:end, 2:2:end-1);

    % Residual computation
    resimg(2:end-1, 2:end-1) = (-(stencilN(2:end-1, 2:end-1) .* sol(1:end-2, 2:end-1) ...
        + stencilS(2:end-1, 2:end-1) .* sol(3:end , 2:end-1) ...
        + stencilE(2:end-1, 2:end-1) .* sol(2:end-1, 3:end) ...
        + stencilW(2:end-1, 2:end-1) .* sol(2:end-1, 1:end-2))) ...
        + stencilM(2:end-1, 2:end-1) .* sol(2:end-1, 2:end-1) - img(2:end-1, 2:end-1);

    res = sum(sum(real(resimg) .* real(resimg)));

    resdiff = resold - res;
    resold = res;
    resarr = [resdiff resarr(1, 1:(size(resarr, 2)-1))];

    % Duplicate edges as new borders
    sol = [sol(:,2), sol(:, 2:end-1), sol(:,end-1)];
    sol = vertcat(sol(2,:), sol(2:end-1, :), sol(end-1,:));
    
    iter = iter + 1;
end

% Remove border, return solution
sol = sol(2:(size(sol,1)-1), 2:(size(sol,2)-1));
if(nargout > 1)
    resimg = resimg(2:(size(sol,1)-1), 2:(size(sol,2)-1));
end;

%--------------------------------------------------------------------------

function r = tukeyEdgeStop(img, sigma)
% TUKEYEDGESTOP Tukey Edge-Stopping function on matrix
% tukeyEdgeStop(img, sigma)
% img: 2D image matrix
% sigma: standard derivation parameter

r = gradientAbsolute(img);
r = 1 - r .* r / (sigma * sigma);
r(r < 0) = 0;
r = r .* r;

%--------------------------------------------------------------------------

function r = tukeyEdgeStopLog(img, sigma)
% TUKEYEDGESTOPLOG Tukey Edge-Stopping function on matrix, added log
% tukeyEdgeStopLog(img, sigma)
% img: 2D image matrix
% sigma: standard derivation parameter

r = log(img);
r = gradientAbsolute(r);
r = 1 - r .* r / (sigma * sigma);
r(r < 0) = 0;
r = r .* r;

%--------------------------------------------------------------------------

function r = peronaEdgeStop(img, sigma)
% PERONAEDGESTOP Perona Edge-Stopping function on matrix
% peronaEdgeStop(img, sigma)
% img: 2D image matrix
% sigma: standard derivation parameter

r = gradientAbsolute(img);
r = exp(- r .* r / (2 * sigma * sigma));

%--------------------------------------------------------------------------

function r = complexEdgeStop(img, sigma)
% COMPLEXEDGESTOP Complex edge-stopping function by Gilboa et al.
% complexEdgeStop(img, sigma)
% img: 2D image matrix, can be complex
% sigma (2)-Vector, first entry: Diffusion stopper, second: theta

j = sqrt(-1);
r = gradientAbsolute(img);
r = exp(j * sigma(2))./(1+(imag(r) / (sigma(1) * sigma(2))) .^ 2 );

%--------------------------------------------------------------------------

function r = complexIntensitySensitiveEdgeStop(img, sigma, imgSmoothed)
% COMPLEXEDGESTOP Complex edge-stopping function by Gilboa et al.
% complexEdgeStop(img, sigma)
% img: 2D image matrix, can be complex
% sigma (4)-Vector: [Diffusion stop min, Diffusion stop max, theta]

imgSmoothed = imgSmoothed .^ sigma(5);
minS = min(imgSmoothed(:));
maxS = max(imgSmoothed(:));
factor = (imgSmoothed - minS) ./ (maxS - minS);
newSigma = factor .* (sigma(1) - sigma(2)) + sigma(2);

j = sqrt(-1);
r = gradientAbsolute(img);
r = exp(j * sigma(2))./(1+(imag(r) ./ (newSigma * sigma(2))) .^ 2 );

%--------------------------------------------------------------------------

function r = gradientAbsolute(A)
% GRADIENTABSOLUTE Returns the absolute value of the gradient
% gradientAbsolute(A): A must be a 2D matrix

[Gx, Gy] = gradient(A);
r = sqrt(Gx .* Gx + Gy .* Gy);


