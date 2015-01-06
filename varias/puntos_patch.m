%% function [valor coordx coordy] = puntos_patch(val, coord, deltax, deltay)
% funcion que ordena las coordenadas y los valores de manera de dejarlos listos para usarlos en la función patch de matlab. La lógica de esta función es agregar como parte del sistema de coordenadas los valores correspondientes a las esquinas de cada nodo de resolución.

function [valor coordx coordy] = puntos_patch(val, coord, deltax, deltay)

dx = deltax;
dy = deltay;
[x y] = getxy(coord);

x = x';
y = y';
val = val';

coordx = [x-dx/2; x+dx/2; x+dx/2; x-dx/2; x-dx/2];
coordy = [y-dy/2; y-dy/2; y+dy/2; y+dy/2; y-dy/2];
% keyboard
% coordenadas = [x,y];
valor = [val; val; val; val; val];






