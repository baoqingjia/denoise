function [SNR MaxSignal Noise] = SNRCalculate(Spec)
%SNRCALCULATE 此处显示有关此函数的摘要
%   此处显示详细说明
MaxSignal=max(real(Spec));
Noise=std(cat(2,Spec(1:50),Spec(end-50:end)));
SNR=MaxSignal/Noise;
end

