     % Read a grayscale image and scale its intensities in range [0,1]
     y = im2double(imread('cameraman.png')); 
     % Generate the same seed used in the experimental results of [1]
     randn('seed', 0);
     % Standard deviation of the noise --- corresponding to intensity 
     %  range [0,255], despite that the input was scaled in [0,1]
     sigma = 25;
     % Add the AWGN with zero mean and standard deviation 'sigma'
     z = y + (sigma/255)*randn(size(y));
     % Denoise 'z'. The denoised image is 'y_est', and 'NA = 1' because 
     %  the true image was not provided
     [NA, y_est] = BM3D(1, z, sigma); 
     % Compute the putput PSNR
     PSNR = 10*log10(1/mean((y(:)-y_est(:)).^2))
     % show the noisy image 'z' and the denoised 'y_est'
     figure; imshow(z);   
     figure; imshow(y_est);
     
     disp('over')