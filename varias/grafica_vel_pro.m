% Rodrigo Pérez I. 
% grafica_eta(x, y, dx, dy, xgeodat, ygeodat, eta, u, v, Ineta)
% Función que grafica solución hidrodinámica.
% (x,y) = coordenadas de nodos eta
% (xgeodat, ygeodat) = coordenadas de bordes
% eta = Vector solución para la superficie libre
% u = vector de velocidad (x)
% v = vector de velocidad (y)
% dx = espaciamiento en x
% dy = espaciamiento en y
% Ineta = Matriz que identifica puntos dentro de la geometría

% function [] = grafica_eta(x, y, dx, dy, xgeodat, ygeodat, eta, u, v, Ineta, xeta, yeta)

x = coordeta(:,1);
y = coordeta(:,2);

linewd = 0.5;
frac = 0.3;
deltax = frac*dx;
deltay = frac*dy;

[uint coordp] = interpolador_supuesto(x,y,full(u),deltax,deltay);
[uint coordx coordy] = puntos_patch(uint, coordp, deltax, deltay);
[vint coordp] = interpolador_supuesto(x,y,full(v),deltax,deltay);
[vint coordx coordy] = puntos_patch(vint, coordp, deltax, deltay);


handle_patch = patch(coordx/R,coordy/R, sqrt(uint.^2 + vint.^2)/max(max(sqrt(uint.^2 + vint.^2))));
shading('interp')
hold on
[xplot yplot uplot vplot hplot hoplot] = puntos_quiver(SOLam, coordeta, coordu, coordv, nBIz, nBDe, nBSu, nBIn, IDwe, IDns, dx, dy, Ineta, H);
handle_quiver = quiver(xplot/R,yplot/R,uplot,vplot, 'MaxHeadSize', 1);
plot(xgeodat/R,ygeodat/R,'k','linewidth',linewd);
handle_figure = gcf;

% keyboard
set(handle_quiver,'linewidth', 0.01, 'color', 0*[1 1 1]);
set(handle_quiver,'autoscalefactor', 1);
axis equal
xlim([-0.125 2.125]);
ylim([-0.125 2.125]);

%% xlabel 'X [m]' 
%% ylabel 'Y [m]'
%%clbr = colorbar;
%%set(get(clbr,'xlabel'),'string','\eta/\eta_{max}')
%hold off

