	function thisBorde = getBorde(varargin)	
		if nargin == 1
			switch class(varargin{:})
				case 'Simulacion'				
					thisBorde = varargin{:}.Cuerpo.Geometria.Borde;					
				case 'Cuerpo'
					thisBorde = varargin{:}.Geometria.Borde;
				case 'Geometria'
					thisBorde = varargin{:}.Borde;
				case 'Borde'
					thisBorde = varargin{:};
				otherwise 
					error(['El objeto ', class(varargin{:}), ' no contiene un Borde'])
			end %switch	
		end %if
	end %getBorde
