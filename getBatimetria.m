	function thisBatimetria = getBatimetria(varargin)	
		if nargin == 1
			switch class(varargin{:})
				case 'Simulacion'				
					thisBatimetria = varargin{:}.Cuerpo.Geometria.Batimetria;					
				case 'Cuerpo'
					thisBatimetria = varargin{:}.Geometria.Batimetria;
				case 'Geometria'
					thisBatimetria = varargin{:}.Batimetria;
				case 'Batimetria'
					thisBatimetria = varargin{:};
				otherwise 
					error(['El objeto ', class(varargin{:}), ' no contiene una Batimetria'])
				end %switch	
		end %if
	end %getBatimetria
