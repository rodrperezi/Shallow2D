% Prueba grafico matriz
clear all 
close all

 %matriz = [1,2;3,4]
matriz = [0, 0, 0, 0, 0, 0;
	  0, 0, 0, 1, 0, 0; 
	  0, 2, 3, 4, 0, 0; 
	  0, 0, 0, 0, 5, 0;
	  0, 0, 0, 0, 0, 0];

matrizGeo = [0, 0, 0, 0, 0, 0;
	     0, 0, 0, 1, 0, 0; 
	     0, 1, 1, 1, 0, 0; 
	     0, 0, 0, 0, 1, 0;
             0, 0, 0, 0, 0, 0];

[xNodos yNodos] = find(matrizGeo' == 1);
% graficaNumerosMatriz(matriz);

% Agrego filas con zeros intercaladas a las filas de matriz
[m n] = size(matriz);
% La metodología para intercalar filas es 
% Creo una la fila a intercalar de cuantas 
% columnas tenga la matriz a la cual se intercalará
matrizAIntercalar = matriz;
filaIntercalar = zeros(1,n);

numeroNodosEta = 5;
numeroNodosV = 9;

if(yNodos(1) == 1)
	matrizIntercalada = filaIntercalar;
else
	matrizIntercalada = [matrizAIntercalar(1:yNodos(1)-1,:);filaIntercalar];
end

for iFilas = yNodos(1):m
	matrizIntercalada = [matrizIntercalada; matrizAIntercalar(iFilas,:); filaIntercalar];
end

% calculo nuevas coordenadas de nodosEta

[xNuevosNodos yNuevosNodos] = find(matrizIntercalada' ~=0);
% Las filas deberían haber cambiado con respecto a antes
% mientras que la posición en las columnas debería ser la misma
% Lo que hago ahora es recorrer los nodosEta y agrego -1 
% arriba y abajo de ellos, que es donde estarían ubicados los nodos v

for iNodo = 1:length(xNuevosNodos)
	matrizIntercalada(yNuevosNodos(iNodo)+1, xNuevosNodos(iNodo)) = -1;
	matrizIntercalada(yNuevosNodos(iNodo)-1, xNuevosNodos(iNodo)) = -1;
end

% Finalmente, enumero los nodos v

[xNodosV yNodosV] = find(matrizIntercalada' == -1);

for iEnum = 1:length(xNodosV) 
	matrizIntercalada(yNodosV(iEnum),xNodosV(iEnum)) = iEnum + numeroNodosEta;    
end

% Funciona. Entonces ahora hago esto mismo pero para los nodos U.

graficaNumerosMatriz(matrizIntercalada);


