function[RMSnoise]=calcRMSnoise(SPECTRA,Specscale)
       spect1=SPECTRA(:,1);
       sw=(max(Specscale)-min(Specscale));
       [moose, column]=find(Specscale>(Specscale(1)+(sw/20)),1,'first');
       noise=real(spect1(1:column,1));
       sqnoise=noise.^2;
       avgsq=sum(sqnoise)/length(noise);
       RMSnoise=sqrt(avgsq);
end