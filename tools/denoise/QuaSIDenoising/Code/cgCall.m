function [ result ] = cgCall( f_new_vec, wk, alpha, beta, M, MT, L)
%use cg to solve the linear system of equations in equation (4)

    result = (2 * wk .* f_new_vec) ...       % Data term
        + beta .* getLaplacian(f_new_vec,L) ...     % Total variation
        + alpha .* MT * M * f_new_vec;              % Dark channel
