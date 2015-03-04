classdef Geometria < hgsetget

	% GEOMETRIA se entiende como las caracteristicas físicas
	% que identifican a un cuerpo. Entre ellas se incluye el borde,
	% la batimetría,  la malla y otros parametros. En este caso 
	% la Geometria esta especialmente adecuada a kranenburg.	

	properties

		tipoGeometria
		centroMasa 
		parametrosGeometria
		Borde
		Malla
		Batimetria
		deltaX
		deltaY
       
	    end
    
	methods

		function thisGeometria = Geometria(varargin)
		% function thisGeometria = Geometria()    
		% Constructor del objeto Geometria
	
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
	

		function thisGeometria = construyeKranenburg(thisGeometria, radio, altura, centroMasa)
			% function thisGeometria = construyeKranenburg(thisGeometria, radio, altura, centroMasa)
			% Función que construye la geometría de Kranenburg (1992)

			thisGeometria.tipoGeometria = 'Kranenburg';		
			parametrosGeometria.Radio = radio;
			parametrosGeometria.Altura = altura;
			thisGeometria.parametrosGeometria = parametrosGeometria;
			thisGeometria.centroMasa = centroMasa;
			thisGeometria.Borde = generaBordeCircular(Borde(), radio, centroMasa);
			thisGeometria.deltaX = 0.25*radio;
			thisGeometria.deltaY = thisGeometria.deltaX;
			thisGeometria.Malla = Malla(thisGeometria, 'staggered');
			thisGeometria.Batimetria = batimetriaKranenburg(Batimetria(), thisGeometria);

		end %function construyeKranenburg
	end %methods
end %classdef
