function [SNR MaxSignal Noise] = SNRCalculate(Spec)
%SNRCALCULATE �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
MaxSignal=max(real(Spec));
Noise=std(cat(2,Spec(1:50),Spec(end-50:end)));
SNR=MaxSignal/Noise;
end

