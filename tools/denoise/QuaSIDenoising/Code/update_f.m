function [f_new_vec, sigma] = update_f( f_old_vec,g,alpha,beta,v_vec,bv_vec,bu_vec,u_vec,...
    M,MT,grad,gradT,L,tol)

% Assemble right hand side of the equation system (eq. (4))
% Part for TV denoising
[~,directions] = size(v_vec);
[R,C] = size(v_vec{1});
TVpart =zeros(R*C,1);

for pos = 1: directions
    TVpart = TVpart + getGradient(( v_vec{pos}- bv_vec{pos})...
        ,grad,gradT,pos, 'backward');
end

% Determine residual error.
r = repmat( vectorToMatrix(f_old_vec, size(g,1), size(g,2)), 1, 1, size(g,3)) - g;
if (all(r(:) == 0))
    % No adaptive noise estimation.
    sigma = Inf;
    w = ones(size(r));
else
    % Noise estimation.
    sigma = 0.2;
    % Compute confidence weights according to the Huber loss.
    % Set threshold to 95-percent efficiency
    w = (1.345*sigma) ./ abs(r);
    w(abs(r) <= 1.345*sigma) = 1;
end

% Put both parts together to get the right hand side of the equation.
b = (2*matrixToVector(sum(w .* g,3))) + beta *TVpart ...
    + alpha * MT * (u_vec - bu_vec );

% Assemble matrix (implemented via imfilter)
[Af] = @(f_new_vec)cgCall( f_new_vec, matrixToVector( sum(w, 3) )...
    , alpha, beta, M, MT, L);

% Solve A * f_new = b
[f_new_vec,~,~,~,~] = cgs(Af, b, ...
    tol,3, [], [],...
    f_old_vec);

% Truncate intensity values to [0, 1].
f_new_vec(f_new_vec < 0) = 0;
f_new_vec(f_new_vec > 1) = 1;

end