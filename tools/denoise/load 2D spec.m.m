% FID = 1:1:100;
fidPath = 'I:\topspindata\topspindata\1.9mm-20191129-800M\401\pdata\1\2rr';
FID = load(fidPath).';
[row,column] = size(FID);