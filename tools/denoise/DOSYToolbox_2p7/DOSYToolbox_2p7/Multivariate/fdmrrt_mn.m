function [dosydata]=fdmrrt_mn(NmrData)


%   [DOSY]=dosy_mn(pfgnmrdata,thresh,Specrange,Diffrange,Options,Nugc)   
%   DOSY (diffusion-ordered spectroscopy) fitting of
%   PFG-NMR diffusion data (aka DOSY data)
%   
%   -------------------------------INPUT--------------------------------------
%   pfgnmrdata      Data structure containing the PFGNMR experiment.
%                   containing the following members:
%                       filename: the name and path of the original file
%                       np: number of (real) data points in each spectrum
%                       wp: width of spectrum (ppm)
%                       sp: start of spectrum (ppm)
%                       dosyconstant: gamma.^2*delts^2*DELTAprime
%                       Gzlvl: vector of gradient amplitudes (T/m)
%                       ngrad: number of gradient levels
%                       Ppmscale: scale for plotting the spectrum
%                       SPECTRA: spectra (processed)
%   ---------------------------INPUT - OPTIONAL-------------------------------
%   thresh =        Noise threshold. Any data point below won't be used in
%                   the fitting. Expressed as % of highest peak. Default 5
%                   (%).
%   Specrange       The spectral range (in ppm) in which the score fitting
%                   will be performed. if set to [0] defaults will be used.
%                   DEFAULT is [sp wp+sp];
%   Diffrange =     The range in diffusion coeeficients that will be
%                   calculated AND the number of data points in the
%                   diffusion dimension (fn1). DEFAULT is [0 20 128];
%                     Diffrange(1) - Min diffusion coefficient plotted.
%                              (0)   DEFAULT. (*10e-10 m2/s)
%                     Diffrange(2) - Max diffusion coefficient plotted.
%                              (20)  DEFAULT  (*10e-10 m2/s)
%                     Diffrange(3) - Number of datapoints in the diffusion
%                                    dimension
%                              (128) DEFAULT
%
%   Options =       Optional parameters. If not given or set to zero or [],
%                   defaults will be used. If you want Options(5) to be 2
%                   and not change others, simply write Options(5)=2. Even
%                   if Options hasn't been defined Options will contain
%                   zeros except its fifth element.
%
%           Options(1) - peak picking.
%             (0) DEFAULT does peak picking;
%             (1) fits each frequency individually
%
%           Options(2) - fitting functions.
%             (0)  DEFAULT: fits to a pure monoexponential.
%             (1)  fits to a function compensating for non-uniform
%                  gradients (NUG); Supply your own coefficients or use the
%                  default (Varian ID 5mm probe, Manchester 2006).Max 4
%                  coefficients is supported.
%
%           Options(3) - Multiexponential fiting. The max number of
%                        componets per peak/data point. Warning - the higer
%                        number the longer the calculation. 2 is often the
%                        practical limit.
%             (1)  DEFAULT: - monoexponental fit
%
%           Options(4) - The number of random starting values (Monte
%                        Carlo) that will be tried for the biexponetial
%                        fit. Default is 100. Higher exponentials will be
%                        corrspondingly increased (i.e 1000 as a default.
%                        If you get a successful fit with a low number of
%                        random starting values it probably means that the
%                        data is multiexponetial but you may not have found
%                        the globl minimum. It may be worthwhile to
%                        increase it to increase the likelyhood of getting
%                        a correct result.
%           Options(5) - The fitting routine used
%               (0) DEFAULT: - lsqcurvefit. Required the Otimization Toolbox
%                   and uses gradients. Probably the fastest and most reliable
%                   option.
%               (1) fminsearch: uses the Nelder-Mead simplex method. 
%
%   Nugc =          Vector contaning coefficients for non-uniform field
%                   gradient correction. If not supplied default values
%                   from a Varian ID 5mm probe (Manchester 2006) will be
%                   used.U0_R2C(:,j2+1)
%
%   --------------------------------------OUTPUT------------------------------
%   dosydata       Structure containg the data obtained after dosy with
%                  the follwing elements:
%                     
%                  
%                  fit_time:   The time it took to run the fitting
%                  Gzlvl: vector of gradient amplitudes (T/m)
%                  wp: width of spectrum (ppm)
%                  sp: start of spectrum (ppm)
%                  Ppmscale: scale for plotting the spectrum
%                  filename: the name and path of the original file
%                  Options: options used for the fitting
%                  Nug: coeffients for the non-uniform field gradient
%                       compensation
%                  FITSTATS: amplitude and diffusion coeffcient with 
%                            standard error for the fitted peaks
%                  FITTED: the fitted decys for each peak
%                  freqs: frequencies of the fitted peaks (ppm)
%                  RESIDUAL: difference between the fitted decay and the
%                            original (experimental) for all peaks
%                  ORIGINAL: experimental deacy of all fitted peaks
%                  type: type of data (i.e. dosy or something else)
%                  DOSY: matrix containing the DOSY plot
%                  Spectrum: the least attenuated spectrum      
%                  fn1: number of data points (digitisation) in the
%                       diffusion dimension
%                  dmin: plot limit in the diffusion dimension 10-10 m^2/s)
%                  dmax: plot limit in the diffusion dimension 10-10 m^2/s)
%                  Dscale: Plot scale for the diffusion dimension       
%                  threshold: theshold (%) over which peaks are included in
%                             the fit
%                   
%   Example:  
%
%   See also: dosy_mn, score_mn, decra_mn, mcr_mn, varianimport, 
%             brukerimport, jeolimport, peakpick_mn, dosyplot_mn, 
%             dosyresidual, dosyplot_gui, scoreplot_mn, decraplot_mn,
%             mcrplot_mn
%             
%   References:
%   Nilsson M, Connell, MA, Davis, AL, Morris, GA Anal. Chem.
%   2006; 78: 3040.

