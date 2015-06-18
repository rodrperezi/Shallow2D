classdef Cuerpo < hgsetget
	 
	% CUERPO es un cuerpo de fluido. Conceptualmente está definido	
	% por la GEOMETRIA que contiene un FLUIDO y para los cuales 
	% se utiliza un set de PARAMETROS para resolver el problema. 
	% 
	% >> properties(Cuerpo)  
	% 
	%	Properties for class Cuerpo:
	% 
	%	    Geometria
	%	    Fluido
	%	    Parametros
	%	    ID
	% 
	% Los componentes anteriores contienen la información necesaria
	% y detallada de las variables hidrodinámicas y numéricas.
	% 
	% Construcción:
	% 
	% Por defecto, un cuerpo se construye con los parámetros
	% especificados en la clase PARAMETROS y con agua como 
	% objeto de la clase FLUIDO. Estas propiedades pueden 
	% ser modificadas. En este caso, sólo resta especficar 
	% la GEOMETRIA para que el cuerpo quede correctamente definido.
	% 
	% thisCuerpo = Cuerpo(thisCuerpo, geo);
	% thisCuerpo = addGeometria(thisCuerpo, geo);
	% thisCuerpo.Geometria = geo;
	% 
	% En caso de querer asignar o modificar alguna de las otras propiedades
	% estas se pueden asignar usando el constructor del objeto:
	% 
	% thisCuerpo = Cuerpo(thisCuerpo, fluido, parametros)
        
	 properties
     
		Geometria 
		Fluido
		Parametros
		ID
        
	end
    
	methods

	        function thisCuerpo = Cuerpo(thisCuerpo, varargin)

			if nargin == 0

				thisCuerpo;
				thisCuerpo.Parametros = Parametros();			
				thisCuerpo.Fluido = Fluido('Agua', thisCuerpo.Parametros.densidadRho, thisCuerpo.Parametros.viscosidadNu);

			else

				thisCuerpo.Parametros = Parametros();			
				thisCuerpo.Fluido = Fluido('Agua', thisCuerpo.Parametros.densidadRho, thisCuerpo.Parametros.viscosidadNu);

				for iVariable = 1:length(varargin)
					switch class(varargin{iVariable})
						case 'Geometria' 
							thisCuerpo.Geometria = varargin{iVariable};
						case 'GeoKranenburg' 
							thisCuerpo.Geometria = varargin{iVariable};
						case 'Parametros'
							thisCuerpo.Parametros = varargin{iVariable};
						case 'Fluido'
							thisCuerpo.Fluido = varargin{iVariable};
						otherwise 
							error(['Clase cuerpo no trabaja con ', class(varargin{iVariable})])
					end %switch 
				end %for
			end %if
	       	end % function Cuerpo

		function thisCuerpo = addGeometria(thisCuerpo, geometria)
				
			thisCuerpo.Geometria = geometria;			
					
		end %function addGeometria


		function malla = getMalla(cuerpo)
				
			malla = cuerpo.Geometria.Malla;			
					
		end %function getMalla

		function batimetria = getBatimetria(cuerpo)
				
			batimetria = cuerpo.Geometria.Batimetria;			
					
		end %function getBatimetria

		function parametros = getParametros(cuerpo)
				
			parametros = cuerpo.Parametros;			
					
		end %function getParametros

		function fluido = getFluido(cuerpo)
				
			fluido = cuerpo.Fluido;			
					
		end %function getFluido

		function geometria = getGeometria(cuerpo)
				
			geometria = cuerpo.Geometria;			
					
		end %function getGeometria

    end % methods
end % classdef



