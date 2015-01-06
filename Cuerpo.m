classdef Cuerpo

    % CUERPO se entiende como un cuerpo de fluido.
    %   Los objetos creados con la clase cuerpo tiene como PROPIEDADES 
    %   las clases Geometria, Fluido, Forzante, Parametros y Matrices. 
    %   Los componentes anteriores contienen la información necesaria y
    %   detallada de las variables hidrodinámicas y numéricas.
    %   Batimetría, malla numérica son algunos ejemplos.
    %   Para mas información help PROPIEDAD
        
    properties
     
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
%     %%%%%%%%%%%%%%%%%%%%%% Propiedades de la hoya %%%%%%%%%%%%%%%%%%%%%%%%%
%     ID        % Identificador
	Geometria % Borde, la batimetría y otros valores.
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
					error('myapp:chk', ['Wrong input argument: Clase cuerpo no trabaja con ', class(varargin{iVariable})])
			end
		end
         end
    end
end



		
		% class(varargin)

%	switch class(varargin)
%		case 'Cuerpo' 
%			fprintf('cuerpo')	
%		case 'Forzante'
%			fprintf('forzante')
%	end		
		
%		if nargin == 1        	
%			thisCuerpo.Geometria = geometria;
%			thisCuerpo.Parametros = Parametros();
%			thisCuerpo.Fluido = Fluido('Agua', thisCuerpo.Parametros.densidadRho, thisCuerpo.Parametros.viscosidadNu);
%		elseif nargin == 2
%			thisCuerpo.Geometria = geometria;
%			thisCuerpo.Parametros = Parametros();
%			thisCuerpo.Fluido = fluido;
%		elseif nargin == 3
%			thisCuerpo.Geometria = geometria;
%			thisCuerpo.Parametros = Parametros();
%			thisCuerpo.Fluido = fluido;
%			thisCuerpo.Forzante = forzante;
%			thisCuerpo.Matrices = generaMatrices(thisCuerpo);
%		else
%			thisCuerpo.Parametros = Parametros();			
%			thisCuerpo.Fluido = Fluido('Agua', thisCuerpo.Parametros.densidadRho, thisCuerpo.Parametros.viscosidadNu);
%		% keyboard
%		end

%function varargin_test(varargin)
%    options = [0 0 0];
%    
%    if (~isempty(varargin))
%        for c=1:length(varargin)
%            switch varargin{c}
%                case {'option1'}
%                    options(1)=1;

%                case {'option2'}
%                    options(2)=1;
%    
%                case {'option3'}
%                    options(3)=1;
%                    
%            % (continued)
%            
%            otherwise         
%                error(['Invalid optional argument, ', ...
%                    varargin{c}]);
%            end % switch
%        end % for
%    end % if
%    
%disp(options);

