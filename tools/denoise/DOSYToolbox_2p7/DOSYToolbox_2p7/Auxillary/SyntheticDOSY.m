function[RandSynthData] = SyntheticDOSY(SynthData)

% Generate a DOSY experiment
sw=SynthData.sw;
np=SynthData.np;
mingrad=SynthData.mingrad;
maxgrad=SynthData.maxgrad;
ngrad=SynthData.ni;
npeaks=SynthData.npeaks;
noise=SynthData.noise;
% gw=SynthData.gw';
lw=SynthData.lw';
NUGs=SynthData.NUGs;
Amps=SynthData.Amps;
sfrq=500;
mults=SynthData.multiplicity;

J=7;
at=np/sw;
dwell=1/sw;
t=0:dwell:(at-dwell);
gamma=2.67522212e8;
Dmax=20;
del=0.004;
DEL=0.1;
dosyconstant=gamma^2*del^2*DEL;
    
% hz=0:(2500/(np-1)):(sw);
% hz=hz-1250;

% Useful Arrays
Timescale=linspace(0,at,np);

%% Randomisation or not
if isfield(SynthData,'Freqs')
% Use the values from the Table in the Toolbox
    omega=(SynthData.Freqs');
else
% Generate a number(npeaks) of random frequencies within 1/4 to 3/4 sw.
    omega=(0.5*sw*(rand(npeaks,1)-1.5)+sw/2);
end

if isfield(SynthData,'Dvals')
% Use the values from the Table in the Toolbox    
    Dvals=SynthData.Dvals*1e-10';
else
% generate some random D
%     Dvals=(Dmax.*rand(1,npeaks))*1e-10;
    dtemp=round((Dmax.*rand(1,npeaks))*1000)/1000;
    Dvals=dtemp*1e-10;
end
%% Multiplet Generation
nsignals=0;
SignalFreqs=[];
SignalAmps=[];
SignalLws=[];
SignalDvals=[];
for f=1:npeaks
   switch mults(f)
       case 1 % Singlet 1
           nsignals=nsignals+1;
           SignalFreqs=[SignalFreqs omega(f)];
           SignalAmps=[SignalAmps 1*(Amps(f))];
           SignalLws=[SignalLws lw(f)];
           SignalDvals=[SignalDvals Dvals(f)];
       case 2 % Doublet 0.5:0.5
           nsignals=nsignals+2;
           doublet=[(omega(f)-J/2) (omega(f)+J/2)];
           SignalFreqs=[SignalFreqs doublet];
           SignalAmps=[SignalAmps 0.5*(Amps(f)) 0.5*(Amps(f))];
           SignalLws=[SignalLws lw(f) lw(f)];
           SignalDvals=[SignalDvals Dvals(f) Dvals(f)];
       case 3 % Triplet 0.25:0.5:0.25
           nsignals=nsignals+3;
           triplet=[(omega(f)-J) omega(f) (omega(f)+J)];
           SignalFreqs=[SignalFreqs triplet];
           SignalAmps=[SignalAmps 0.25*(Amps(f)) 0.5*(Amps(f)) ...
               0.25*(Amps(f))];
           SignalLws=[SignalLws lw(f) lw(f) lw(f)];
           SignalDvals=[SignalDvals Dvals(f) Dvals(f) Dvals(f)];
       case 4 % Quartet 0.125:0.375:0.375:0.125
           nsignals=nsignals+4;
           quartet=[(omega(f)-1.5*J) (omega(f)-J/2) ...
               (omega(f)+J/2) (omega(f)+1.5*J)];
           SignalFreqs=[SignalFreqs quartet];
           SignalAmps=[SignalAmps 0.125*(Amps(f)) 0.375*(Amps(f)) ...
               0.375*(Amps(f)) 0.125*(Amps(f))];
           SignalLws=[SignalLws lw(f) lw(f) lw(f) lw(f)];
           SignalDvals=[SignalDvals Dvals(f) Dvals(f) Dvals(f)...
               Dvals(f)];
       case 5 % Quintet 0.0675:0.25:0.375:0.25:0.0675
           nsignals=nsignals+5;
           SignalFreqs=[SignalFreqs (omega(f)-2*J) (omega(f)-J) ...
               omega(f) (omega(f)+J) (omega(f)+2*J)];
           SignalAmps=[SignalAmps 0.0675*(Amps(f)) 0.25*(Amps(f)) ...
               0.375*(Amps(f)) 0.25*(Amps(f)) 0.0675*(Amps(f))];
           SignalLws=[SignalLws lw(f) lw(f) lw(f) lw(f) lw(f)];
           SignalDvals=[SignalDvals Dvals(f) Dvals(f) Dvals(f)...
               Dvals(f) Dvals(f)];
   end
end
%% Lineshape

% Add lineshape (Lorentzian)
for l=1:nsignals
    if lw~=0
        LbFunc(l,:)=exp(-Timescale'*pi*SignalLws(l));
    else
        LbFunc(l,:)=ones(1,np);
    end
end

% % Add lineshape (Gaussian)
% for g=1:npeaks
%     if gw(g)~=0
%         gf(g)=2*sqrt(log(2))/(pi*gw(g));
%         GwFunc(g,:)=exp(-(Timescale'/gf(g)).^2);
%     else
%         GwFunc(g,:)=ones(1,np);
%     end
% end

% % Combine the window functions.
% Winfunc=GwFunc.*LbFunc;
%% Frequencies into rotating decaying exponentials
Signals={nsignals};
    for k=1:nsignals
        Signals{k}=SignalAmps(k)*exp(-1i*2*pi*SignalFreqs(k)*t);
        Signals{k}=Signals{k}.*LbFunc(k,:);
        Signals{k}=repmat(Signals{k},ngrad,1);
    end
%% Decays
% Generate some DOSY decays
    % calculate the gradient array
    gradlvl=zeros(1,ngrad);
    for p=1:ngrad
        gradlvl(p)=mingrad^2+(p-1)*(maxgrad^2-mingrad^2)/(ngrad-1);
    end
    gradlvl=sqrt(gradlvl);

    % form a decay matrix
    decays={npeaks};
    for p=1:nsignals
    expfactor=SignalDvals(p)*gamma^2*del^2*DEL.*gradlvl.^2;
        if NUGs==0      
            decays1{p}=exp(-expfactor);
            decays{p}=repmat(decays1{p},np,1)';
        else
            decays1{p} = exp( - NUGs(1)*expfactor.^1 -...
            NUGs(2)*expfactor.^2 -...
            NUGs(3)*expfactor.^3 -...
            NUGs(4)*expfactor.^4);
            decays{p}=repmat(decays1{p},np,1)';
        end   
    end
%% Combine Signals and Decays
    % Apply the decays
    DOSYcell={nsignals};
    for f=1:nsignals
        DOSYcell{f}=Signals{f}.*decays{f};
    end
    
    % Merge Cell matrix into a DOSY dataset
    DOSYdata=zeros(ngrad,np);
    for h=1:nsignals
        DOSYdata=DOSYdata+DOSYcell{h};
    end
    
DOSYFIDs=DOSYdata;
%% Add noise
% to add the right amount of noise: fft, add noise, ifft.
DOSYspect=fft(DOSYFIDs');

if SynthData.noise==0
    GaussianNoise=0;
else
% Add some noise
GaussianNoise=((randn(ngrad,np)+1i*randn(ngrad,np)).* ...
    max(max(real(DOSYspect))))./SynthData.noise;
end

DOSYspect=DOSYspect+GaussianNoise';

% 3D plot
if SynthData.meshplot==1
    figure
    mesh(real(fftshift(DOSYspect,1)))       
end

for f=1:ngrad
DOSYFIDs(f,:)=ifft(DOSYspect(:,f));
end

TimeErrFlag=0;
if TimeErrFlag==1
    DOSYFIDs=DOSYFIDs(:,3:end);
end

%% Prepare data for exporting
RandSynthData.Freqs=omega;
RandSynthData.SPECTRA=DOSYspect';
RandSynthData.FIDs=DOSYFIDs';
RandSynthData.npeaks=npeaks;
RandSynthData.sw=sw;
RandSynthData.np=np;
RandSynthData.ngrad=ngrad;
RandSynthData.maxgrad=maxgrad;
RandSynthData.mingrad=mingrad;
RandSynthData.noise=noise;
RandSynthData.Dvals=Dvals;
RandSynthData.delta=del;
RandSynthData.DELTA=DEL;
RandSynthData.at=at;
RandSynthData.gradlvl=gradlvl;
RandSynthData.gamma=gamma;
RandSynthData.dosyconstant=dosyconstant;
RandSynthData.Amps=Amps;
RandSynthData.Lw=lw;
% RandSynthData.Gw=gw;
RandSynthData.multiplicity=mults;
RandSynthData.sfrq=sfrq;
end