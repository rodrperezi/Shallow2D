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
		coeficienteFriccion

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

			if isempty(thisVientoUniforme.coeficienteFriccion)
		
				parametros = getParametros(thisSimulacion);
				g = parametros.aceleracionGravedad;
				hom = profundidadMedia(thisSimulacion);
				malla = getMalla(thisSimulacion);
				Lx = max(malla.coordenadasU(:,1)) - ... 	
				     min(malla.coordenadasU(:,1));
				Ly = max(malla.coordenadasV(:,2)) - ... 	
				     min(malla.coordenadasV(:,2));
				L = max([Lx Ly]);

				wed = g*hom^2/(uAsterisco^2*L);
				relAsp = L/hom;
				alpha = 0.0188;
				beta = -0.4765;
				gamma = -0.3804;
				coefEstimado = alpha*(wed^beta)*(relAsp^gamma);
				thisVientoUniforme.coeficienteFriccion = coefEstimado*sqrt(g*hom); 			

%				parametros = getParametros(thisSimulacion);
%				 uTilde = parametros.factorUTilde*uAsterisco;
%				 factorFriccion = parametros.factorFriccion;	
%				 thisVientoUniforme.coeficienteFriccion = sqrt(2)*factorFriccion*uTilde;

%				malla = getMalla(thisSimulacion);
%				Lx = max(malla.coordenadasU(:,1)) - ... 	
%				     min(malla.coordenadasU(:,1));
%				Ly = max(malla.coordenadasV(:,2)) - ... 	
%				     min(malla.coordenadasV(:,2));
%				L = max([Lx Ly]);

				% g = parametros.aceleracionGravedad;
				% hom = profundidadMedia(thisSimulacion);
				% coefA = 1.2308;
				% coefB = -0.6638;
				% wed = g*hom^2/(uAsterisco^2*L);
				% thisVientoUniforme.coeficienteFriccion = sqrt(g*hom)*coefA*froude2^coefB;
				% thisVientoUniforme.coeficienteFriccion = (hom/L)*sqrt(g*hom)*coefA*wed^coefB;
			end


		end %adaptaForzante 
	end %methods
end %classdef
