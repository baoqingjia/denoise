function [SpecDataReal,SpecDataImg] = LoadBrukerSpec(fPath)
%LOADBRUKERSPEC �˴���ʾ�йش˺�����ժҪ
%   ��ȡBruker�������ݣ���pdata\*\1r Ϊʵ���ף�pdata\*\1r Ϊ�鲿��


% fnamereal  = '6_8_10����/601/1/pdata/1/1r';
% fnameimg  = '6_8_10����/601/1/pdata/1/1i';
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

