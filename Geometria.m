classdef Geometria < hgsetget

	% GEOMETRIA son las características físicas de un problema.
	% Conceptulamente se entiende que un objeto de la clase
	% está definido por un BORDE que delimita la superficie.
	% Dentro de este borde se construye la MALLA, a partir de la cual 
	% se construye finalmente la BATIMETRIA. Como propiedad numérica
	% tiene el centro de masa de la geometría el cual es un vector del 
	% tipo centroMasa = [x_cm y_cm];
	% 
	% >> properties(Geometria)
	% 
	%	Properties for class Geometria:
	% 
	%	    centroMasa
	%	    Borde
	%	    Malla
	%	    Batimetria
	% 


	properties

		centroMasa % [x_cm y_cm]
		Borde
		Malla
		Batimetria
       
	end
    
	methods

		function thisGeometria = Geometria(thisGeometria, varargin)

			if nargin == 0

				thisGeometria;
	
			else
				for iVariable = 1:nargin
					switch class(varargin{iVariable})
						case 'Borde' 
							thisGeometria.Borde = varargin{iVariable};
						case 'Malla'
							thisGeometria.Malla = varargin{iVariable};
						case 'Batimetria'
							thisGeometria.Batimetria = varargin{iVariable};
						otherwise 
							error(['Wrong input argument: Clase Geometria no trabaja con ', class(varargin{iVariable})])
					end %switch 
				end %for
			end %if
        	 end %function Geometria


		function malla = getMalla(thisGeometria)
			malla = thisGeometria.Malla;
		end


	end %methods
end %classdef

%%%%%%%%% THRASH

	

%		function thisGeometria = construyeKranenburg(thisGeometria, radio, altura, centroMasa)
%			% Función que construye la geometría de Kranenburg (1992)

%%			thisGeometria.tipoGeometria = 'Kranenburg';		
%			parametrosGeometria.Radio = radio;
%			parametrosGeometria.Altura = altura;
%			thisGeometria.parametrosGeometria = parametrosGeometria;
%			thisGeometria.centroMasa = centroMasa;
%			thisGeometria.Borde = generaBordeCircular(Borde(), radio, centroMasa);
%			if isempty(thisGeometria.deltaX)		
%				thisGeometria.deltaX = 0.1*radio;
%				thisGeometria.deltaY = thisGeometria.deltaX;
%			end
%			thisGeometria.Malla = Malla(thisGeometria, 'staggered');
%			thisGeometria.Batimetria = batimetriaKranenburg(Batimetria(), thisGeometria);

%		end %function construyeKranenburg
	

