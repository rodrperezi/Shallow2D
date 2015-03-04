classdef Forzante < hgsetget

	properties

		Tipo
		TipoTemporal
		Parametros
		Tiempo
		DireccionX		
		DireccionY


	end %properties


	methods

		function thisForzante = Forzante()
			thisForzante;
		end %function Forzante

		function thisForzante = vientoUniforme(thisForzante, uAsterisco, anguloDireccion)
			thisForzante.Tipo = 'vientoUniforme';
			parametros.uAsterisco = uAsterisco;
			parametros.anguloDireccion = anguloDireccion;
			thisForzante.Parametros = parametros;
			thisForzante.TipoTemporal = 'Permanente';
			rho = 1000;
			thisForzante.DireccionX = rho*uAsterisco^2*cos(anguloDireccion);
			thisForzante.DireccionY = rho*uAsterisco^2*sin(anguloDireccion);
			% obtener rho desde el fluido del cuerpo
		end

		function thisForzante = aceleracionHorizontalOscilatoria(thisForzante, amplitud, omegaOscilacion, anguloDireccion)
			thisForzante.Tipo = 'aceleracionHorizontalOscilatoria';
			parametros.amplitud = amplitud;
			parametros.omegaOscilacion = omegaOscilacion;
			thisForzante.Parametros = parametros;
			thisForzante.TipoTemporal = 'Impermanente';
			nCiclos = 4;
			datosPorCiclo = 20;
			thisForzante.Tiempo = 0:(2*pi/omegaOscilacion)/(datosPorCiclo):nCiclos*(2*pi/omegaOscilacion).';
			tiempo = thisForzante.Tiempo;
			thisForzante.DireccionX = sparse(amplitud*omegaOscilacion^2*sin(omegaOscilacion*tiempo)*cos(anguloDireccion));
			thisForzante.DireccionY = sparse(amplitud*omegaOscilacion^2*sin(omegaOscilacion*tiempo)*sin(anguloDireccion));
		end

		function thisForzante = aceleracionHorizontal(thisForzante, magnitud, anguloDireccion)
			thisForzante.Tipo = 'aceleracionHorizontal';
			parametros.magnitud = magnitud;
			thisForzante.Parametros = parametros;
			thisForzante.TipoTemporal = 'Permanente';
			thisForzante.DireccionX = magnitud*cos(anguloDireccion);
			thisForzante.DireccionY = magnitud*sin(anguloDireccion);
		end

		% Esta funcion es critica, asi que no olvidarla

%		function thisForzante = serieAceleracion(thisForzante, archivo, anguloDireccion)
%			thisForzante.Tipo = 'aceleracionHorizontal';
%			parametros.amplitud = amplitud;
%			parametros.omegaOscilacion = omegaOscilacion;
%			thisForzante.Parametros = parametros;
%			thisForzante.TipoTemporal = 'Impermanente';
%			nCiclos = 4;
%			datosPorCiclo = 10;
%			thisForzante.Tiempo = 0:(2*pi/omegaOscilacion)/(datosPorCiclo):nCiclos*(2*pi/omegaOscilacion);
%			tiempo = thisForzante.Tiempo;
%			thisForzante.DireccionX = amplitud*omegaOscilacion^2*sin(omegaOscilacion*tiempo)*cos(anguloDireccion);
%			thisForzante.DireccionY = amplitud*omegaOscilacion^2*sin(omegaOscilacion*tiempo)*sin(anguloDireccion);
%		end


	end %methods
end %classdef

	


