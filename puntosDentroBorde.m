function nodosEtaDentroBorde = puntosDentroBorde(borde, deltaX, deltaY)  
% puntosDentroBorde: Funcion que identifica los puntos del dominio que están dentro del borde de la geometría. 
% El dominio está definido por los valores máximos y mínimos del borde.
% nodosEtaDentroBorde es una matriz de índices. Tiene 1 en los puntos que están dentro del borde 
% y 0 para los que están afuera.
% 
% El valor deltaX/2 o deltaY/2 en xeta e yeta es para alejar el nodo eta desde el borde. 
% Aquí se asume que siempre en esta malla staggered los nodos eta 
% estarán ubicados en el centro y colineal con los dos puntos u o v adyacentes

xEta = min(borde(:,1)) + deltaX/2: deltaX : max(borde(:,1)) - deltaX/2;
yEta = max(borde(:,2)) - deltaX/2: -deltaY: min(borde(:,2)) + deltaY/2;

[meshXEta meshYEta] = meshgrid(xEta,yEta); % Construyo meshgrid de dominio
nodosEtaDentroBorde = sparse(inpolygon(meshXEta, meshYEta, borde(:,1), borde(:,2))); 

