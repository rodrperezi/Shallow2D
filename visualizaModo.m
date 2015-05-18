clear all 
close all 

load 'MODOS.mat'

	
	modo = 350;
	tFinal = 2*periodoModo(modo);
	tiempo = 0:tFinal/100:tFinal;

	malla = getMalla(sim);
	Neta = malla.numeroNodosEta;

	cLimit = max(max(real(VamNorm(1:Neta,modo)*exp((Dam(modo))*tiempo))));
	% cLimit = real(min(min(VamNorm(1:Neta,modo)*exp((Dam(modo))*tiempo))));

	h=waitbar(0,'Please wait..');

	for iT = 1:length(tiempo)
		waitbar(iT/length(tiempo))
		graficaModo(sim, VamNorm(:,modo)*exp(real(Dam(modo))*tiempo(iT)))
		caxis([-cLimit cLimit])
		pause(0.01)
	end

	close(h)

