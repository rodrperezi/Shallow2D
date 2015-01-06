% function [valor_interpolado coordenadas] = interpola(xdato, ydato, pdato, deltax, deltay)
% Función que entrega valores interpolados a partir de (xdato, ydato) y el valor pdato para una nueva malla contenida en el borde de las coordenadas espaciales dato. La nueva malla tiene espaciamiento (deltax, deltay). Ojo que siempre se utiliza una malla más refinada por lo que esta función puede ser renombrada a refina. O se puede crear la función refina.

% function [valor_interpolado coordenadas] = interpolador(xdato, ydato, pdato, deltax, deltay, x_interpolar, y_interpolar)

function [valor_interpolado coordenadas] = interpolador(xdato, ydato, pdato, deltax, deltay)

[Radio Centro] = radio(xdato,ydato);
nuevo_borde = genera_borde_circular(Radio, Centro);
coordenadas = genera_malla_staggered(nuevo_borde, deltax, deltay);

% coordenadas = [x_interpolar, y_interpolar];
% keyboard

if(isrow(xdato))
	xdato = xdato';
	ydato = ydato';
end

if(sum(size(xdato) ~= size(pdato)) == 0)
	pdato = reshape(pdato,length(xdato),1);
end

Interpolador = TriScatteredInterp(xdato, ydato, pdato);
% fx = find(coordenadas(:,1) >= min(xdato) && coordenadas(:,1) <= max(xdato));
% fy = find(coordenadas(:,2) >= min(ydato) && coordenadas(:,2) <= max(ydato));

% f = find(fx == fy);
% fx = fx(f);
% fy = fy(f);

% coordenadas = coordenadas(f,:);
% keyboard
valor_interpolado = Interpolador(coordenadas(:,1), coordenadas(:,2));






