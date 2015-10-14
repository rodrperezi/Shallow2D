classdef CrankNicolson < Hidrodinamica

	% HIDRODINAMICA -> CRANKNICOLSON es uno de los motores 
	% que resuelven el flujo hidrodinámico utilizando 
	% la metodología impermanente de Crank Nicolson
	% 
	% Construcción:
	% 
	% Actualmente el constructor de la clase sólo requiere
	% como entrada un objeto de clase SIMULACION de la forma 
	% 
	% 	thisCrankNicolson = CrankNicolson(simulacion)
	% 
	% Por ahora, la metodología de cálculo incluye un vector
	% de tiempo arbitrario para el caso en que el forzante
	% es constante. Lo ideal sería implementar una forma
	% de construcción tal que se pueda especificar el vector de tiempo
	% o que este se construya a partir de algunos parámetros 
	% característicos del problema que se esté resolviendo.
	% Sin embargo, en el caso que el forzante es impermanente como 
	% es el caso de una serie de aceleración o de viento, el motor
	% resuelve las ecuaciones utilizando el vector de tiempo especificado
	% en el forzante.
	% 
	% Propiedades:
	% 
	% >> properties(CrankNicolson)
	%
	%	Properties for class CrankNicolson:
	%
	%	    tiempoComputo
	%	    RegimenTemporal
	%	    Solucion
	%	    Solucion2D
	%	    Tiempo
	%	    Tipo

	properties 

	%	RegimenTemporal
	%	Solucion
	%	Solucion2D	
	%	Tiempo	
		tiempoComputo	

	end % properties

	methods

		function thisCrankNicolson = CrankNicolson(simulacion)
		% function thisCrankNicolson = CrankNicolson(simulacion)	
		% Constructor de la clase
		% 
		% Hacer que al llamar al constructor, se pueda especificar
		% el tiempo inicial, tiempo final y el deltaT. Si especifico
		% el tiempo inicial, entonces debo especificar la condición inicial

			if nargin == 0
				thisCrankNicolson;
			else
				tic
				thisCrankNicolson.Tipo = 'CrankNicolson';
				thisCrankNicolson.RegimenTemporal = 'impermanente';
				thisCrankNicolson = crankNicolson(thisCrankNicolson, simulacion);
				thisCrankNicolson.tiempoComputo = toc;
			end %if
		end %CrankNicolson


		function thisCrankNicolson = crankNicolson(thisCrankNicolson, simulacion)
		% function thisCrankNicolson = crankNicolson(thisCrankNicolson, simulacion)
		% Función que resuelve la simulación utilizando la metodología
		% de CrankNicolson.

				[M, K, C] = getMatrices(simulacion);
				matrices = simulacion.Matrices;
				forzanteExterno = matrices.f;
				vectorTiempo = matrices.Tiempo;


				if(isempty(vectorTiempo))

					% Si el forzante es constante en el tiempo. 
					% Entonces creo un vector de tiempo arbitrario
					% basado en una escala de tiempo caracteristica del 
					% problema. Se considera el periodo de la onda mas 
					% larga T = 2L/sqrt(g*mean(ho))
					% keyboard

					malla = getMalla(simulacion);
					Lx = max(malla.coordenadasU(:,1)) - ... 	
					     min(malla.coordenadasU(:,1));
					Ly = max(malla.coordenadasV(:,2)) - ... 	
					     min(malla.coordenadasV(:,2));
					L = max([Lx Ly]);

					par = getParametros(simulacion);
					g = par.aceleracionGravedad;
		
					bat = getBatimetria(simulacion);
					hom = mean(bat.hoNodosEta);

					TCarac = 2*L/sqrt(g*hom);
					tiempoCalculo = (0:0.05:65)*TCarac; 
					% Este vector de tiempo ha resuelto 
					% satisfactoriamente casos para Wed < 3700
					% Se probó con dt = 0.01 y no hubo cambios
					% importantes en la solución. Sin embargo
					% lo ideal sería definir el tiempo 
					% caracteristico del problema en función 
					% del numero de Wedderburn, ya que incluye
					% el efecto del viento. Revisar			
				
					deltaT = abs(tiempoCalculo(1)-tiempoCalculo(2));
					nTiempoCalculo = length(tiempoCalculo);
					forzanteExterno = repmat(forzanteExterno, 1, nTiempoCalculo);
					% keyboard

				else

					% Si el forzante varía en el tiempo. 
					% Entonces tomo los datos de tiempo del forzante

					tiempoCalculo = vectorTiempo;
					deltaT = abs(tiempoCalculo(1)-tiempoCalculo(2));
					nTiempoCalculo = length(tiempoCalculo);

				end


				% barraEspera = waitbar(0,'Resolviendo hidrodinámica con Crank Nicolson...');
				SOLri = sparse(length(forzanteExterno(:,1)),length(tiempoCalculo));

				for iTiempo = 2:nTiempoCalculo
					% waitbar(iTiempo/nTiempoCalculo)
					% iTiempo/nTiempoCalculo
					fExtTmUno = forzanteExterno(:, iTiempo-1);
					fExtT = forzanteExterno(:, iTiempo);
					fExternoProm = 0.5*(fExtTmUno + fExtT); 
					SOLri(:,iTiempo) = (M/deltaT - 0.5*i*(K + C))\((0.5*i*(K + C) + M/deltaT)*SOLri(:,iTiempo-1) + fExternoProm); 
				end

				% close(barraEspera)

				thisCrankNicolson.Solucion = SOLri;
				thisCrankNicolson.Tiempo = tiempoCalculo;

		end % function CrankNicolson
	end % methods
end % classdef
