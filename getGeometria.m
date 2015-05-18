	function thisGeometria = getGeometria(varargin)	
		if nargin == 1
			objeto = varargin{1};
			switch class(objeto)
				case 'Simulacion'				
					thisGeometria = objeto.Cuerpo.Geometria;					
				case 'Cuerpo'
					thisGeometria = objeto.Geometria;
				case 'Geometria'
					thisGeometria = objeto;
				otherwise 
					error(['El objeto ', class(objeto), ' no contiene una Geometria'])
			end %switch	
		end %if
	end %getGeometria
