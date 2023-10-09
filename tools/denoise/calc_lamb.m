function lam = calc_lamb(data, region)
    if isnumeric(region)

            noise = data(1:int32(0.1*length(data)));
 

    else
        noise = zeros(size(data));
        idx = find(region == 0);
        noise(idx) = data(idx);
    end
    sig = std(noise);
    lam = sig*sqrt(2*log(length(data)));
end