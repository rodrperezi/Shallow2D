	function thisBatimetria = getBatimetria(varargin)	
		if nargin == 1
			objeto = varargin{1};
			switch class(objeto)
				case 'Simulacion'				
					thisBatimetria = objeto.Cuerpo.Geometria.Batimetria;					
				case 'Cuerpo'
					thisBatimetria = objeto.Geometria.Batimetria;
				case 'Geometria'
					thisBatimetria = objeto.Batimetria;
				case 'Batimetria'
					thisBatimetria = objeto;
				otherwise 
					error(['El objeto ', class(objeto), ' no contiene una Batimetria'])
				end %switch	
		end %if
	end %getBatimetria