%   
%   
%   This is a part of the DOSYToolbox        
%   Copyright  2007-2008  <Mathias Nilsson>%
%   This program is free software; you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation; either version 2 of the License, or
%   (at your option) any later version.
%
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or F1ITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for mor1e details.
%
%   You should have received a copy of the GNU General Public License along
%   with this program; if not, write to the Free Software Foundation, Inc.,
%   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
%
%   Dr. Mathias Nilsson
%   School of Chemistry, University of Manchester,
%   Oxford Road, Manchester M13 9PL, UK
%   Telephone: +44 (0) 161 306 4465
%   Fax: +44 (0)161 275 4598
%   mathias.nilsson@manchester.ac.uk

	format long;

	if nargin==0
    	disp(' ')
    	disp(' FDMRRT')
    	disp(' ')
   		disp(' Type <<help fdmrrt_mn>> for more info')
    	disp('  ')
    	return
	elseif nargin<1
    	error(' dosy_mn needs a NmrData stucture as input')
	elseif nargin > 1
    	error(' Too many inputs')
	end

	t_start=cputime;

	%Defaults
	pfgnmrdata = NmrData.pfgnmrdata;
   % dosydata.Spectrum=pfgnmrdata.SPECTRA(:,1);
	thresh = NmrData.th;
	sfrq = NmrData.sfrq;
	fid = NmrData.FID;
	SPECTRA = NmrData.SPECTRA;
%	dlmwrite('fid.out', fid(:), 'delimiter', '\n', 'precision', '%#16.11E')
%	dlmwrite('spectra.out', SPECTRA(:), 'delimiter', '\n', 'precision', '%#16.11E')
	opts = NmrData.FDMRRTopts;

	% User options
	dscale=1e-10;
%	dscale=1;

	format('long')
	use_internal_plotting = true;

	SOURCE_FID = 0;
	SOURCE_SPEC = 1;
	ALGO_FDM = 0;
	ALGO_RRT = 1;
	SPEC_ABS = 0;
	SPEC_PSEUDO = 1;

	source = opts(1);
	algorithm = opts(2); %FDM or RRT
	spec_type = opts(3); %Absolute value or Pseudoabsorption mode
	N1 = opts(4); %Signal elements direct dimensions
	N2 = opts(5); %Signal elements diffusion dimensions
	Kwin = opts(6); %Matrix size, number of basis elements per window
	q = opts(7); %Regularization parameter, unitless ~1 seems to work well
	diff_sigma = opts(8); %standard deviation for gaussian tail masks
	w2min = opts(9) * dscale; %lower alpha limit
	w2max = opts(10) * dscale; %upper alpha limit
	nspec2 = opts(11); %DOSY plot resolution: diffusion pixels
	nspec1 = opts(12); %DOSY plot resolution: chemical shift pixels
	lrfid = opts(20);

	M1 = N1/2 - 1; %Rank of signal: direct dimension
	M2 = N2/2 - 1; %Rank of signal: diffusion dimension
	rho = 1.1; %spectral density factor
	tau1 = 2*pi / pfgnmrdata.wp / sfrq; %time step
	tau2 = pfgnmrdata.dosyconstant * ... %gradient step
		(pfgnmrdata.Gzlvl(pfgnmrdata.ngrad)^2-pfgnmrdata.Gzlvl(1)^2) / ...
		(pfgnmrdata.ngrad-1);
	%w1min = -pfgnmrdata.wp/2 * sfrq
	%w1max = pfgnmrdata.wp/2 * sfrq
	w1min = (NmrData.xlim_spec(1) - pfgnmrdata.wp/2 - pfgnmrdata.sp)*sfrq; %lower freq limit
	w1max = (NmrData.xlim_spec(2) - pfgnmrdata.wp/2 - pfgnmrdata.sp)*sfrq; %upper freq limit
	wstep = 2*pi / (tau1*(M1+1)*rho); %spacing between frequencies of basis functions
	window_size = Kwin * wstep; %window size (rad/s)
	spec1step = (w1max-w1min) / nspec1; %pixel size: direct dimension
	spec2step = (w2max-w2min) / nspec2; %pixel size: diffusion dimension
	g1 = 1/(20000*tau1); %minimum line width: direct dimension;
%	g2 = 1/(20000*tau2) %minimum line width: diffusion dimension
	g2 = 1E-10;
	%g1 = 0
	%g2 = 0
	%gamma = [g1,g2]
	e_tau1g = exp(-tau1*g1); %line broadening factor for time evo eigenvalues
	e_itau2g = exp(i*tau2*g2); %line broadening factor for gradient evo eigenvalues
