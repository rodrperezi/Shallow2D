classdef Forzante

	% FORZANTE es un tipo de forzante externo sobre el fluido.
	% Por ahora tiene solo dos tipos de forzante externo.
	%
	% vientoUniforme: caracterizado por uAsteriscoViento constante en el espacio.
	% oscilacionHorizontalX: Genera un oscilador que sigue la función:
	%
	%               x(t) = amplitudOscilador*sin(omegaOscilador*tiempo)
	% 
	% El forzante está hecho de manera que pueda ser utilizado en el análisis modal.
	% En el caso de tener un forzante de tipo vientoUniforme, el nombre del parámetro 
	% caracteristico deberá ser uAsterisco_anguloViento y su valor entregado en unidades SI (m/s) 
        % para el uAsterisco y en rad para el angulo de desviación. En la direccion positiva del eje x
        % el angulo es cero y crece positivamente en el sentido contrario de las manecillas del reloj
	% Si el forzante es una oscilación horizontal entonces el nombre del parámetro 
	% caracteristico deberá ser amplitud_frecuencia y se entrega un vector de 
	% 1 fila y dos columnas en donde la primera columna contiene la amplitud de oscilación en 	
	% unidades SI (m) y la segunda tiene la frecuencia de oscilación en rad/s.

	properties
		tipoForzante
		parametroCaracteristico1
		valorParametroCaracteristico1
		parametroCaracteristico2
		valorParametroCaracteristico2
		% vectorMagnitudForzante
	end

	methods

		function this_forzante = Forzante(tipoForzante, parametroCaracteristico1, valorParametroCaracteristico1, parametroCaracteristico2, valorParametroCaracteristico2 )
			
			if(nargin ~= 5)
				error('myapp:Chk','Wrong number of input arguments: Deberían ser cinco input')
			elseif(strcmpi(tipoForzante, 'vientoUniforme') && strcmpi(parametroCaracteristico1, 'uAsterisco') && strcmpi(parametroCaracteristico2, 'anguloViento'))

                                % if(length(valorParametroCaracteristico) ~= 2)
				% 	error('myapp:Chk','Wrong number of input arguments: Falta especificar un parámetro del viento')
				% else
		 		        this_forzante.tipoForzante = tipoForzante;
		 		        this_forzante.parametroCaracteristico1 = parametroCaracteristico1;
		 		        this_forzante.valorParametroCaracteristico1 = valorParametroCaracteristico1;
		 		        this_forzante.parametroCaracteristico2 = parametroCaracteristico2;
		 		        this_forzante.valorParametroCaracteristico2 = valorParametroCaracteristico2;

                                % end        

			elseif(strcmpi(tipoForzante, 'oscilacionHorizontalX') && strcmpi(parametroCaracteristico, 'amplitud_frecuencia'))

% 				if(length(valorParametroCaracteristico) ~= 2)
% 					error('myapp:Chk','Wrong number of input arguments: Falta especificar un parámetro de la oscilación')			
  %                               else
%			 		this_forzante.tipoForzante = tipoForzante;
%			 		this_forzante.parametroCaracteristico = parametroCaracteristico;
%  				 	this_forzante.valorParametroCaracteristico = valorParametroCaracteristico;
		 		        this_forzante.tipoForzante = tipoForzante;
		 		        this_forzante.parametroCaracteristico1 = parametroCaracteristico1;
		 		        this_forzante.valorParametroCaracteristico1 = valorParametroCaracteristico1;
		 		        this_forzante.parametroCaracteristico2 = parametroCaracteristico2;
		 		        this_forzante.valorParametroCaracteristico2 = valorParametroCaracteristico2;

% 				end
			else 
				error('myapp:Chk','Wrong name of input arguments: Alguno de los nombres está mal escrito')
			end
		end	
	end
end

	



