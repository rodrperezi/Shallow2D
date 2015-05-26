classdef Geometria < hgsetget

	% GEOMETRIA se entiende como las caracteristicas físicas
	% que identifican a un cuerpo. Entre ellas se incluye el borde,
	% la batimetría,  la malla y otros parametros. 	

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
	

