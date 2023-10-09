function E = calculateEnergyFunction(f, g, gradient, sigma, mu, lambda, patchsize, quantile)
    
    % Calculate data fidelity term.
    [~,~,numberFrames] = size(g);
    r = repmat(f(:),numberFrames,1) - g(:);
    E_data = sum( huber(r, sigma) );
    
    % Calculate TV regularization term.
    E_tv = 0;
    for pos = 1:length(gradient)
        E_tv = E_tv + sum( abs(gradient{pos}) );
    end
    
    % Calculate QuaSI regularization term.
    [LookUpRow, LookUpColumn] = compute_Q(vectorToMatrix(f, size(g,1), size(g,2)), patchsize, quantile);
    M = speye(numel(f), numel(f)) - sparse(LookUpRow,LookUpColumn,1,numel(f),numel(f));
    E_quasi = sum( abs(M * f) );
    
    % Overall energy function.
    E = E_data + mu*E_tv + lambda*E_quasi;
    
function h = huber(x, sigma)

    h = 1/2 * x.^2;
    h(abs(x) > sigma) = sigma * (abs( x(abs(x) > sigma) ) - 1/2*sigma);