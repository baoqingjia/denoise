function [SpecDataReal,SpecDataImg] = LoadBrukerSpec(fPath)
%LOADBRUKERSPEC 此处显示有关此函数的摘要
%   读取Bruker的谱数据，在pdata\*\1r 为实部谱，pdata\*\1r 为虚部谱


% fnamereal  = '6_8_10脑区/601/1/pdata/1/1r';
% fnameimg  = '6_8_10脑区/601/1/pdata/1/1i';
[dirPath]=fileparts(fPath);
fnamereal = [dirPath '/1r'];
fnameimg = [dirPath '/1i'];
specPoints = ReadTopspinParam(fnamereal, 'SI');
SizeTD1 = 1;
ByteOrder = 2;

[ SpecDataReal ] = GetBrukerSpecfromBinary(fnamereal, SizeTD1, specPoints, ByteOrder);
[ SpecDataImg ] = GetBrukerSpecfromBinary(fnameimg, SizeTD1, specPoints, ByteOrder);

% figure(1);
% plot(SpecDataReal);
% 
% figure(2);
% plot(SpecDataImg);

end

