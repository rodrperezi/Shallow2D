% function handleFigura = graficaModo(omegaModo, gammaModo, estructuraModo)
% function handleFigura = graficaModo(solucionModo)
function handleFigura = graficaModo(Simulacion, solucionModo, tipoDeGrafico)

cuerpoAGraficar = Simulacion.Cuerpo;

% stringAyuda = ['solucionCompleta = Simulacion.Resultados.',motorDeCalculo,'.solucionCompleta;'];
% eval(stringAyuda);
solucionCompleta = solucionModo;

R = cuerpoAGraficar.Geometria.radioKranenburg;
H = cuerpoAGraficar.Geometria.alturaKranenburg;

dx = cuerpoAGraficar.Geometria.deltaX;
dy = cuerpoAGraficar.Geometria.deltaY;

frac = 0.5;
nuevoDeltaX = frac*dx;
nuevoDeltaY = frac*dy;
[valorInterpolado coordenadasInterpoladas] = Interpolador(Simulacion, solucionCompleta, tipoDeGrafico, nuevoDeltaX, nuevoDeltaY);
% keyboard
[valorParaPatch coordenadasX coordenadasY] = puntosParaPatch(valorInterpolado, coordenadasInterpoladas, nuevoDeltaX, nuevoDeltaY);
% handlePatch = patch(coordenadasX/R, coordenadasY/R, valorParaPatch);
handlePatch = patch(coordenadasX, coordenadasY, valorParaPatch);
shading('interp')
hold on

% Grafica el Borde
linewd = 0.5;
bordeSuperficie = cuerpoAGraficar.Geometria.bordeSuperficie;
% plot(bordeSuperficie(:,1)/R, bordeSuperficie(:,2)/R,'k','linewidth',linewd);
plot(bordeSuperficie(:,1), bordeSuperficie(:,2),'k','linewidth',linewd);


% keyboard

% Quiver para velocidad
%[xParaQuiver yParaQuiver uParaQuiver vParaQuiver] = puntosParaQuiver(Simulacion, solucionCompleta);
%% handleQuiver = quiver(xParaQuiver/R, yParaQuiver/R, uParaQuiver, vParaQuiver, 'MaxHeadSize', 1);
%handleQuiver = quiver(xParaQuiver, yParaQuiver, uParaQuiver, vParaQuiver, 'MaxHeadSize', 1);
%set(handleQuiver,'linewidth', 0.01, 'color', 0*[1 1 1]);
%set(handleQuiver,'autoscalefactor', 1);
axis equal
% xlim([0.875*min(coordenadasInterpoladas(:,1)) 1.125*max(coordenadasInterpoladas(:,1))]);
% ylim([0.875*min(coordenadasInterpoladas(:,2)) 1.125*max(coordenadasInterpoladas(:,2))]);
% ylim([-0.125 2.125]);
hold off
handleFigura = gcf;

