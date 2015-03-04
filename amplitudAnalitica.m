clear all 
close all 

load simulacionExperimento

valoresPropiosDerechos = cuerpoExperimento.valoresVectoresPropios.valoresPropios.derechos;
valoresPropiosIzquierdos =  cuerpoExperimento.valoresVectoresPropios.valoresPropios.izquierdos;
vectoresPropiosDerechos = cuerpoExperimento.valoresVectoresPropios.vectoresPropios.derechos;
vectoresPropiosIzquierdos =  cuerpoExperimento.valoresVectoresPropios.vectoresPropios.izquierdos;

[valoresAyuda Indices] = sort(abs(real(valoresPropiosDerechos)),'descend');
valoresPropiosDerechosOrdenados = valoresPropiosDerechos(Indices);
vectoresPropiosDerechosOrdenados = vectoresPropiosDerechos(:,Indices);

indiceOmegaNoNulo = find(valoresAyuda ~= 0);

valoresPropiosNoNulos = valoresPropiosDerechosOrdenados(indiceOmegaNoNulo);
vectoresPropiosNoNulos = vectoresPropiosDerechosOrdenados(:, indiceOmegaNoNulo);

indiceOmegaPositivo = find(real(valoresPropiosNoNulos) > 0);

valoresPropiosOmegaPositivo = valoresPropiosNoNulos(indiceOmegaPositivo);
vectoresPropiosOmegaPositivo = vectoresPropiosNoNulos(:,indiceOmegaPositivo);

[valoresPropiosOmegaPositivo Indices]= sort(abs(real(valoresPropiosOmegaPositivo)), 'ascend');
vectoresPropiosOmegaPositivo = vectoresPropiosOmegaPositivo(:, Indices);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

iModo = 2;
muestraModo = iModo;
omegaModo = abs(real(valoresPropiosOmegaPositivo(muestraModo)));
gammaModo = imag(valoresPropiosOmegaPositivo(muestraModo));
estructuraModo = vectoresPropiosOmegaPositivo(:, muestraModo);
tiempoFinal = 2*(2*pi/omegaModo);
time = 0:tiempoFinal/100:tiempoFinal;


rpm = 65;
omegaForzante = 2*pi*rpm/60;
% omegaForzante = omegaModo;
% omegaModo = ;
% gammaModo = ;
amplitudOscilacion = 0.006; %metros
deltaX = cuerpoExperimento.Geometria.deltaX;
deltaY = deltaX;
nodosEta = cuerpoExperimento.Geometria.Malla.InformacionMalla.numeroNodosEta;
areaHoya = nodosEta*deltaX*deltaY;
% batimetriaU = cuerpoExperimento.Geometria.batimetriaKranenburg.hoU;
% batimetriaV = cuerpoExperimento.Geometria.batimetriaKranenburg.hoV;
% batimetriaVelocidad = [batimetriaU; batimetriaV];
batimetriaVelocidad = cuerpoExperimento.Matrices.batimetria;
cTilde = dot(estructuraModo, amplitudOscilacion*omegaForzante^2*batimetriaVelocidad)*areaHoya;
% tiempo = ;
% cTilde = dot(estructuraModo, amplitudOscilacion*omegaForzante^2*batimetriaVelocidad);


solucionAmplitudAnalitica = inline('-0.5*cTilde*omegaModo*(exp(i*omegaForzante*tiempo)/(omegaForzante - omegaModo - i*gammaModo) + exp(-i*omegaForzante*tiempo)/(omegaForzante + omegaModo + i*gammaModo))', 'cTilde', 'omegaModo', 'omegaForzante', 'gammaModo', 'tiempo');


for iTiempo = 1:length(time)
%	figure(1)

	amplitud = solucionAmplitudAnalitica(cTilde, omegaModo, omegaForzante, gammaModo, time(iTiempo));
	solucionModo = real(amplitud*estructuraModo);
% 	graficaModo(simulacionExperimento, solucionModo, 'Eta')	
%	title(['t = ', num2str(time(iTiempo)),'[s]'])
%	xlabel 'x [m]'
%	ylabel 'y [m]'
	
	figure(2)
	title(['t = ', num2str(time(iTiempo)),'[s]'])
	sp(1) = subplot(2,1,1);
	graficaPerfilTransversal(simulacionExperimento, solucionModo, 'Eta') %seccion central dado Y
	ylabel 'eta [m]'
	xlabel 'x [m]'
	
	ylim([-5 5]/1000)	
	xlim([-0.2 0.2])


	sp(2) = subplot(2,1,2);
	graficaPerfilTransversal(simulacionExperimento, solucionModo, 'velocidadU') %seccion central dado Y
	ylabel 'u [m/s]'
	xlabel 'x [m]'
% 	vel = get(gca, 'children');
	h = findobj(gca,'Type','line');
	x=get(h,'Xdata');
	y=get(h,'Ydata');

	% keyboard
	title(['ucentral = ', num2str(y(10)),'[m/s]'])

	ylim([-20 20]/100)
	xlim([-0.2 0.2])

	pause
	% clf(1)

end











