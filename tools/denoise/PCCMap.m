function weights = PCCMap(A,B, windowSize)
% GETCORRELATIONWEIGHT
% Computes the correlation weight for the wavelet multiframe denoising as
% described in:
%
% Markus A. Mayer, Anja Borsdorf, Martin Wagner, Joachim Hornegger,
% Christian Y. Mardin, and Ralf P. Tornow: "Wavelet denoising of multiframe
% optical coherence tomography data", Biomedical Optics Express, 2012
%
% Implementation by Martin Wagner and Markus Mayer,
% Pattern Recognition Lab, University of Erlangen-Nuremberg.
% This version was revised in January 2012.
%
%--------------------------------------------------------------------------

n = 2 * windowSize + 1;




        windowA = im2col(padarray(A, [windowSize windowSize], 'circular'), [n n], 'sliding');

            windowB = im2col(padarray(B, [windowSize windowSize], 'circular'), [n n], 'sliding');
            weights = col2im(correlationCol(windowA, windowB), [n n], [size(A,1)+n-1 size(A,2)+n-1], 'sliding');


end

%--------------------------------------------------------------------------
% Pearsons correlation coefficient of to ROIs of images of the same size.
% Some error handling is performed (division by 0 in the
% correlation computation)

function corr = correlationCol(A, B)
meanA = mean(A);
meanB = mean(B);

varA = var(A);
varB = var(B);

varA(varA < 0.01) = 0.01;
varB(varB < 0.01) = 0.01;

corr = (mean((A - meanA(ones(size(A,1),1), :)) .* (B - meanB(ones(size(B,1),1),:))) ./ sqrt(varA .* varB));

end
