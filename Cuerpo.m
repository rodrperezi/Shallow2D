classdef Cuerpo < handle
	% Descripción General
	% 
	% CUERPO se entiende como un cuerpo de fluido
	% Los objetos creados con la clase cuerpo tienen
	% como propiedadres objetos de las clases GEOMETRIA, FLUIDO, 
	% FORZANTE, PARAMETROS y MATRICES.
	% Los componentes anteriores contienen la información necesaria
	% y detallada de las variables hidrodinámicas y numéricas.
	% Batimetría, malla numérica son algunos ejemplos.
	% Por defecto, un cuerpo se construye con los parámetros
	% especificados en la clase PARAMETROS y con agua como 
	% objeto de la clase FLUIDO. Estas propiedades pueden 
	% ser modificadas.
        
	properties
     
%%%%%%%%%%%%%%%%%%%%%% Propiedades de la hoya %%%%%%%%%%%%%%%%%%%%%%%%%
%     ID        % Identificador
	Geometria 
	Fluido
	Forzante
	Parametros
	Matrices
	valoresVectoresPropios
%     Malla     % Malla numérica
%     Variables_Hidrodinamicas % Definicion de forzantes y num. adim. 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    end
    
    methods

        function thisCuerpo = Cuerpo(varargin)

		thisCuerpo.Parametros = Parametros();			
		thisCuerpo.Fluido = Fluido('Agua', thisCuerpo.Parametros.densidadRho, thisCuerpo.Parametros.viscosidadNu);

		for iVariable = 1:nargin
			switch class(varargin{iVariable})
				case 'Geometria' 
					thisCuerpo.Geometria = varargin{iVariable};
				case 'Parametros'
					thisCuerpo.Parametros = varargin{iVariable};
				case 'Forzante'
					thisCuerpo.Forzante = varargin{iVariable};
				case 'Fluido'
					thisCuerpo.Fluido = varargin{iVariable};
				case 'Matrices'
					thisCuerpo.Matrices = varargin{iVariable};
				otherwise 
					error(['Wrong input argument: Clase cuerpo no trabaja con ', class(varargin{iVariable})])
			end %switch 
		end %for
         end % function Cuerpo
    end % methods
end % classdef



