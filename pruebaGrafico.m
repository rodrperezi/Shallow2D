clear all 
close all 

%% PRUEBA ANALISIS MODAL
%load 'modosPrueba.mat'

%% modoR = 30;
%modoR = 1;
%modos = simulacionPrueba.AnalisisModal.VyVPropios.ProblemaDerecha;
%omegaModo = real(modos.MasR.valores(modoR));
%periodoModo = 2*pi/omegaModo;

%tiempo = 0:2*periodoModo/100:2*periodoModo;

%for iT = 1:length(tiempo)
%	% solucion = modos.MasR.vectores(:,modoR)*exp(i*(modos.MasR.valores(modoR))*tiempo(iT)) + modos.MenosR.vectores(:,modoR)*exp(i*(modos.MenosR.valores(modoR))*tiempo(iT));
%	solucion = modos.MasR.vectores(:,modoR)*exp(i*(modos.MasR.valores(modoR))*tiempo(iT));
%	graficaEta(simulacionPrueba, solucion);
%	colorbar
%	caxis([-0.02 0.02])
%	pause

%end

%% PRUEBA CRANK NICOLSON

load 'crankNicolson.mat'

tiempo = simulacionPrueba.CrankNicolson.Tiempo;
solucion = simulacionPrueba.CrankNicolson.Solucion;

for iT = 1: length(tiempo) 
	solucionaux = solucion(:,iT);
	graficaEta(simulacionPrueba, solucionaux)
	pause
end

