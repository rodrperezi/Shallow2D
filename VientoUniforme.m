classdef VientoUniforme < Forzante

	% FORZANTE -> VIENTOUNIFORME es un tipo de forzante
	% que caracteriza a un viento que actúa uniformemente 
	% sobre una laguna. 
	% 
	% >> properties(VientoUniforme)
	% 
	%	Properties for class VientoUniforme:
	% 
	%	    uAsterisco
	%	    anguloDireccion
	%	    Tipo
	%	    RegimenTemporal
	%	    Tiempo
	%	    DireccionX
	%	    DireccionY
	% 
	% uAsterisco es la propiedad numérica que caracteriza el esfuerzo 
	% de corte del viento del tipo \tau = \rho uAsterisco^2, 
	% siendo \tau el esfuerzo de corte sobre la superficie y \rho 
	% la densidad del fluido.
	% anguloDireccion es propiedad numérica que indica la dirección 
	% del viento. El ángulo cero está alineado con el sentido positivo
	% del eje X y crece en sentido anti horario. Se expresa en radianes.
	% 
	% Las propiedades numéricas pueden ser asignadas como 
	% 
	% thisVientoUniforme = 
	% VientoUniforme(thisVientoUniforme, 'prop1', valor1, 'prop2', valor2..)
	% 

	properties

		uAsterisco
		anguloDireccion

	end %properties

	methods

		% function thisVientoUniforme = VientoUniforme(thisVientoUniforme, uAsterisco, anguloDireccion)
		function thisVientoUniforme = VientoUniforme(thisVientoUniforme, varargin)		
			if nargin == 0
				thisVientoUniforme;
			else
				thisVientoUniforme = asignaPropNumerica(thisVientoUniforme, varargin{:});
%				thisVientoUniforme.uAsterisco = uAsterisco;
%				thisVientoUniforme.anguloDireccion = anguloDireccion;
				thisVientoUniforme.Tipo = 'vientoUniforme';
				thisVientoUniforme.RegimenTemporal = 'Permanente';
			end %if
		end %VientoUniforme

		function uAsterisco = getUAsterisco(vientoUniforme)
			uAsterisco = vientoUniforme.uAsterisco;
		end

		function anguloDireccion = getAnguloDireccion(vientoUniforme)
			anguloDireccion = vientoUniforme.anguloDireccion;
		end

		function thisVientoUniforme = adaptaForzante(thisVientoUniforme, thisSimulacion);

			fluido = getFluido(thisSimulacion);
			rho = fluido.densidadRho;
			uAsterisco = getUAsterisco(thisVientoUniforme);
			anguloDireccion = getAnguloDireccion(thisVientoUniforme);
			thisVientoUniforme.DireccionX = rho*uAsterisco^2*cos(anguloDireccion);
			thisVientoUniforme.DireccionY = rho*uAsterisco^2*sin(anguloDireccion);

		end %adaptaForzante 
	end %methods
end %classdef
