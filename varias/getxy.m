%% [x y]= getxy(coordenadas)
% función que recupera coordenada x del set de datos espaciales coordenadas

function [x y] = getxy(coordenadas)

if(length(coordenadas(1,:)) ~= 2)
	coordenadas = coordenadas';
end

x = coordenadas(:,1);
y = coordenadas(:,2);



