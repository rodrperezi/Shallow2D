clear all 
close all 

set(0,'DefaultAxesFontName', 'times')
set(0,'DefaultAxesFontSize', 9)

set(0,'DefaultTextFontname', 'times')
set(0,'DefaultTextFontSize', 9)

% cd Modelo

R = 0.18;
H = 0.03;

uAsteriscoViento = [0.0056, 0.01, 0.012, 0.0141]*100; %m/s

cuerpoPrueba = Cuerpo;
cuerpoPrueba.Geometria = Geometria(R, H, [0,0]);
cuerpoPrueba.Forzante = Forzante('vientoUniforme','uAsterisco', uAsteriscoViento(1), 'anguloViento', pi/2);
simulacionPrueba1 = Simulacion(cuerpoPrueba,'AnalisisModal');
% simulacionPrueba1 = Simulacion(simulacionPrueba1,'CrankNicolson');
%simulacionPrueba1 = Simulacion(simulacionPrueba1,'VolumenesFinitos');

%subplot(2,2,1)

%graficaResultados(simulacionPrueba1, 'AnalisisModal','Peclet')


%for iUasterisco = 2:length(uAsteriscoViento)

%	% figure
%	subplot(2,2,iUasterisco)
%	simulacionPrueba2 = simulacionPrueba1;
%	simulacionPrueba2.Cuerpo.Forzante = Forzante('vientoUniforme','uAsterisco',  uAsteriscoViento(iUasterisco), 'anguloViento', pi/2);
%	simulacionPrueba2 = Simulacion(simulacionPrueba2,'AnalisisModal');
%	simulacionPrueba2 = Simulacion(simulacionPrueba2,'VolumenesFinitos');
%	
%	% graficaResultados(simulacionPrueba2, 'AnalisisModal','Concentracion')
%	graficaResultados(simulacionPrueba2, 'AnalisisModal','Peclet')

%end


%figure

%subplot(2,2,1)

%graficaResultados(simulacionPrueba1, 'AnalisisModal','Concentracion')

%for iUasterisco = 2:length(uAsteriscoViento)

%	% figure
%	subplot(2,2,iUasterisco)
%	simulacionPrueba2 = simulacionPrueba1;
%	simulacionPrueba2.Cuerpo.Forzante = Forzante('vientoUniforme','uAsterisco',  uAsteriscoViento(iUasterisco), 'anguloViento', pi/2);
%	simulacionPrueba2 = Simulacion(simulacionPrueba2,'AnalisisModal');
%	simulacionPrueba2 = Simulacion(simulacionPrueba2,'VolumenesFinitos');
%	
%	graficaResultados(simulacionPrueba2, 'AnalisisModal','Concentracion')
%	% graficaResultados(simulacionPrueba2, 'AnalisisModal','Peclet')

%end













% simulacionPrueba2 = Simulacion(simulacionPrueba1,'CrankNicolson');
% graficaResultados(cuerpoPrueba, 'etaVelocidad');
% subplot(1,2,1)
% graficaResultados(simulacionPrueba1, 'AnalisisModal', 'Eta')
% subplot(1,2,2)
% graficaResultados(simulacionPrueba2, 'CrankNicolson', 'Eta')




% valoresPropios = simulacionPrueba1.Cuerpo.valoresVectoresPropios.valoresPropios.derechos;
% vectoresPropios = simulacionPrueba1.Cuerpo.valoresVectoresPropios.vectoresPropios.derechos; 
% [valoresPropiosAyuda Indices] = sort(abs(real(valoresPropios)),'descend');

% valoresPropiosOrdenados = valoresPropios(Indices);
% vectoresPropiosOrdenados = vectoresPropios(:,Indices);

% modoMuestra = 141;
% omegaModo = abs(real(valoresPropiosOrdenados(modoMuestra)));
% gammaModo = imag(valoresPropiosOrdenados(modoMuestra));
% estructuraModo = vectoresPropiosOrdenados(:, modoMuestra);
% tiempoFinal = 2*(2*pi/omegaModo);
% time = 0:tiempoFinal/40:tiempoFinal;

% for iTime = 1:length(time)
% 	solucionModo = real(estructuraModo*exp(i*(omegaModo + i*gammaModo)*time(iTime)));
% 	graficaModo(simulacionPrueba1, solucionModo, 'Eta')	
% 	colorbar
	% graficaModo(solucionModo)
% 	pause
% end



