function [ matrix ] = vectorToMatrix( vector,R,C )
%Function converts a vector into a matrix. The storage is made in a
%row-wise manner

matrix = transpose(reshape(vector,C,R));

end

