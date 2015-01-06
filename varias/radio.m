%% Funcion R  = radio(x,y)
%% Calcula el radio de la geometría circular definida en los puntos x,y y lo entrega en la variable R. El vector C corresponde al centro de la circunferencia.

% En el futuro hacer que entregue una estructura de tipo circunferencia. No se que es mejor toravia, calcular o arrastrar caracteristicas

function [R C]= radio(x,y);

% try{

R = abs(max(x) - min(x))/2;
C = [min(x) + R,  min(y) + R];

% }catch{


% }
