classdef Forzante < hgsetget

	% FORZANTE es el objeto que caracteriza a un forzante
	% que actúa sobre un cuerpo de fluido. 
	% 
	% >> properties(Forzante)
	% 
	%	Properties for class Forzante:
	% 
	%	    Tipo
	%	    RegimenTemporal
	%	    Tiempo
	%	    DireccionX
	%	    DireccionY
	% 
	% Tipo es el nombre del forzante o clase de forzante, RegimenTemporal
	% especifica si el forzante es permanente o impermanente, Tiempo
	% contiene el vector de tiempo en el caso que el forzante sea 
	% impermanente y es vacío en el caso de que el forzante sea permanente
	% DireccionX y DireccionY caracteriza la magnitud del forzante 
	% en el eje respectivo.

	properties

		Tipo
		RegimenTemporal
		Tiempo
		DireccionX		
		DireccionY

	end %properties

	methods

		function thisForzante = Forzante()
			thisForzante;
		end %function Forzante

		function objetoForzante = getObjetoForzante(forzante)
			objetoForzante = forzante.ObjetoForzante;
		end %getObjetoForzante

	end %methods
end %classdef

	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% THRASH

%		function thisForzante = vientoUniforme(thisForzante, uAsterisco, anguloDireccion)
%			% El viento se entiende como visto desde el fluido
%			% por lo tanto el uAsterisco debe ser expresado 
%			% en esos términos.
%			% El forzante se describe en términos de uAsterisco^2.
%			% Este parámetro se multiplica por rho una vez que
%			% el forzante se asigna a la simulacion, desde donde 
%			% se puede extraer la densidad del fluido.
%			thisForzante.Tipo = 'vientoUniforme';
%			thisForzante.ObjetoForzante = VientoUniforme(VientoUniforme(), uAsterisco, anguloDireccion);
%			thisForzante.RegimenTemporal = 'Permanente';
%			% parametros.uAsterisco = uAsterisco;
%			% parametros.anguloDireccion = anguloDireccion;
%			% thisForzante.Parametros = parametros;
%			% thisForzante.DireccionX = uAsterisco^2*cos(anguloDireccion);
%			% thisForzante.DireccionY = uAsterisco^2*sin(anguloDireccion);
%			
%		end
%		function thisForzante = aceleracionHorizontalOscilatoria(thisForzante, amplitud, omegaOscilacion, anguloDireccion)
%			% AQUI FALTA MULTIPLICAR EL VECTOR DE ACELERACION POR LA PROFUNDIDAD
%			thisForzante.Tipo = 'aceleracionHorizontalOscilatoria';
%			parametros.amplitud = amplitud;
%			parametros.omegaOscilacion = omegaOscilacion;
%			thisForzante.Parametros = parametros;
%			thisForzante.RegimenTemporal = 'Impermanente';
%			nCiclos = 4;
%			datosPorCiclo = 20;
%			thisForzante.Tiempo = 0:(2*pi/omegaOscilacion)/(datosPorCiclo):nCiclos*(2*pi/omegaOscilacion).';
%			tiempo = thisForzante.Tiempo;
%			thisForzante.DireccionX = sparse(amplitud*omegaOscilacion^2*sin(omegaOscilacion*tiempo)*cos(anguloDireccion));
%			thisForzante.DireccionY = sparse(amplitud*omegaOscilacion^2*sin(omegaOscilacion*tiempo)*sin(anguloDireccion));
%		end

%		function thisForzante = aceleracionHorizontal(thisForzante, magnitud, anguloDireccion)
%			% FALTA LO MISMO QUE EN LA ACELERACION ANTERIOR
%			thisForzante.Tipo = 'aceleracionHorizontal';
%			parametros.magnitud = magnitud;
%			thisForzante.Parametros = parametros;
%			thisForzante.RegimenTemporal = 'Permanente';
%			thisForzante.DireccionX = magnitud*cos(anguloDireccion);
%			thisForzante.DireccionY = magnitud*sin(anguloDireccion);
%		end

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

%		function thisForzante = serieViento(thisForzante, archivo, anguloDireccion)
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
