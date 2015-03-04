classdef CrankNicolson < Motor

	% CRANKNICOLSON es el motor que procesa la información 
	% utilizando la metodología de cálculo de Crank Nicolson

	properties 

		TipoTemporal
		Solucion	
		Tiempo	
	
	end % properties

	methods

		function thisCrankNicolson = CrankNicolson(simulacion)
	
			thisCrankNicolson;
			thisCrankNicolson.TipoTemporal = 'impermanente';
			thisCrankNicolson = crankNicolson(thisCrankNicolson, simulacion);

		end


		function thisCrankNicolson = crankNicolson(thisCrankNicolson, simulacion)
	
				matrices = simulacion.Matrices;
				M = matrices.M;
				K = matrices.K;
				C = matrices.C;
				forzanteExterno = matrices.f;
				vectorTiempo = matrices.Tiempo;

				if isempty(vectorTiempo)
				% Si es que el vector forzante es permanente

					tFinal = 10000;
					deltaT = 10;
					tiempoCalculo = 0:deltaT:tFinal;
					SOLri = sparse(length(forzanteExterno),length(tiempoCalculo));
					h=waitbar(0,'Please wait..');
					nTiempoCalculo = length(tiempoCalculo);

					for iTiempoCalculo = 2:nTiempoCalculo
						waitbar(iTiempoCalculo/nTiempoCalculo)
						SOLri(:,iTiempoCalculo) = (M/deltaT - 0.5*i*(K + C))\((0.5*i*(K + C) + M/deltaT)*SOLri(:,iTiempoCalculo-1) + forzanteExterno); 
					end

					close(h)

				else
				% Si es que el vector forzante es impermanente


				end % if

				thisCrankNicolson.Solucion = SOLri;
				thisCrankNicolson.Tiempo = tiempoCalculo;

		end % function CrankNicolson
	end % methods
end % classdef
