	function thisCuerpo = getCuerpo(varargin)	
		if nargin == 1
			objeto = varargin{1};
			switch class(objeto)
				case 'Simulacion'				
					thisCuerpo = objeto.Cuerpo;					
				case 'Cuerpo'
					thisCuerpo = objeto;
				otherwise 
					error(['El objeto ', class(objeto), ' no contiene un Cuerpo'])
			end %switch	
		end %if
	end %getCuerpo
