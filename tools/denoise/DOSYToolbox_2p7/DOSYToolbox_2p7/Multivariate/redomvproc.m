function[mvdata, ncomp]=redomvproc(mvdata,pfgnmrdata,ncomp,Range,Opts_score,Opts_lrank,nug,Dlimit,minpercent)
redo=1;
while redo==1;
[rubbish1]=find(mvdata.Dval>Dlimit);
[rubbish2]=find(mvdata.Dval<0);
relp=100*(mvdata.relp./sum(mvdata.relp));
[rubbish3]=find(relp>100);
[rubbish4]=find(relp<minpercent);
[rubbish5]=find((histc(round(mvdata.Dval*100)/100,(unique(round(mvdata.Dval*100)/100)))>1));
if (isempty(rubbish1) && isempty(rubbish2) && isempty(rubbish3)...
        && isempty(rubbish4) && isempty(rubbish5));
    redo=0;
    % ok
else
    if ncomp==1
        disp('locodosy: The one remaining component matches the exclusion criteria') 
        disp('locodosy: Try adjusting these criteria.')
        redo=0;
    else
    if rubbish1
        disp('locodosy: Upper diffusion limit exceeded, lowering ncomp')
    elseif rubbish2
        disp('locodosy: Negative diffusion coefficient, lowering ncomp')
    elseif rubbish3
        disp('locodosy: Component percentage > 100, lowering ncomp')
    elseif rubbish4
        disp('locodosy: Component percentage < 5, lowering ncomp')
    elseif rubbish5
        disp('locodosy: I think we have mirror spectra, lowering ncomp')
    end
    ncomp=ncomp-1;
    switch Opts_lrank(3)
    case 0
        disp('locodosy: Using SCORE fitting')  
        mvdata=score_mn(pfgnmrdata,ncomp,Range,Opts_score,nug);
    case 1
        disp('locodosy: Using DECRA fitting')  
        mvdata=decra_mn(pfgnmrdata,ncomp,Range,Opts_lrank(4));
        mvdata.Dval=mvdata.Dval'*1e10;
    otherwise
        error('locodosy: Illegal Options(3)')
    end
    end
end
end
