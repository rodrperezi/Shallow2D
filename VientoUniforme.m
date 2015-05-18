classdef VientoUniforme < Forzante

	properties

		uAsterisco
		anguloDireccion

	end %properties

	methods

		function thisVientoUniforme = VientoUniforme(thisVientoUniforme, uAsterisco, anguloDireccion)	
			if nargin == 0
				thisVientoUniforme;
			else
				thisVientoUniforme.uAsterisco = uAsterisco;
				thisVientoUniforme.anguloDireccion = anguloDireccion;
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
