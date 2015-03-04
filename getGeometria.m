	function thisGeometria = getGeometria(varargin)	
		if nargin == 1
			switch class(varargin{:})
				case 'Simulacion'				
					thisGeometria = varargin{:}.Cuerpo.Geometria;					
				case 'Cuerpo'
					thisGeometria = varargin{:}.Geometria;
				case 'Geometria'
					thisGeometria = varargin{:};
				otherwise 
					error(['El objeto ', class(varargin{:}), ' no contiene una Geometria'])
			end %switch	
		end %if
	end %getGeometria
