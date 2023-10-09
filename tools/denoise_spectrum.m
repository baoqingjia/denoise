function denoised_spectrum = denoiseNMR(spectrum, wavelet_type)

% Inputs: 
% spectrum - NMR spectrum with added noise
% wavelet_type - type of wavelet to use for denoising

% Output: 
% denoised_spectrum - denoised NMR spectrum

% Perform wavelet transform
wt = modwt(spectrum, wavelet_type);

% Threshold the wavelet coefficients
% threshold = sqrt(2*log(length(spectrum))) * mad(wt(end,:),1) / 0.6745;
threshold = sqrt(2*log(length(spectrum))) * mad(wt(end,:),1) ;
wt = wthresh(wt, 'h', threshold);

% Perform inverse wavelet transform
denoised_spectrum = imodwt(wt, wavelet_type);

end