	function thisBorde = getBorde(varargin)	

		if nargin == 1
			objeto = varargin{1};
			switch class(objeto)
				case 'Simulacion'				
					thisBorde = objeto.Cuerpo.Geometria.Borde;					
				case 'Cuerpo'
					thisBorde = objeto.Geometria.Borde;
				case 'Geometria'
					thisBorde = objeto.Borde;
				case 'Borde'
					thisBorde = objeto;
				otherwise 
					error(['El objeto ', class(objeto), ' no contiene un Borde'])
			end %switch	
		end %if
	end %getBorde
