classdef SerieAceleracionOsci < Forzante

	properties

		amplitud
		frecAngular
		anguloDireccion
		aceleracion

	end %properties

	methods

		function thisSerieAceleracionOsci = SerieAceleracionOsci(thisSerieAceleracion, aceleracion, tiempo, amplitud, frecAngular, anguloDireccion)
	
			if nargin == 0
				thisSerieAceleracionOsci;
			else
				thisSerieAceleracionOsci.amplitud = amplitud;
				thisSerieAceleracionOsci.frecAngular = frecAngular;
				thisSerieAceleracionOsci.aceleracion = aceleracion;
				thisSerieAceleracionOsci.Tiempo = tiempo;
				thisSerieAceleracionOsci.anguloDireccion = anguloDireccion;
				thisSerieAceleracionOsci.Tipo = 'serieAceleracionOsci';
				thisSerieAceleracionOsci.RegimenTemporal = 'Impermanente';
			end %if
		end %SerieAceleracion

		function aceleracion = getAceleracion(serieAceleracionOsci)
			aceleracion = serieAceleracionOsci.aceleracion;
		end %getAceleracion

		function anguloDireccion = getAnguloDireccion(serieAceleracionOsci)
			anguloDireccion = serieAceleracionOsci.anguloDireccion;
		end %getAnguloDireccion

		function tiempo = getTiempo(serieAceleracionOsci)
			tiempo = serieAceleracionOsci.Tiempo;
		end %getTiempo

		function amplitud = getAmplitud(serieAceleracionOsci)
			amplitud = serieAceleracionOsci.amplitud;
		end %getAmplitud

		function frecAngular = getFrecAngular(serieAceleracionOsci)
			frecAngular = serieAceleracionOsci.frecAngular;
		end %getFrecAngular

		function thisSerieAceleracionOsci = adaptaForzante(thisSerieAceleracionOsci, thisSimulacion);

			fluido = getFluido(thisSimulacion);
			rho = fluido.densidadRho;
			bat = getCompiladoBatimetria(thisSimulacion);
			malla = getMalla(thisSimulacion);
			Neta = malla.numeroNodosEta;
			Nns = malla.numeroNodosV;
			New = malla.numeroNodosU;

			anguloDireccion = getAnguloDireccion(thisSerieAceleracionOsci);
			tiempo = getTiempo(thisSerieAceleracionOsci);
			aceleracion = getAceleracion(thisSerieAceleracionOsci)';
			batx = bat(Neta + 1: Neta + New);
			baty = bat(Neta + New + 1: New + Neta + Nns);
			thisSerieAceleracionOsci.DireccionX = -rho*batx*aceleracion*cos(anguloDireccion);
			thisSerieAceleracionOsci.DireccionY = -rho*baty*aceleracion*sin(anguloDireccion);

		end %adaptaForzante 

	end %methods
end %classdef

