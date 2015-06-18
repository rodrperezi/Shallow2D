% Rodrigo Pérez I. 
% Rutina que genera matrices para el problema de volúmenes finitos
% El problema se plantea de la forma G*C = b
% IDetaC = zeros(Neta,6); % Nodos eta: W, E, E+1, S, N, N+1

fila = (1:Neta)';
G = sparse([fila;fila;fila;fila;fila],[fila; IDetaCaux(:,1); IDetaCaux(:,2); IDetaCaux(:,5); IDetaCaux(:,4)], [aP;-aW;-aE;-aN;-aS]);


