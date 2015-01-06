clear all 
close all 

A=rand(100,100);

h=waitbar(0,'Waiting...');
EndOfLoop=2000;

for i=1:EndOfLoop
A=A.^2;
waitbar(i/EndOfLoop,h);
end
delete(h);
