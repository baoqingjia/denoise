function res = waveletHardThreshold( img, varargin)
% RES = WAVELETHARDTHRESHOLD(IMG, VARARGIN)
% Performs standard wavelet hard thresholding. Read your favorite wavelet
% theory book for more details.
%
% Parameters:
%   img:  Noisy image
%   varargin: additional parameters:
%       - 'lmax':   Maximum wavelet decomposition level (default: 3)
%       - 'mu':     Threshold (default: 0.1)
%       - 'basis':    Wavelet basis function (default: 'haar'. Other
%       options are all the wavelet provided by matlab, as well as
%       'dualtree' and 'dddtcwt', as provided by Selesnick et. al. on their
%       homepage (see code for URLs).
%   res: Denoised image.
%
% Calling example:
% res = waveletHardThreshold(img, 'mu', 0.005:0.01:0.3, ...
%                           'lmax', 5, 'basis', 'dualtree');
%
% Author: Markus Mayer, Pattern Recognition Lab, University
% of Erlangen-Nuremberg, markus.mayer@informatik.uni-erlangen.de
%
% This version of the code was revised and commented in December 2011
%
% Thanks to: Ivan Selesnick et al. for providing the dual-tree and double
% density dual tree complex wavelet code on his homepage.
%
% You may use this code as you want. I would be grateful if you would go to
% my homepage look for articles that you find worth citing in your next
% publication:
% http://www5.informatik.uni-erlangen.de/en/our-team/mayer-markus
% Thanks, Markus

% Default parameters
lmax = 3;
mu = 0.1;
basis = 'haar';

% Read Optional Parameters
if (~isempty(varargin) && iscell(varargin{1}))
    varargin = varargin{1};
end

for k = 1:2:length(varargin)
    if (strcmp(varargin{k}, 'lmax'))
        lmax = varargin{k+1};
    elseif (strcmp(varargin{k}, 'mu'))
        mu = varargin{k+1};
    elseif (strcmp(varargin{k}, 'basis'))
        basis = varargin{k+1};
    end
end

% Some day, we should perform a real size test/mirroring here. As long as
% that happens, we have to live with a personalized solution (customize to
% your needs or leave this code section out).
cutBack = 0;
if (lmax == 5) && (size(img,1) == 496)
    imgTemp = zeros(512, size(img,2));
    imgTemp(1:496,:) = img;
    img = imgTemp;
    clear imgTemp;
    cutBack = 1;
end

if strcmp(basis, 'dualtree')
    % For the dual tree complex wavelet transformation, I'll use the
    % WAVELET SOFTWARE AT POLYTECHNIC UNIVERSITY, BROOKLYN, NY
    % http://taco.poly.edu/WaveletSoftware/
    [Faf, Fsf] = FSfarras;
    [af, sf] = dualfilt1;
    img = double(img);
    w = dualtree2D(img, lmax, Faf, af);
    
    for l = 1:lmax
        for direction = 1:3
            c = complex(w{l}{1}{direction},w{l}{2}{direction});
            w{l}{1}{direction}(abs(c) < mu) = 0;
            w{l}{2}{direction}(abs(c) < mu) = 0;
        end
    end
    
    res = idualtree2D(w, lmax, Fsf, sf);
elseif strcmp(basis, 'dddtcwt')
    % For the double density dual tree complex wavelet transformation,
    % I'll use the
    % DOUBLE DENSITY WAVELET SOFTWARE, POLYTECHNIC UNIVERSITY, BROOKLYN, NY
    % http://eeweb.poly.edu/iselesni/DoubleSoftware/index.html
    [Faf, Fsf] = FSdoubledualfilt;
    [af, sf] = doubledualfilt;
    img = double(img);
    w = cplxdoubledual_f2D(img, lmax, Faf, af);
    
    for l = 1:lmax
        for s1 = 1:2
            for s2 = 1:8
                c = complex(w{l}{1}{s1}{s2},w{l}{2}{s1}{s2});
                w{l}{1}{s1}{s2}(abs(c) < mu) = 0;
                w{l}{2}{s1}{s2}(abs(c) < mu) = 0;
            end
        end
    end
    
    res = real(cplxdoubledual_i2D(w, lmax, Fsf, sf));
else % Standard DWT
    approx = cell(1,lmax);
    horizontal = cell(1,lmax);
    vertical = cell(1,lmax);
    diagonal = cell(1,lmax);
    
    for l = 1:lmax
        if (l == 1)
            [approx{l}, horizontal{l}, vertical{l}, diagonal{l}] = dwt2(img,basis);
        else
            [approx{l}, horizontal{l}, vertical{l}, diagonal{l}] = dwt2(approx{l-1},basis);
        end
        
        horizontal{l}(abs(horizontal{l}) < mu) = 0;
        vertical{l}(abs(vertical{l}) < mu) = 0;
        diagonal{l}(abs(diagonal{l}) < mu) = 0;
    end
    
    for l = lmax:-1:1
        if l > 1
            approx{l-1} = idwt2(approx{l}, horizontal{l}, vertical{l}, diagonal{l}, basis, size(approx{l-1}));
        else
            res = idwt2(approx{l}, horizontal{l}, vertical{l}, diagonal{l}, basis, size(img));
        end
    end
end

if cutBack
    res = res(1:496, :);
end


