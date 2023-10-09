function [ vector ] = matrixToVector( matrix)
%reshape the matrix as a vector in a row-wise manner

vector = reshape(transpose(matrix),[numel(matrix),1]);
end