%	diff_sigma = 1E-11;
%	diff_sigma = 0;
	gamma_to_sigma = 1/(2 * sqrt(2 * log(2))); %conversion between gauss and lorentzian widths

	if(source == SOURCE_FID) 
		fid = circshift(fid,-lrfid); % compensate for zero filling, delay
		fid(end-lrfid+1:end,:) = 0.0;
	else
		fid=ifft(flipud(fftshift(SPECTRA,1)));
		fid(1,:)=fid(1,:)./NmrData.fpmult;
	end

	single_window = 0; % single or multiple window FDM
	if (single_window | window_size > 2 * (w1max-w1min))
		windows = 1;
		single_window = 1;
		Kspec = Kwin;
	else
		windows = ceil(2*(w1max-w1min)/window_size+1);
		Kspec = Kwin * (windows+1)/2.0;
	end

	z_ = zeros(Kspec,1); % z^(-1) for all values of j
	z_m = zeros(Kspec,1); % z^(-M) for all values of j
	% assign all basis functions phi
	for j=1:Kspec
		if(single_window)
			wj = (w1min + w1max - window_size)/2.0 + j*wstep; % "phi_j"
		else
			wj = w1min - window_size/2.0 + j*wstep;
		end
		z_(j) = exp(i*tau1*wj); % 1/z
		z_m(j) = z_(j)^(M1);
	end

	ap = zeros(N1-1,3); % evaluate U sums over m, n', m' to get a^(p)_n
	for n2=0:N2-2
		triangle = (M2 - abs(M2-n2) + 1);
		for n1=0:N1-2
				ap(n1+1,0+1) = ap(n1+1,0+1) + fid(n1+0+1,n2+0+1) * triangle;
				ap(n1+1,1+1) = ap(n1+1,1+1) + fid(n1+1+1,n2+0+1) * triangle;
				ap(n1+1,2+1) = ap(n1+1,2+1) + fid(n1+0+1,n2+1+1) * triangle;
		end
	end

	%cm = zeros(Kspec,N2);
	%for n2=0:N2-2
	%	cm(:,n2+1) = Slow_FT(M1, fid(1+1:M1+1,n2+1), Kspec, z_);
	%	cm(:,n2+1) = cm(:,n2+1) + fid(1,n2+1);
	%end
	%c_sum = sum(cm(:,1:M2+1),2);
	c_sum = Slow_FT(M1, sum(fid(2:M1+1,1:M2+1),2), Kspec, z_); % dynamically programmed to evaluate and save multiple powers of n (summed over all m)
	c_sum = c_sum + sum(fid(1,1:M2+1),2); % add the excluded sum of c0 elements for all m

	%c_fn = zeros(M1,1);
	sum_f = zeros(Kspec,3); % fourier transforms of a^(p)_n for off diagonal U
	sum_g = zeros(Kspec,3); % fourier transforms of a^(p)_n for off diagonal U
	sum_h = zeros(Kspec,3); % fourier transforms of a^(p)_n for diagonal U

	hp = waitbar(0,'Fourier basis functions');
	for p=0:2 % p0 = overlap matrix, p1 = time evo, p2 = gradient evo
	% the following block computes the Fourier basis functions 
	%	for n1=1:M1
	%		c_fn(n1) = (n1+1) * ap(n1+1,p+1);
	%	end
		c_fn = (2:M1+1)' .* ap(2:M1+1,p+1);
		sum_h(:,p+1) = Slow_FT(M1, c_fn(1:M1), Kspec, z_);
		waitbar((4*p+1)/(3*4),hp);
	%	for n1=1:M1
	%		c_fn(n1) = (n1+1) * ap(n1+M1+1,p+1);
	%	end
		c_fn = (2:M1+1)' .* ap(M1+2:2*M1+1,p+1);
		sum_f(:,p+1) = Slow_FT(M1, c_fn(1:M1), Kspec, z_);
		waitbar((4*p+2)/(3*4),hp);
		sum_g(:,p+1) = Slow_FT(M1, ap(M1+1+1:2*M1+1,p+1), Kspec, z_);
		waitbar((4*p+3)/(3*4),hp);
	%	for j=1:Kspec
	%		sum_g(j,p+1) = sum_g(j,p+1) * z_m(j);
	%		sum_h(j,p+1) = sum_h(j,p+1) + ap(0+1,p+1) + (M1+2) * ...
	%			sum_g(j,p+1) - sum_f(j,p+1) * z_m(j);
	%	end
		sum_g(:,p+1) = sum_g(:,p+1) .* z_m(:);
		sum_h(:,p+1) = sum_h(:,p+1) + ap(0+1,p+1) + (M1+2) * ...
			sum_g(:,p+1) - sum_f(:,p+1) .* z_m(:);
		sum_f(:,p+1) = Slow_FT(M1, ap(1+1:M1+1,p+1), Kspec, z_);
		waitbar((4*p+4)/(3*4),hp);
	end

	matrix_scale = 0.0;
	for j=1:Kspec
		matrix_scale = matrix_scale + abs(sum_h(j,0+1));
	end
	matrix_scale = matrix_scale / Kspec; % average value of matrix diagonals

	S_2d = zeros(nspec1, nspec2); % spectrup bitmap

	uk = zeros(Kwin,windows); % time evolution eigenvalues
	wk = zeros(Kwin,windows); % frequency eigenvalues
	dk = zeros(Kwin,windows); % coamplitudes 1
	u2k = zeros(Kwin,windows); % gradient evolution eigenvalues
	ak = zeros(Kwin,windows); % decay rate eigenvalues
	d2k = zeros(Kwin,windows); %% coamplitudes 2

	window_limit = zeros(windows,2);

	% evaluate each window sequentially
	waitbar(0,hp,['rendering window ', num2str(0),' of ', num2str(windows)])
	for window=1:windows
		if(single_window)
			lwindow = 0.5*(w1min+w1max-window_size); % window centered on 1 bounds
		else
			lwindow = w1min + 0.5*(window-2)*window_size; % windows with 1/2 window overlap
		end
		rwindow = lwindow + window_size;
		window_limit(window,:) = [lwindow, rwindow];
		basis_offset = floor(0.5*(window-1)*Kwin); % index of basis funstions in this window (from global list)
		Up = zeros(Kwin, Kwin, 3);
		for p=0:2 % S, U, L matrixes
			for j=1:Kwin % diagonals
				z_2m = z_m(basis_offset+j)^2;
				Up(j,j,p+1) = sum_h(basis_offset+j,p+1);
	%			disp(Up(j,j,p+1))
	        end
			for j1=1:Kwin
				for j2=1:j1-1 % off-diagonal terms (upper triangle)
					z_z = z_(basis_offset+j1) / z_(basis_offset+j2);
					Up(j1,j2,p+1) = ap(0+1,p+1) + (sum_f(basis_offset+j2,p+1) - ...
						z_z^(M1+1) * sum_g(basis_offset+j2,p+1) - ...
						z_z * sum_f(basis_offset+j1,p+1) + ...
						z_z ^(-M1) * sum_g(basis_offset+j1,p+1)) / (1-z_z);
						% mirror upper triangle onto lower triangle
						Up(j2,j1,p+1) = Up(j1,j2,p+1);
				end
			end
		end

		% index of this windows boundaries in the global spectrum bitmat	
		spec1min_win = floor(max((lwindow-w1min)*nspec1 / (w1max-w1min),0.0));
		spec1max_win = floor(min((rwindow-w1min)*nspec1 / (w1max-w1min),nspec1+0.0))-1;

		right = zeros(Kwin,nspec2); %diffusion dependant portion of spectrum
		left = zeros(1,Kwin); %frequency dependant portion of spectrum
		lambda_delta = exp(-tau2 * spec2step/2); % factor reused in alpha integrations
		z_delta = exp(-i * tau1 * spec1step/2); % factor reused in omega integrations

		if(algorithm == ALGO_FDM)
			% regularization here.
			[U,S,V] = svd(Up(:,:,0+1));
			svd_continuous = 0;
			if(svd_continuous)	
				% augment small singular values
				for j1=1:Kwin
					if(S(j1,j1) > 0);
						S(j1,j1) = (S(j1,j1)^2 + q*matrix_scale) / S(j1,j1);
					end
				end
			else
				% replace small singular values with q*matrix_scale
				for j1=1:Kwin
					if(q*matrix_scale > S(j1,j1));
						S(j1,j1) = q*matrix_scale;
					end
				end
			end
			Up(:,:,0+1) = U * S * V'; %reconstruct regularized matrix
			U0 = Up(:,:,0+1);
			[b1, u1] = eig(Up(:,:,1+1),Up(:,:,0+1),'qz'); % computer eigensystem 1
			u1 = diag(u1);
			w = -log(u1)/(i * tau1); % frequency eigenvalues
			b1 = b1 / sqrt(conj(b1') * U0 * b1);
			d1 = conj(b1') * c_sum(basis_offset+1:basis_offset+Kwin); % amplitudes
			uk(:,window) = u1; % stored for later
			wk(:,window) = real(w); % stored for later
			dk(:,window) = d1; % stored for later
%			for k1=1:Kwin  
%				if(imag(w(k1)) > 0) % adjust evo eigenvalues to be decaying
%						u1(k1) = (u1(k1) / abs(u1(k1))^2);
%				end
%				if(abs(imag(w(k1))) < g1) % broaden if necessary
%					u1(k1) = exp(-i * tau1 * real(w(k1))) * e_tau1g;
%				end
%			end
			[b2, u2] = eig(Up(:,:,2+1),Up(:,:,0+1),'qz'); % compute eigensystem 2
			u2 = diag(u2);
			alph = -log(u2)/tau2; % decay rate eigenvalues
			a2 = -log(u2)/(-tau2);
			b2 = b2 / sqrt(conj(b2') * U0 * b2);
			d2 = conj(b2') * c_sum(basis_offset+1:basis_offset+Kwin); % amplitudes
			d2 = d2 .* d2;
			u2k(:,window) = u2; % stored for later
			ak(:,window) = alph; % stored for later
			d2k(:,window) = d2; % stored for later
			for k2=1:Kwin
				if(abs(imag(alph(k2))) < g2) % broaden if necessary
%					alph(k2) = alph(k2) + g2 * i * sign(imag(alph(k2)));
					alph(k2) = real(alph(k2)) + g2 * i * sign(imag(alph(k2)));
%					u2(k2) = exp(-tau2 * real(alph(k2))) * e_itau2g^sign(imag(alph(k2)));
					u2(k2) = exp(-tau2 * alph(k2));
				end
			end
			D = conj(b1') * U0 * b2; % reconciliation matrix "couples" k, k'
			dosydata.D(:,:,window) = D; % stored for later
		end
	
		if(algorithm == ALGO_FDM)
			for k2=1:Kwin
%				if(spec_type == SPEC_PSEUDO)
%%					alph(k2) = alph(k2)...
%%						- imag(alph(k2)) + pseudo_stretch * imag(alph(k2));
%					alph(k2) = real(alph(k2)); % discarded non-physical imag park of decay
%				end
				if(false) % disabled: diffusion widths based on imaginary part of decay
					eff_sigma = 4 * gamma_to_sigma * imag(a2(k2));
				elseif(diff_sigma < spec2step/10) % hard coded minimum sigma (neccessary?)
					eff_sigma = spec2step/10;
				else % default: use user input sigmavalue
					eff_sigma = diff_sigma;
				end
				jrange = 3 * eff_sigma / spec2step; % plot peaks only in "nonzero" nearby region
				if(diff_sigma < 0) % unless unmasked, long tail abs value mode
					jrange = nspec2;
				end
				jcenter = (real(-a2(k2)) - w2min) / spec2step;
				for j2=max(floor(jcenter - jrange), 0) ... % in "nonzero" region
						:min(ceil(jcenter + jrange), nspec2-1)
%s				for j2=0:nspec2-1
					aj = w2min + j2*spec2step;
					lj = exp(-tau2*aj); %central lambda
					la = lj / lambda_delta; %lambda at lower pixel integration limit
					lb = lj * lambda_delta;  %lambda at upper pixel integration limit

					%%% below are many ways of rendering the data. integrationis preferred where available. %%%
					if(spec_type == SPEC_PSEUDO)
						%% sample double lorentzian
						%right(k2,j2+1) = right(k2,j2+1) + tau2^2 * ...
						%	(1 - lj / u2(k2)) ^(-2) * d2(k2);
						%% sample approx double lorentzian
						%right(k2,j2+1) = right(k2,j2+1) + ...
						%	-1/(aj-alph(k2))^2 * d2(k2);
						%% integrate approx double lorentzian
						right(k2,j2+1) = right(k2,j2+1) + ...
							-1 * (1 /(aj-spec2step/2-alph(k2)) ...
							- 1/(aj+spec2step/2-alph(k2))) * d2(k2);
						%% integrate approx double lorentzian * sample gaussian
						right(k2,j2+1) = right(k2,j2+1) + ...
							-1 * (1 /(aj-spec2step/2-alph(k2)) ...
							- 1/(aj+spec2step/2-alph(k2))) * d2(k2) * ...	
								exp(-(-aj - real(a2(k2)))^2 /(2*diff_sigma^2)) ...
								/ (eff_sigma * sqrt(2*pi)) * d2(k2);
					else
						if(diff_sigma < 0)
							%% sample lorentzian
							%right(k2,j2+1) = right(k2,j2+1) + tau2 * ...
							%	(1 - lj / u2(k2)) ^(-1) * d2(k2);
							%% integrate lorentzian
							right(k2,j2+1) = right(k2,j2+1) + tau2 * ...
								(log((lb - u2(k2))/(la - u2(k2))) / tau2 ...
								- spec2step) * d2(k2);
						else
							%% sample gaussian
							%right(k2,j2+1) = right(k2,j2+1) + tau2 * ...
							%	exp(-(-aj - real(a2(k2)))^2 /(2*diff_sigma^2)) ...
							%	* d2(k2) / (eff_sigma * sqrt(2*pi));
							%% integrate gaussian
							%right(k2,j2+1) = right(k2,j2+1) + tau2 * ...
							%	(erf(((-aj - real(a2(k2))) + spec2step/2) ...
							%	/ (eff_sigma*sqrt(2))) ...
							%	- erf(((-aj - real(a2(k2))) - spec2step/2) ...
							%	/ (eff_sigma*sqrt(2)))) / 2;
							%% integrate lorentzian * sample gaussian
							right(k2,j2+1) = right(k2,j2+1) + tau2 * ...
								(log((lb - u2(k2))/(la - u2(k2))) / tau2 ...
								- spec2step) * ...	
								exp(-(-aj - real(a2(k2)))^2 /(2*diff_sigma^2)) ...
								/ (eff_sigma * sqrt(2*pi)) * d2(k2);
						end
					end
				end
			end
			for j2=0:nspec2-1 % apply "coupling" transformation matrix
				right(:,j2+1) = D * right(:,j2+1);
			end
		else
			% RRT
			for j2=0:nspec2-1
				aj = w2min + j2*spec2step;
				lj = exp(-tau2*aj);
				R = Up(:,:,0+1) - Up(:,:,2+1) / lj; % matrix pencil
				[U,S,V] = svd(R); %perform SVD
				for k1=1:Kwin
					for k2=1:Kwin
						VS(k1,k2) = V(k1,k2) * S(k2,k2) / (S(k2,k2)^2 + q * matrix_scale);
					end
				end
				R_ = VS * U'; % reconstruct regularized matrix pencil
				U0_R2 = Up(:,:,0+1) * R_;
				right(:,j2+1) = U0_R2 * c_sum(basis_offset+1:basis_offset+Kwin);
				if(spec_type == SPEC_PSEUDO)
					right(:,j2+1) = U0_R2 * right(:,j2+1); % apply U0 and R2 again
				end
			end
		end

		for j1=spec1min_win:spec1max_win
			wj = w1min + j1*spec1step;
			zj = exp(-i*tau1*wj); % central z
			za = zj / z_delta; % z at lower pixel integration limit
			zb = zj * z_delta; % z at lower pixel integration limit
			if(single_window)
				weight = 1.0;
			else
				weight = cos((wj-lwindow)*2*pi/(rwindow-lwindow)+pi)*0.5 + 0.5;
			end
			if(algorithm == ALGO_FDM)
				for k1=1:Kwin
					if(spec_type == SPEC_PSEUDO)
						%% sample lorentzian
						%	left(k1) = tau1^2 * 1/(1 - zj ./ u1(k1))^2 * d1(k1);
						%% sample approx double lorentizian
						%	left(k1) = i / (wj-w(k1))^2 * d1(k1);
						%% integrate approx double lorentzian
						left(k1) = i * (1 /(wj-spec1step/2-w(k1)) ...
									- 1/(wj+spec1step/2-w(k1))) * d1(k1);
					else
						% sample lorentzian		left(k1) = tau1 * ...
						%	1/(1 - zj ./ u1(k1)) * d1(k1);
						%% integrate lorentzian
						left(k1) = tau1 * ...
							(i * log(zb*(za - u1(k1))/(za*(zb - u1(k1)))) ...
							/ tau1) * d1(k1);
					end
				end
			else
				R = Up(:,:,0+1) - Up(:,:,1+1) / zj; % R1 frequency resolvent matrix pencil
				[U,S,V] = svd(R); % performSVD
				for k1=1:Kwin
					for k2=1:Kwin
						VS(k1,k2) = V(k1,k2) * S(k2,k2) / (S(k2,k2)^2 + q * ...
							matrix_scale);
					end
				end
				R_ = VS * U'; % reconstruct regularized matrix pencil
				left = transpose(c_sum(basis_offset+1:basis_offset+Kwin)) * R_;
				if(spec_type == SPEC_PSEUDO)
					left = left * Up(:,:,0+1) * R_; % apply U0 and R1 again
				end
			end

			for j2=0:nspec2-1 % combine left and right vectors to compute DOSY values for this j1
%				S_2d(j1+1,j2+1) = S_2d(j1+1,j2+1) + ...
%					weight * sum(right(:,j2+1) .* left(:));
				S_2d(j1+1,j2+1) = S_2d(j1+1,j2+1) + ...
					weight * left * right(:,j2+1);

			end
		end
		waitbar(window/windows,hp,['rendering window ', num2str(window), ...
			' of ',  num2str(windows)]);
	end
	close(hp);

	%expfactor=pfgnmrdata.dosyconstant*dscale;
	%pfgnmrdata.Gzlvl=pfgnmrdata.Gzlvl.^2;
	%[nspec,ngrad]=size(pfgnmrdata.SPECTRA);

	th = thresh/100; % not used anymore ... i think
	if(th <= 0)
		th = 0.10;
	end

	top_th = 0.1; % upper contour cutoff
	bottom_th = 0.02; % lower contour cutoff
	DOSY = abs(S_2d); % abs value of complex spectrum
	diffusion_profile = sum(DOSY, 1); % axis projections
	chem_shift_profile = sum(DOSY, 2);
	DOSYth = max(bottom_th,min(DOSY / max(DOSY(:)),top_th))/top_th; % normalize
	%aaaa = zeros(100,1);
	%for ii = 1:100
	%	aaaa(ii) = sum(DOSYth(:) > ii/100);
	%end
	%figure();
	%plot(aaaa);
	%avdosy = mean(DOSYth(:))

	endt=cputime-t_start; % timing stuff
	h=fix(endt/3600);
	m=fix((endt-3600*h)/60);
	s=endt-3600*h - 60*m;
	fit_time=[h m s];
	disp(['DOSY: Fitting time was: ', num2str(fit_time(1)), ' h  ', ...
		num2str(fit_time(2)) ' m 	and ' num2str(fit_time(3),2) ' s']);	
	spec_samples = floor(linspace(1, size(pfgnmrdata.SPECTRA,1), nspec1));

	% store all the computed information in dosydata to be used elsewhere in the toolblx
	dosydata.type='fdm/rrt';
	dosydata.fit_time=fit_time;
	dosydata.DOSY=DOSY;
%	dosydata.DOSY=DOSYth;
	dosydata.Gzlvl=pfgnmrdata.Gzlvl;

	%dosydata.Ppmscale=pfgnmrdata.Ppmscale';
	dosydata.Ppmscale = linspace(w1min,w1max,nspec1) / sfrq - ...
		(-pfgnmrdata.wp/2-pfgnmrdata.sp);
    %size(dosydata.Ppmscale)
	%dosydata.Spectrum=imresize(pfgnmrdata.SPECTRA(:,1),[nspec1,1]);
    %size(dosydata.DOSY)
	%dosydata.Spectrum = pfgnmrdata.SPECTRA(floor(...
	%	linspace(1,size(pfgnmrdata.SPECTRA,1),nspec1)));
    %MN Sampling the spectrum t the right number of points
    dosydata.Spectrum=ifft(pfgnmrdata.XSPEC(:,1));
    dosydata.Spectrum=(real(fft(dosydata.Spectrum,nspec1)));
    

    
	dosydata.sp=pfgnmrdata.sp;
	dosydata.wp=pfgnmrdata.wp;
	dosydata.np=pfgnmrdata.np;
	dosydata.fn1=nspec2;
	dosydata.dmin=w2min;
	dosydata.dmax=w2max;
	dosydata.Dscale=linspace(w2min,w2max,nspec2)/dscale;
	dosydata.Options=opts;
	dosydata.threshold=th;
	dosydata.uk = uk;
	dosydata.wk = -(wk/sfrq - (-pfgnmrdata.wp/2-pfgnmrdata.sp));
	dosydata.dk = dk.^2;
	dosydata.u2k = u2k;
	dosydata.ak = ak;
	dosydata.d2k = d2k;
	dosydata.windows = window_limit;
	%-(window_limit/sfrq - (-pfgnmrdata.wp/2-pfgnmrdata.sp));

%	dlmwrite('my_data.out', ...
%		[dosydata.uk(:), dosydata.dk(:), dosydata.u2k(:), dosydata.d2k(:)], ...
%			'delimiter', '\t', 'precision', 16);
%	dlmwrite('my_data2.out', ...
%		reshape(dosydata.D, [Kwin*Kwin, windows]).', 'delimiter', '\t', 'precision', 16);
%	dlmwrite('my_data3.out', [nspec1, nspec2, w1min, w1max, w2min, w2max, ...
%		spec1step, spec2step, tau1, tau2, window_size, th] , ...
%		'delimiter', '\t', 'precision', 16);
%	dlmwrite('my_data4.out', dosydata.Ppmscale, 'delimiter', '\t', 'precision', 16);
%	dlmwrite('my_data5.out', dosydata.Dscale, 'delimiter', '\t', 'precision', 16);

	% all this stuff is for displaying and handling user interface to the DOSY plot

	
	if(use_internal_plotting);
		dosyplot_gui(dosydata);
		return;
		figure('Name','Dosy Image', 'NumberTitle','Off');
		image(fliplr(dosydata.DOSY.' * 256 / max(max(dosydata.DOSY))));
		colormap(hot(256));
	end

	dosyfigure = figure('Name','Dosy Plot', 'NumberTitle','Off');
	set(zoom(dosyfigure), 'ActionPostCallback', @zoomer);
	set(rotate3d(dosyfigure), 'ButtonDownFilter', @fixer);
	[xax,yax]=meshgrid(dosydata.Ppmscale,dosydata.Dscale);
%	chem_shift_axes = axes('Position',[0.05, 0.915, 0.9, 0.060]);
	chem_shift_axes = axes('Position',[0.05, 0.915, 0.8, 0.060]);
	plot(-dosydata.Ppmscale, chem_shift_profile);
	set(chem_shift_axes, 'XTick', []);
	set(chem_shift_axes, 'YTick', []);
	diffusion_axes = axes('Position',[0.915, 0.2, 0.060, 0.65]);
	plot(diffusion_profile, -dosydata.Dscale);
	set(diffusion_axes, 'XTick', []);
	set(diffusion_axes, 'YTick', []);
	dosyaxes = axes('Position',[0.05, 0.2, 0.8, 0.65]);
	dosy_plot = contour(-fliplr(xax),-flipud(yax), fliplr(flipud(DOSYth')));
	xlimits = get(dosyaxes, 'XLim');
	ylimits = get(dosyaxes, 'YLim');
	set(chem_shift_axes, 'XLim', xlimits);
	set(diffusion_axes, 'YLim', ylimits);
	zmax = max(DOSYth(:));
	windowpane = patch([xlimits(1),xlimits(2),xlimits(2),xlimits(1)],...
		[ylimits(2),ylimits(2),ylimits(1),ylimits(1)], ...
		[zmax,zmax,zmax,zmax], ...
		'Blue','FaceAlpha',0.0,'LineStyle','none','ButtonDownFcn',@click_callback);
	dfdata = struct('DOSY', DOSY, ... %'DOSYth', DOSYth, ...
		'Ppmscale', dosydata.Ppmscale, 'Dscale', ...
		dosydata.Dscale, 'bottom_th', bottom_th, 'top_th', top_th, ...
		'wmin', w1min, 'wmax', w1max, ...
		'wmin_ppm', xlimits(1), 'wmax_ppm', xlimits(2), ...
		'nclicks', 0, 'last_y', 0, 'last_line', 0, 'Regions', [], ...
		'window', windowpane, 'windows', dosydata.windows, ...
		'wk', dosydata.wk, 'dk', dosydata.dk, 'ak', dosydata.ak, 'uk', dosydata.uk, ...
		'tau1', tau1, 'wp', dosydata.wp, 'sp', dosydata.sp, 'sfrq', sfrq, ...
		'chem_shift_axes', chem_shift_axes, 'diffusion_axes', diffusion_axes);
	ui_thresh_minus = uicontrol(dosyfigure,'Style','PushButton','String', '-', ...
		'Units', 'Normalized','Position',[0.05, 0.09, 0.25, 0.06], ...
		'Callback', @threshold_minus);
	ui_thresh_label = uicontrol(dosyfigure,'Style','Edit','String', ...
		num2str(top_th), 'enable', 'off', ...
		'Units', 'Normalized','Position',[0.30, 0.09, 0.30, 0.06]);
	ui_thresh_plus = uicontrol(dosyfigure,'Style','PushButton','String', '+', ...
		'Units', 'Normalized','Position',[0.60, 0.09, 0.25, 0.06], ...
		'Callback', @threshold_plus);
	dfdata.th_minus = ui_thresh_minus;
	dfdata.th_label = ui_thresh_label;
	dfdata.th_plus = ui_thresh_plus;
	if(algorithm == ALGO_FDM)
		uirender1 = uicontrol(dosyfigure,'Style','PushButton','String', ...
 			'Absorption', ...
			'Units', 'Normalized','Position',[0.05, 0.03, 0.25, 0.06], ...
			'Callback', @CallbackRender);
		uirender2 = uicontrol(dosyfigure,'Style','PushButton','String', ...
			'Pseudoabsorption', ...
			'Units', 'Normalized','Position',[0.30, 0.03, 0.30, 0.06], ...
			'Callback', @CallbackRender);
		uirender3 = uicontrol(dosyfigure,'Style','PushButton','String', ...
			'Absolute', ...
			'Units', 'Normalized','Position',[0.60, 0.03, 0.25, 0.06], ...
			'Callback', @CallbackRender);
	end
	guidata(dosyfigure, dfdata);
end

%-----------------------END of fdmrrt_mn-------------------------------------


%-----------------Auxillary functions--------------------------------------
function [f] = Slow_FT(M,coef,Nz,z)
	f = zeros(Nz,1);
	for j=1:Nz
		f(j) = 0.0;
%		disp(coef(M))
%		disp(z(j))
%		disp(coef(M)*z(j))
		fff = coef(M)*z(j);
		if(M == 1)
			f(j) = fff;
			continue;
		end
		for n=M-1:-1:1
			fff = (fff+coef(n))*z(j);
			if(mod(n,100) == 0 | n == 1)
				f(j)=f(j)+fff*z(j)^(n-1);
	      fff=0.0;
			end
		end
	end
end

function click_callback(source, eventdata)
	dosyfigure = gcf;
	dosyaxes = get(dosyfigure,'CurrentAxes');
	dfdata = guidata(dosyfigure);
	set(dfdata.th_minus, 'enable', 'off');
	set(dfdata.th_label, 'enable', 'off');
	set(dfdata.th_plus, 'enable', 'off');
	button = get(dosyfigure,'SelectionType');
	pos = get(dosyaxes,'CurrentPoint');
	y = pos(1,2);
	left = dfdata.wmin_ppm;
	right = dfdata.wmax_ppm;
	zlimits = get(dosyaxes, 'ZLim');
	zmax = zlimits(2);
	if(strcmp(button,'normal'))
		if(dfdata.nclicks)
			delete(dfdata.last_line);
			top = max(y, dfdata.last_y);
			bottom = min(y, dfdata.last_y);
			for r = 1:length(dfdata.Regions)
				rect = dfdata.Regions(r);
				rvert = get(rect,'Vertices');
				rtop = rvert(1,2);
				rbottom = rvert(3,2);
				if(top > rtop & bottom < rbottom)
					bottom = top;
					break;
				end
				if(top < rtop & top > rbottom)
					top = rbottom;
				end
				if(bottom < rtop & bottom > rbottom)
					bottom = rtop;
				end
			end
			if(top > bottom)
				rect = patch([left,right,right,left],[top,top,bottom,bottom],...
					[zmax,zmax,zmax,zmax], ...
					'Green', 'FaceAlpha',0.25, 'ButtonDownFcn',@delete_region);
				dfdata.Regions(end+1) = rect;
				% do stuff
			end
		else
			dfdata.last_y = y;
			dfdata.last_line = line([left,right],[y,y],[zmax,zmax], ...
				'Color', 'Black');
		end
		dfdata.nclicks = ~dfdata.nclicks;
	end	
	guidata(source,dfdata);
end

function delete_region(source,eventdata)
	dosyfigure = gcf();
	dosydata = guidata(dosyfigure);
	if(strcmp(get(dosyfigure,'SelectionType'),'normal'))
		dosyaxes = get(dosyfigure, 'CurrentAxes');
		click_callback(dosydata.window, eventdata);
	end
	if(strcmp(get(gcf,'SelectionType'),'alt') & ~dosydata.nclicks)
		dosydata.Regions(find(dosydata.Regions == source)) = [];
		guidata(source,dosydata);
		delete(source);
	end
end

function delete_patch(source, eventdata)
	disp(['delete ', num2str(source)]);
end

function CallbackRender(source,eventdata)
	nspec = 20000;
	dosyfigure = gcf();
	dosydata = guidata(dosyfigure);
	regions = dosydata.Regions;
	if(length(regions) < 1)
		return;
	end
	windows = dosydata.windows;
	ak = -real(dosydata.ak);
	uk = dosydata.uk;
	dk = dosydata.dk;
	tau1 = dosydata.tau1;
	wmin = dosydata.wmin;
	wmax = dosydata.wmax;
	wstep = (wmax-wmin)/nspec;
	wp = dosydata.wp;
	sp = dosydata.sp;
	sfrq = dosydata.sfrq;
	spec = zeros(nspec,length(regions));
	bottom_top = zeros(length(regions),2);
	for r = 1:length(regions)
		vert = get(regions(r),'Vertices');
		bottom_top(r,:) = [vert(3,2),vert(1,2)];
		for window=1:size(windows,1)
			lwindow = windows(window,1);
			rwindow = windows(window,2);
			spec1min_win = floor(max((lwindow-wmin)*nspec / (wmax-wmin),0.0));
			spec1max_win = floor(min((rwindow-wmin)*nspec / (wmax-wmin),nspec+0.0))-1;
			selected = ak(:,window) > bottom_top(r,1) & ak(:,window) < bottom_top(r,2);
			for j=spec1min_win:spec1max_win
				w = wmin + j * wstep;
				weight = cos((w-lwindow)*2*pi/(rwindow-lwindow)+pi)*0.5 + 0.5;
				z = exp(-i*tau1*w);
				for k=1:size(uk,1)
					if(selected(k))
						if(strcmp(get(source, 'String'), 'Pseudoabsorption'))
							spec(j+1,r) = spec(j+1,r) + tau1^2 * weight * dk(k,window) ...
								* (1/(1 - uk(k,window)/z)^2 - 0.5);
						else
							spec(j+1,r) = spec(j+1,r) + tau1 * weight * dk(k,window) ...
								* (1/(1 - uk(k,window)/z) - 0.5);
						end
					end
				end
			end
		end
	end
	if(strcmp(get(source, 'String'), 'Absorption'))
		spec = real(spec);
	else
		spec = abs(spec);
	end
	specfig = figure();
	nplot = size(spec,2);
	pad = 0.1;
	axisfract = 0.2;
	plotheight = (1-pad)/(nplot+(nplot-1)*axisfract);
	for a=1:nplot
		ax(a) = axes('Position', [pad/2, pad/2 + (a-1)*plotheight*(1+axisfract), ...
			1-pad, plotheight]);
		plot(-(linspace(wmin, wmax, nspec)/sfrq - (-wp/2 - sp)), spec(:,a));
	end
end

function zoomer(source,eventdata)
	dosyfigure = gcf();
	dosyaxes = get(dosyfigure, 'CurrentAxes');
	xlimits = get(dosyaxes, 'XLim');
	ylimits = get(dosyaxes, 'YLim');
	zlimits = get(dosyaxes, 'ZLim');
	zmax = zlimits(2);
	dfdata = guidata(dosyfigure);
	set(dfdata.chem_shift_axes, 'XLim', xlimits);
	set(dfdata.diffusion_axes, 'YLim', ylimits);
	set(dfdata.window, 'Vertices', ...
		[[xlimits(1),xlimits(2),xlimits(2),xlimits(1)]',...
		[ylimits(2),ylimits(2),ylimits(1),xlimits(1)]', [zmax,zmax,zmax,zmax]'])
	guidata(dosyfigure, dfdata);
end

function [rotate]=fixer(source,eventdata)
	rotate = 1;
end

function threshold_minus(source,eventdata)
	increment = 0.001;
	dosyfigure = gcf();
	dfdata = guidata(dosyfigure);
	dfdata.top_th = max(dfdata.top_th - increment, dfdata.bottom_th + increment);
	guidata(dosyfigure, dfdata);
	set(dfdata.th_label, 'String', num2str(dfdata.top_th));
	replot_DOSY();
end

function threshold_plus(source,eventdata)
	increment = 0.001;
	dosyfigure = gcf();
	dfdata = guidata(dosyfigure);
	dfdata.top_th = min(dfdata.top_th + increment, 1);
	guidata(dosyfigure, dfdata);
	set(dfdata.th_label, 'String', num2str(dfdata.top_th));
	replot_DOSY();
end

function replot_DOSY()
	dosyfigure = gcf();
%%	dosyaxes = get(dosyfigure, 'CurrentAxes');
%	dosyaxes = axes('Position',[0.05, 0.2, 0.9, 0.65]);
	dosyaxes = axes('Position',[0.05, 0.2, 0.8, 0.65]);
	dfdata = guidata(dosyfigure);
	DOSYth = max(dfdata.bottom_th,min(dfdata.DOSY / max(dfdata.DOSY(:)),dfdata.top_th));
	[xax,yax]=meshgrid(dfdata.Ppmscale,dfdata.Dscale);
	set(dfdata.th_minus, 'enable', 'off');
	set(dfdata.th_plus, 'enable', 'off');
	[dosy_plot, cont] = ...
		contour(dosyaxes, -fliplr(xax),-flipud(yax), fliplr(flipud(DOSYth')));
	xlimits = get(dosyaxes, 'XLim');
	ylimits = get(dosyaxes, 'YLim');
	zmax = max(DOSYth(:));
	dfdata.windowpane = patch([xlimits(1),xlimits(2),xlimits(2),xlimits(1)],...
		[ylimits(2),ylimits(2),ylimits(1),ylimits(1)], ...
		[zmax,zmax,zmax,zmax], ...
		'Blue','FaceAlpha',0.0,'LineStyle','none','ButtonDownFcn',@click_callback);
	set(dfdata.th_minus, 'enable', 'on');
	set(dfdata.th_plus, 'enable', 'on');
	guidata(dosyfigure, dfdata);

end

