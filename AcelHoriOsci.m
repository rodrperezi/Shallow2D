classdef AcelHoriOsci < Forzante

	properties

		amplitud
		frecAngular
		anguloDireccion
		aceleracion

	end %properties

	methods

		function thisAcelHoriOsci = AcelHoriOsci(thisAcelHoriOsci, amplitud, frecAngular, anguloDireccion)	
			if nargin == 0
				thisAcelHoriOsci;
			else
				thisAcelHoriOsci.amplitud = amplitud;
				thisAcelHoriOsci.frecAngular = frecAngular;
				thisAcelHoriOsci.anguloDireccion = anguloDireccion;
				thisAcelHoriOsci.Tipo = 'acelHoriOsci';
				thisAcelHoriOsci.RegimenTemporal = 'Impermanente';
			end %if
		end %AcelHoriOsci

		function amplitud = getAmplitud(acelHoriOsci)
			amplitud = acelHoriOsci.amplitud;
		end %getAmplitud

		function anguloDireccion = getAnguloDireccion(acelHoriOsci)
			anguloDireccion = acelHoriOsci.anguloDireccion;
		end %getAnguloDireccion

		function frecAngular = getFrecAngular(acelHoriOsci)
			frecAngular = acelHoriOsci.frecAngular;
		end %getFrecAngular

		function aceleracion = getAceleracion(acelHoriOsci)
			aceleracion = acelHoriOsci.aceleracion;
		end %getSerieAceleracion

		function thisAcelHoriOsci = adaptaForzante(thisAcelHoriOsci, thisSimulacion);

			fluido = getFluido(thisSimulacion);
			rho = fluido.densidadRho;
			bat = getCompiladoBatimetria(thisSimulacion);
			malla = getMalla(thisSimulacion);
			Neta = malla.numeroNodosEta;
			Nns = malla.numeroNodosV;
			New = malla.numeroNodosU;

			nCiclos = 5;
			datosPorCiclo = 50;
			amplitud = getAmplitud(thisAcelHoriOsci);			
			frecAngular = getFrecAngular(thisAcelHoriOsci);
			anguloDireccion = getAnguloDireccion(thisAcelHoriOsci);
			thisAcelHoriOsci.Tiempo = 0:(2*pi/frecAngular)/(datosPorCiclo):nCiclos*(2*pi/frecAngular).';
			tiempo = thisAcelHoriOsci.Tiempo;
			batx = bat(Neta + 1: Neta + New);
			baty = bat(Neta + New + 1: New + Neta + Nns);
			thisAcelHoriOsci.aceleracion = -amplitud*frecAngular^2*sin(frecAngular*tiempo);
			thisAcelHoriOsci.DireccionX = -rho*batx*sparse(thisAcelHoriOsci.aceleracion*cos(anguloDireccion));
			thisAcelHoriOsci.DireccionY = -rho*baty*sparse(thisAcelHoriOsci.aceleracion*sin(anguloDireccion));

		end %adaptaForzante 

	end %methods
end %classdef

