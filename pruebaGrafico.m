clear all 
close all 

%% PRUEBA CRANK NICOLSON%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%55

load 'crankNicolson.mat'

tiempo = simulacionPrueba.CrankNicolson.Tiempo;
solucion = simulacionPrueba.CrankNicolson.Solucion;
neta = getNumeroNodos(simulacionPrueba);
cLimit = max(max(solucion(1:neta,:)));
malla = getMalla(simulacionPrueba);
x = malla.coordenadasEta2DX;
y = malla.coordenadasEta2DY;
u = simulacionPrueba.CrankNicolson.Solucion2D.U;
v = simulacionPrueba.CrankNicolson.Solucion2D.V;
forzante = simulacionPrueba.ListaForzantes{1};
acelx = getAceleracion(forzante);

uplot = squeeze(u(12,12,:));
barraEspera = waitbar(0,'Please wait..');



for iT = ceil(length(tiempo)*0.05) :length(tiempo) 

	waitbar(iT/length(tiempo))
	solucionaux = solucion(:,iT);
	% graficaEta(simulacionPrueba, solucionaux)
	subplot(3,1,1:2)
	graficaModo(simulacionPrueba, solucionaux)
	caxis([-cLimit cLimit])
	hold on
	quiver(x,y,u(:,:,iT),v(:,:,iT), 'color', 0*[1 1 1])
	hold off
	pause(0.01)
%	subplot(3,1,2)
%	plot(tiempo, uplot)
%	hold on
%	scatter(tiempo(iT), uplot(iT))
%	hold off
%	ylabel 'u [m/s]'
	subplot(3,1,3)	
	plot(tiempo, acelx)
	ylim([1.1*min(acelx) 1.1*max(acelx)])
	hold on
	scatter(tiempo(iT), acelx(iT))
	hold off
	ylabel 'a_x [m/s^2]'
	
end
close(barraEspera)



%%%%%%%%%%%%% PRUEBA ANALISIS MODAL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%load 'analisisModal.mat'

%analisisModal = simulacionPrueba.AnalisisModal;
%solucion = analisisModal.Solucion;
%neta = getNumeroNodos(simulacionPrueba);
%cLimit = max(max(solucion(1:neta,:)));

%graficaEta(simulacionPrueba, solucion)
%caxis([-cLimit cLimit])
%hold on
%malla = getMalla(simulacionPrueba);
%x = malla.coordenadasEta2DX;
%y = malla.coordenadasEta2DY;
%u = analisisModal.Solucion2D.U;
%v = analisisModal.Solucion2D.V;
%quiver(x,y,u,v, 'color', 0*[1 1 1])
%hold off

%%%%%%%%%%%%% PRUEBA ANALISIS MODAL IMPERMANENTE%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%load 'analisisModal.mat'

%tiempo = simulacionPrueba.AnalisisModal.Tiempo;
%solucion = simulacionPrueba.AnalisisModal.Solucion;
%neta = getNumeroNodos(simulacionPrueba);
%cLimit = max(max(real(solucion(1:neta,:))));
%malla = getMalla(simulacionPrueba);
%%x = malla.coordenadasEta2DX;
%%y = malla.coordenadasEta2DY;
%%u = simulacionPrueba.CrankNicolson.Solucion2D.U;
%%v = simulacionPrueba.CrankNicolson.Solucion2D.V;

%barraEspera = waitbar(0,'Please wait..');

%for iT = ceil(length(tiempo)*0.85) :length(tiempo) 

%	waitbar(iT/length(tiempo))
%	solucionaux = solucion(:,iT);
%	% graficaEta(simulacionPrueba, solucionaux)
%	graficaModo(simulacionPrueba, solucionaux)
%	caxis([-cLimit cLimit])
%	% hold on
%	% quiver(x,y,u(:,:,iT),v(:,:,iT), 'color', 0*[1 1 1])
%	hold off
%	pause(0.01)
%end
%close(barraEspera)

%%%%%%%%%%%%%% RECORRE MODOS

%load 'analisisModal.mat'

%modos = simulacionPrueba.AnalisisModal.VyVPropios.ProblemaDerecha.Vectores.MasR;
%nModos = length(modos(1,:));

%valores = simulacionPrueba.AnalisisModal.VyVPropios.ProblemaDerecha.Valores.MasR; 

%for iModo = 1:nModos
%	modo = modos(:,iModo);
%	graficaModo(simulacionPrueba, modo)
%	omega = valores(iModo)/(2*pi)*60 %RPM
%	keyboard
%end





