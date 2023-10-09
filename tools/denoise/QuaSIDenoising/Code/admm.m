function [ f, E ] = admm(g,mu,lambda,alpha,beta,tol,maxOuterIter,maxInnerIter,patchsize,quantile)

%store the size of the image
[R,C,K] = size(g);

%initialize the denoised image with the average of all input images
f_new = mean(g, 3);

%number of directions for the gradient
directions = 2;
%define the gradient directions and compute its transposes
numberPixel = R*C;
gradX = getGradientMatrix(numberPixel,1);
gradY = getGradientMatrix(numberPixel,C);
gradXT = gradX';
gradYT = gradY';
grad = {gradX, gradY};
gradT = {gradXT, gradYT};

%iniitalize the auxiliary variable and the bregman variable related to the 
%total variation term
v_vec = cell(1,directions);
bv_vec = cell(1,directions);

for pos = 1:directions
    v_vec{pos} = matrixToVector(zeros(R,C));
    bv_vec{pos} = matrixToVector(zeros(R,C));
end

%iniitalize the auxiliary variable and the bregman variable related to the
%quasi prior
u_vec = zeros(R*C,1);
bu_vec = zeros(R*C,1);

%compute Laplacian
[Rgrad, Cgrad] = size(grad{1});
L = sparse(Rgrad,Cgrad);
for pos  = 1:length(grad)    
    L = L + gradT{pos}*grad{pos};    
end

%vectorize the image
f_new_vec = matrixToVector(f_new);
flag = 0;
% store the value of the energy function in each iteration step (equation (1))
E = [];


for outerIter = 1:maxOuterIter
    
    if lambda > 0
        % Compute look up table for quantile regularization (M = Id - Q)
        [LookUpRow, LookUpColumn] = compute_Q(vectorToMatrix(f_new_vec,R,C),patchsize,quantile);
        M = speye(numberPixel, numberPixel) - sparse(LookUpRow,LookUpColumn,1,numberPixel,numberPixel);
        MT = speye(numberPixel, numberPixel) - sparse(LookUpColumn,LookUpRow,1,numberPixel,numberPixel);
    else
        M = speye(numberPixel, numberPixel);
        MT = speye(numberPixel, numberPixel);
    end
    
    f_old_vec = f_new_vec;   
    
    for innerIter = 1:maxInnerIter
         %update the intermediate image f
        [f_new_vec, sigma] = update_f( f_new_vec,g,alpha,beta,v_vec,bv_vec,...
            bu_vec,u_vec,M,MT,grad,gradT,L,tol);

       
        if(find(isnan(f_new_vec(:)) == 1))
            flag = 1;
            f_new_vec = zeros(R,C);
            error('Optimize_f returned NaN')            
        end
        
        % Gradient for TV denoising
        gradient = cell(1,directions);
        %Anisotropic TV denoising
        for pos = 1:directions        
            gradient{pos} = getGradient(f_new_vec,grad,gradT,pos);
            v_vec{pos} = update_vAnisotropic(gradient{pos},bv_vec{pos},beta,mu);
             %update bregman variable bv of the TV
            bv_vec{pos} = bv_vec{pos} + (gradient{pos} - v_vec{pos});
        end
          
        %part for the quasi prior
        if lambda > 0
            %update the auxiliary variable u and the bregman variable bu
            u_vec = update_u( f_new_vec,M,bu_vec,lambda,alpha);
            bu_vec = update_bu( bu_vec,f_new_vec,u_vec,M);
        end
    
        if nargout > 1
            % Compute energy function            
            E = [E; calculateEnergyFunction(f_new_vec, g, gradient, 1.345*sigma, mu, lambda, patchsize, quantile)];
        end
            
    end
        
    if(flag == 1)
        break;
    end
    
    %compute the difference between the intermediate image and the
    %image from the previous iteration step 
    %return is difference is small
    if norm(f_old_vec - f_new_vec) / norm(f_old_vec) < tol 
        f = vectorToMatrix(f_new_vec,R,C);
        return;
    end
    
end

f = vectorToMatrix(f_new_vec,R,C);