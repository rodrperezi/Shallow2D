classdef CrankNicolson < Hidrodinamica

	% CRANKNICOLSON es el motor que procesa la información 
	% utilizando la metodología de cálculo de Crank Nicolson

	properties 

		RegimenTemporal
		Solucion
		Solucion2D	
		Tiempo	
	
	end % properties

	methods

		function thisCrankNicolson = CrankNicolson(simulacion)
		% function simulacion = CrankNicolson(simulacion)
	
			thisCrankNicolson;
			thisCrankNicolson.RegimenTemporal = 'impermanente';
			thisCrankNicolson = crankNicolson(thisCrankNicolson, simulacion);
			[Solucion2D.Eta Solucion2D.U Solucion2D.V] = solucion2D(simulacion, thisCrankNicolson.Solucion);
			thisCrankNicolson.Solucion2D = Solucion2D;

		end


		function thisCrankNicolson = crankNicolson(thisCrankNicolson, simulacion)
	
				[M, K, C] = getMatrices(simulacion);
				matrices = simulacion.Matrices;
				forzanteExterno = matrices.f;
				vectorTiempo = matrices.Tiempo;


				if(isempty(vectorTiempo))

					% Si el forzante es constante en el tiempo. 
					% Entonces creo un vector de tiempo arbitrario

					tFinal = 20000; %segundos
					deltaT = 20; %segundos
					tiempoCalculo = 0:deltaT:tFinal;
					nTiempoCalculo = length(tiempoCalculo);
					forzanteExterno = repmat(forzanteExterno, 1, nTiempoCalculo);

				else

					% Si el forzante varía en el tiempo. 
					% Entonces tomo los datos de tiempo del forzante

					tiempoCalculo = vectorTiempo;
					deltaT = abs(tiempoCalculo(1)-tiempoCalculo(2));
					nTiempoCalculo = length(tiempoCalculo);

				end


				barraEspera = waitbar(0,'Please wait..');
				SOLri = sparse(length(forzanteExterno(:,1)),length(tiempoCalculo));

				for iTiempo = 2:nTiempoCalculo
					waitbar(iTiempo/nTiempoCalculo)
					fExtTmUno = forzanteExterno(:, iTiempo-1);
					fExtT = forzanteExterno(:, iTiempo);
					fExternoProm = 0.5*(fExtTmUno + fExtT); 
					SOLri(:,iTiempo) = (M/deltaT - 0.5*i*(K + C))\((0.5*i*(K + C) + M/deltaT)*SOLri(:,iTiempo-1) + fExternoProm); 
				end

				close(barraEspera)

				thisCrankNicolson.Solucion = SOLri;
				thisCrankNicolson.Tiempo = tiempoCalculo;
				% simulacion.CrankNicolson = thisCrankNicolson;

		end % function CrankNicolson
	end % methods
end % classdef
