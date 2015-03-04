	function thisCuerpo = getCuerpo(varargin)	
		if nargin == 1
			switch class(varargin{:})
				case 'Simulacion'				
					thisCuerpo = varargin{:}.Cuerpo;					
				case 'Cuerpo'
					thisCuerpo = varargin{:};
				otherwise 
					error(['El objeto ', class(varargin{:}), ' no contiene un Cuerpo'])
			end %switch	
		end %if
	end %getCuerpo
