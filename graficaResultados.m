function handleFigura = graficaResultados(Simulacion, motorDeCalculo, tipoDeGrafico)

cuerpoAGraficar = Simulacion.Cuerpo;

stringAyuda = ['solucionCompleta = Simulacion.Resultados.Hidrodinamica.',motorDeCalculo,'.solucionCompleta;'];
eval(stringAyuda);

mallaStaggered = getMalla(cuerpoAGraficar);
mallaStaggered = mallaStaggered.InformacionMalla;	
Neta = getNumeroNodos(cuerpoAGraficar);

valorAdimensionalizador = 1;

if(strcmp(tipoDeGrafico, 'Concentracion'))
	stringAyuda = ['solucionCompleta(1:Neta) = Simulacion.Resultados.Transporte.',motorDeCalculo,'.concentracionEta;'];
	eval(stringAyuda);
	valorAdimensionalizador = cuerpoAGraficar.Parametros.saturacionOD;
% keyboard
end

if(strcmp(tipoDeGrafico, 'Peclet'))
	stringAyuda = ['solucionCompleta(1:Neta) = Simulacion.Resultados.Transporte.',motorDeCalculo,'.numeroPeclet;'];
	eval(stringAyuda);
% keyboard
end


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
handlePatch = patch(coordenadasX, coordenadasY, valorParaPatch/valorAdimensionalizador);
% handlePatch = patch(coordenadasX, coordenadasY, valorParaPatch/8.82e-3);
shading('interp')
colormap('gray')
hold on

% Grafica el Borde
linewd = 0.5;
bordeSuperficie = cuerpoAGraficar.Geometria.bordeSuperficie;
% plot(bordeSuperficie(:,1)/R, bordeSuperficie(:,2)/R,'k','linewidth',linewd);
plot(bordeSuperficie(:,1), bordeSuperficie(:,2),'k','linewidth',linewd);


% keyboard

% Quiver para velocidad
[xParaQuiver yParaQuiver uParaQuiver vParaQuiver] = puntosParaQuiver(Simulacion, solucionCompleta);
% handleQuiver = quiver(xParaQuiver/R, yParaQuiver/R, uParaQuiver, vParaQuiver, 'MaxHeadSize', 1);
handleQuiver = quiver(xParaQuiver, yParaQuiver, uParaQuiver, vParaQuiver, 'MaxHeadSize', 1);
set(handleQuiver,'linewidth', 0.01, 'color', 0*[1 1 1]);
set(handleQuiver,'autoscalefactor', 1);
axis equal
% xlim([0.875*min(coordenadasInterpoladas(:,1)) 1.125*max(coordenadasInterpoladas(:,1))]);
% ylim([0.875*min(coordenadasInterpoladas(:,2)) 1.125*max(coordenadasInterpoladas(:,2))]);
% ylim([-0.125 2.125]);

clbr = colorbar;
caxisbord = [min(valorInterpolado/valorAdimensionalizador) max(valorInterpolado/valorAdimensionalizador)];
% caxisbord = [min(valorInterpolado/8.82e-3) max(valorInterpolado/8.82e-3)];
caxis(caxisbord)

clbr = colorbar;
if(strcmp(tipoDeGrafico, 'Eta'))
% 	set(get(clbr,'xlabel'),'string','$\eta \eta_{max}^{-1}$','interpreter','latex')
	set(get(clbr,'xlabel'),'string','$\eta$ [m]','interpreter','latex')
elseif(strcmp(tipoDeGrafico, 'Velocidad'))
	set(get(clbr,'xlabel'),'string','$|\vec{v}| [m/s]$','interpreter','latex')
elseif(strcmp(tipoDeGrafico, 'Concentracion'))
	set(get(clbr,'xlabel'),'string','$C C_s^{-1}$','interpreter','latex')
elseif(strcmp(tipoDeGrafico, 'Peclet'))
	set(get(clbr,'xlabel'),'string','$Pe$','interpreter','latex')
end

xlabel('x [m]', 'interpreter', 'latex')
ylabel('y [m]', 'interpreter', 'latex')
box on

hold off
handleFigura = gcf;


