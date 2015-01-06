% function [xqv yqv uqv vqv] = puntos_quiver(SOL, coordeta, coordu, coordv, nBIz, nBDe, nBSu, nBIn, IDwe, IDns, deltax, deltay, Ineta)
% Función que genera la distribución de puntos adecuada para construir un grafico tipo quiver. La función recibe la solución del problema SOL con sus respectivas coordenadas. Coordenadas es el vector (x,y)


function [xqv yqv uqv vqv hqv hoqv] = puntos_quiver(SOL, coordeta, coordu, coordv, nBIz, nBDe, nBSu, nBIn, IDwe, IDns, deltax, deltay, Ineta, H,heta)

[eta u v] = get_etauv(SOL, coordeta, coordu, coordv, nBIz, nBDe, nBSu, nBIn, IDwe, IDns);
[Radio Centro] = radio(coordeta(:,1), coordeta(:,2));
nuevo_borde = genera_borde_circular(Radio, Centro);
[aid bid] = find(Ineta'==1);


x = coordeta(:,1);
y = coordeta(:,2);
% keyboard
for i = 1:length(aid)
	hoqv(bid(i),aid(i)) = heta(i);	
	hqv(bid(i),aid(i)) = eta(i);	
	uqv(bid(i),aid(i)) = u(i);
	vqv(bid(i),aid(i)) = v(i);
	xqv(bid(i),aid(i)) = x(i);
	yqv(bid(i),aid(i)) = y(i);
end





