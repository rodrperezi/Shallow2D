clear all 
close all 

N=100;
T=1000;
Trials=rand(N,T);
AverageValue=mean(Trials,2);
Trials=bsxfun(@minus,Trials,AverageValue);
